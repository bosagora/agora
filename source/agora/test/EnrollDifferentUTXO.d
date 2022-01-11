/*******************************************************************************

    Contains networking tests with multiple enrollments with different UTXOs.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.EnrollDifferentUTXOs;

version (unittest):

import agora.consensus.data.genesis.Test: genesis_validator_keys;
import agora.test.Base;

import core.thread;

private class SameKeyValidator : TestValidatorNode
{
    mixin ForwardCtor!();

    /// Enroll with new UTXO which is not yet used
    public override Enrollment setRecurringEnrollment (bool doIt)
    {
        Hash[] utxo_hashes;
        auto utxos = this.utxo_set.getUTXOs(
            this.config.validator.key_pair.address);
        foreach (key, utxo; utxos)
        {
            if (utxo.output.type == OutputType.Freeze &&
                utxo.output.value.integral() >= Amount.MinFreezeAmount.integral())
            {
                utxo_hashes ~= key;
            }
        }

        // Find a UTXO which is not used for the enrollments in Genesis block
        Hash unused_utxo;
        auto validators = this.ledger.getValidators(Height(1));
        foreach (utxo; utxo_hashes)
        {
            if (!validators.map!(val => val.utxo).canFind(utxo))
            {
                unused_utxo = utxo;
                break;
            }
        }
        assert(unused_utxo != Hash.init);

        const new_enroll =
            this.enroll_man.createEnrollment(unused_utxo, this.ledger.getBlockHeight() + 1);
        this.postEnrollment(new_enroll, this.ledger.getBlockHeight() + 1);

        return new_enroll;
    }
}

private class SameKeyNodeAPIManager : TestAPIManager
{
    ///
    mixin ForwardCtor!();

    /// See base class
    public override void createNewNode (Config conf, string file, int line)
    {
        if (this.nodes.length == 0)
            this.addNewNode!SameKeyValidator(conf, file, line);
        else
            super.createNewNode(conf, file, line);
    }
}

/// Situation: There are six validators enrolled in Genesis block. Right before
///     the cycle ends, the first validator re-enrolls with another UTXO and
///     other validators re-enrolls again with the same UTXO used in the current
///     enrollments.
/// Expectation: Enrolling with the different UTXO of first validator fails but
///     trying re-enrolling with the UTXO succeeds after the cycle ends.
unittest
{
    TestConf conf = {
        recurring_enrollment : false
    };

    auto network = makeTestNetwork!SameKeyNodeAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;

    // generate 17 blocks
    network.generateBlocks(Height(17));

    // create and send tx to all nodes
    network.postAndEnsureTxInPool(iota(GenesisValidators),
        network.freezeUTXO(iota(GenesisValidators)));

    // Block 18
    network.expectHeightAndPreImg(Height(18), network.blocks[0].header, 5.seconds);

    // Block 19
    network.generateBlocks(Height(19));

    // Now we re-enroll the first validator with a new UTXO but it will fail
    // because an enrollment with same public key of the first validator is
    // already present in the validator set.
    Enrollment new_enroll = nodes[0].setRecurringEnrollment(true);
    Thread.sleep(3.seconds);  // postEnrollment() can take a while..
    nodes.each!(node =>
        retryFor(node.getEnrollment(new_enroll.utxo_key) == Enrollment.init, 1.seconds));

    // Now we re-enroll other five validators
    foreach (node; nodes[1 .. $])
    {
        Enrollment enroll = node.setRecurringEnrollment(true);
        nodes.each!(node =>
            retryFor(node.getEnrollment(enroll.utxo_key) == enroll, 5.seconds));
    }

    // Block 20
    network.generateBlocks(Height(20));
    auto b20 = nodes[0].getBlocksFrom(20, 2)[0];
    assert(b20.header.enrollments.length == 5);

    // Now we retry re-enrolling the first validator with the new UTXO
    nodes[0].postEnrollment(new_enroll, Height(21));
    nodes.each!(node =>
        retryFor(node.getEnrollment(new_enroll.utxo_key) == new_enroll, 5.seconds));

    // Block 21 created with the new enrollment
    network.generateBlocks(Height(21));
    auto b21 = nodes[0].getBlocksFrom(21, 2)[0];
    assert(b21.header.enrollments.length == 1);
    assert(b21.header.enrollments[0] == new_enroll);
}
