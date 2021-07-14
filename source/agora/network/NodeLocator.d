/*******************************************************************************

    Contains code to locate the geographical location of the nodes in the network.

    The current implementation retrieves the node's continent, country, city,
    latitue, longitude information using the GeoIP2 MMDB database.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.NodeLocator;

import agora.common.Types : Address;
import agora.utils.Log;
import mmdb.MaxMindDB;

import core.stdc.errno;
import core.stdc.stdio;
import core.stdc.string;

/// Interface for the node locator
public interface INodeLocator
{
    /// Start the node locator, returns true on succes, false otherwise
    public bool start ();

    /// Stop the node locator
    public void stop ();

    /***************************************************************************

        Extracts certain properties of the geographical location of the node.
        The properties can be continent, country, ...
        The exact properties that can be extracted and the query path that
        identifies the properties are implementation dependent.

        Params:
            address = the network address of the node
            paths = query parts to identify which properties needs to be extracted

        Returns:
            an array of extracted properties, if a particular property
            cannot be extracted, then `MissingValue` is returned

    ***************************************************************************/

    public string[] extractValues (Address address, string[] paths);

    /// Value returned when a property cannot be retrieved by `extractValues`
    public static immutable MissingValue = "Unknown";
}

/// Node locator implementation using MaxMindDB to retrieve the geographical
/// location of the nodes
public class NodeLocatorGeoIP : INodeLocator
{
    /// path to the MaxMindDB database
    private string locator_db_path;

    /// MMDB_s struct returned by `open` call
    private MMDB_s mmdb;

    /// Logger
    private Logger log;

    /// Path separator between the elements of the property query path, for
    /// example: `continent->names->en`
    public static immutable PathSeparator = "->";

    ///
    public this (string locator_db_path)
    {
        this.log = Logger(__MODULE__);
        this.locator_db_path = locator_db_path;
    }

    /// Start the node locator, returns true on succes, false otherwise
    public bool start ()
    {
        import std.string : toStringz;

        int status = MMDB_open(this.locator_db_path.toStringz(), MMDB_MODE_MMAP, &this.mmdb);
        if (MMDB_SUCCESS != status)
        {
            log.error("Can't open {} - {}", this.locator_db_path, MMDB_strerror(status));

            if (MMDB_IO_ERROR == status)
                log.error("IO error: {}", strerror(errno));

            return false;
        }
        return true;
    }

    /// Stop the node locator
    public void stop ()
    {
        MMDB_close(&this.mmdb);
        this.mmdb = MMDB_s.init;
    }

    ///
    public ~this ()
    {
        if (this.mmdb != MMDB_s.init)
        {
            fprintf(stderr, "NodeLocator.shutdown() was not called manually");
            this.stop();
        }
    }

    /***************************************************************************

        Extracts certain properties of the geographical location of the node.
        The properties can be continent, country, ...
        The exact properties that can be extracted and the query path that
        identifies the properties are implementation dependent.

        An example query path can be:
            continent->names->en
            location->latitude

        Params:
            address = the network address of the node
            paths = query parts to identify which properties needs to be extracted

        Returns:
            an array of extracted properties, if a particular property
            cannot be extracted, then `MissingValue` is returned

    ***************************************************************************/

    public string[] extractValues (Address address, string[] paths)
    {
        import std.algorithm : map;
        import std.array : array, split;
        import std.range : repeat;
        import std.string : toStringz;

        string[] extractedValues;
        extractedValues.length = paths.length;

        // Look up the value in the database
        int gai_error;
        int mmdb_error;
        MMDB_lookup_result_s result = MMDB_lookup_string(&this.mmdb, address.ptr, &gai_error, &mmdb_error);
        if (0 != gai_error)
        {
            log.warn("Error from getaddrinfo for {}", address);
            return MissingValue.repeat(paths.length).array();
        }
        if (MMDB_SUCCESS != mmdb_error)
        {
            log.warn("Got an error from libmaxminddb: {}", MMDB_strerror(mmdb_error));
            return MissingValue.repeat(paths.length).array();
        }

        // Extract the data
        foreach (ind, path; paths)
        {
            auto path_splitted = path.split(PathSeparator).map!(path_part => path_part.toStringz()).array();
            path_splitted ~= null;
            MMDB_entry_data_s entry_data;
            int status = MMDB_aget_value(&result.entry, &entry_data, path_splitted.ptr);
            extractedValues[ind] = (MMDB_SUCCESS == status && entry_data.has_data)
                ? getStringFromEntry(entry_data)
                : MissingValue;
        }
        return extractedValues;
    }

    /***************************************************************************

        Convert data stored in MMDB_entry_data_s structure into a string

        Params:
            entry_data = data to convert

        Returns:
            data converted to string

    ***************************************************************************/

    private string getStringFromEntry (in MMDB_entry_data_s entry_data) const
    {
        import std.conv : to;
        import std.utf : toUTF8;

        switch (entry_data.type)
        {
            case MMDB_DATA_TYPE_UTF8_STRING :
                return entry_data.utf8_string[0 .. entry_data.data_size].toUTF8();
            case MMDB_DATA_TYPE_FLOAT :
                return entry_data.float_value.to!string();
            case MMDB_DATA_TYPE_DOUBLE :
                return entry_data.double_value.to!string();
            case MMDB_DATA_TYPE_UINT16 :
                return entry_data.uint16.to!string();
            case MMDB_DATA_TYPE_UINT32 :
                return entry_data.uint32.to!string();
            case MMDB_DATA_TYPE_INT32 :
                return entry_data.int32.to!string();
            case MMDB_DATA_TYPE_UINT64 :
                return entry_data.uint64.to!string();
            case MMDB_DATA_TYPE_BOOLEAN :
                return entry_data.boolean.to!string();
            default :
                assert(0, "Datatype not implemented");
        }
    }
}

/// Node locator mock which is supposed to be used in network tests
public class NodeLocatorMock : INodeLocator
{
    /// Start the node locator, returns true on succes, false otherwise
    public override bool start () const @safe @nogc pure nothrow {return true;}

    /// Stop the node locator
    public override void stop () const @safe @nogc pure nothrow {}

    /***************************************************************************

        Extracts certain properties of the geographical location of the node.
        The properties can be continent, country, ...
        The exact properties that can be extracted and the query path that
        identifies the properties are implementation dependent.

        Params:
            address = the network address of the node
            paths = query parts to identify which properties needs to be extracted

        Returns:
            an array of extracted properties, if a particular property
            cannot be extracted, then `MissingValue` is returned

    ***************************************************************************/

    public override string[] extractValues (Address address, string[] paths) const @safe pure nothrow
    {
        // Returns the same information regardless of the address
        string[string] path_map =
            [
                "continent->names->en" : "Asia",
                "country->names->en"   : "South Korea",
                "city->names->en"     : "Seoul (Namdaemunno 5(o)-ga)",
                "location->latitude"   : "1.111",
                "location->longitude"  : "2.222",
            ];

        string[] extractedValues;
        extractedValues.length = paths.length;

        foreach (ind, path; paths)
            if (auto it = path in path_map)
                extractedValues[ind] = *it;
            else
                extractedValues[ind] = MissingValue;

        return extractedValues;
    }
}
