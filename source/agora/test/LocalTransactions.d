/*******************************************************************************

    Contains tests for network behaviour when nominated TXs are not known to
    every node

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.LocalTransactions;

version (unittest):

import agora.crypto.Hash;
import agora.common.Set;
import agora.consensus.Fee;
import agora.consensus.Ledger;
import agora.test.Base;
import agora.utils.Log;
import agora.script.Engine;
import core.thread;

mixin AddLogger!();

// No TX gossiping and every node has unique TXs in their pool
// Nodes should request the TXs from other nodes explicitly
unittest
{
    static class NoGossipValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        protected override NoGossipTransactionRelayer makeTransactionRelayer ()
        {
            return new NoGossipTransactionRelayer();
        }
    }

    static class NoGossipAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        public override void createNewNode (Config conf, string file = __FILE__,
            int line = __LINE__)
        {
            if (conf.validator.enabled)
                this.addNewNode!NoGossipValidator(conf, file, line);
            else
                this.addNewNode!TestFullNode(conf, file, line);
        }
    }

    TestConf conf;
    conf.consensus.quorum_threshold = 100;
    auto network = makeTestNetwork!NoGossipAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = network.clients[0].getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    // Create 6 transactions - one for each validator
    auto txs = blocks[0].spendable().map!(txb => txb.sign()).takeExactly(6);
    // Distribute them to different clients
    txs.enumerate.each!(
        (idx, tx) {
            network.postAndEnsureTxInPool((idx % network.clients.length).only, tx);
        });
    network.expectTxExternalization(
        Set!Hash.from(txs.map!(tx => tx.hashFull())), 6);
}

// A node never receives the TXs that was externalized. It should be able to
// catch up to the network.
unittest
{
    static class PickyLedger : ValidatingLedger
    {
        mixin ForwardCtor!();

        public override string acceptTransaction (in Transaction tx,
            in ubyte double_spent_threshold_pct = 0, in ushort min_fee_pct = 0) @safe
        {
            // Dont accept any incoming TX
            log.info("Picky node ignoring TX {}", tx);
            return "Nah";
        }
    }

    static class PickyValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        protected override ValidatingLedger makeLedger ()
        {
            return new PickyLedger(this.params, this.engine,
                this.utxo_set, this.storage, this.enroll_man, this.pool,
                new FeeManager(this.stateDB, this.params), &this.onAcceptedBlock);
        }

        public override TransactionResult postTransaction (in Transaction tx) @safe
        {
            // Dont accept any incoming TXs
            log.info("Picky node ignoring TX {}", tx);

            return TransactionResult(TransactionResult.Status.Accepted);
        }
    }

    static class PickyAPIManager : TestAPIManager
    {
        mixin ForwardCtor!();

        public override void createNewNode (Config conf, string file = __FILE__,
            int line = __LINE__)
        {
            static bool picky_node_created = false;
            if (conf.validator.enabled && !picky_node_created)
            {
                this.addNewNode!PickyValidator(conf, file, line);
                picky_node_created = true;
            }
            else if (conf.validator.enabled)
                this.addNewNode!TestValidatorNode(conf, file, line);
            else
                this.addNewNode!TestFullNode(conf, file, line);
        }
    }

    TestConf conf;
    conf.consensus.quorum_threshold = 80;
    auto network = makeTestNetwork!PickyAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto picky_node = network.clients[0];
    auto node = network.clients[1];
    // Get the genesis block, make sure it's the only block externalized
    auto blocks = picky_node.getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    auto txs = blocks[0].spendable().takeExactly(1).map!(txb => txb.sign());
    txs.each!(tx => node.postTransaction(tx));
    Thread.sleep(1.seconds);
    txs.each!(tx => assert(!picky_node.hasTransactionHash(tx.hashFull())));

    network.expectHeightAndPreImg(Height(1));
}
