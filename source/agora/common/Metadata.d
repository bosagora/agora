/*******************************************************************************

    Defines metadata which is stored to disk (e.g. peer info)

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Metadata;

import agora.common.Data;
import agora.common.Set;

import vibe.core.log;
import vibe.data.json;

import std.array;
import std.file;
import std.format;
import std.meta;
import std.stdio;
import std.typecons;

/*******************************************************************************

    Contains the serialized set of peers a node has connected to.

*******************************************************************************/

public abstract class Metadata
{
    /// The set of peers we previously established connection to
    public Set!Address peers;

    /// Deserialize the Metadata from a Json string
    public static void fromJsonString (Metadata metadata, string json)
    {
        metadata.peers = deserializeJson!(Set!Address)(json);
    }

    /// Dump the Metadata to a Json string
    public string toJsonString ()
    {
        auto app = appender!string();
        serializeToJson(app, this.peers);
        return app.data[];
    }

    /// Load the metadata
    public void load() { }

    /// Dump the metadata
    public void dump() { }
}

/// Metadata stored in memory (for unittests)
public class MemMetadata : Metadata
{
    ///
    public this ()
    {
    }

    ///
    public override void load ()
    {
    }

    ///
    public override void dump ()
    {
    }
}

/// Metadata stored on disk (for persistence)
public class DiskMetadata : Metadata
{
    /// Path to the metadata on disk
    private string file_path;


    /***************************************************************************

        Constructor

        Params:
            data_dir = path to the data directory

    ***************************************************************************/

    public this (string data_dir)
    in
    {
        assert(data_dir.length > 0);
    }
    body
    {
        this.file_path = format("%s/%s", data_dir, "metadata.dat");
    }

    /// Load metadata from disk
    public override void load ()
    {
        try
        {
            string raw_data = cast(string)std.file.read(file_path);
            Metadata.fromJsonString(this, raw_data);
        }
        catch (Exception ex)
        {
            // ignored for now, missing metadata is not critical
            logError(ex.message);
        }
    }

    /// Dump metadata to disk
    public override void dump ()
    {
        std.file.write(this.file_path, this.toJsonString());
    }
}

///
unittest
{
    auto meta = new MemMetadata();
    const peer = "http://127.0.0.1:4567";
    meta.peers.put(peer);
    assert(peer in meta.peers);

    auto str = meta.toJsonString();
    meta.peers.clear();

    Metadata.fromJsonString(meta, str);
    assert(peer in meta.peers);
}
