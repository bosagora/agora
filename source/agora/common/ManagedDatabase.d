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

import core.stdc.stdlib : abort;

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
                try log.fatal("SQLite BEGIN statement failed: {}", exc.message);
                catch (Exception e) { /* Nothing more we can do at this point */ }
                abort();
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
                try log.fatal("SQLite COMMIT statement failed: {}", exc.message);
                catch (Exception e) { /* Nothing more we can do at this point */ }
                abort();
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
                try log.fatal("SQLite ROLLBACK statement failed: {}", exc.message);
                catch (Exception e) { /* Nothing more we can do at this point */ }
                abort();
            }
        }
    }
}
