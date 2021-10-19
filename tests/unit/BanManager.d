/*******************************************************************************

    IO-performing tests for `agora.common.BanManager`

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module unit.BanManager;

import agora.common.BanManager;
import agora.common.Types : Address;
import agora.network.Clock;
import agora.utils.Test;

import ocean.time.WallClock;

import std.algorithm;
import std.file;
import std.path;
import std.range;

import core.time;

///
private void main ()
{
    import std.path : buildPath;

    auto path = makeCleanTempDir();

    BanManager.Config conf = { max_failed_requests : 10, ban_duration : 60.seconds };
    auto banman = new BanManager(conf, new Clock(null, null), buildPath(path, "banned.dat"));
    banman.load();  // should not throw

    const IP = Address("http://127.0.0.1");
    10.iota.each!(_ => banman.onFailedRequest(IP));
    banman.isBanned(IP);
    assert(banman.isBanned(IP));
    banman.dump();

    auto new_banman = new BanManager(conf, new Clock(null, null), buildPath(path, "banned.dat"));
    new_banman.load();
    assert(new_banman.isBanned(IP));
}
