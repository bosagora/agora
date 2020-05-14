/*******************************************************************************

    Contains validation rountines for blocks

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.validation.Block;

import agora.common.Amount;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.UTXOSet;
import VEn = agora.consensus.validation.Enrollment;
import VTx = agora.consensus.validation.Transaction;
import agora.consensus.Genesis;

version (unittest)
{
    import agora.common.crypto.ECC;
    import agora.common.crypto.Key;
    import agora.common.crypto.Schnorr;
    import agora.common.Hash;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.Transaction;
    import agora.utils.Test;
}

/*******************************************************************************

    Check the validity of a block.

    A block is considered valid if:
        - its height is the previous block height + 1
        - its prev_hash is the previous block header's hash
        - the number of transactions in the block are equal to Block.TxsInBlock
        - the merkle root in the header matches the re-built merkle tree root
          based on the included transactions in the block
        - Transactions are ordered by their hash value
        - all the the transactions pass validation, which implies:
            - signatures are authentic
            - the inputs spend an output which must be found with the
              findUTXO() delegate

    Note that checking for transactions which double-spend is the responsibility
    of the findUTXO() delegate. During validation, whenever this delegate is
    called it should also keep track of the used UTXOs, thereby marking
    it as a spent output. See the `findNonSpent` function in the
    unittest for an example.

    Params:
        block = the block to check
        prev_height = the height of the direct ancestor of this block
        prev_hash = the hash of the direct ancestor of this block
        findUTXO = delegate to find the referenced unspent UTXOs with

    Returns:
        `null` if the block is valid, a string explaining the reason it
        is invalid otherwise.

*******************************************************************************/

public string isInvalidReason (const ref Block block, in ulong prev_height,
    in Hash prev_hash, UTXOFinder findUTXO) nothrow @safe
{
    import std.algorithm;

    // special case for the genesis block
    if (block.header.height == 0)
        return block == GenesisBlock ?
            null : "Block: Height 0 but not Genesis block";

    if (block.header.height > prev_height + 1)
        return "Block: Height is above expected height";
    if (block.header.height < prev_height + 1)
        return "Block: Height is under expected height";

    if (block.header.prev_block != prev_hash)
        return "Block: Header.prev_block does not match previous block";

    if (block.txs.length != Block.TxsInBlock)
        return "Block: Number of transaction mismatch";

    if (!block.txs.isSorted())
        return "Block: Transactions are not sorted";

    foreach (const ref tx; block.txs)
    {
        if (auto fail_reason = VTx.isInvalidReason(tx, findUTXO, block.header.height))
            return fail_reason;
    }

    Hash[] merkle_tree;
    if (block.header.merkle_root != Block.buildMerkleTree(block.txs, merkle_tree))
        return "Block: Merkle root does not match header's";

    if (!isStrictlyMonotonic!"a.utxo_key < b.utxo_key"(block.header.enrollments))
        return "Block: The enrollments are not sorted in ascending order";

    foreach (const ref enrollment; block.header.enrollments)
    {
        if (auto fail_reason = VEn.isInvalidReason(enrollment, findUTXO))
            return fail_reason;
    }

    return null;
}

/// Ditto but returns `bool`, only usable in unittests
version (unittest)
public bool isValid (const ref Block block, ulong prev_height,
    Hash prev_hash, UTXOFinder findUTXO) nothrow @safe
{
    return isInvalidReason(block, prev_height, prev_hash, findUTXO) is null;
}

