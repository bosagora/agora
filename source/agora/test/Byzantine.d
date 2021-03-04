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
import agora.consensus.protocol.Data;
import agora.consensus.protocol.Nominator;
import agora.crypto.Schnorr;
import agora.network.Clock;
import agora.node.Ledger;
import agora.test.Base;
import agora.utils.SCPPrettyPrinter;

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
import core.thread;
import core.atomic;

enum ByzantineReason
{
    None,
    NotSigningEnvelope,
    BadSigningEnvelope,
}

struct EnvelopeTypeCounts
{
    size_t nominate_count;
    size_t prepare_count;
    size_t confirm_count;
    size_t externalize_count;
}

private extern(C++) class ByzantineNominator : TestNominator
{
    private ByzantineReason reason;

    extern(D) this (Parameters!(typeof(super).__ctor) args, ByzantineReason reason)
    {
        super(args);
        this.reason = reason;
    }

    // override signing with Byzantine behaviour of not signing or signing with invalid signature
    extern(C++) override void signEnvelope (ref SCPEnvelope envelope)
    {
        final switch (reason)
        {
            case ByzantineReason.BadSigningEnvelope:
                envelope.signature = sign(this.schnorr_pair,
                    Hash.fromString(
                        "0x412ce227771d98240ffb0015ae49349670eded40267865c18f655db662d4e698f" ~
                        "7caa4fcffdc5c068a07532637cf5042ae39b7af418847385480e620e1395986"));
                break;
            case ByzantineReason.NotSigningEnvelope, ByzantineReason.None:
                // Do nothing
                break;
        }
    }
}

/// node which refuses to co-operate: doesn't sign or signs with invalid signature
class ByzantineNode (ByzantineReason reason) : TestValidatorNode
{
    mixin ForwardCtor!();

    protected override TestNominator getNominator (
        Parameters!(TestValidatorNode.getNominator) args)
    {
        return new ByzantineNominator(
            this.params, this.config.validator.key_pair, args,
            this.config.node.data_dir,
            this.txs_to_nominate, this.test_start_time, reason);
    }
}

private class SpyNominator : TestNominator
{
    private shared(EnvelopeTypeCounts)* envelope_type_counts;

    private NodeID[][SCPStatementType.max + 1] nodes_received;

    /// Ctor
    public this (Parameters!(typeof(super).__ctor) args,
        shared(EnvelopeTypeCounts)* envelope_type_counts)
    {
        super(args);
        this.envelope_type_counts = envelope_type_counts;
    }

    public override void receiveEnvelope (scope ref const(SCPEnvelope) envelope) @trusted
    {
        super.receiveEnvelope(envelope);
        // Make sure we don't count for same node more than once
        if (nodes_received[envelope.statement.pledges.type_].count(envelope.statement.nodeID) > 0) return;
        nodes_received[envelope.statement.pledges.type_] ~= envelope.statement.nodeID;
        final switch (envelope.statement.pledges.type_) {
            case SCPStatementType.SCP_ST_NOMINATE:
                atomicOp!("+=")(this.envelope_type_counts.nominate_count, 1);
                break;
            case SCPStatementType.SCP_ST_PREPARE:
                atomicOp!("+=")(this.envelope_type_counts.prepare_count, 1);
                break;
            case SCPStatementType.SCP_ST_CONFIRM:
                atomicOp!("+=")(this.envelope_type_counts.confirm_count, 1);
                break;
            case SCPStatementType.SCP_ST_EXTERNALIZE:
                atomicOp!("+=")(this.envelope_type_counts.externalize_count, 1);
                break;
        }
    }
}

private class SpyingValidator : TestValidatorNode
{
    shared(EnvelopeTypeCounts)* envelope_type_counts;

    /// Ctor
    public this (Parameters!(typeof(super).__ctor) args,
        shared(EnvelopeTypeCounts)* envelope_type_counts)
    {
        this.envelope_type_counts = envelope_type_counts;
        super(args);
    }

    ///
    protected override TestNominator getNominator (
        Parameters!(TestValidatorNode.getNominator) args)
    {
        return new SpyNominator(
            this.params, this.config.validator.key_pair, args,
            this.config.node.data_dir,
            this.txs_to_nominate, this.test_start_time, this.envelope_type_counts);
    }
}

