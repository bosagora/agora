/*******************************************************************************

    Contains tests for the node discovery behavior

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NetworkDiscovery;

version (unittest):

import agora.test.Base;
import agora.api.Validator;
import agora.crypto.Schnorr;
import agora.crypto.Key;

///
unittest
{
    TestConf conf;
    conf.node.retry_delay = 100.msecs;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    foreach (key, node; network.nodes)
    {
        auto addresses = node.client.getNodeInfo().addresses.keys;
        assert(addresses.sort.uniq.count >= GenesisValidators - 1,  // >= since it may connect to itself (#772)
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}

/// test network discovery through the getNodeInfo() API
unittest
{
    TestConf conf =
    {
        topology : NetworkTopology.MinimallyConnected,
        full_nodes : 4,
    };
    conf.node.min_listeners = 9;
    conf.node.network_discovery_interval = 2.seconds;
    conf.node.retry_delay = 250.msecs;
    auto network = makeTestNetwork!TestAPIManager(conf);

    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    foreach (key, node; network.nodes)
    {
        auto addresses = node.client.getNodeInfo().addresses.keys;
        assert(addresses.sort.uniq.count >= 9,  // >= since it may connect to itself (#772)
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}

/// test finding all quorum nodes before network discovery is complete
unittest
{
    TestConf conf =
    {
        topology : NetworkTopology.MinimallyConnected,
    };
    conf.node.min_listeners = 1;
    conf.node.network_discovery_interval = 2.seconds;
    conf.node.retry_delay = 250.msecs;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    foreach (key, node; network.nodes)
    {
        auto addresses = node.client.getNodeInfo().addresses.keys;
        assert(addresses.sort.uniq.count >= GenesisValidators - 1,  // >= since it may connect to itself (#772)
               format("Node %s has %d peers: %s", key, addresses.length, addresses));
    }
}

///
unittest
{
    import core.thread;
    import core.atomic;

    __gshared shared(int) call_count = 0;
    __gshared NodePair impersonator_node;

    static class ImpersonatorValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        /// GET /public_key
        protected override Identity getPublicKey (PublicKey key = PublicKey.init)
            nothrow @trusted
        {
            atomicOp!"+="(call_count, 1);
            return Identity(this.config.validator.key_pair.address);
        }
    }

    static class ImpersonatorManager : TestAPIManager
    {
        mixin ForwardCtor!();

        public override void createNewNode (Config conf, string file = __FILE__,
            int line = __LINE__)
        {
            if (impersonator_node == NodePair.init && conf.validator.enabled)
            {
                this.addNewNode!ImpersonatorValidator(conf, file, line);
                impersonator_node = this.nodes[$ - 1];
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf;
    auto network = makeTestNetwork!ImpersonatorManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();

    int count = 0;
    while (atomicLoad(call_count) < GenesisValidators - 1)
    {
        if (count++ > 30) // 3 secs
            break;
        Thread.sleep(100.msecs);
    }

    assert(atomicLoad(call_count) >= GenesisValidators - 1);

    // All nodes should've banned impersonator_node
    foreach (node; network.nodes)
        if (node != impersonator_node)
            retryFor(node.client.isBanned(Address("http://"~impersonator_node.address)), 1.seconds,
                format!"Node %s did not ban %s"(node.address, impersonator_node.address));
}