///
unittest
{
    import std.algorithm;
    import std.range;

    // note: using array as a workaround to be able to store const Transactions
    const(Transaction)[][Hash] tx_map;
    scope findUTXO = (Hash hash, size_t index, out UTXOSetValue value)
    {
        if (auto tx = hash in tx_map)

        {
            if (index < (*tx).front.outputs.length)
            {
                value.unlock_height = 0;
                value.type = TxType.Payment;
                value.output = (*tx).front.outputs[index];
                return true;
            }
        }

        return false;
    };

    auto gen_key = getGenesisKeyPair();
    assert(GenesisBlock.isValid(GenesisBlock.header.height, Hash.init, null));
    auto gen_hash = GenesisBlock.header.hashFull();

    tx_map[GenesisTransaction.hashFull()] = [GenesisTransaction];
    auto txs = makeChainedTransactions(gen_key, null, 1).sort.array;
    auto block = makeNewBlock(GenesisBlock, txs);

    // height check
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.header.height = 100;
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.header.height = GenesisBlock.header.height + 1;
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    /// .prev_block check
    block.header.prev_block = block.header.hashFull();
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.header.prev_block = gen_hash;
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    /// .txs length check
    block.txs = txs[0 .. $ - 1];
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.txs = (txs ~ txs).sort.array;
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.txs = txs;
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    /// Txs sorting check
    block.txs = txs.reverse;
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    block.txs = txs.reverse;
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    /// no matching utxo => fail
    tx_map.clear();
    assert(!block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    tx_map[GenesisTransaction.hashFull()] = [GenesisTransaction];
    assert(block.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    tx_map.clear();  // genesis is spent
    auto prev_txs = txs;
    prev_txs.each!(tx => tx_map[tx.hashFull()] = [tx]);  // these will be spent

    auto prev_block = block;
    txs = makeChainedTransactions(gen_key, prev_txs, 1);
    block = makeNewBlock(prev_block, txs);
    assert(block.isValid(prev_block.header.height, prev_block.header.hashFull(),
        findUTXO));

    assert(prev_txs.length > 0);  // sanity check
    foreach (tx; prev_txs)
    {
        // one utxo missing from the set => fail
        tx_map.remove(tx.hashFull);
        assert(!block.isValid(prev_block.header.height, prev_block.header.hashFull(),
            findUTXO));

        tx_map[tx.hashFull] = [tx];
        assert(block.isValid(prev_block.header.height, prev_block.header.hashFull(),
            findUTXO));
    }

    // the key is hashMulti(hash(prev_tx), index)
    Output[Hash] utxo_set;

    foreach (idx, ref output; GenesisTransaction.outputs)
        utxo_set[hashMulti(GenesisTransaction.hashFull, idx)] = output;

    assert(utxo_set.length != 0);
    const utxo_set_len = utxo_set.length;

    // contains the used set of UTXOs during validation (to prevent double-spend)
    Output[Hash] used_set;
    UTXOFinder findNonSpent = (Hash hash, size_t index, out UTXOSetValue value)
    {
        auto utxo_hash = hashMulti(hash, index);

        if (utxo_hash in used_set)
            return false;  // double-spend

        if (auto utxo = utxo_hash in utxo_set)
        {
            used_set[utxo_hash] = *utxo;
            value.unlock_height = 0;
            value.type = TxType.Payment;
            value.output = *utxo;
            return true;
        }

        return false;
    };

    // consumed all utxo => fail
    txs = makeChainedTransactions(gen_key, null, 1).sort.array;
    block = makeNewBlock(GenesisBlock, txs);
    assert(block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
            findNonSpent));

    assert(used_set.length == utxo_set_len);  // consumed all utxos

    // reset state
    used_set.clear();

    // consumed same utxo twice => fail
    txs[$ - 1] = txs[$ - 2];
    block = makeNewBlock(GenesisBlock, txs);
    assert(!block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
            findNonSpent));

    // we stopped validation due to a double-spend
    assert(used_set.length == txs.length - 1);

    txs = makeChainedTransactions(gen_key, prev_txs, 1);
    block = makeNewBlock(GenesisBlock, txs);
    assert(block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));

    // modify the last hex byte of the merkle root
    block.header.merkle_root[][$ - 1]++;

    assert(!block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));

    // now restore it back to what it was
    block.header.merkle_root[][$ - 1]--;
    assert(block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));
    const last_root = block.header.merkle_root;

    // txs with a different amount
    txs = makeChainedTransactions(gen_key, prev_txs, 1, 20_000_000);
    block = makeNewBlock(GenesisBlock, txs);
    assert(block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));

    // the previous merkle root should not match the new txs
    block.header.merkle_root = last_root;
    assert(!block.isValid(GenesisBlock.header.height, GenesisBlock.header.hashFull(),
        findUTXO));
}

