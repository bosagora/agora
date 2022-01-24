/*******************************************************************************

    Contains code to support temporarily banning from communicating with
    specific addressses which may belong to badly-behaving nodes.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.BanManager;


import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.Types;
import agora.network.Clock;
import agora.utils.InetUtils;
import agora.utils.Log;

import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.algorithm;
import std.datetime.systime : SysTime;
import std.datetime.timezone : UTC;
import std.file;
import std.format;
import std.socket : getAddressInfo, AddressFamily;
import std.stdio;

import core.stdc.stdlib;
import core.stdc.time;
import core.time;

/// ditto
public class BanManager
{
    /// SQLite db instance
    private ManagedDatabase db;

    /// Ban configuration
    public struct Config
    {
        /// max failed requests until an address is banned
        public size_t max_failed_requests = 100;

        /// How long does a ban lasts, in seconds (default: 1 day)
        public Duration ban_duration = 1.days;
    }

    ///
    private struct Status
    {
        /// the total number of failed requests.
        /// if the number of failed requests reaches a certain number,
        /// then the IP is temporarily banned
        private uint fail_count;

        /// To set an IP as banned, we simply set its un-ban time in the future.
        /// By default it's set to zero which is in the past and therefore un-banned
        private TimePoint banned_until;
    }

    /// validators are whitelisted so we store them in a set to not be banned
    private Set!Address whitelisted;

    /// the total number of failed requests.
    /// if the number of failed requests reaches a certain number,
    /// then the url is temporarily banned
    private Status[Address] url_failures;

    /// Logger instance
    protected Logger log;

    /// configuration
    private const Config config;

    /// Clock instance
    private Clock clock;

    /// Avoid using the caller's module as our logger name
    private static immutable string ThisModule = __MODULE__;

    /***************************************************************************

        Ctor.

        Params:
            config = the configuration
            clock = clock instance
            data_dir = path to the data directory
            logger = Logger to use. Workaround for attributes' purpose.

    ***************************************************************************/

    public this (Config config, Clock clock,
        ManagedDatabase db, Logger logger = Logger(ThisModule)) @safe nothrow
    {
        this.config = config;
        this.log = logger;
        this.clock = clock;

        this.db = db;

        this.createTables();

        // load from cache db current state
        this.loadWhitelisted();
        this.loadBanned();
    }

    /// If the tables do not exist create them
    private void createTables () @trusted nothrow
    {
        try
        {
            // create banned if required
            this.db.execute("CREATE TABLE IF NOT EXISTS banned " ~
                "(url TEXT PRIMARY KEY, until INTEGER NOT NULL, " ~
                "CHECK (until >= 0))");

            // create whitelisted if required
            this.db.execute("CREATE TABLE IF NOT EXISTS whitelisted " ~
                "(url TEXT PRIMARY KEY)");
        }
        catch (Exception ex)
        {
            log.warn("BanManager: failed to create banned and whitelisted tables: {}", ex.msg);
        }
    }

    /// Load whitelist from cache db
    private void loadWhitelisted () @trusted nothrow
    {
        try
        {
            this.db.execute("SELECT url FROM whitelisted")
                .each!(row => this.whitelisted.put(Address(row.peek!string(0))));
        }
        catch (Exception ex)
        {
            log.warn("BanManager: failed to load whitelist from cache database: {}", ex.msg);
        }
    }

    /// Load banned from cache db
    private void loadBanned () @trusted nothrow
    {
        try
        {
            // First remove bans that have expired
            this.db.execute("DELETE FROM banned where until < ?", this.getCurTime());

            this.db.execute("SELECT url, until FROM banned")
                .each!((row)
                {
                    this.url_failures.require(Address(row.peek!string(0))).banned_until = row.peek!ulong(1);
                });
        }
        catch (Exception ex)
        {
            log.warn("BanManager: failed to load banned from cache database: {}", ex.msg);
        }
    }

    /***************************************************************************

        Updates the fail count for this address

        Params:
            address = the address to increase the fail count for
            fail_count_inc = the number with which the failed request count
                should be increased

    ***************************************************************************/

    public void onFailedRequest (Address address, uint fail_count_inc = 1) @safe nothrow
    {
        // fast return if already banned or whitelisted
        if (this.isWhitelisted(address) || this.isBanned(address))
            return;

        // Use a pointer to prevent multiple lookups in this function
        Status* url_failure;
        try
        {
            () @trusted {
                // set pointer to existing or new entry in AA
                url_failure = &this.url_failures.require(address);
            }();
        }
        catch (Exception e)
        {
            log.error("Exception setting fail_count for address {}", address);
            return;
        }

        url_failure.fail_count += fail_count_inc;
        if (url_failure.fail_count >= this.config.max_failed_requests)
        {
            try
            {
                immutable host_and_port = InetUtils.extractHostAndPort(address);
                if (host_and_port.type == HostType.Domain)
                    foreach (ref addr_info; getAddressInfo(host_and_port.host))
                    {
                       auto resolved_address = addr_info.address.toAddrString();
                       if (addr_info.address.addressFamily == AddressFamily.INET6)
                           resolved_address = "[" ~ InetUtils.expandIPv6(resolved_address) ~ "]";

                       this.ban(Address(address.schema ~ resolved_address));
                    }
            }
            catch (Exception e)
            {
                log.trace("Error happened while trying to resolve DNS name {}", address);
            }
            url_failure.fail_count = 0;
            this.ban(address);
        }
    }

    /***************************************************************************

        Manually ban an address using the configured ban time in the ban config.

        Params:
            address = the address to ban

    ***************************************************************************/

    public void ban (Address address) @safe nothrow
    {
        this.banFor(address, this.config.ban_duration);
    }

    /***************************************************************************

        Manually ban an address, for the specified number of seconds from
        the current time.

        Params:
            address = the address to ban
            duration = How long to ban the address for

    ***************************************************************************/

    public void banFor (Address address, Duration duration) @safe nothrow
    {
        const ban_until = this.getCurTime() + duration.total!"seconds";
        this.banUntil(address, ban_until);
    }

    private string unixDateTime(TimePoint unixtime) @safe nothrow
    {
        static import agora.utils.Utility;
        return agora.utils.Utility.assumeNothrow(
            format!"unixtime:%s (%s)"(unixtime, SysTime.fromUnixTime(unixtime, UTC()).toString));
    }

    /***************************************************************************

        Manually ban an address, until the specified time.

        Params:
            address = the address to ban
            banned_until = the time at which the IP will be considered un-banned

    ***************************************************************************/

    public void banUntil (Address address, TimePoint banned_until) @safe nothrow
    {
        if (address is Address.init || this.isWhitelisted(address))
            return; // no address or Whitelisted address

        try
        {
            log.info("BanManager: Address {} banned at {} until {}", address,
                unixDateTime(this.getCurTime()), unixDateTime(banned_until));
            this.url_failures.require(address).banned_until = banned_until;
            this.storeBanned(address, banned_until);
        }
        catch (Exception e)
        {
            log.warn("Exception setting banUntil for address {}", address);
        }
    }

    private void storeBanned (Address address, TimePoint banned_until) @trusted nothrow
    {
        try
        {
            this.db.execute("REPLACE INTO banned (url, until) VALUES (?, ?)",
                address, banned_until);
        }
        catch (Exception ex)
        {
            log.warn("BanManager: failed to insert banned into cache database: {}", ex.msg);
        }
    }

    /***************************************************************************

        Whitelist an address to avoid banning it

        Params:
            address = the address to whitelist

    ***************************************************************************/

    public void whitelist (Address address) @safe nothrow
    {
        if (address is Address.init)
            return;

        this.whitelisted.put(address);
        this.storeWhitelisted(address);
        log.dbg("{}/{}: Whitelisted address {}", __FILE__, __LINE__, address);
    }

    private void storeWhitelisted (Address address) @trusted nothrow
    {
        try
        {
            this.db.execute("REPLACE INTO whitelisted (url) VALUES (?)", address);
        }
        catch (Exception ex)
        {
            log.warn("BanManager: failed to insert whitelisted into cache database: {}", ex.msg);
        }
    }

    /***************************************************************************

        Unwhitelist an address to allow banning it

        Params:
            address = the address to unwhitelist

    ***************************************************************************/

    public void unwhitelist (Address address) @safe nothrow
    {
        // remove from Set
        this.whitelisted.remove(address);
        // remove from cache db
        this.deleteWhitelisted(address);
        log.dbg("[{}:{}] {} No longer whitelisted at {}", __FILE__, __LINE__, address, unixDateTime(this.getCurTime()));
    }

    private void deleteWhitelisted (Address address) @trusted nothrow
    {
        try
        {
            this.db.execute("DELETE FROM whitelisted WHERE url = ?", address);
        }
        catch (Exception ex)
        {
            log.warn("BanManager: failed to delete whitelisted into cache database: {}", ex.msg);
        }
    }

    /***************************************************************************

        Checks whether the address is considered banned

        Params:
            address = the address to check

        Returns:
            true if the fail count is greater than configured

    ***************************************************************************/

    public bool isBanned (Address address) @safe nothrow
    {
        auto status = address in this.url_failures;
        if (!status)
            return false;

        // if the ban was set and has expired then remove it
        if (status.banned_until > 0 && this.getCurTime() > status.banned_until)
        {
            log.dbg("[{}:{}] {} No longer banned at {}", __FILE__, __LINE__, address, unixDateTime(this.getCurTime()));
            // remove from AA
            this.url_failures.remove(address);
            // remove from cache db
            this.deleteBanned(address);
            return false;
        }
        // return if the ban is still active
        const stillBanned = status.banned_until > this.getCurTime();
        if (stillBanned)
            log.dbg("[{}:{}] {} Still banned at {} until {}", __FILE__, __LINE__, address, unixDateTime(this.getCurTime()), unixDateTime(status.banned_until));
        return stillBanned;
    }

    private void deleteBanned (Address address) @trusted nothrow
    {
        try
        {
            this.db.execute("DELETE FROM banned WHERE url = ?", address);
        }
        catch (Exception ex)
        {
            log.warn("BanManager: failed to delete from banned in cache database: {}", ex.msg);
        }
    }

    /***************************************************************************

        Checks whether the address is whitelisted

        Params:
            address = the address to check

        Returns:
            true if whitelisted

    ***************************************************************************/

    public bool isWhitelisted (Address address) @safe nothrow
    {
        return !!(address in this.whitelisted);
    }

    /***************************************************************************

        Get the current time. Overridable for unittests.

        Returns:
            the current time

    ***************************************************************************/

    protected TimePoint getCurTime () @safe nothrow @nogc
    {
        return this.clock.localTime();
    }

}

