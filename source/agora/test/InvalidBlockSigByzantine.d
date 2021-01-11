/*******************************************************************************

    Contains Byzantine node tests, which refuse to co-operate in the
    SCP consensus protocol in various ways.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.InvalidBlockSigByzantine;

version (unittest):

import agora.api.Validator;
import agora.common.Config;
import agora.common.Task;
import agora.common.Types;
import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
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

private enum ByzantineReason
{
    BadCommitmentR,
    BadSignature
}

private extern(C++) class BadBlockSigningNominator : TestNominator
{
    private ByzantineReason reason;

    extern(D) this (immutable(ConsensusParams) params,
        Clock clock, NetworkManager network, KeyPair key_pair, Ledger ledger,
        EnrollmentManager enroll_man, TaskManager taskman, string data_dir, ByzantineReason reason, ulong test_start_time)
    {
        this.reason = reason;
        super(params, clock, network, key_pair, ledger, enroll_man, taskman, data_dir,
            this.txs_to_nominate, test_start_time);
    }

    extern(D) override protected Sig createBlockSignature(const Block block) @trusted nothrow
    {
        import agora.common.crypto.Schnorr;
        import agora.common.crypto.ECC;
        import agora.common.Hash;
        import agora.utils.Test : WK;

        // challenge = Hash(block) to Scalar
        const Scalar challenge = hashFull(block);
        final switch (reason)
        {
            case ByzantineReason.BadCommitmentR:
                const Scalar rc = Scalar.random(); // This is normally the enrollment commitment
                const Scalar r = rc + challenge;
                const Point R = r.toPoint();
                return Sig(R, multiSigSign(r, this.schnorr_pair.v, challenge));
            case ByzantineReason.BadSignature:
                const Scalar rc = Scalar(hashMulti(secretKeyToCurveScalar(WK.Keys.NODE2.secret),
                "consensus.signature.noise", 0));
                const Scalar r = rc + challenge;
                const Point R = r.toPoint();
                // Sign with random in place of validator secret key
                const wrong_scalar_v = Scalar.random();
                return Sig(R, multiSigSign(r, wrong_scalar_v, challenge));
        }
    }

    extern(D) override protected void verifyBlock (const Block signed_block)
    {
        // Do nothing for this byzantine node
    }
}

/// node which refuses to co-operate: signs with invalid R or block signature
private class ByzantineNode (ByzantineReason reason) : TestValidatorNode
{
    mixin ForwardCtor!();

    protected override TestNominator getNominator (immutable(ConsensusParams) params,
        Clock clock, NetworkManager network, KeyPair key_pair, Ledger ledger,
        EnrollmentManager enroll_man, TaskManager taskman, string data_dir)
    {
        return new BadBlockSigningNominator(params, clock, network, key_pair, ledger,
            enroll_man, taskman, data_dir, reason, this.test_start_time);
    }
}

/// create some nodes depending which will not sign or will sign with invalid signature
private class ByzantineManager (ByzantineReason reason) : TestAPIManager
{
    ///
    public this (immutable(Block)[] blocks, TestConf test_conf, time_t genesis_start_time)
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

/// MultiSig test: One node signs with an invalid block signature.
/// The block should only have 5 / 6 block signatures added
unittest
{
    TestConf conf = { quorum_threshold : 83 , txs_to_nominate : 1 };
    auto network = makeTestNetwork!(ByzantineManager!(ByzantineReason.BadSignature))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto last_node = nodes[$ - 1];
    assert(last_node.getQuorumConfig().threshold == 5); // We should need 5 nodes
    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => last_node.putTransaction(tx));
    network.expectBlock([1,2,3,4,5], Height(1));
    assertValidatorsBitmask(last_node.getAllBlocks()[1]);
}

/// MultiSig test: One node signs with a valid block signature using incorrect R.
/// The block should only have 5 / 6 block signatures added
unittest
{
    TestConf conf = { quorum_threshold : 83 , txs_to_nominate : 1 };
    auto network = makeTestNetwork!(ByzantineManager!(ByzantineReason.BadCommitmentR))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto last_node = nodes[$ - 1];
    assert(last_node.getQuorumConfig().threshold == 5); // We should need 5 nodes
    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => last_node.putTransaction(tx));
    network.expectBlock([1,2,3,4,5], Height(1));
    assertValidatorsBitmask(last_node.getAllBlocks()[1]);
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
