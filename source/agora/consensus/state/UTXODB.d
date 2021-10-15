/*******************************************************************************

    ManagedDatabase of UTXOs using SQLite as the backing store

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.state.UTXODB;

import agora.common.Amount;
import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Transaction;
public import agora.consensus.state.UTXOCache;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.script.Lock;
import agora.serialization.Serializer;

import std.file;

///
package class UTXODB
{
    import d2sqlite3.results : PeekMode;

    /// SQLite db instance
    private ManagedDatabase db;

    /***************************************************************************

        Constructor

        Params:
            db = Instance of the state database

    ***************************************************************************/

    public this (ManagedDatabase db)
    {
        this.db = db;
        // create the table if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS utxo " ~
            "(hash TEXT NOT NULL PRIMARY KEY, unlock_height INTEGER NOT NULL, " ~
            "type INTEGER NOT NULL, amount INTEGER NOT NULL, " ~
            "locktype INTEGER NOT NULL, lock BLOB NOT NULL)");
    }

    /***************************************************************************

        Returns:
            the number of elements in the UTXO set

    ***************************************************************************/

    public size_t length () @safe
    {
        return () @trusted {
            return this.db.execute("SELECT count(*) FROM utxo")
                .oneValue!size_t;
        }();
    }

    ///
    public int opApply (
        scope int delegate (const ref Hash, const ref UTXO) @safe dg) @safe
    {
        return () @trusted {
            auto results = this.db.execute("SELECT hash, unlock_height, type, amount, locktype, lock FROM utxo ORDER BY hash");

            foreach (ref row; results)
            {
                auto hash = Hash(row.peek!(const(char)[], PeekMode.slice)(0));
                auto unlock_height = Height(row.peek!ulong(1));
                auto type = row.peek!OutputType(2);
                // DMD BUG: Cannot construct the object directly, `inout` bug
                Output output;
                output.type = type;
                output.value = Amount(row.peek!ulong(3));
                output.lock  = Lock(row.peek!(LockType)(4), row.peek!(ubyte[])(5));
                UTXO value = {
                    unlock_height: unlock_height,
                    output: output,
                };
                if (auto ret = dg(hash, value))
                    return ret;
            }
            return 0;
        }();
    }


    /***************************************************************************

        Look up the UTXO in the map, and store it to 'output' if found

        Params:
            key = the key to find
            value = will contain the UTXO if found

        Returns:
            true if the value was found

    ***************************************************************************/

    public bool find (in Hash key, out UTXO value) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute(
                "SELECT unlock_height, type, amount, locktype, lock FROM utxo WHERE hash = ?", key);

            foreach (row; results)
            {
                auto unlock_height = Height(row.peek!ulong(0));
                // DMD BUG: Cannot construct the object directly, `inout` bug
                Output output;
                output.type = row.peek!OutputType(1);
                output.value = Amount(row.peek!ulong(2));
                output.lock  = Lock(row.peek!(LockType)(3), row.peek!(ubyte[])(4));
                value = UTXO(unlock_height, output);
                return true;
            }
            return false;
        }
        catch (Exception exc)
        {
            import std.stdio;
            try writeln("Exception thrown in UTXODB.find: ", exc);
            catch (Exception exc) { assert(0, "Last chance writeln thrown: Giving up"); }
            assert(0, exc.toString());
        }
    }

    /***************************************************************************

        Get UTXOs from the UTXO set

        Params:
            pubkey = the key by which the UTXO set search UTXOs

        Returns:
            the associative array for UTXOs

    ***************************************************************************/

    public UTXO[Hash] getUTXOs (in PublicKey pubkey) @trusted nothrow
    {
        scope(failure) assert(0);
        UTXO[Hash] utxos;

        auto results = this.db.execute(
            "SELECT hash, unlock_height, type, amount, lock FROM utxo WHERE locktype = ? AND lock = ? ORDER BY hash",
            LockType.Key, pubkey[]);

        foreach (row; results)
        {
            auto hash = Hash(row.peek!(const(char)[], PeekMode.slice)(0));
            auto unlock_height = Height(row.peek!ulong(1));
            // DMD BUG, see above
            Output output;
            output.type = row.peek!OutputType(2);
            output.value = Amount(row.peek!ulong(3));
            output.lock  = Lock(LockType.Key, row.peek!(ubyte[])(4));
            UTXO value = {
                unlock_height: unlock_height,
                output: output,
            };
            utxos[hash] = value;
        }

        return utxos;
    }

    /***************************************************************************

        Get UTXOs from the UTXO set by the output type

        Params:
            type = the output type by which to search UTXOs in UTXOSet

        Returns:
            the associative array for UTXOs

    ***************************************************************************/

    public UTXO[Hash] getUTXOs (in OutputType type) @trusted nothrow
    {
        scope(failure) assert(0);
        UTXO[Hash] utxos;

        auto results = this.db.execute(
            "SELECT hash, unlock_height, type, amount, lock FROM utxo WHERE " ~
            "type = ? ORDER BY hash", type);

        foreach (row; results)
        {
            auto hash = Hash(row.peek!(const(char)[], PeekMode.slice)(0));
            auto unlock_height = Height(row.peek!ulong(1));
            // DMD BUG, see above
            Output output;
            output.type = row.peek!OutputType(2);
            output.value = Amount(row.peek!ulong(3));
            output.lock  = Lock(LockType.Key, row.peek!(ubyte[])(4));
            UTXO value = {
                unlock_height: unlock_height,
                output: output,
            };
            utxos[hash] = value;
        }

        return utxos;
    }

    /***************************************************************************

        Add an UTXO to the map

        Params:
            value = the UTXO to add
            key = the key to use

    ***************************************************************************/

    public void opIndexAssign (const ref UTXO value, in Hash key) @trusted
    {
        db.execute("INSERT INTO utxo (hash, unlock_height, type, amount, locktype, lock) " ~
                   "VALUES (?, ?, ?, ?, ?, ?)",
                   key, value.unlock_height, value.output.type,
                   value.output.value, value.output.lock.type, value.output.lock.bytes);
    }

    /***************************************************************************

        Remove an Output from the map

        Params:
            key = the key to remove

    ***************************************************************************/

    public void remove (in Hash key) @trusted
    {
        db.execute("DELETE FROM utxo WHERE hash = ?", key);
    }

    /***************************************************************************

        Clear the UTXO database

    ***************************************************************************/

    public void clear () @trusted
    {
        db.execute("DELETE FROM utxo");
    }
}
