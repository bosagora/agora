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

import agora.serialization.Serializer;
import agora.common.ConfigAttributes;
import agora.common.Types;
import agora.network.Clock;
import agora.utils.InetUtils;
import agora.utils.Log;

import std.file;
import std.socket : getAddressInfo, AddressFamily;
import std.stdio;

import core.stdc.stdlib;
import core.stdc.time;
import core.time;

/// ditto
public class BanManager
{
    /// Ban configuration
    public struct Config
    {
        /// max failed requests until an address is banned
        public size_t max_failed_requests = 100;

        /// How long does a ban lasts, in seconds (default: 1 day)
        public @fromSeconds Duration ban_duration = 1.days;
    }

    ///
    private struct Status
    {
        /// the total number of failed requests.
        /// if the number of failed requests reaches a certain number,
        /// then the IP is temporarily banned
        private uint fail_count;

        /// To set an IP as banned, we simply set its un-ban time in the future.
        /// By default it's set to the past (therefore un-banned)
        private TimePoint banned_until;

        /// Can not be banned
        private bool whitelisted;
    }

    /// Container type to emulate an AA, with serialization routines
    private static struct BannedList
    {
        /// Internal implementation relies on AA
        private Status[Address] data;

        /// Serialization hook
        public void serialize (scope SerializeDg dg) const @safe
        {
            // This is serialized as an array of { key, val }
            // Note that since keys are string, the array size
            // is actually unknown before ending deserialization,
            // but since it's only local data, we don't risk DoS.
            serializePart(this.data.length, dg);
            foreach (const ref key, const ref val; this.data)
            {
                serializePart(key, dg);
                serializePart(val, dg);
            }
        }

        /// Deserialization hook
        public static QT fromBinary (QT) (
            scope DeserializeDg dg, in DeserializerOptions opts) @safe
        {
            BannedList ret;
            size_t length = deserializeLength(dg, opts.maxLength);
            foreach (idx; 0 .. length)
            {
                Address key = deserializeFull!Address(dg);
                Status value = deserializeFull!Status(dg);
                ret.data[key] = value;
            }
            return (() @trusted => cast(QT)ret)();
        }
    }

    /// Logger instance
    protected Logger log;

    /// configuration
    private const Config config;

    /// per-address status
    private BannedList ips;

    /// Path to the ban file on disk
    private const string banfile_path;

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

    public this (Config config, Clock clock, string banfile_path,
        Logger logger = Logger(ThisModule)) @safe nothrow pure
    {
        this.config = config;
        this.log = logger;
        this.clock = clock;
        this.banfile_path = banfile_path;
    }

    /***************************************************************************

        Load the ban data from disk

    ***************************************************************************/

    public void load ()
    {
        if (!this.banfile_path.exists())
            return;  // nothing to load

        auto ban_file = File(this.banfile_path, "rb");
        scope DeserializeDg dg = (size) @trusted
        {
            ubyte[] res;
            res.length = size;
            ban_file.rawRead(res);
            return res;
        };
        this.ips = deserializeFull!BannedList(dg);
    }

    /***************************************************************************

        Dump the ban data to disk

    ***************************************************************************/

