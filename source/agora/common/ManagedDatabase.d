/*******************************************************************************

    Contains a managed wrapper around SQLite databases.

    This class ensures that all D2SQLite databases handled by the thread
    are cleanly destroyed after the thread shuts down.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.ManagedDatabase;

import agora.utils.Log;

import d2sqlite3.database;
import d2sqlite3.sqlite3;
import d2sqlite3.library;

import std.conv : emplace;
import std.string;

import core.stdc.stdio : printf;
import core.stdc.stdlib : free, malloc;

mixin AddLogger!();

shared static this ()
{
    .config(SQLITE_CONFIG_MULTITHREAD);
    .config(SQLITE_CONFIG_LOG, &ManagedDatabase.loggerCallback, null);
}

/// Ditto
public class ManagedDatabase
{
    /// ManagedDatabase managed by the current thread
    private static Database*[] thread_dbs;

    /// Close all database handles
    static ~this ()
    {
        foreach (db; thread_dbs)
        {
            try
            {
                db.close();
            }
            catch (Exception ex)
            {
                printf("Error closing database handles: %.*s\n",
                       cast(int) ex.message.length, ex.message.ptr);
            }
            finally
            {
                db.__xdtor();  // we cannot use the destroy(db) call here, as the object is not GC allocated
                free(db);
                db=null;
            }
        }
    }

    /// Pointer to the database handle
    private Database* database; // this object is NOT GC allocated and will be destroyed by the static destructor

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
        this.database = emplace(cast(Database*) malloc(Database.sizeof), path, flags);
        this.database.run("PRAGMA foreign_keys = ON");
        this.database.run("PRAGMA busy_timeout = 100"); // 100 msec timeout
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

    /***************************************************************************

        Callback used

        Params:
            arg = unused (null)
            code = the error code
            msg = the error message

    ***************************************************************************/

    private static extern(C) void loggerCallback (void *arg, int code,
        const(char)* msg) nothrow
    {
        log.error("SQLite error: ({}) {}", code, msg.fromStringz);
    }
}
