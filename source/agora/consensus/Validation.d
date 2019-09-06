/*******************************************************************************

    Contains validation routines for all data types required for consensus.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Validation;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;

/// Delegate to find an unspent UTXO
public alias UTXOFinder = scope const(Output)* delegate (Hash hash, size_t index)
    @safe nothrow;

/*******************************************************************************

    Get result of transaction data and signature verification

    Params:
        tx = `Transaction`
        findUTXO = delegate for finding `Output`

    Return:
        `null` if the transaction is valid, a string explaining the reason it
        is invalid otherwise.

*******************************************************************************/

public string isInvalidReason (const Transaction tx, UTXOFinder findUTXO)
    @safe nothrow
{
    if (tx.inputs.length == 0)
        return "Transaction: No input";

    if (tx.outputs.length == 0)
        return "Transaction: No output";

    // disallow negative amounts
    foreach (output; tx.outputs)
        if (!output.value.isValid())
            return "Transaction: Output(s) overflow or underflow";

    Amount sum_unspent;

    const tx_hash = hashFull(tx);
    foreach (input; tx.inputs)
    {
        // all referenced outputs must be present
        auto output = findUTXO(input.previous, input.index);
        if (output is null)
            return "Transaction: Input ref not in UTXO";

        if (!output.address.verify(input.signature, tx_hash[]))
            return "Transaction: Input has invalid signature";

        if (!sum_unspent.add(output.value))
            return "Transaction: Input overflow";
    }

    Amount new_unspent;
    if (!tx.getSumOutput(new_unspent))
        return "Transaction: Referenced Output(s) overflow";
    if (!sum_unspent.sub(new_unspent))
        return "Transaction: Output(s) are higher than Input(s)";
    return null;
}

/// Ditto but returns a bool
public bool isValid (const Transaction tx, UTXOFinder findUTXO)
    @safe nothrow
{
    return isInvalidReason(tx, findUTXO) is null;
}

