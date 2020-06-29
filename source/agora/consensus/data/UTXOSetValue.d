/*******************************************************************************

    Defines the UTXO transaction set struct,
    contains the UTXOFinder delegate

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.UTXOSetValue;

import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Transaction;

/// Delegate to find an unspent UTXO
public alias UTXOFinder = scope bool delegate (Hash hash, size_t index,
    out UTXOSetValue) @safe nothrow;

/// The structure of spendable transaction output
public struct UTXOSetValue
{
    /// Height of the block to be unlock
    ulong unlock_height;

    /// Transaction type
    TxType type;

    /// Unspend transaction output
    Output output;

    /***************************************************************************

        Get the combined hash of the previous hash and index.
        This makes sure the index is always of the same type,
        as mixing different-sized uint/ulong would create different hashes.

        Returns:
            the combined hash of a previous hash and index

    ***************************************************************************/

    public static Hash getHash (Hash hash, ulong index) @safe nothrow
    {
        return hashMulti(hash, index);
    }
}

/*******************************************************************************

    This is a simple UTXOSet, used when the AA behavior is desired

    Most unittestsdo not need a full-fledged UTXOSet with all the DB and
    serialization that comes with it, instead relying on an associative array
    and a delegate.

    Since this pattern is so common, this class is offered as a mean to achieve
    this without code duplication. See issue #501 for history.

    Note that this should *NOT* be used to replace the above UTXOSet,
    when for example doing integration tests with LocalRest.

*******************************************************************************/

public class TestUTXOSet
{
    ///
    public UTXOSetValue[Hash] storage;

    /// Keeps track of spent outputs
    private Set!Hash used_utxos;

    ///
    alias storage this;

    /// Similar to `UTXOSet.getUTXOFinder`
    public UTXOFinder getUTXOFinder () @trusted nothrow
    {
        this.used_utxos.clear();
        return &this.findUTXO_;
    }

    /// FIXME: Remove and make UTXO-sensible tests use either `peekUTXO`
    /// or `getUTXOFinder`
    public alias findUTXO = peekUTXO;

    /// Get an UTXO, no double-spend protection
    public bool peekUTXO (Hash hash, size_t index, out UTXOSetValue value)
        nothrow @safe
    {
        // Note: Keep this in sync with `findUTXO`
        Hash utxo_hash = (index == size_t.max) ?
            hash : UTXOSetValue.getHash(hash, index);
        if (auto ptr = utxo_hash in this.storage)
        {
            value = *ptr;
            return true;
        }
        return false;
    }

    /// Short hand to add a transaction
    public void put (const Transaction tx) nothrow @safe
    {
        Hash txhash = hashFull(tx);
        foreach (size_t idx, ref output_; tx.outputs)
        {
            Hash h = UTXOSetValue.getHash(txhash, idx);
            UTXOSetValue v = {
                type: tx.type,
                output: output_
            };
            this.storage[h] = v;
        }
    }

    /// Workaround 20559...
    public void clear ()
    {
        this.storage.clear();
    }

    /// Get an UTXO, does not return double spend
    private bool findUTXO_ (Hash hash, size_t index, out UTXOSetValue value)
        nothrow @safe
    {
        // Note: Keep this in sync with the real `findUTXO`
        Hash utxo_hash = (index == size_t.max) ?
            hash : UTXOSetValue.getHash(hash, index);
        // double-spend
        if (utxo_hash in this.used_utxos)
            return false;
        if (auto ptr = utxo_hash in this.storage)
        {
            value = *ptr;
            this.used_utxos.put(utxo_hash);
            return true;
        }
        return false;
    }
}

unittest
{
    testSymmetry!UTXOSetValue();
}