    public void dump () @safe
    {
        auto ban_file = File(this.banfile_path, "wb");
        serializePart(this.ips, (in bytes) @trusted => ban_file.rawWrite(bytes));
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
        auto status = this.get(address);
        if (this.isBanned(address) || status.whitelisted)
            return;

        status.fail_count += fail_count_inc;

        if (status.fail_count >= this.config.max_failed_requests)
        {
            try
            {
                immutable host_and_port = InetUtils.extractHostAndPort(address);
                if (host_and_port.type == HostType.Domain)
                    foreach (ref addr_info; getAddressInfo(host_and_port.host))
                    {
                       auto resolved_address = addr_info.address.toAddrString();
                       if (addr_info.address.addressFamily == AddressFamily.INET6)
                           resolved_address = InetUtils.expandIPv6(resolved_address);

                       this.ban(resolved_address);
                    }
            }
            catch (Exception e)
            {
                log.trace("Error happened while trying to resolve DNS name {}", address);
            }
            status.fail_count = 0;
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

    /***************************************************************************

        Manually ban an address, until the specified time.

        Params:
            address = the address to ban
            banned_until = the time at which the IP will be considered un-banned

    ***************************************************************************/

    public void banUntil (Address address, TimePoint banned_until) @safe nothrow
    {
        if (this.get(address).whitelisted)
            return; // Whitelisted address

        log.info("BanManager: Address {} banned until {}", address, banned_until);
        this.get(address).banned_until = banned_until;
    }

    /***************************************************************************

        Whitelist an address to avoid banning it

        Params:
            address = the address to whitelist

    ***************************************************************************/

    public void whitelist (Address address)
    {
        this.get(address).whitelisted = true;
    }

    /***************************************************************************

        Unwhitelist an address to allow banning it

        Params:
            address = the address to unwhitelist

    ***************************************************************************/

    public void unwhitelist (Address address)
    {
        auto status = this.get(address);
        if (status.whitelisted)
            status.fail_count = 0;
        status.whitelisted = false;
    }

    /***************************************************************************

        Checks whether the address is considered banned

        Params:
            address = the address to check

        Returns:
            true if the fail count is greater than 10

    ***************************************************************************/

    public bool isBanned (Address address) @safe nothrow @nogc
    {
        if (auto stats = address in this.ips.data)
            return stats.banned_until > this.getCurTime();

        return false;
    }

    /***************************************************************************

        Get the un-ban unix time offset from Genesis timestamp of the provided address,
        or 0 if the address was never banned.

        Params:
            address = the address to check

        Returns:
            the un-ban time, or 0 if address was never banned.

    ***************************************************************************/

    public TimePoint getUnbanTime (Address address) @safe nothrow pure @nogc
    {
        if (auto stats = address in this.ips.data)
            return stats.banned_until;

        return 0;
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

    /***************************************************************************

        Return a pointer to the status of the provided address.
        If the address doesn't exist, it's created.

        Workaround for `ref` returns which store a copy to
        the call-site when using structs

        Params:
            address = the address to retrieve the status for

        Returns:
            pointer to the address status

    ***************************************************************************/

    private Status* get (Address address) @trusted nothrow pure
    {
        scope(failure) assert(0);  // it will never throw
        return &this.ips.data.require(address, Status.init);
    }
}

///
unittest
{
    class UnitBanMan : BanManager
    {
        TimePoint time;
        this () { super(Config(10, 1.days), null, null); }
        protected override TimePoint getCurTime () const { return this.time; }
        public override void dump () { }
        public override void load () { }
    }

    auto banman = new UnitBanMan();
    banman.whitelist("whitelist-node");
    foreach (idx; 0 .. 9)
    {
        banman.onFailedRequest("node-1");
        banman.onFailedRequest("whitelist-node");
        assert(banman.get("node-1").fail_count == idx + 1);
        assert(!banman.isBanned("node-1"));
    }

    assert(banman.getUnbanTime("node-1") == 0);  // not banned yet

    banman.onFailedRequest("node-1");
    assert(banman.get("node-1").fail_count == 0);  // reset counter on ban
    assert(banman.isBanned("node-1"));
    assert(banman.getUnbanTime("node-1") == 86400);  // banned until "next day"

    banman.onFailedRequest("whitelist-node");
    assert(!banman.isBanned("whitelist-node"));

    // stop counting failed requests during the ban
    banman.onFailedRequest("node-1");
    assert(banman.get("node-1").fail_count == 0);

    banman.time = 86401;  // "next day"
    assert(!banman.isBanned("node-1"));

    // banUntil
    banman.banUntil("node-1", 86500);
    banman.time = 86499;
    assert(banman.isBanned("node-1"));
    banman.time = 86500;
    assert(!banman.isBanned("node-1"));

    // banFor
    banman.banFor("node-1", 10.seconds);
    banman.time = 86509;
    assert(banman.isBanned("node-1"));
    banman.time++;
    assert(!banman.isBanned("node-1"));

    banman.time = 0;
    banman.ban("node-2");  // use default ban time
    assert(banman.getUnbanTime("node-2") == 86400);

    // Serialization tests
    testSymmetry(banman.ips);
}
