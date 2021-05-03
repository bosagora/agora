/*******************************************************************************

    Contains supporting code for storing the latest SCP envelopes,
    using SQLite as a backing store.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
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

import std.range;


/// Ditto
public class SCPEnvelopeStore
{
    /// Logger instance
    protected Logger log;

    /// SQLite db instance
    private ManagedDatabase db;

    /***************************************************************************

        Constructor

        Params:
            db = Cache database to store SCP envelopes

    ***************************************************************************/

    public this (ManagedDatabase db)
    {
        this.log = Logger(__MODULE__);
        assert(db !is null);
        this.db = db;

        this.db.execute("CREATE TABLE IF NOT EXISTS scp_envelopes " ~
            "(seq INTEGER PRIMARY KEY AUTOINCREMENT, envelope BLOB NOT NULL, processed INTEGER NOT NULL)");
    }

    /***************************************************************************

        Store the envelope to the database.

        First, clean with 'removeAll' before Adding it in new envelopes.

        Params:
            envelope = the envelope to add
            processed = If the envelope has been processed

        Returns:
            true if the envelope has been added to the database

    ***************************************************************************/

    public bool add (const ref SCPEnvelope envelope, bool processed) @safe nothrow
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
                db.execute("INSERT INTO scp_envelopes (envelope, processed) VALUES(?, ?)",
                           envelope_bytes, processed);
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

    public int opApply (scope int delegate(bool processed, const ref SCPEnvelope) dg)
    {
        () @trusted
        {
            auto results = this.db.execute(
                "SELECT envelope, processed FROM scp_envelopes");

            foreach (ref row; results)
            {
                auto env = deserializeFull!(const SCPEnvelope)(row.peek!(ubyte[])(0));
                auto processed = row.peek!bool(1);

                if (auto ret = dg(processed, env))
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
    auto envelope_store = new SCPEnvelopeStore(new ManagedDatabase(":memory:"));

    SCPEnvelope[] envelopes;

    foreach (_; 0 .. 2)
    {
        envelopes ~= SCPEnvelope.init;
    }

    foreach (env; envelopes)
    {
        envelope_store.add(env, false);
    }

    assert(envelope_store.length == 2);

    foreach (_, const ref SCPEnvelope env; envelope_store)
    {
        assert(env == SCPEnvelope.init);
    }

    envelope_store.removeAll();
    assert(envelope_store.length == 0);
}