///
unittest
{
    class UnitBanMan : BanManager
    {
        TimePoint time;
        this (ManagedDatabase db) { super(Config(10, 1.days), null, db); }
        protected override TimePoint getCurTime () const { return this.time; }
    }

    const node1 = Address("agora://node-1");
    const node2 = Address("agora://node-2");
    const whitelistNode = Address("agora://whitelist-node");

    auto db = new ManagedDatabase(":memory:");
    auto banman = new UnitBanMan(db);
    banman.whitelist(whitelistNode);
    assert(db.execute("select url from whitelisted where url = ?", whitelistNode)
        .oneValue!string == whitelistNode.toString());
    foreach (idx; 0 .. 9)
    {
        banman.onFailedRequest(node1);
        banman.onFailedRequest(whitelistNode);
        assert(banman.url_failures[node1].fail_count == idx + 1);
        assert(!banman.isBanned(node1));
    }

    banman.onFailedRequest(node1);
    assert(banman.url_failures[node1].fail_count == 0);  // reset counter on ban
    assert(banman.isBanned(node1));
    assert(banman.url_failures[node1].banned_until == 86400);  // banned until "next day"
    assert(db.execute("select until from banned where url = ?", node1).oneValue!ulong == 86400);

    banman.onFailedRequest(whitelistNode);
    assert(!banman.isBanned(whitelistNode));

    // stop counting failed requests during the ban
    banman.onFailedRequest(node1);
    assert(banman.url_failures[node1].fail_count == 0);

    banman.time = 86401;  // "next day"
    assert(!banman.isBanned(node1));

    // banUntil
    banman.banUntil(node1, 86500);
    banman.time = 86499;
    assert(banman.isBanned(node1));
    banman.time = 86500;
    assert(!banman.isBanned(node1));

    // banFor
    banman.banFor(node1, 10.seconds);
    banman.time = 86509;
    assert(banman.isBanned(node1));
    banman.time++;
    assert(!banman.isBanned(node1));

    banman.time = 0;
    banman.ban(node2);  // use default ban time
    assert(banman.url_failures[node2].banned_until == 86400);

    // test loading from db
    auto banman2 = new UnitBanMan(db);
    assert(banman2.isBanned(node2));
    assert(banman2.isWhitelisted(whitelistNode));

    // unwhitelist
    banman.unwhitelist(whitelistNode);
    assert(!banman.isWhitelisted(whitelistNode));
}
