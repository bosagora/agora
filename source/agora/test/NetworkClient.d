/*******************************************************************************

    Contains tests for the functionality of the NetworkClient.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NetworkClient;

version (unittest):

import agora.api.Validator;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.common.Types;
import agora.common.Hash;
import agora.consensus.data.Transaction;
import agora.test.Base;

import core.thread;

/// test retrying requests after failure
unittest
{
    auto conf = TestConf.init;
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    // block periodic getBlocksFrom for last node
    nodes[conf.validators - 1].filter!(API.getBlocksFrom);

    // reject inbound requests for all but first node
    nodes[1 .. conf.validators - 1].each!(node => node.filter!(API.putTransaction));

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();

    // last node will keep trying to send transactions up to
    // (max_retries * retry_delay) seconds (see Base.d)
    txes.each!(tx => nodes[conf.validators - 1].putTransaction(tx));

    // clear filter after 100 msecs, the above requests will eventually be gossiped
    Thread.sleep(100.msecs);
    nodes[1 .. conf.validators - 1].each!(node => node.clearFilter());
    network.expectBlock(Height(1));
}

/// test request timeouts
unittest
{
    TestConf conf;
    auto network = makeTestNetwork(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    // block periodic getBlocksFrom for last node
    nodes[conf.validators - 1].filter!(API.getBlocksFrom);

    // reject inbound requests
    const DropRequests = true;
    nodes[1 .. conf.validators - 1].each!(node => node.sleep(100.msecs, DropRequests));

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();

    txes.each!(tx => nodes[$ - 1].putTransaction(tx));

    // last node will keep trying to send transactions up to
    // max_retries * (retry_delay + timeout) seconds (see Base.d),
    const delay = conf.max_retries * (conf.retry_delay + conf.timeout);
    network.expectBlock(Height(1), network.blocks[0].header, delay);
}
