/*******************************************************************************

    Contains a managed wrapper around SQLite databases.

    This class ensures that all D2SQLite databases handled by the thread
    are cleanly destroyed after the thread shuts down.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.ManagedDatabase;

import agora.utils.Log;

import d2sqlite3.database;
import d2sqlite3.sqlite3;

mixin AddLogger!();

/// Ditto
public class ManagedDatabase
{
    /// ManagedDatabase managed by the current thread
    private static Database*[] thread_dbs;

    /// Close all database handles
    static ~this ()
    {
        try
        {
            foreach (db; thread_dbs)
                db.close();
        }
        catch (Exception ex)
        {
            log.error("Error closing database handles: {}", ex.message);
            throw ex;
        }
    }

    /// Pointer to the database handle
    private Database* database;

    /// Subtype
    public alias getDatabase this;

    /***************************************************************************

        Constructs a managed database

        Params:
            path = path to the db on disk, or :memory: for an in-memory database
            flags = SQLite read / write flags

    ***************************************************************************/

    public this (string path,
        int flags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE)
    {
        this.database = new Database(path, flags);
        thread_dbs ~= this.database;
    }

    /***************************************************************************

        Returns:
            the database handle (used via alias this)

    ***************************************************************************/

    public Database* getDatabase () pure nothrow @safe @nogc
    {
        return this.database;
    }
}
