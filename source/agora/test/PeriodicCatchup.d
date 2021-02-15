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

version (none):

import agora.common.BitField;
import agora.common.Config;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.test.Base;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import scpd.types.Stellar_SCP;

import std.exception;
import core.stdc.inttypes;
import core.thread;

mixin AddLogger!();


private extern(C++) class DoesNotExternalizeBlockNominator : TestNominator
{
    extern(D) this (Parameters!(TestNominator.__ctor) args)
    {
        super(args);
    }

    public override void valueExternalized (uint64_t slot_idx, ref const(Value) value) nothrow
    {
        try
        {
            if (slot_idx == 2)
            {
                log.trace("Remove signatures for block 1 to test signature catchup");
                BlockHeader header = super.ledger.getBlocksFrom(Height(1)).front.header;
                header.validators = BitField!ubyte(6);
                header.signature = Signature.init;
                super.ledger.updateBlockMultiSig(header);
                log.trace("Do not externalize block 2 to test periodic catchup of blocks");
                return;
            }
            super.valueExternalized(slot_idx, value);
        }
        catch (Exception e)
        {
            assert(0, format!"PeriodicCatchup exception thrown during test: %s"(e));
        }
    }
}

/// node for testing periodic catchup
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
    mixin ForwardCtor!();

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
    network.assertSameBlocks(target_height);
}
