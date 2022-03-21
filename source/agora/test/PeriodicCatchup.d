/*******************************************************************************

    Check that if the node does not externalize the block when triggered by SCP
    that it will fetch the block later during periodic catchup and then
    successfully externalize.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.PeriodicCatchup;

version (unittest):

import agora.common.BitMask;
import agora.consensus.data.Block;
import agora.consensus.data.ValidatorBlockSig;
import agora.consensus.protocol.Nominator;
import agora.crypto.Schnorr: Signature;
import agora.test.Base;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import scpd.types.Stellar_SCP: Value;

import std.exception;
import core.stdc.inttypes;
import core.thread;

mixin AddLogger!();


private extern(C++) class DoesNotExternalizeBlockNominator : Nominator
{
    extern(D) {
        mixin ForwardCtor!();
    }

    extern(D) public override void checkExternalize () @safe nothrow
    {
        try
        {
            if (this.ledger.height == 0)
            {
                log.trace("{}: Do not externalize block 1 to test periodic catchup of blocks", __FUNCTION__);
                return;
            }
            super.checkExternalize();
        }
        catch (Exception e)
        {
            assert(0, __FUNCTION__ ~ ": exception thrown during test: " ~ e.msg);
        }
    }

    extern(D) public override const(BlockHeader) receiveBlockSignature (in ValidatorBlockSig block_sig) @safe
    {
        if (block_sig.height == 2)
        {
            log.trace("{}: Ignore signatures for block 2 to test signature catchup", __FUNCTION__);
            return BlockHeader.init;
        }
        return super.receiveBlockSignature(block_sig);
    }
}

/// node for testing periodic catchup
private class TestNode () : TestValidatorNode
{
    mixin ForwardCtor!();

    protected override DoesNotExternalizeBlockNominator makeNominator (
        Parameters!(TestValidatorNode.makeNominator) args)
    {
        return new DoesNotExternalizeBlockNominator(
            this.params, this.config.validator.key_pair, args,
            this.cacheDB, this.config.validator.nomination_interval,
            &this.acceptBlock);
    }
}

/// create a node that will not externalize second block
private class NodeManager (): TestAPIManager
{
    ///
    mixin ForwardCtor!();

    public override void createNewNode (Config conf,
        string file = __FILE__, int line = __LINE__)
    {
        if (this.nodes.length == 0)  // Use first node as test node
        {
            assert(conf.validator.enabled);
            log.trace("Create node #{} ({}) as catchup test node",
                this.nodes.length, conf.validator.key_pair.address);
            this.addNewNode!(TestNode!())(conf, file, line);
        }
        else
        {
            log.trace("Create node {} as normal node", this.nodes.length);
            super.createNewNode(conf, file, line);
        }
    }
}

/// All nodes should have same blocks given enough time for periodic catchup to take place
unittest
{
    TestConf conf;
    conf.node.test_validators = 4;  // limit to 4 Genesis validators
    conf.full_nodes = 2;            // Add a couple of fullnodes
    conf.node.block_catchup_interval = 300.msecs; // Speed up the test
    auto network = makeTestNetwork!(NodeManager!())(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto target_height = Height(3);
    network.generateBlocks(target_height);
    // Check all validators and fullnodes have all the same blocks to height 3
    network.assertSameBlocks(iota(conf.node.test_validators + conf.full_nodes), target_height);
    // Check the signature counts are complete for all blocks up to height 3 for first node
    network.clients.front.getBlocksFrom(Height(1), 5).each!(b => assert(b.header.validators.percentage == 100));
    // Check all nodes have same signatures
    network.assertSameSignatures(iota(conf.node.test_validators + conf.full_nodes), target_height);
}
