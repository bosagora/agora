/*******************************************************************************

    IO-performing tests for `agora.common.BanManager`

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module unit.BanManager;

import agora.common.BanManager;

import ocean.time.WallClock;

import std.algorithm;
import std.file;
import std.path;
import std.range;

///
private void main ()
{
    string path = buildPath(getcwd, ".cache");
    if (path.exists)
        rmdirRecurse(path);
    mkdir(path);

    BanManager.Config conf = { max_failed_requests : 10, ban_duration : 60 };
    auto banman = new BanManager(conf, path);
    banman.load();  // should not throw

    const IP = "127.0.0.1";
    10.iota.each!(_ => banman.onFailedRequest(IP));
    assert(banman.isBanned(IP));
    banman.dump();

    auto new_banman = new BanManager(conf, path);
    new_banman.load();
    assert(new_banman.isBanned(IP));
}
