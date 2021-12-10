/*******************************************************************************

    Checks the rewards are correct in the payout blocks

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.BlockRewards;

version (unittest):

import agora.consensus.data.Params: ConsensusConfig;
import agora.consensus.Fee: calculateDataFee;
import agora.consensus.protocol.Nominator;
import agora.test.Base;

import scpd.types.Stellar_SCP;

import core.stdc.inttypes;
import std.numeric : gcd;

// Use a shorter payout period for testing
private const int PayoutPeriod = 6;

// year 1: coins per 5 secs: commons = 50 validators = 27
private const BlockSecs = 30;
private const FiveSecsPerBlock = BlockSecs / 5;
private const CommonsReward = 50.coins * FiveSecsPerBlock;
private const ValRewards = 27.coins * FiveSecsPerBlock;
private const ValReward = 27.coins * (FiveSecsPerBlock / GenesisValidators);

/// BlockRewards test with empty blocks so that fees are not added to the payouts
unittest
{
    TestConf conf;
    conf.consensus.block_interval = BlockSecs.seconds;
    conf.consensus.payout_period = PayoutPeriod;
    conf.consensus.quorum_threshold = 100;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[1];

    const emptyBlocks = true;
    // Create blocks until second payout block and make sure signatures are added for those who signed
    const target_height = Height(3 * PayoutPeriod);
    Height last_height = Height(0);
    iota(Height(PayoutPeriod), target_height + 1)
        .stride(Height(PayoutPeriod))
        .each!((Height h)
    {
        network.generateBlocks(h, emptyBlocks);
        retryFor(node_1.getBlocksFrom(h, 1).front.header.validators.setCount() == 6, 5.seconds,
            format!"First node failed to achieve desired signature count of %s at height %s"(6, h));
        network.assertSameBlocks(h, last_height + 1);
        last_height = h;
    });

    // As we created emtpy blocks there should be no txs until second payout period ends
    assert(node_1.getBlocksFrom(Height(PayoutPeriod), 1).front.txs.empty);

    // test first and second payouts
    iota(2 * PayoutPeriod, 3 * PayoutPeriod + 1, PayoutPeriod).each!((height)
    {
        auto cb_tx = node_1.getBlocksFrom(Height(height), 1).front.txs.front;
        cb_tx.outputs.each!(o => assert(o.type == OutputType.Coinbase));
        assert(cb_tx.outputs.map!(o => o.value).sum() == (ValRewards + CommonsReward) * PayoutPeriod);
        assert(cb_tx.outputs.walkLength == GenesisValidators + 1);
        assert(cb_tx.outputs.filter!(o => o.address() == WK.Keys.CommonsBudget.address)
            .front.value == CommonsReward * PayoutPeriod);
        assert(cb_tx.outputs.map!(o => o.value).count!(v => v == ValReward * PayoutPeriod) == GenesisValidators);
    });
}

/// BlockRewards test with blocks with fees added to the payouts
unittest
{
    TestConf conf;
    conf.consensus.block_interval = BlockSecs.seconds;
    conf.consensus.payout_period = PayoutPeriod;
    conf.consensus.quorum_threshold = 100;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[1];

    // Create blocks until second payout block and make sure signatures are added for those who signed
    const target_height = Height(3 * PayoutPeriod);
    Height last_height = Height(0);
    iota(Height(PayoutPeriod), target_height + 1)
        .stride(Height(PayoutPeriod))
        .each!((Height h)
    {
        network.generateBlocks(h);
        retryFor(node_1.getBlocksFrom(h, 1).front.header.validators.setCount() == 6, 5.seconds,
            format!"First node failed to achieve desired signature count of %s at height %s"(6, h));
        network.assertSameBlocks(h, last_height + 1);
        last_height = h;
    });

    // No Coinbase until second payout period ends
    assert(node_1.getBlocksFrom(Height(PayoutPeriod), 1).front.txs.filter!(tx => tx.isCoinbase).empty);

    void assertPayout (Height height) // height is payout block with Coinbase tx
    {
        const firstBlock = Height(1 + height - (2 * PayoutPeriod));
        Amount val_payout = 0.coins;
        Amount commons_payout = 0.coins;
        Amount total_fees = 0.coins;

        node_1.getBlocksFrom(firstBlock, PayoutPeriod).takeExactly(PayoutPeriod).each!((block)
        {
            size_t txs_size = block.txs.filter!(tx => !tx.isCoinbase)
                .map!(tx => tx.sizeInBytes).sum();
            Amount fees = Amount(700) * txs_size;
            total_fees += fees;
            Amount validatorsFees = fees;
            assert(validatorsFees.percentage(ConsensusConfig.init.validator_tx_fee_cut));
            Amount val_fees = validatorsFees;
            val_fees.div(GenesisValidators);    // Change from this will go to Commons Budget
            commons_payout += CommonsReward + fees - (val_fees * GenesisValidators);
            val_payout += val_fees + ValReward;
        });

        auto cb_tx = node_1.getBlocksFrom(height, 1).front.txs.filter!(tx => tx.isCoinbase).front;
        // first check no rewards are lost
        assert(cb_tx.outputs.map!(o => o.value).sum() >= (ValRewards + CommonsReward) * PayoutPeriod);
        assert(cb_tx.outputs.walkLength == GenesisValidators + 1);
        // check no rewards or fees are lost
        assert(cb_tx.outputs.map!(o => o.value).sum() == (ValRewards + CommonsReward) * PayoutPeriod + total_fees);
        cb_tx.outputs.filter!(o => o.address() != WK.Keys.CommonsBudget.address)
            .each!(o => assert(o.value == val_payout));
        assert(cb_tx.outputs.filter!(o => o.address() == WK.Keys.CommonsBudget.address)
            .front.value == commons_payout);
    }

    // test the first two payout blocks
    iota(2 * PayoutPeriod, 3 * PayoutPeriod + 1, PayoutPeriod).each!(h => assertPayout(Height(h)));
}

/// node 0 will only sign even blocks
/// node 5 will be slashed for not revealing pre-images
unittest
{
    TestConf conf;
    conf.consensus.block_interval = BlockSecs.seconds;
    conf.consensus.payout_period = PayoutPeriod;
    auto network = makeTestNetwork!TestManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;
    auto node_1 = nodes[1];
    const activeValidators = 5;

    // Create blocks until third payout block and make sure signatures are added for those who signed
    const target_height = Height(3 * PayoutPeriod);
    Height last_height = Height(0);
    iota(Height(PayoutPeriod), target_height + 1)
        .stride(Height(PayoutPeriod))
        .each!((Height h)
    {
        network.generateBlocks(iota(activeValidators), h, true); // Don't include node 5
        // To ensure we have expected percentage of signatures at each height wait long enough for first node to have them
        auto required_sigs = (h % 2 == 0) ? 5 : 4;
        retryFor(node_1.getBlocksFrom(h, 1).front.header.validators.setCount() == required_sigs, 5.seconds,
            format!"First node failed to achieve desired signature count of %s at height %s"(required_sigs, h));
        last_height = h;
    });

    void assertPayout (Height height) // height is payout block with Coinbase tx
    {
        const firstBlock = Height(1 + height - (2 * PayoutPeriod));
        Amount val_payout_node0 = 0.coins;
        Amount val_payout_rest = 0.coins;
        Amount commons_payout = 0.coins;
        Amount total_fees = 0.coins;

        node_1.getBlocksFrom(firstBlock, PayoutPeriod).takeExactly(PayoutPeriod).each!((const(Block) block)
        {
            size_t txs_size = block.txs.filter!(tx => !tx.isCoinbase)
                .map!(tx => tx.sizeInBytes).sum();
            Amount fees = Amount(700) * txs_size;
            Amount validatorsFees = fees;
            total_fees += fees;
            assert(validatorsFees.percentage(ConsensusConfig.init.validator_tx_fee_cut));

            Amount val_fees = validatorsFees;

            auto slashed_penaly = 10_000.coins *
                block.header.preimages.enumerate.filter!(en => en.value is Hash.init).walkLength;
            total_fees += slashed_penaly;

            // Node 0 only signed half the blocks
            if (block.header.height % 2 == 0)
            {
                val_fees.div(activeValidators);
                Amount val_reward = 27.coins * FiveSecsPerBlock;
                val_reward.div(activeValidators); // div remainder goes to commons_payout
                Amount val_payout = val_fees + val_reward;
                val_payout_node0 += val_payout;
                val_payout_rest += val_payout;
                Amount leftover = ValRewards - (val_payout * activeValidators);
                commons_payout += CommonsReward + fees + leftover + slashed_penaly;
            } else
            {
                // For first block all nodes will be included but afterwards node 5 is slashed
                auto isHeight_1 = block.header.height == 1;
                ubyte signed_percent = 100 * (activeValidators - 1) / (isHeight_1 ? GenesisValidators : activeValidators);
                ubyte percentage_reward = cast(ubyte) (100 - 2 * (100 - signed_percent));
                assert(percentage_reward == isHeight_1 ? 32 : 60);
                Amount reduced_val_reward = 27.coins * FiveSecsPerBlock;
                reduced_val_reward.div(activeValidators - 1); // div remainder goes to commons_payout
                assert(reduced_val_reward.percentage(percentage_reward));
                val_fees.div(activeValidators - 1); // div remainder goes to commons_payout
                Amount val_payout = val_fees + reduced_val_reward;
                val_payout_rest += val_payout;
                Amount leftover = ValRewards - (val_payout * (activeValidators - 1));
                commons_payout += CommonsReward + fees + leftover + slashed_penaly;
            }
        });
        auto cb_tx = node_1.getBlocksFrom(height, 1).front.txs.filter!(tx => tx.isCoinbase).front;
        assert(cb_tx.outputs.map!(o => o.value).sum() >= (ValRewards + CommonsReward) * PayoutPeriod);
        assert(cb_tx.outputs.walkLength == activeValidators + 1);
        assert(cb_tx.outputs.map!(o => o.value).sum() == (ValRewards + CommonsReward) * PayoutPeriod + total_fees);
        assert(cb_tx.outputs.filter!(o => o.address() != WK.Keys.CommonsBudget.address)
            .map!(o => o.value).array == [ val_payout_rest, val_payout_rest, val_payout_node0,
                val_payout_rest, val_payout_rest]);
        assert(cb_tx.outputs.filter!(o => o.address() == WK.Keys.CommonsBudget.address)
            .front.value == commons_payout);
    }

    // test the first two payout blocks at heights 12 and 18
    iota(2 * PayoutPeriod, 3 * PayoutPeriod + 1, PayoutPeriod).each!(h => assertPayout(Height(h)));
}

private extern(C++) class EvenBlockHeightSignerNominator : Nominator
{
     extern(D) {
        mixin ForwardCtor!();
    }

    public override void valueExternalized (uint64_t slot_idx,
        ref const(Value) value) nothrow
    {
        // only sign even block heights
        if (slot_idx % 2 == 0)
            return super.valueExternalized(slot_idx, value);
    }
}

/// node which only signs even block heights
private class EvenBlockHeightSignerNode () : TestValidatorNode
{
    mixin ForwardCtor!();

    protected override EvenBlockHeightSignerNominator makeNominator (
        Parameters!(TestValidatorNode.makeNominator) args)
    {
        return new EvenBlockHeightSignerNominator(
            this.params, this.config.validator.key_pair, args,
            this.cacheDB, this.config.validator.nomination_interval,
            &this.acceptBlock);
    }
}

/// create node which only signs even blocks and a node that will be slashed for not revealing pre images
private class TestManager: TestAPIManager
{
    // Always `false`
    private shared bool neverRevealPreImage;

    ///
    public this (immutable(Block)[] blocks, TestConf test_conf, TimePoint genesis_start_time)
    {
        super(blocks, test_conf, genesis_start_time);
    }

    public override void createNewNode (Config conf,
        string file = __FILE__, int line = __LINE__)
    {
        if (this.nodes.length < 1)  // node 0 will only sign even blocks
        {
            assert(conf.validator.enabled);
            this.addNewNode!(EvenBlockHeightSignerNode!())(conf, file, line);
        } else if (this.nodes.length == 5) // node 5 will never reveal preimages
        {
            assert(conf.validator.enabled);
            this.addNewNode!NoPreImageVN(conf, &this.neverRevealPreImage, file, line);
        }
        else
            super.createNewNode(conf, file, line);
    }
}
