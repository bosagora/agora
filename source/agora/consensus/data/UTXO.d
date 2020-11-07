/*******************************************************************************

    Defines the UTXO transaction set struct,
    contains the UTXOFinder delegate

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.UTXO;

import agora.common.Hash;
import agora.common.Serializer;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Transaction;

/// The structure of spendable transaction output
public struct UTXO
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

    public static Hash getHash (in Hash hash, ulong index) @safe nothrow
    {
        return hashMulti(hash, index);
    }
}

unittest
{
    testSymmetry!UTXO();
}
