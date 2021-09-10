/*******************************************************************************

    Contains tests for accepting "future" enrollments

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.FutureEnrollment;

version (unittest):

import agora.api.FullNode;
import agora.common.Amount;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.crypto.Key;
import agora.node.Config;
import agora.test.Base;

import core.atomic : atomicLoad;

/// Situation: A delayed validator is a block behind the latest height(19)
///     where other nodes have a block that contains a frozen UTXO for
///     the enrollment for the outsider. The validator only has the `tx`
///     in the pool for the frozen UTXO. At that time, the outsider tries
///     to enroll and the validator receives the enrollment.
/// Expectation: The validator accepts the enrollment even though there is
///     not the frozen UTXO in the UTXO set because the transaction that
///     contains the UTXO exists in the transaction pool. And the block
///     having the enrollment is externalized for all the nodes.
unittest
{
    static class CustomValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        private shared bool* enable_catchup;

        ///
        public this (Parameters!(TestValidatorNode.__ctor) args,
            shared(bool)* enable_catchup)
        {
            this.enable_catchup = enable_catchup;
            super(args);
        }

        ///
        protected override void catchupTask () nothrow
        {
            if (atomicLoad(*this.enable_catchup))
                super.catchupTask();
        }
    }

    static class CustomAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        public static shared bool enable_catchup = false;

        /// set base class
        public override void createNewNode (Config conf, string file, int line)
        {
            if (this.nodes.length == GenesisValidators - 1)
                this.addNewNode!CustomValidator(conf, &this.enable_catchup,
                    file, line);
            else
                super.createNewNode(conf, file, line);
        }
    }

    TestConf conf = {
        outsider_validators : 1,
        recurring_enrollment : false,
    };
    auto all_validators = GenesisValidators + conf.outsider_validators;
    auto network = makeTestNetwork!CustomAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto delayed_node = GenesisValidators - 1;
    auto outsider = network.nodes[GenesisValidators];

    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, all_validators),
        Height(GenesisValidatorCycle - 2));

    // prepare frozen outputs for the outsider validator to enroll
    const key = outsider.getPublicKey().key;
    network.blocks[0].spendable().drop(1).takeExactly(1)
        .map!(txb => txb
            .split([key]).sign(OutputType.Freeze))
            .each!(tx => network.nodes[delayed_node].postTransaction(tx));

    // the delayed validator becomes unresponsive
    network.clients[delayed_node].filter!(API.postTransaction);

    // Block 19 we add the frozen utxo for the outsider validator
    network.generateBlocks(iota(GenesisValidators - 1), Height(GenesisValidatorCycle - 1));
    network.expectHeight([GenesisValidators], Height(GenesisValidatorCycle - 1));

    // the delayed validator is a block behind from the latest height
    assert(network.clients[delayed_node].getBlockHeight() == GenesisValidatorCycle - 2);

    // enroll the outsider
    auto enroll = network.clients[GenesisValidators].setRecurringEnrollment(true);
    assert(enroll != Enrollment.init);

    // re-enroll all the validators
    iota(GenesisValidators).each!(i => network.enroll(iota(GenesisValidators), i));

    // check that the delayed validator has the enrollment of the outsider
    auto gotten_enroll = network.clients[delayed_node].getEnrollment(enroll.utxo_key);
    assert(gotten_enroll == enroll);

    // enable `catchupTask` for the delayed validator and clear filter
    CustomAPIManager.enable_catchup = true;
    network.clients[delayed_node].clearFilter();
    network.expectHeight([delayed_node], Height(GenesisValidatorCycle - 1));

    // Block 20 and check the all the enrollments to be validators
    network.generateBlocks(iota(GenesisValidators), Height(GenesisValidatorCycle));
    network.expectHeight(iota(all_validators), Height(GenesisValidatorCycle));
    auto b20 = network.nodes[delayed_node].getBlocksFrom(GenesisValidatorCycle, 2)[0];
    assert(b20.header.enrollments.length == 7);
}
