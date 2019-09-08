/*******************************************************************************

    Contains code to support temporarily banning from communicating with
    specific addressses which may belong to badly-behaving nodes.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.BanManager;

import agora.common.Data;
import agora.utils.Log;

import core.stdc.stdlib;
import core.stdc.time;

mixin AddLogger!();

/// ditto
public class BanManager
{
    /// Ban configuration
    public struct Config
    {
        /// max failed requests until an address is banned
        public size_t max_failed_requests;

        /// the default duration of a ban
        public time_t ban_duration;
    }

    ///
    private struct Status
    {
        /// the total number of failed requests.
        /// if the number of failed requests reaches a certain number,
        /// then the IP is temporarily banned
        private size_t fail_count;

        /// To set an IP as banned, we simply set its un-ban time in the future.
        /// By default it's set to the past (therefore un-banned)
        private time_t banned_until = 0;
    }

    /// configuration
    private const Config config;

    /// per-address status
    private Status[Address] ips;


    /***************************************************************************

        Ctor.

        Params:
            config = the configuration

    ***************************************************************************/

    public this (Config config) @safe nothrow pure @nogc
    {
        this.config = config;
    }

    /***************************************************************************

        Updates the fail count for this address

        Params:
            address = the address to increase the fail count for

    ***************************************************************************/

    public void onFailedRequest (Address address) @safe nothrow
    {
        if (this.isBanned(address))
            return;

        auto status = this.get(address);
        status.fail_count++;

        if (status.fail_count >= this.config.max_failed_requests)
        {
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
            ban_seconds = the amount of seconds to ban the address for

    ***************************************************************************/

    public void banFor (Address address, long ban_seconds) @safe nothrow
    {
        const ban_until = this.getCurTime() + ban_seconds;
        this.banUntil(address, ban_until);
    }

    /***************************************************************************

        Manually ban an address, until the specified time.

        Params:
            address = the address to ban
            banned_until = the time at which the IP will be considered un-banned

    ***************************************************************************/

    public void banUntil (Address address, time_t banned_until) @safe nothrow
    {
        scope (failure) assert(0);
        log.trace("BanManager: Address {} banned until {}", address, banned_until);
        this.get(address).banned_until = banned_until;
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
        if (auto stats = address in this.ips)
            return stats.banned_until > this.getCurTime();

        return false;
    }

    /***************************************************************************

        Get the un-ban unix timestamp of the provided address,
        or 0 if the address was never banned.

        Params:
            address = the address to check

        Returns:
            the un-ban time, or 0 if address was never banned.

    ***************************************************************************/

    public time_t getUnbanTime (Address address) @safe nothrow pure @nogc
    {
        if (auto stats = address in this.ips)
            return stats.banned_until;

        return 0;
    }

    /***************************************************************************

        Get the current time. Overridable for unittests.

        Returns:
            the current time

    ***************************************************************************/

    protected time_t getCurTime () @safe nothrow @nogc
    {
        return time(null);
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
        return &this.ips.require(address, Status.init);
    }
}

///
unittest
{
    class UnitBanMan : BanManager
    {
        time_t time;
        this () { super(Config(10, 86400)); }
        protected override time_t getCurTime () const { return this.time; }
    }

    auto banman = new UnitBanMan();
    foreach (idx; 0 .. 9)
    {
        banman.onFailedRequest("node-1");
        assert(banman.get("node-1").fail_count == idx + 1);
        assert(!banman.isBanned("node-1"));
    }

    assert(banman.getUnbanTime("node-1") == 0);  // not banned yet

    banman.onFailedRequest("node-1");
    assert(banman.get("node-1").fail_count == 0);  // reset counter on ban
    assert(banman.isBanned("node-1"));
    assert(banman.getUnbanTime("node-1") == 86400);  // banned until "next day"

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
    banman.banFor("node-1", 10);
    banman.time = 86509;
    assert(banman.isBanned("node-1"));
    banman.time++;
    assert(!banman.isBanned("node-1"));

    banman.time = 0;
    banman.ban("node-2");  // use default ban time
    assert(banman.getUnbanTime("node-2") == 86400);
}