/// create some nodes depending which will not sign or will sign with invalid signature
private class ByzantineManager (bool addSpyValidator = false,
    size_t byzantine_not_signing_count = 0,
    size_t byzantine_bad_signing_count = 0) : TestAPIManager
{
    shared(EnvelopeTypeCounts) envelope_type_counts;

    ///
    mixin ForwardCtor!();

    public override void createNewNode (Config conf,
        string file = __FILE__, int line = __LINE__)
    {
        if (this.nodes.length < byzantine_not_signing_count + byzantine_bad_signing_count)
        {
            auto time = new shared(TimePoint)(this.initial_time);
            assert(conf.validator.enabled);
            RemoteAPI!TestAPI node;
            if (this.nodes.length < byzantine_not_signing_count)
                this.addNewNode!(ByzantineNode!(ByzantineReason.NotSigningEnvelope))
                    (conf, file, line);
            else
                this.addNewNode!(ByzantineNode!(ByzantineReason.BadSigningEnvelope))
                    (conf, file, line);
        }
        else
            // Add spying validator as last node
            if (addSpyValidator && this.nodes.length == GenesisValidators - 1)
            {
                auto time = new shared(TimePoint)(this.initial_time);
                assert(conf.validator.enabled);
                auto node = RemoteAPI!TestAPI.spawn!SpyingValidator(
                    conf, &this.reg, &this.nreg, this.blocks, this.test_conf,
                    time, &this.envelope_type_counts);
                this.reg.register(conf.node.address, node.ctrl.listener());
                this.nodes ~= NodePair(conf.node.address, node, time);
            }
            else
                super.createNewNode(conf, file, line);
    }
}

/// Block should be added if we have 6 of 6 validators signing
unittest
{
    TestConf conf = { quorum_threshold : 100 };
    auto network = makeTestNetwork!(ByzantineManager!(true, 0, 0))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[$ - 1];
    assert(node_1.getQuorumConfig().threshold == 6); // We should need all 6 nodes
    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1));
}

/// Block should be added if we have 5 of 6 valid signatures (1 not signing the envelope)
unittest
{
    TestConf conf = { quorum_threshold : 83 };
    auto network = makeTestNetwork!(ByzantineManager!(true, 1, 0))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[$ - 1];
    assert(node_1.getQuorumConfig().threshold == 5); // We should need 5 nodes
    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1));
}

/// Block should be added if we have 5 of 6 valid signatures (1 signs envelope with invalid signature)
unittest
{
    TestConf conf = { quorum_threshold : 83 };
    auto network = makeTestNetwork!(ByzantineManager!(true, 0, 1))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[$ - 1];
    assert(node_1.getQuorumConfig().threshold == 5); // We should need 5 nodes
    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.expectBlock(Height(1));
}


private void waitForCount(size_t target_count, shared(size_t)* counter, string name)
{
    size_t loopCount;
    while (atomicLoad(*counter) < target_count)
    {
        // That's at least 5 seconds
        assert(loopCount < 1000, format("Only received %d of %d, expected %s envelopes!",
                   atomicLoad(*counter), target_count, name));
        loopCount++;
        Thread.sleep(30.msecs);
    }
}

/// 4 out of 6 nodes signing correctly WILL NOT prevent block from being externalized if we require 4 out of 6
unittest
{
    TestConf conf = { quorum_threshold : 66 };
    auto network = makeTestNetwork!(ByzantineManager!(true, 1, 1))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto node_1 = nodes[$ - 1];
    assert(node_1.getQuorumConfig().threshold == 4); // We should need 4 nodes
    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.setTimeFor(Height(1));  // trigger consensus
    waitForCount(1, &network.envelope_type_counts.externalize_count, "externalize");
    Thread.sleep(1.seconds);
    assert(network.envelope_type_counts.confirm_count > 0, "The block should have been confirmed! Perhaps the delay needs to be increased");
    assert(network.envelope_type_counts.externalize_count > 0, "The block should have been externalized!");
}

/// 4 out of 6 nodes signing correctly WILL prevent block from being externalized if we require 5 out of 6
unittest
{
    TestConf conf = { quorum_threshold : 83 };
    auto network = makeTestNetwork!(ByzantineManager!(true, 1, 1))(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto node_1 = nodes[$ - 1];
    assert(node_1.getQuorumConfig().threshold == 5); // We should need 5 nodes
    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => node_1.putTransaction(tx));
    network.setTimeFor(Height(1));  // trigger consensus
    Thread.sleep(2.seconds);
    assert(atomicLoad(network.envelope_type_counts.confirm_count) == 0,
           "The block should not have been confirmed!");
    assert(atomicLoad(network.envelope_type_counts.externalize_count) == 0,
           "The block should not have been externalized!");
}
