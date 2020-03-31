/*******************************************************************************

    Test providing a custom Genesis block for the test-suite.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.GenesisBlock;

version (unittest):

import agora.api.Validator;
import agora.common.Amount;
import agora.common.BitField;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.test.Base;

import std.exception : assumeUnique;
import std.typecons : tuple;

/// create our own genesis block that uses the given keypair,
/// returns tuple(block, genesis_tx)
private auto makeCustomGenesisBlock (in KeyPair key_pair)
{
    Transaction GenTx =
    {
        TxType.Payment,
        inputs: [ Input.init ],
        outputs: [
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
            Output(Amount(62_500_000L * 10_000_000L), key_pair.address),
        ],
    };

    Transaction[] txs = [GenTx];
    Hash[] merkle_tree;
    auto merkle_root = Block.buildMerkleTree(txs, merkle_tree);

    immutable(BlockHeader) makeHeader ()
    {
        return immutable(BlockHeader)(
            Hash.init,   // prev
            0,           // height
            merkle_root,
            BitField!uint.init,
            Signature.init,
            null,        // enrollments
        );
    }

    return tuple(immutable(Block)(
        makeHeader(),
        txs.assumeUnique,
        merkle_tree.assumeUnique
    ), GenTx);
}

/// ditto
unittest
{
    import std.algorithm;
    import std.range;
    import core.thread;

    auto kp = KeyPair.random();
    auto genesis = makeCustomGenesisBlock(kp);

    import agora.consensus.Genesis;
    TestConf conf = { gen_block : genesis[0] };
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[0];

    // create spending txs refering to our own genesis block txs
    auto txes = makeChainedTransactions(kp, null, 1, 40_000_000, genesis[1]);
    txes.each!(tx => node_1.putTransaction(tx));

    nodes.all!(node => node.getBlockHeight() == 1).retryFor(2.seconds);
}
