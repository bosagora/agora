/*******************************************************************************

    Contains tests for Gossip Protocol.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.GossipProtocol;

version (unittest):

import agora.common.Data;
import agora.test.Base;

///
unittest
{
    import std.digest.sha;
    const NodeCount = 4;
    auto network = makeTestNetwork!TestNetworkManager(NetworkTopology.Simple, NodeCount);
    network.start();
    assert(network.getDiscoveredNodes().length == NodeCount);

    Hash h1 = sha256Of("Message No. 1");
    auto n1 = network.apis.values[0];

    // Return true if this message was first received at this node.
    assert(n1.setMessage(h1));

    // Return false if this message was a message already received.
    assert(!n1.setMessage(h1));

    // Check hasMessage
    foreach (key, ref node; network.apis)
    {
        assert(node.hasMessage(h1));
    }
}

/// This creates a new transaction and signs it as a publickey
/// of the previous transaction to create and validate the input.
unittest
{
    TransactionManager manager = new TransactionManager();

    immutable(KeyPair)[] key_pairs;
    key_pairs ~= KeyPair.random;
    key_pairs ~= KeyPair.random;

    // Creates the first transaction.
    Transaction tx0 = manager.newCoinbaseTX(key_pairs[0].address, 100);
    Hash h0 = manager.getTxHash(tx0);
    manager.saveTransaction(h0, tx0);

    // Creates the second transaction.
    Transaction tx1;
    Input input = manager.newTxIn(h0, 0 );
    Hash inputHash = sha256Of(serializeToJsonString(input));

    // Signs at the previous hash value.
    Signature signature = key_pairs[0].secret.sign(inputHash[]);
    input.signature = signature;
    tx1.inputs ~= input;
    tx1.outputs ~= manager.newTxOut(key_pairs[1].address, 7);

    PublicKey pubkey = key_pairs[0].address;

    // Verify input
    assert(pubkey.verify(input.signature, inputHash[]));

}
