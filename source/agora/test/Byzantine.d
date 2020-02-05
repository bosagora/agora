/*******************************************************************************

    Contains Byzantine node tests, which refuse to co-operate in the
    SCP consensus protocol in various ways.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Byzantine;

version (none):

import agora.api.Validator;
import agora.common.Config;
import agora.common.Task;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.ConsensusParams;
import agora.consensus.data.Transaction;
import agora.consensus.protocol.Nominator;
import agora.network.NetworkClient;
import agora.network.NetworkManager;
import agora.node.Ledger;
import agora.test.Base;

import scpd.types.Stellar_SCP;

import geod24.Registry;

import std.algorithm;
import std.datetime;
import std.exception;
import std.format;
import std.range;
import std.stdio;
import core.exception;

/// node which refuses to co-operate: doesn't sign / forges the signature / etc
class BynzantineNode : TestValidatorNode
{
    public this (Config config, Registry* reg, immutable(Block)[] blocks,
        immutable(ConsensusParams) params = null)
    {
        super(config, reg, blocks, params);
    }

    protected override Nominator getNominator (NetworkManager network,
        KeyPair key_pair, Ledger ledger, TaskManager taskman)
    {
        return new class Nominator
        {
            extern(D) this ()
            {
                super(network, key_pair, ledger, taskman);
            }

            // refuse to sign
            extern(C++) override void signEnvelope (ref SCPEnvelope envelope)
            {
            }
        };
    }
}

class ByzantineManager : TestAPIManager
{
    ///
    public this (immutable(Block)[] blocks, immutable(ConsensusParams) params)
    {
        super(blocks, params);
    }

    public override void createNewNode (Config conf)
    {
        RemoteAPI!TestAPI api;
        if (this.nodes.length == 0)  // first node is byzantine
            api = RemoteAPI!TestAPI.spawn!BynzantineNode(conf, &this.reg,
                this.blocks, this.params, conf.node.timeout.msecs);
        else
            api = RemoteAPI!TestAPI.spawn!TestValidatorNode(conf, &this.reg,
                this.blocks, this.params, conf.node.timeout.msecs);

        this.reg.register(conf.node.address, api.tid());
        this.nodes ~= NodePair(conf.node.address, api);
    }
}

/// 1 byzantine => fail
unittest
{
    TestConf conf = { nodes : 4 };
    auto network = makeTestNetwork!ByzantineManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[$ - 1];

    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1), 2.seconds);
}
