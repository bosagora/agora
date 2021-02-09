/*******************************************************************************

    Contains tests for network behaviour when nominated TXs are not known to
    every node

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.LocalTransactions;

import agora.consensus.data.Transaction;
import agora.consensus.Fee;
import agora.common.Task;
import agora.common.Config;
import agora.common.Metadata;
import agora.common.crypto.Key;
import agora.crypto.Hash;
import agora.node.Ledger;
import agora.test.Base;
import agora.utils.Log;

import geod24.Registry;
import core.thread;

mixin AddLogger!();

// No TX gossiping and every node has unique TXs in their pool
// Nodes should request the TXs from other nodes explicitly
unittest
{
    static class NoGossipValidator : TestValidatorNode
    {
        mixin ForwardCtor!();

        /// Do what `FullNode.putTransaction` does, minus gossipping
        public override void putTransaction (Transaction tx) @safe
        {
            auto tx_hash = hashFull(tx);
            if (this.pool.hasTransactionHash(tx_hash))
                return;

            if (this.ledger.acceptTransaction(tx))
            {
                log.info("Accepted transaction but not gossiping: {}", tx_hash);
                this.pushTransaction(tx);
            }
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

    TestConf conf = {
        quorum_threshold : 100,
        txs_to_nominate : 1,
    };
    auto network = makeTestNetwork!NoGossipAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // Get the genesis block, make sure it's the only block externalized
    auto blocks = network.clients[0].getBlocksFrom(0, 2);
    assert(blocks.length == 1);

    // create enough tx's for a single block
    auto txs = blocks[0].spendable().map!(txb => txb.sign()).array();

    txs.enumerate.each!((idx, tx) => network.clients[idx % network.clients.length]
        .putTransaction(tx));

    network.expectBlock(Height(1), blocks[0].header);
}

// A node never receives the TXs that was externalized. It should be able to
// catch up to the network.
unittest
{
    static class PickyLedger : Ledger
    {
        mixin ForwardCtor!();

        public override bool acceptTransaction (Transaction tx) @safe
        {
            // Dont accept any incoming TX
            log.info("Picky node ignoring TX {}", tx);
            return false;
        }
    }

    static class PickyValidator : TestValidatorNode
    {
        public this (Parameters!(typeof(super).__ctor) args)
        {
            super(args);
            this.ledger = new PickyLedger(params, this.utxo_set, this.storage,
                this.enroll_man, this.pool, this.fee_man, this.clock,
                this.config.node.block_timestamp_tolerance, &this.onAcceptedBlock);
        }

        public override void putTransaction (Transaction tx) @safe
        {
            // Dont accept any incoming TXs
            log.info("Picky node ignoring TX {}", tx);
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

    TestConf conf = {
        quorum_threshold : 80,
        txs_to_nominate : 1,
    };
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

    auto txs = blocks[0].spendable().map!(txb => txb.sign()).array();
    txs.each!(tx => node.putTransaction(tx));
    Thread.sleep(1.seconds);
    txs.each!(tx => assert(!picky_node.hasTransactionHash(tx.hashFull())));

    network.expectBlock(Height(1), blocks[0].header);
}
