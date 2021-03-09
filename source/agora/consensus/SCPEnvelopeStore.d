/*******************************************************************************

    Contains supporting code for storing the latest SCP envelopes,
    using SQLite as a backing store.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.SCPEnvelopeStore;

import agora.common.ManagedDatabase;
import agora.serialization.Serializer;
import agora.common.Types;
import agora.utils.Log;

import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import scpd.types.Stellar_SCP;

import std.file : exists;
import std.range;

mixin AddLogger!();


/// Ditto
public class SCPEnvelopeStore
{
    /// SQLite db instance
    private ManagedDatabase db;

    /***************************************************************************

        Constructor

        Params:
            db_path = path to the database file, or in-memory storage if
                      :memory: was passed

    ***************************************************************************/

    public this (in string db_path)
    {
        const db_exists = db_path.exists;
        if (db_exists)
            log.info("Loading database from: {}", db_path);

        this.db = new ManagedDatabase(db_path);

        this.db.execute("CREATE TABLE IF NOT EXISTS scp_envelopes " ~
            "(seq INTEGER PRIMARY KEY AUTOINCREMENT, envelope BLOB NOT NULL)");
    }

    /***************************************************************************

        Store the envelope to the database.

        First, clean with 'removeAll' before Adding it in new envelopes.

        Params:
            envelope = the envelop to add

        Returns:
            true if the envelope has been added to the database

    ***************************************************************************/

    public bool add (const ref SCPEnvelope envelope) @safe nothrow
    {
        static ubyte[] envelope_bytes;

        try
        {
            envelope_bytes = serializeFull(envelope);
        }
        catch (Exception ex)
        {
            log.error("Serialization error: {}, Data was: {}", ex.msg,
                envelope_bytes);
            return false;
        }

        try
        {
            () @trusted {
                db.execute("INSERT INTO scp_envelopes (envelope) VALUES(?)",
                    envelope_bytes);
            }();
        }
        catch (Exception ex)
        {
            log.error("Unexpected error while adding envelope: {}", ex.msg);
            return false;
        }
        return true;
    }

    /***************************************************************************

        Remove all envelopes from the database

    ***************************************************************************/

    public void removeAll () @trusted nothrow
    {
        try
        {
            this.db.execute("DELETE FROM scp_envelopes");
        }
        catch (Exception ex)
        {
            log.error("Error while calling SCPEnvelopeStore.removeAll(): {}", ex);
        }
    }

    /***************************************************************************

        Walk over the envelopes in the database
        and call the provided delegate

        Params:
            dg = the delegate to call

        Returns:
            the status code of the delegate, or zero

    ***************************************************************************/

    public int opApply (scope int delegate(const ref SCPEnvelope) dg)
    {
        () @trusted
        {
            auto results = this.db.execute(
                "SELECT envelope FROM scp_envelopes");

            foreach (ref row; results)
            {
                auto env = deserializeFull!(const SCPEnvelope)(row.peek!(ubyte[])(0));

                if (auto ret = dg(env))
                    return ret;
            }
            return 0;
        }();

        return 0;
    }

    /***************************************************************************

        Returns:
            the number of envelope in the database

    ***************************************************************************/

    public size_t length () @safe
    {
        return () @trusted {
            return db.execute("SELECT count(*) FROM scp_envelopes")
                .oneValue!size_t;
        }();
    }
}

/// add & opApply & remove tests
unittest
{
    auto envelope_store = new SCPEnvelopeStore(":memory:");

    SCPEnvelope[] envelopes;

    foreach (_; 0 .. 2)
    {
        envelopes ~= SCPEnvelope.init;
    }

    foreach (env; envelopes)
    {
        envelope_store.add(env);
    }

    assert(envelope_store.length == 2);

    foreach (const ref SCPEnvelope env; envelope_store)
    {
        assert(env == SCPEnvelope.init);
    }

    envelope_store.removeAll();
    assert(envelope_store.length == 0);
}
