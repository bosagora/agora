/*******************************************************************************

    Contains the base class for a UTXO set and an AA-backed UTXO set.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.state.UTXOCache;

import agora.common.Amount;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Transaction;
public import agora.consensus.data.UTXO;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.serialization.Serializer;

import std.file;

/// Delegate to find an unspent UTXO
public alias UTXOFinder = bool delegate (in Hash utxo, out UTXO) nothrow @safe;

/*******************************************************************************

    UTXOCache is the the base class of a UTXO storage.
    It is inherited by UTXOSet and TestUTXOSet.

*******************************************************************************/

abstract class UTXOCache
{
    /// Keeps track of spent outputs during the validation of a Tx / Block
    private Set!Hash used_utxos;

    /***************************************************************************

        Add all of a transaction's outputs to the Utxo set,
        and remove the spent outputs in the transaction from the set.

        Params:
            tx = the transaction
            height = local height of the block
            commons_budget = the CommonsBudget address

    ***************************************************************************/

    public void updateUTXOCache (const ref Transaction tx, Height height,
        immutable PublicKey commons_budget) @safe
    {
        import std.algorithm : any;

        bool melting = false;

        // check if payment and any inputs are from frozen output
        if (tx.isPayment && tx.inputs.any!(input => this.getUTXO(input.utxo).output.type == OutputType.Freeze))
        {
            melting = true;
        }

        foreach (const ref input; tx.inputs)
        {
            this.remove(input.utxo);
        }

        Hash tx_hash = tx.hashFull();
        foreach (idx, output; tx.outputs)
        {
            auto utxo_hash = UTXO.getHash(tx_hash, idx);

            // In general, melting UTXOs will be available after 2016 blocks
            // UTXOs which are towards the Commons Budget are excluded from this
            // rule, and will be available from the next block.
            if (melting && output.address != commons_budget)
                this.add(utxo_hash, UTXO(height + 2016, output));
            // Finally, the following is the most common case
            else
                this.add(utxo_hash, UTXO(height + 1, output));
        }
    }

    /***************************************************************************

        Returns:
            the number of elements in the UTXO set

    ***************************************************************************/

    public abstract size_t length () @safe;


    /// Allows iteration on UTXOs
    public abstract int opApply (
        scope int delegate (const ref Hash, const ref UTXO) @safe dg) @safe;

    /***************************************************************************

        Get UTXOs from the UTXO set

        Params:
            pubkey = the key by which to search UTXOs in UTXOSet

        Returns:
            the associative array for UTXOs

    ***************************************************************************/

    public abstract UTXO[Hash] getUTXOs (in PublicKey pubkey) nothrow @safe;

    /***************************************************************************

        Get an UTXO from the UTXO set.

        Params:
            utxo = the hash of the UTXO to get

        Return:
            Return UTXO

    ***************************************************************************/

    protected UTXO getUTXO (in Hash utxo) nothrow @safe
    {
        UTXO value;
        if (!this.peekUTXO(utxo, value))
            assert(0);
        return value;
    }

    /***************************************************************************

        Prepare tracking double-spent transactions and
        return the UTXOFinder delegate

        Returns:
            the UTXOFinder delegate

    ***************************************************************************/

    public UTXOFinder getUTXOFinder () nothrow @trusted
    {
        this.used_utxos.clear();
        return &this.findUTXO;
    }

    /***************************************************************************

        Get an UTXO, does not return double spend.

        Params:
            hash = the hash of the UTXO (`hashMulti(tx_hash, index)`)
            output = will contain the UTXO if found

        Return:
            Return true if the UTXO was found

    ***************************************************************************/

    public bool findUTXO (in Hash utxo, out UTXO value) nothrow @safe
    {
        if (utxo in this.used_utxos)
            return false;  // double-spend

        if (this.peekUTXO(utxo, value))
        {
            this.used_utxos.put(utxo);
            return true;
        }
        return false;
    }

    /***************************************************************************

        Get an UTXO, no double-spend protection.

        Params:
            hash = the hash of the UTXO (`hashMulti(tx_hash, index)`)
            value = the UTXO

    ***************************************************************************/

    public abstract bool peekUTXO (in Hash utxo, out UTXO value) nothrow @safe;

    /***************************************************************************

        Helper function to remove an UTXO in the UTXO set.

        Params:
            hash = the hash of the UTXO (`hashMulti(tx_hash, index)`)

    ***************************************************************************/

    protected abstract void remove (in Hash utxo) @safe;

    /***************************************************************************

        Helper function to add an UTXO in the UTXO set.

        Params:
            hash = the hash of the UTXO (`hashMulti(tx_hash, index)`)
            value = the UTXO

    ***************************************************************************/

    protected abstract void add (in Hash utxo, UTXO value) @safe;

    /***************************************************************************

        Clear the UTXO cache

    ***************************************************************************/

    public abstract void clear () @safe;
}

/*******************************************************************************

    This is a simple UTXOSet, used when the AA behavior is desired

    Most unittests do not need a fully-fledged UTXOSet with all the DB and
    serialization that comes with it, instead relying on an associative array
    and a delegate.

    Since this pattern is so common, this class is offered as a mean to achieve
    this without code duplication. See issue #501 for history.

    Note that this should *NOT* be used to replace the above UTXOSet,
    when for example doing integration tests with LocalRest.

*******************************************************************************/

public class TestUTXOSet : UTXOCache
{
    /// UTXO cache backed by an AA
    public UTXO[Hash] storage;

    ///
    alias storage this;

    /// Short hand to add a transaction
    public void put (const Transaction tx) nothrow @safe
    {
        Hash txhash = hashFull(tx);
        foreach (size_t idx, ref output_; tx.outputs)
        {
            Hash h = UTXO.getHash(txhash, idx);
            UTXO v = {
                output: output_
            };
            this.storage[h] = v;
        }
    }

    ///
    public override bool peekUTXO (in Hash utxo, out UTXO value) nothrow @safe
    {
        // Note: Keep this in sync with `findUTXO`
        if (auto ptr = utxo in this.storage)
        {
            value = *ptr;
            return true;
        }
        return false;
    }

    ///
    protected override void remove (in Hash utxo) @safe
    {
        this.storage.remove(utxo);
    }

    ///
    protected override void add (in Hash utxo, UTXO value) @safe
    {
        this.storage[utxo] = value;
    }

    /***************************************************************************

        Returns:
            the number of elements in the UTXO set

    ***************************************************************************/

    public override size_t length () @safe
    {
        return this.storage.length;
    }

    ///
    public override int opApply (
        scope int delegate (const ref Hash, const ref UTXO) @safe dg) @safe
    {
        foreach (const ref key, const ref value; this.storage)
            if (auto ret = dg(key, value))
                return ret;
        return 0;
    }

    /***************************************************************************

        Get UTXOs from the UTXO set

        Params:
            pubkey = the key by which to search UTXOs in UTXOSet

        Returns:
            the associative array for UTXOs

    ***************************************************************************/

    public override UTXO[Hash] getUTXOs (in PublicKey pubkey) nothrow @safe
    {
        UTXO[Hash] utxos;
        foreach (const ref key_val; storage.byKeyValue)
            if (key_val.value.output.lock.bytes[] == pubkey[])
                utxos[key_val.key] = key_val.value;
        return utxos;
    }

    /***************************************************************************

        Clear the UTXO cache

    ***************************************************************************/

    public override void clear () @trusted
    {
        this.storage.clear();
    }
}
