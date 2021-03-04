/*******************************************************************************

    Tests restoring SCP Envelope state on restart

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.RestoreSCPState;

version (unittest):

import agora.common.Config;
import agora.common.Serializer;
import agora.common.Task;
import agora.common.crypto.Key;
import agora.consensus.EnrollmentManager;
import agora.consensus.protocol.Nominator;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.Transaction;
import agora.consensus.SCPEnvelopeStore;
import agora.node.Ledger;
import agora.node.Validator;
import agora.network.Clock;
import agora.test.Base;

import geod24.Registry;

import scpd.Cpp;
import scpd.types.Stellar_SCP;

import core.thread;

/// Class containing gshared store for SCPEnvelopeStoreTest
public class TestSCPEnvelopeStore : SCPEnvelopeStore
{
    __gshared const(SCPEnvelope)[] store;

    this ()
    {
        super(":memory:");
    }

    public override bool add (const ref SCPEnvelope envelope) @trusted nothrow
    {
        store ~= envelope;
        return true;
    }

    public override void removeAll () @trusted nothrow
    {
        // no-op
    }

    public override int opApply (scope int delegate(const ref SCPEnvelope) dg) @trusted
    {
        foreach (ref env; store)
        {
            if (auto ret = dg(env))
                return ret;
        }
        return 0;
    }

    public override size_t length () @trusted
    {
        return store.length;
    }
}

/// A test to store SCP state and recover SCP state
unittest
{
    __gshared bool Checked = false;

    static class ReNominator : TestNominator
    {
        /// Ctor
        public this (Parameters!(TestNominator.__ctor) args)
        {
            super(args);
        }

        ///
        override void restoreSCPState ()
        {
            // on first boot the envelope store will be empty,
            // but on restart it should contain two envelopes
            // (nominate & ballot protocol messages)
            if (Checked)
            {
                assert(TestSCPEnvelopeStore.store.length == 2);
                Checked = false;
            }
            super.restoreSCPState();
        }
        protected override SCPEnvelopeStore getSCPEnvelopeStore (string)
        {
            return new TestSCPEnvelopeStore();
        }
    }

    static class ReValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        ///
        protected override ReNominator getNominator (
            Parameters!(TestValidatorNode.getNominator) args)
        {
            return new ReNominator(
                this.params, this.config.validator.key_pair, args,
                this.config.node.data_dir,
                this.txs_to_nominate, this.test_start_time);
        }
    }

    static class ReAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        ///
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == 0)
            {
                auto time = new shared(TimePoint)(this.initial_time);
                auto api = RemoteAPI!TestAPI.spawn!ReValidator(
                    conf, &this.reg, &this.nreg, this.blocks, this.test_conf, time);
                this.reg.register(conf.node.address, api.ctrl.listener());
                this.nodes ~= NodePair(conf.node.address, api, time);
                assert(conf.validator.enabled);
            }
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = TestConf.init;
    auto network = makeTestNetwork!ReAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto re_validator = network.clients[0];
    auto txes = genesisSpendable().map!(txb => txb.sign()).array();
    txes.each!(tx => re_validator.putTransaction(tx));
    network.expectBlock(Height(1));

    Checked = true;
    // Now shut down & restart one node
    network.restart(re_validator);
    network.waitForDiscovery();
    network.expectBlock(Height(1));
    assert(!Checked);
}
