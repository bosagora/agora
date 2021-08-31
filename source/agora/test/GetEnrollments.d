/*******************************************************************************

    Contains tests for getting missing enrollments from the network

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.GetEnrollments;

version (unittest):

import agora.test.Base;

import core.atomic : atomicLoad;

/// Situation: There are six validators enrolled in Genesis block.
///     But a validator can not receive any enrollments in the case
///     of an abnormal situation. The validator tries to get missing
///     enrollments periodically
/// Expectation: The validator ends up restoring misssing enrollments
///     from other nodes.
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
        recurring_enrollment : false
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

    // the delayed_node validator becomes unresponsive
    network.clients[delayed_node].filter!(API.postTransaction);

    // prepare frozen outputs for the outsider validator to enroll
    const key = outsider.getPublicKey().key;
    network.blocks[0].spendable().drop(1).takeExactly(1)
        .map!(txb => txb
            .split([key]).sign(OutputType.Freeze))
            .each!(tx => network.nodes[0].postTransaction(tx));

    // Block 19 we add the frozen utxo for the outsider validator
    // The delayed validator don't receive this `postTransaction` request
    network.generateBlocks(iota(GenesisValidators - 1), Height(GenesisValidatorCycle - 1));
    network.expectHeight([GenesisValidators], Height(GenesisValidatorCycle - 1));

    // enroll the outsider
    auto enroll = network.clients[GenesisValidators].setRecurringEnrollment(true);
    assert(enroll != Enrollment.init);

    // re-enroll all the validators
    iota(GenesisValidators).each!(i => network.enroll(iota(GenesisValidators), i));

    // check that the delayed validator doesn't have the enrollment of the outsider
    assert(network.clients[delayed_node].getEnrollment(enroll.utxo_key) == Enrollment.init);

    // enable `catchupTask` for the delayed validator and clear filter
    CustomAPIManager.enable_catchup = true;
    network.clients[delayed_node].clearFilter();
    network.expectHeight([delayed_node], Height(GenesisValidatorCycle - 1));

    // check the missing enrollment to be restored
    retryFor(network.clients[delayed_node].getEnrollment(enroll.utxo_key) == enroll,
        2 * conf.node.enrollment_catchup_interval,
        format!"The enrollment (%s) not in pool of the delayed validator"(enroll.utxo_key));

    // Block 20 and check the all the enrollments to be validators
    network.generateBlocks(iota(GenesisValidators), Height(GenesisValidatorCycle));
    network.expectHeight(iota(all_validators), Height(GenesisValidatorCycle));
    auto b20 = network.nodes[0].getBlocksFrom(GenesisValidatorCycle, 1)[0];
    assert(b20.header.enrollments.length == 7);
}