/// verify transaction data
unittest
{
    import std.format;

    Transaction[Hash] storage;
    KeyPair[] key_pairs = [KeyPair.random, KeyPair.random, KeyPair.random, KeyPair.random];

    // Creates the first transaction.
    Transaction previousTx = newCoinbaseTX(key_pairs[0].address, Amount(100));

    // Save
    Hash previousHash = hashFull(previousTx);
    storage[previousHash] = previousTx;

    // Creates the second transaction.
    Transaction secondTx = Transaction(
        [
            Input(previousHash, 0)
        ],
        [
            Output(Amount(50), key_pairs[1].address, TXO_PAYMENT)
        ]
    );

    // delegate for finding `Output`
    scope findUTXO = (Hash hash, size_t index)
    {
        if (auto tx = hash in storage)
            if (index < tx.outputs.length)
                return &tx.outputs[index];

            return null;
    };

    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` < the sum of `Input`)
    assert(secondTx.isValid(findUTXO), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(Amount(50), key_pairs[2].address, TXO_PAYMENT);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It is validated. (the sum of `Output` == the sum of `Input`)
    assert(secondTx.isValid(findUTXO), format("Transaction data is not validated %s", secondTx));

    secondTx.outputs ~= Output(Amount(50), key_pairs[3].address, TXO_PAYMENT);
    secondTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(secondTx)[]);

    // It isn't validated. (the sum of `Output` > the sum of `Input`)
    assert(!secondTx.isValid(findUTXO), format("Transaction data is not validated %s", secondTx));
}

/// negative output amounts disallowed
unittest
{
    KeyPair[] key_pairs = [KeyPair.random(), KeyPair.random()];
    Transaction tx_1 = newCoinbaseTX(key_pairs[0].address, Amount(1000));
    Hash tx_1_hash = hashFull(tx_1);

    Transaction[Hash] storage;
    storage[tx_1_hash] = tx_1;

    // delegate for finding `Output`
    scope findUTXO = (Hash hash, size_t index)
    {
        if (auto tx = hash in storage)
            if (index < tx.outputs.length)
                return &tx.outputs[index];
        return null;
    };

    // Creates the second transaction.
    Transaction tx_2 =
    {
        inputs  : [Input(tx_1_hash, 0)],
        // oops
        outputs : [Output(Amount.invalid(-400_000), key_pairs[1].address, TXO_PAYMENT)]
    };

    tx_2.inputs[0].signature = key_pairs[0].secret.sign(hashFull(tx_2)[]);

    assert(!tx_2.isValid(findUTXO));
}

/// This creates a new transaction and signs it as a publickey
/// of the previous transaction to create and validate the input.
unittest
{
    import std.format;

    Transaction[Hash] storage;

    immutable(KeyPair)[] key_pairs;
    key_pairs ~= KeyPair.random();
    key_pairs ~= KeyPair.random();
    key_pairs ~= KeyPair.random();

    // delegate for finding `Output`
    scope findUTXO = (Hash hash, size_t index)
    {
        if (auto tx = hash in storage)
            if (index < tx.outputs.length)
                return &tx.outputs[index];

            return null;
    };

    // Create the first transaction.
    Transaction genesisTx = newCoinbaseTX(key_pairs[0].address, Amount(100_000));
    Hash genesisHash = hashFull(genesisTx);
    storage[genesisHash] = genesisTx;
    genesisTx.inputs[0].signature = key_pairs[0].secret.sign(hashFull(genesisTx)[]);

    // Create the second transaction.
    Transaction tx1 = Transaction(
        [
            Input(genesisHash, 0)
        ],
        [
            Output(Amount(1_000), key_pairs[1].address, TXO_PAYMENT)
        ]
    );

    // Signs the previous hash value.
    Hash tx1Hash = hashFull(tx1);
    tx1.inputs[0].signature = key_pairs[0].secret.sign(tx1Hash[]);
    storage[tx1Hash] = tx1;

    assert(tx1.isValid(findUTXO), format("Transaction signature is not validated %s", tx1));

    Transaction tx2 = Transaction(
        [
            Input(tx1Hash, 0)
        ],
        [
            Output(Amount(1_000), key_pairs[1].address, TXO_PAYMENT)
        ]
    );

    Hash tx2Hash = hashFull(tx2);
    // Sign with incorrect key
    tx2.inputs[0].signature = key_pairs[2].secret.sign(tx2Hash[]);
    storage[tx2Hash] = tx2;
    // Signature verification must be error
    assert(!tx2.isValid(findUTXO), format("Transaction signature is not validated %s", tx2));
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

    if (block.txs.any!(tx => !tx.isValid(findUTXO)))
        return "Block: Some transactions are invalid";

    Hash[] merkle_tree;
    if (block.header.merkle_root != Block.buildMerkleTree(block.txs, merkle_tree))
        return "Block: Merkle root does not match header's";

    return null;
}

/// Ditto but returns `bool`
public bool isValid (const ref Block block, in ulong prev_height,
    in Hash prev_hash, UTXOFinder findUTXO) nothrow @safe
{
    return isInvalidReason(block, prev_height, prev_hash, findUTXO) is null;
}

///
unittest
{
    import agora.consensus.Genesis;
    import std.algorithm;
    import std.range;

    // note: using array as a workaround to be able to store const Transactions
    const(Transaction)[][Hash] tx_map;
    scope findUTXO = (Hash hash, size_t index)
    {
        if (auto tx = hash in tx_map)
        {
            if (index < (*tx).front.outputs.length)
                return &(*tx).front.outputs[index];
        }

        return null;
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
    UTXOFinder findNonSpent = (Hash hash, size_t index)
    {
        auto utxo_hash = hashMulti(hash, index);

        if (utxo_hash in used_set)
            return null;  // double-spend

        if (auto utxo = utxo_hash in utxo_set)
        {
            used_set[utxo_hash] = *utxo;
            return utxo;
        }

        return null;
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
