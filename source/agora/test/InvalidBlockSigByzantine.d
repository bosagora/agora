/*******************************************************************************

    Test that when a node signs the block with an invalid signature that it is
    not included in the block multisignature.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.InvalidBlockSigByzantine;

version (unittest):

import agora.consensus.protocol.Nominator;
import agora.crypto.ECC;
import agora.crypto.Schnorr;
import agora.test.Base;
import agora.utils.Log;

import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : NodeID;

import core.stdc.inttypes;

mixin AddLogger!();

private enum ByzantineReason
{
    BadPreimage,
    BadSecretKey
}

private extern(C++) class BadBlockSigningNominator : Nominator
{
    private ByzantineReason reason;

    extern(D) this (Parameters!(Nominator.__ctor) args, ByzantineReason reason)
    {
        super(args);
        this.reason = reason;
    }

    extern(D) override protected Signature signBlock (in Block block)
        @trusted nothrow
    {
        final switch (reason)
        {
            case ByzantineReason.BadPreimage:
                // use preimage from wrong height
                return sign(this.kp.secret,
                    this.enroll_man.getOurPreimage(Height(block.header.height + 1)));
            case ByzantineReason.BadSecretKey:
                // Sign with random in place of validator secret key
                return sign(Scalar.random(),
                    this.enroll_man.getOurPreimage(block.header.height));
        }
    }

    extern(D) override protected void verifyBlock (in Block signed_block)
    {
        // Do nothing for this byzantine node
    }
}

/// node which refuses to co-operate: signs with invalid R or block signature
private class ByzantineNode (ByzantineReason reason) : TestValidatorNode
{
    mixin ForwardCtor!();

    protected override BadBlockSigningNominator makeNominator (
        Parameters!(TestValidatorNode.makeNominator) args)
    {
        return new BadBlockSigningNominator(
            this.params, this.config.validator.key_pair, args,
            this.cacheDB, this.config.validator.nomination_interval,
            &this.acceptBlock, &this.acceptHeader, reason);
    }
}

/// create some nodes depending which will not sign or will sign with invalid signature
private class ByzantineManager (ByzantineReason reason) : TestAPIManager
{
    ///
    public this (immutable(Block)[] blocks, TestConf test_conf, TimePoint genesis_start_time)
    {
        super(blocks, test_conf, genesis_start_time);
    }

    public override void createNewNode (Config conf,
        string file = __FILE__, int line = __LINE__)
    {
        if (this.nodes.length < 1)  // Use first node as byzantine
        {
            assert(conf.validator.enabled);
            log.trace("Create node {} as Bad block signer", this.nodes.length);
            this.addNewNode!(ByzantineNode!(reason))(conf, file, line);
        }
        else
        {
            log.trace("Create node {} as normal validator", this.nodes.length);
            super.createNewNode(conf, file, line);
        }
    }
}

/// MultiSig test: One node signs with an invalid preimage.
/// The block should only have 5 / 6 block signatures added
unittest
{
    TestConf conf;
    conf.node.block_catchup_interval = 100.msecs; // force catchup
    conf.consensus.quorum_threshold = 83;
    auto network = makeTestNetwork!(ByzantineManager!(ByzantineReason.BadPreimage))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto last_node = nodes[$ - 1];
    assert(last_node.getQuorumConfig().threshold == 5); // We should need 5 nodes
    auto txes = genesisSpendable().takeExactly(1).map!(txb => txb.sign()).array();
    txes.each!(tx => last_node.postTransaction(tx));
    // Trigger generation of block
    network.expectHeightAndPreImg(iota(1, GenesisValidators), Height(1));
    // Make sure the client we will check is in sync with others (except for byzantine)
    network.assertSameBlocks(iota(1, GenesisValidators), Height(1));
    nodes.drop(1).each!(node => assertValidatorsBitmask(node.getAllBlocks()[1]));
}

/// MultiSig test: One node signs with an invalid secretkey.
/// The block should only have 5 / 6 block signatures added
unittest
{
    TestConf conf;
    conf.node.block_catchup_interval = 100.msecs; // force catchup
    conf.consensus.quorum_threshold = 83;
    auto network = makeTestNetwork!(ByzantineManager!(ByzantineReason.BadSecretKey))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto last_node = nodes[$ - 1];
    assert(last_node.getQuorumConfig().threshold == 5); // We should need 5 nodes
    auto txes = genesisSpendable().takeExactly(1).map!(txb => txb.sign()).array();
    txes.each!(tx => last_node.postTransaction(tx));
    // Trigger generation of block
    network.expectHeightAndPreImg(iota(1, GenesisValidators), Height(1));
    // Make sure the client we will check is in sync with others (except for byzantine)
    network.assertSameBlocks(iota(1, GenesisValidators), Height(1));
    nodes.drop(1).each!(node => assertValidatorsBitmask(node.getAllBlocks()[1]));
}

private void assertValidatorsBitmask (const Block block)
{
    assert(!block.header.validators[0],
        format!"The first validator signed with an invalid block signature so should not be included. mask=%s"
        (block.header.validators));
    iota(1, 6).each!(i =>
        assert(block.header.validators[i],
            format!"The validator #%s signed with a valid block signature so should be included. mask=%s"
                (i, block.header.validators)));
}
