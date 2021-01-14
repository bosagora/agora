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

import agora.test.Base;
import agora.utils.Log;

import agora.consensus.data.Params;
import agora.consensus.protocol.Data;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.data.Block;
import agora.consensus.state.UTXODB;
import agora.consensus.EnrollmentManager;
import agora.consensus.Fee;
import agora.common.Hash;
import agora.common.Task;
import agora.common.Config;
import agora.common.Metadata;
import agora.common.crypto.Key;
import agora.network.NetworkManager;
import agora.network.Clock;
import agora.node.Ledger;
import agora.node.BlockStorage;
import agora.node.TransactionPool;
import geod24.Registry;
import core.stdc.time;
import core.thread;

mixin AddLogger!();

// No TX gossiping and every node has unique TXs in their pool
// Nodes should request the TXs from other nodes explicitly
unittest
{
    static class NoGossipNetworkManager : TestNetworkManager
    {
        /// Constructor
        public this (Config config, Metadata metadata,
            TaskManager taskman, Clock clock, Registry* reg)
        {
            super(config, metadata, taskman, clock, reg);
        }

        public override void gossipTransaction (Transaction tx) @safe
        {
            // Dont
        }
    }

    static class NoGossipValidator : TestValidatorNode
    {
        public this (Config config, Registry* reg, immutable(Block)[] blocks,
            in TestConf test_conf, shared(time_t)* cur_time)
        {
            super(config, reg, blocks, test_conf, cur_time);
        }

        protected override NetworkManager getNetworkManager (Metadata metadata,
            TaskManager taskman, Clock clock)
        {
            assert(taskman !is null);
            return new NoGossipNetworkManager(this.config, metadata, taskman,
                clock, this.registry);
        }

    }

    static class NoGossipAPIManager : TestAPIManager
    {
        public this (immutable(Block)[] blocks, TestConf test_conf,
            time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

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
        public this (immutable(ConsensusParams) params,
            UTXOSet utxo_set, IBlockStorage storage,
            EnrollmentManager enroll_man, TransactionPool pool,
            FeeManager fee_man, Clock clock,
            Duration block_timestamp_tolerance = 60.seconds,
            void delegate (const ref Block, bool) @safe onAcceptedBlock = null)
        {
            super(params, utxo_set, storage, enroll_man, pool, fee_man,
                clock, block_timestamp_tolerance, onAcceptedBlock);
        }

        public override bool acceptTransaction (Transaction tx) @safe
        {
            // Dont accept any incoming TX
            log.info("Picky node ignoring TX {}", tx);
            return false;
        }
    }

    static class PickyValidator : TestValidatorNode
    {
        public this (Config config, Registry* reg, immutable(Block)[] blocks,
            in TestConf test_conf, shared(time_t)* cur_time)
        {
            super(config, reg, blocks, test_conf, cur_time);
            this.ledger = new PickyLedger(params, this.utxo_set, this.storage,
                this.enroll_man, this.pool, this.fee_man, this.clock,
                config.node.block_timestamp_tolerance, &this.onAcceptedBlock);
        }

        public override void putTransaction (Transaction tx) @safe
        {
            // Dont accept any incoming TXs
            log.info("Picky node ignoring TX {}", tx);
        }
    }

    static class PickyAPIManager : TestAPIManager
    {
        public this (immutable(Block)[] blocks, TestConf test_conf,
            time_t initial_time)
        {
            super(blocks, test_conf, initial_time);
        }

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
