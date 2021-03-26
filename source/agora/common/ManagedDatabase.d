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

import d2sqlite3.database;
import d2sqlite3.sqlite3;

import std.conv : emplace;

import core.stdc.stdio : printf;
import core.stdc.stdlib : free, malloc;

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

        Begins a batch operation on all the open databases.

        A beginBatch() call must be followed by either a commitBatch() or
        a rollback() call (in case of exceptions).

        The rollback() call will cancel any transactions started after the
        beginBatch() call.

        In case of crashes it is not necessary to call rollback() because
        none of the transactions were commited, and since the application
        crashed it will have to start and initialize new database handles
        which will not have any of the previously pending transactions in
        its transaction queue.

    ***************************************************************************/

    public static void beginBatch () @trusted nothrow
    {
        foreach (db; thread_dbs)
        {
            try
            {
                db.begin();
            }
            catch (Exception exc)
            {
                // in most cases this would only trigger if there was a
                // code-flow error
                assert(0, "SQLite BEGIN statement failed: " ~ exc.message);
            }
        }
    }

    /// Ditto
    public static void commitBatch () @trusted nothrow
    {
        foreach (db; thread_dbs)
        {
            try
            {
                db.commit();
            }
            catch (Exception exc)
            {
                // in most cases this would only trigger if there was a
                // code-flow error
                assert(0, "SQLite COMMIT statement failed: " ~ exc.message);
            }
        }
    }

    /// Ditto
    public static void rollback () @trusted nothrow
    {
        foreach (db; thread_dbs)
        {
            try
            {
                db.rollback();
            }
            catch (Exception exc)
            {
                // in most cases this would only trigger if there was a
                // code-flow error
                assert(0, "SQLite ROLLBACK statement failed: " ~ exc.message);
            }
        }
    }
}
