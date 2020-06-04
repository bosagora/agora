/*******************************************************************************

    Contains tests for the creation of an enrollment data, enrolling as a
    validator and propagating the information through the network

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.EnrollmentManager;

version (unittest):

import agora.common.Amount;
import agora.common.Hash;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.EnrollmentManager;
import agora.consensus.Genesis;
import agora.test.Base;

/// test for  enrollment process & revealing a pre-image periodically
unittest
{
    auto network = makeTestNetwork(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    // Enroll validators without enrollment data in genesis block.
    // If more than one is enrolled then two blocks are added,
    // otherwise, no blocks are added.
    auto enrolls = enrollValidators(iota(0, nodes.length)
        .filter!(idx => idx >= ValidateCountInGenesis)
        .map!(idx => nodes[idx])
        .array);
    containSameBlocks(nodes, 2).retryFor(3.seconds);

    // Check if nodes have a pre-image newly sent
    // While the timer is running on the taskmanager
    foreach (enroll; enrolls)
        nodes.each!(node =>
            retryFor(node.getPreimage(enroll.utxo_key) != PreImageInfo.init,
                10.seconds));
}