///
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.Transaction;
    import agora.consensus.data.UTXOSet;

    import std.algorithm;
    import std.range;

    auto utxo_set = new UTXOSet(":memory:");
    scope (exit) utxo_set.shutdown();
    UTXOFinder findUTXO = utxo_set.getUTXOFinder();

    auto gen_key = getGenesisKeyPair();
    assert(GenesisBlock.isValid(GenesisBlock.header.height, Hash.init, null));
    auto gen_hash = GenesisBlock.header.hashFull();
    foreach (ref tx; GenesisBlock.txs)
        utxo_set.updateUTXOCache(tx, GenesisBlock.header.height);

    auto txs_1 = makeChainedTransactions(gen_key, null, 1,
        400_000_000_000 * Block.TxsInBlock).sort.array;

    auto block1 = makeNewBlock(GenesisBlock, txs_1);
    assert(block1.isValid(GenesisBlock.header.height, gen_hash, findUTXO));

    foreach (ref tx; txs_1)
        utxo_set.updateUTXOCache(tx, block1.header.height);

    KeyPair keypair = KeyPair.random();
    Transaction[] txs_2;
    foreach (idx, pre_tx; txs_1)
    {
        Input input = Input(hashFull(pre_tx), 0);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
        };
        if (idx > 3)
            tx.type = TxType.Payment;

        if (idx == 7)
        {
            foreach (_; 0 .. Block.TxsInBlock)
            {
                Output output;
                output.value = Amount(100);
                output.address = keypair.address;
                tx.outputs ~= output;
            }
        }
        else
        {
            Output output;
            output.value = Amount.MinFreezeAmount;
            output.address = keypair.address;
            tx.outputs ~= output;
        }

        tx.inputs[0].signature = gen_key.secret.sign(hashFull(tx)[]);
        txs_2 ~= tx;
    }

    auto block2 = makeNewBlock(block1, txs_2);
    assert(block2.isValid(block1.header.height, hashFull(block1.header), findUTXO));
    foreach (ref tx; txs_2)
        utxo_set.updateUTXOCache(tx, block2.header.height);

    KeyPair keypair2 = KeyPair.random();
    Transaction[] txs_3;
    foreach (idx; 0 .. Block.TxsInBlock)
    {
        Input input = Input(hashFull(txs_2[7]), idx);

        Transaction tx =
        {
            TxType.Payment,
            [input],
            [Output(Amount(1), keypair2.address)]
        };
        tx.inputs[0].signature = keypair.secret.sign(hashFull(tx)[]);
        txs_3 ~= tx;
    }

    Pair signature_noise = Pair.random;
    Pair node_key_pair;
    node_key_pair.v = secretKeyToCurveScalar(keypair.secret);
    node_key_pair.V = node_key_pair.v.toPoint();

    auto utxo_hash1 = utxo_set.getHash(hashFull(txs_2[0]), 0);
    Enrollment enroll1;
    enroll1.utxo_key = utxo_hash1;
    enroll1.random_seed = hashFull(Scalar.random());
    enroll1.cycle_length = 1008;
    enroll1.enroll_sig = sign(node_key_pair.v, node_key_pair.V, signature_noise.V,
        signature_noise.v, enroll1);

    auto utxo_hash2 = utxo_set.getHash(hashFull(txs_2[1]), 0);
    Enrollment enroll2;
    enroll2.utxo_key = utxo_hash2;
    enroll2.random_seed = hashFull(Scalar.random());
    enroll2.cycle_length = 1008;
    enroll2.enroll_sig = sign(node_key_pair.v, node_key_pair.V, signature_noise.V,
        signature_noise.v, enroll2);

    Enrollment[] enrollments;
    enrollments ~= enroll1;
    enrollments ~= enroll2;
    enrollments.sort!("a.utxo_key < b.utxo_key");
    auto block3 = makeNewBlock(block2, txs_3, enrollments);
    assert(block3.isValid(block2.header.height, hashFull(block2.header), findUTXO));
    enrollments.sort!("a.utxo_key > b.utxo_key");
    findUTXO = utxo_set.getUTXOFinder();
    // Block: The enrollments are not sorted in ascending order
    assert(!block3.isValid(block2.header.height, hashFull(block2.header), findUTXO));
}
