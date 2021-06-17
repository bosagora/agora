/*******************************************************************************

    Create some signed blocks and update the signature and validators values.
    This simulates the signing by validators after the block has been
    externalised.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module unit.BlockStorageMultiSig;

import agora.common.Amount;
import agora.common.BitMask;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.crypto.ECC;
import agora.node.BlockStorage;
import agora.utils.Test;
import agora.utils.PrettyPrinter;

import std.algorithm;
import std.file;
import std.path;
import std.range;
import std.conv;
import std.format;
import std.stdio : writeln;

/// The maximum number of block in one file
private immutable ulong MFILE_MAX_BLOCK = 10;

/// blocks to test
const ulong BlockCount = 5;

///
private void main ()
{
    auto path = makeCleanTempDir(__MODULE__);

    BlockStorage storage = new BlockStorage(path);
    storage.load(GenesisBlock);

    Block block;
    Block prev_block = cast(Block) GenesisBlock;

    // For genesis, we need to use the outputs, not previous transactions
    Transaction[] txs = genesisSpendable().map!(txb => txb.refund(WK.Keys.A.address).sign()).array();

    void signBlockSig1 (Height h)
    {
        block = makeNewBlock(prev_block, txs, prev_block.header.time_offset + 1, Hash.init, genesis_validator_keys.length);
        block.header.signature = Signature(Scalar.random().toPoint(), Scalar.random());
        block.header.validators = BitMask(6);
        block.header.validators[1] = true;
        storage.saveBlock(block);
        // Prepare transactions for the next block
        txs = txs
            .map!(tx => TxBuilder(tx).refund(WK.Keys[h + 1].address).sign())
            .array();
        prev_block = block;
    }
    // Sign each block with signature and set validator 1 as signed
    iota(1, BlockCount).each!(h => signBlockSig1(Height(h)));

    void signBlockSig2 (Height h)
    {
        auto block2 = storage.readBlock(Height(h));
        assert(block2.header.validators[1] == true, format!"block at height %s:\n%s\n\n"(h, prettify(block2)));
        block2.header.signature = Signature(Scalar.random().toPoint(), Scalar.random());
        block2.header.validators[0] = true;
        storage.updateBlockSig(Height(h), block2.hashFull(), block2.header.signature, block2.header.validators);
        block = storage.readBlock(Height(h));
        assert(block == block2, format!"Signature not updated for block at height %s:\n%s\n\n%s != %s"
            (h, prettify(block), block.header.signature, block2.header.signature));
    }
    /// Update each block adding an updated block multisig and set validator 0
    /// as also signed
    iota(1, BlockCount).each!(h => signBlockSig2(Height(h)));
}
