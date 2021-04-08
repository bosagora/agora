/*******************************************************************************

    Contains tests for the validators not revealing their pre-images.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.MissingPreImageDetection;

version (unittest):

import agora.common.Config;
import agora.common.Task;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Data;
import agora.serialization.Serializer;
import agora.test.Base;
import agora.utils.Test;

import scpd.types.Stellar_SCP;
import scpd.types.Utils;

import core.stdc.stdint;
import core.thread;

import geod24.Registry;

/*******************************************************************************

    Verifies that the nodes have not generated a block at the given height.

    Params:
        clients = the nodes to be checked
        height = the unexpected block height

*******************************************************************************/

private void unexpectBlock (Clients)(Clients clients, Height height)
{
    foreach (_; 0 .. 10)
    {
        clients.each!(node => retryFor(
            node.getBlockHeight() < height, 1.seconds));
        Thread.sleep(1.seconds);
    }
}

private class MissingPreImageEM : EnrollmentManager
{
    mixin ForwardCtor!();

    /// This does not reveal pre-images intentionally
    public override bool getNextPreimage (out PreImageInfo preimage,
        in Height height) @safe
    {
        return false;
    }
}

private class NoPreImageVN : TestValidatorNode
{
    mixin ForwardCtor!();

    protected override EnrollmentManager makeEnrollmentManager ()
    {
        return new MissingPreImageEM(this.stateDB, this.cacheDB,
            this.config.validator.key_pair, params);
    }
}

private class BadNominator : TestNominator
{
    /// Ctor
    public this (Parameters!(TestNominator.__ctor) args)
    {
        super(args);
    }

extern (C++):

    public override ValidationLevel validateValue (uint64_t slot_idx,
        ref const(Value) value, bool nomination) nothrow
    {
        scope(failure) assert(0);
        ValidationLevel ret;
        () @trusted {
            auto data = deserializeFull!ConsensusData(value[]);
            data.missing_validators.length = 0;
            data.missing_validators ~= 2;
            auto next_value = data.serializeFull().toVec();
            ret = super.validateValue(slot_idx, next_value, nomination);
        }();

        return ret;
    }
}

private class BadNominatingVN : TestValidatorNode
{
    mixin ForwardCtor!();

    ///
    protected override TestNominator makeNominator (
        Parameters!(TestValidatorNode.makeNominator) args)
    {
        return new BadNominator(
            this.params, this.config.validator.key_pair, args,
            this.config.node.data_dir,
            this.txs_to_nominate, this.test_start_time);
    }
}

/// Situation: There is a validator does not reveal a pre-image for
///     the height after next.
/// Expectation: The expected block has been generated.
unittest
{
    static class BadAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 5)
                this.addNewNode!NoPreImageVN(conf, file, line);
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork!BadAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto spendable = network.blocks[$ - 1].spendable().array;

    // discarded UTXOs (just to trigger block creation)
    auto txs = spendable[0 .. 8].map!(txb => txb.sign()).array;

    Thread.sleep(5.seconds);

    // block 1
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectHeight(Height(1));
}

/// Situation: There is a validator does not reveal a pre-image for next
//      height and the information is contained in a `ConsensusData`. But
//      a bad nominator manipulates information about the missing preimage
//      validators.
/// Expectation: The expected block has been generated.
unittest
{
    static class BadNominatingAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
                this.addNewNode!NoPreImageVN(conf, file, line);
            else if (this.nodes.length == 5)
                this.addNewNode!BadNominatingVN(conf, file, line);
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        recurring_enrollment : false,
    };
    auto network = makeTestNetwork!BadNominatingAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto spendable = network.blocks[$ - 1].spendable().array;

    // discarded UTXOs (just to trigger block creation)
    auto txs = spendable[0 .. 8].map!(txb => txb.sign()).array;

    Thread.sleep(5.seconds);

    // try to make block 1
    txs.each!(tx => nodes[0].putTransaction(tx));
    network.expectHeight(Height(1));
}
