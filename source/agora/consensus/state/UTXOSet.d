/*******************************************************************************

    Contains a SQLite-backed UTXO set class.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.state.UTXOSet;

import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Transaction;
public import agora.consensus.state.UTXOCache;
import agora.consensus.state.UTXODB;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.serialization.Serializer;
import agora.utils.Log;

import std.file;

mixin AddLogger!();

///
public class UTXOSet : UTXOCache
{
    /// UTXO cache backed by a database
    private UTXODB utxo_db;

    /***************************************************************************

        Constructor

        Params:
            utxo_db_path = path to the UTXO database

    ***************************************************************************/

    public this (in string utxo_db_path)
    {
        this.utxo_db = new UTXODB(utxo_db_path);
    }

    /***************************************************************************

        Returns:
            the number of elements in the UTXO set

    ***************************************************************************/

    public size_t length () @safe
    {
        return this.utxo_db.length();
    }

    /***************************************************************************

        Get UTXOs from the UTXO set

        Params:
            pubkey = the key by which to search UTXOs in UTXOSet

        Returns:
            the associative array for UTXOs

    ***************************************************************************/

    public UTXO[Hash] getUTXOs (const ref PublicKey pubkey) nothrow @safe
    {
        return this.utxo_db.getUTXOs(pubkey);
    }

    ///
    public override bool peekUTXO (in Hash utxo, out UTXO value) nothrow @safe
    {
        return this.utxo_db.find(utxo, value);
    }

    ///
    protected override void remove (in Hash utxo) @safe
    {
        this.utxo_db.remove(utxo);
    }

    ///
    protected override void add (in Hash utxo, UTXO value) @safe
    {
        this.utxo_db[utxo] = value;
    }
}

/// test for get UTXOs with a node's public key
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Transaction;
    import agora.consensus.data.UTXO;

    import TESTNET = agora.consensus.data.genesis.Test;

    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random];

    auto utxo_set = new UTXOSet(":memory:");

    // create the first transaction
    Transaction tx1 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[0].address)]
    );
    utxo_set.updateUTXOCache(tx1, Height(0), TESTNET.CommonsBudgetAddress);
    Hash hash1 = hashFull(tx1);
    auto utxo_hash = UTXO.getHash(hash1, 0);

    // test for getting UTXOs
    auto utxos = utxo_set.getUTXOs(key_pairs[0].address);
    assert(utxos[utxo_hash].output.address == key_pairs[0].address);

    // create the second transaction
    Transaction tx2 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount(100_000 * 10_000_000L), key_pairs[0].address)]
    );
    utxo_set.updateUTXOCache(tx2, Height(0), TESTNET.CommonsBudgetAddress);

    // create the third transaction
    Transaction tx3 = Transaction(
        TxType.Freeze,
        [Input(Hash.init, 0)],
        [Output(Amount.MinFreezeAmount, key_pairs[1].address)]
    );
    utxo_set.updateUTXOCache(tx3, Height(0), TESTNET.CommonsBudgetAddress);

    // test for getting UTXOs for the first KeyPair
    utxos = utxo_set.getUTXOs(key_pairs[0].address);
    assert(utxos.length == 2);

    // test for getting UTXOs for the second KeyPair
    utxos = utxo_set.getUTXOs(key_pairs[1].address);
    assert(utxos.length == 1);
}
