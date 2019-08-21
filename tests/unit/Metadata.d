/*******************************************************************************

    IO-performing tests for `agora.common.Metadata`

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module unit.Metadata;

import agora.common.Metadata;

import std.algorithm;
import std.file;
import std.path;

///
private void main ()
{
    string path = buildPath(getcwd, ".cache");
    if (path.exists)
        rmdirRecurse(path);

    mkdir(path);

    auto disk_meta = new DiskMetadata(path);
    disk_meta.load();  // should not throw

    const IPs = ["127.0.0.1", "192.0.0.0", "192.168.0.0"];
    IPs.each!(IP => disk_meta.peers.put(IP));
    assert(disk_meta.peers.length == 3);  // sanity check
    disk_meta.dump();

    auto new_meta = new DiskMetadata(path);
    assert(new_meta.peers.length == 0);  // sanity check
    new_meta.load();
    assert(new_meta.peers.length == 3);
    IPs.each!(IP => assert(IP in new_meta.peers));
}
