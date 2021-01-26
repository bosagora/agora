/*******************************************************************************

    Check that if the node does not externalize the block when triggered by SCP
    that it will fetch the block later during periodic catchup and then
    successfully externalize.

    Copyright:
        Copyright (c) 2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.PeriodicCatchup;

version (unittest):

import agora.api.Validator;
import agora.common.Config;
import agora.common.Task;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.EnrollmentManager;
import agora.consensus.data.Params;
import agora.consensus.data.Transaction;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.protocol.Data;
import agora.consensus.protocol.Nominator;
import agora.network.Clock;
import agora.network.NetworkClient;
import agora.network.NetworkManager;
import agora.node.Ledger;
import agora.test.Base;
import agora.utils.SCPPrettyPrinter;
import agora.utils.Log;
import agora.utils.PrettyPrinter;


import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : NodeID;

import geod24.Registry;

import std.algorithm;
import std.exception;
import std.format;
import std.range;
import std.stdio;

import core.exception;
import core.stdc.inttypes;
import core.stdc.time;
import core.thread;
import core.atomic;

mixin AddLogger!();


private extern(C++) class DoesNotExternalizeBlockNominator : TestNominator
{
    extern(D) this (Parameters!(TestNominator.__ctor) args)
    {
        super(args);
    }

    public override void valueExternalized (uint64_t slot_idx, ref const(Value) value) nothrow
    {
        if (slot_idx == 2)
        {
            log.trace("Do not externalize this block to test periodic catchup");
            return;
        }
        super.valueExternalized(slot_idx, value);
    }
}

/// node which refuses to co-operate: signs with invalid R or block signature
private class TestNode () : TestValidatorNode
{
    mixin ForwardCtor!();

    protected override TestNominator getNominator (
        Parameters!(TestValidatorNode.getNominator) args)
    {
        return new DoesNotExternalizeBlockNominator(
            this.params, this.config.validator.key_pair, args,
            this.config.node.data_dir,
            this.txs_to_nominate, this.test_start_time);
    }
}

/// create a node that will not externalize second block
private class NodeManager (): TestAPIManager
{
    ///
    public this (immutable(Block)[] blocks, TestConf test_conf, time_t genesis_start_time)
    {
        super(blocks, test_conf, genesis_start_time);
    }

    public override void createNewNode (Config conf,
        string file = __FILE__, int line = __LINE__)
    {
        if (this.nodes.length < 1)  // Use first node as test node
        {
            assert(conf.validator.enabled);
            log.trace("Create node {} as cathup test node", this.nodes.length);
            this.addNewNode!(TestNode!())(conf, file, line);
        }
        else
        {
            log.trace("Create node {} as normal validator", this.nodes.length);
            super.createNewNode(conf, file, line);
        }
    }
}

/// All nodes should have same blocks given enough time for periodic catchup to take place
unittest
{
    TestConf conf = { txs_to_nominate : 1 };
    auto network = makeTestNetwork!(NodeManager!())(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto target_height = Height(3);
    network.generateBlocks(target_height);
    Thread.sleep(conf.block_catchup_interval); // Give time for catchup to have taken place
    network.assertSameBlocks(target_height);
}
