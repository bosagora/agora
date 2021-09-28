/*******************************************************************************

    Contains functions to calculate the block reward.

    Block rewards are given to validators for verifying transactions and signing
    blocks. This serves as an incentive for coin holders to participate in the
    network as validators. The more active validators the network has, the more
    signatures are on the blocks, and ultimately the more secure the overall
    network is.

    Block rewards are also sent to the Commons Budget address for the first
    6.7 years. After that period, the Commons Budget will be funded only from
    the transaction and data fees.

    Here are some finer details of the block reward calculation:

    $(UL
    $(LI Block rewards, along with transaction and data fees, will be
    distributed in a `Coinbase transaction` which will be added to a block's
    transaction set at the end of each payout period.)

    $(LI The distribution of the block rewards and fees will be delayed by one
    payout period, so that enough time is given to validators to share block
    signatures.)

    $(LI Each validator will be rewarded based on the percentage of the
    actual / maximum possible block signatures for the payout period.)

    $(LI The total block reward for a particular height is fixed, however this
    doesn't mean that the total validator reward is fixed. The total validator
    reward is based on the total number of signatures on the blocks in question.
    The total validator reward is reduced using a multiplier function of the
    missing signatures, meaning that the more that are missing the higher the
    penalty per missing signature. This is to encourage validators to share
    signatures.
    The coins remaining will go to the Commons Budget.
    i.e. `fixed block reward at height X - total validator reward`)

    $(LI The part of the total validator reward that cannot be divived equally
    between the validators will also go to the Commons Budget.)

    )

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Reward;

import agora.common.Amount;
import agora.common.Ensure;
import agora.common.Types;
import agora.utils.Log;

import core.time;

import std.algorithm;
import std.array;
import std.format;
import std.math;
import std.range;

/// struct to return the calculated block rewards for the `Validators` and the
/// `Commons Budget`
public struct BlockRewards
{
    public Amount validator_rewards;
    public Amount commons_budget_rewards;
}

/// number of seconds in a year of 365 days
private const ulong yearOfSecs = 365 * 24 * 60 * 60;

/// As defined in the Whitepaper: 27 coins every 5 seconds for first year (in Coin units)
private const ulong firstYearValRewards = 27 * (yearOfSecs / 5) * 10_000_000L;

/*******************************************************************************

    Calculate Block Rewards for `Validators` and `Commons Budget`

*******************************************************************************/

public class Reward
{
    private Logger log;

    /// As defined in the Whitepaper this is the total rewards to be sent to
    /// Commons Budget over about 6.7 years
    private const Amount totalCommonsBudgetRewards = 1_800_000_000.coins;

    /// As defined in the Whitepaper this is the total rewards allocated to be
    /// distributed to all the Validators over about 128 years
    private const Amount totalValRewards = 2_700_000_000.coins;

    /// Every 5 secs 50 coins are rewarded equals 10 per second (Block interval of 600 secs)
    private const Amount commonsCoinsPerBlock = 6000.coins;

    /// Number of blocks that rewards are paid for each payout (also the interval for payments)
    private uint payout_period;

    /// Duration of a block in seconds
    private ulong block_interval_sec;

    /// Number of blocks per year
    private ulong blocks_per_year;

    /***************************************************************************

        Construct `Reward` object which encapsulates block reward calculations.

        Params:
            payout_period = how many blocks are included for a reward payout
            block_interval_sec = time span for each block

    ***************************************************************************/

    public this (in uint payout_period, in Duration block_interval)
    {
        this.log = Logger(__MODULE__);

        this.payout_period = payout_period;
        this.block_interval_sec = block_interval.total!"seconds";

        // Calculate expected blocks per year from block interval
        this.blocks_per_year = yearOfSecs / this.block_interval_sec;
    }

    /***************************************************************************

        Returns the Block Rewards for the given height.

        Params:
            height = height of block for payout
            percent_signed = (#actual signatures / #expected signatures) * 100

        Returns:
            `BlockRewards` which indicates the `Amount` to pay the `Validators`
            and the `Commons Budget`

    ***************************************************************************/

    public BlockRewards calculateBlockRewards (in Height height, in ubyte percent_signed) nothrow @safe
    {
        assert(height > 0, "We can not payout in Genesis block");

        auto validator_allocated = allocatedValRewards(height);
        auto validator = reducedValRewards(validator_allocated, percent_signed);

        // First initialize penalty as allocated and then subtract what is validator actual rewards
        auto penalty = validator_allocated;
        if (!penalty.sub(validator))
            assert(0, format!"Failed to subtract Amount %s from %s"(validator, penalty));

        // First initialize commons as allocated Commons Budget rewards and then
        // add the penalty deducted from the Validator rewards
        auto commons = commonsBudgetRewards(height);
        if (!commons.add(penalty))
            assert(0, format!"Failed to add Amount %s to %s"(penalty, commons));

        return BlockRewards(validator, commons);
    }

    /***************************************************************************

        Returns the Commons Budget reward as defined in the Whitepaper.

        Params:
            height = block height for reward

        Returns:
            Reward amount

    ***************************************************************************/

    private Amount commonsBudgetRewards (in Height height) nothrow @safe
    {
        // Calculate maximum height we will payout from 1.8 billion allocation
        // Using tupleOf trick to access private ulong value for calculation
        auto max_height = this.totalCommonsBudgetRewards.tupleof[0]
                / this.commonsCoinsPerBlock.tupleof[0];

        // Allocated rewards for Commons Budget are limited
        if (height > max_height)
            return 0.coins;

        return this.commonsCoinsPerBlock;
    }

    /***************************************************************************

        Returns the total allocated whitepaper validator reward.

        Params:
            height = block height for reward

        Returns:
            validator reward

    ***************************************************************************/

    private Amount allocatedValRewards (in Height height) nothrow @safe
    {
        // we use previous block height to only reduce after last payment of year
        ulong payoutYear = (this.block_interval_sec * (height - 1)) / yearOfSecs;

        // Initially set to first year in coin units and doing the maths using ulong
        ulong reward_value = firstYearValRewards;

        // Apply the yearly reduction of 6.31% of rewards to Validators
        iota(payoutYear).each!((ulong y)
        {
            // Reduction of 6.31%
            //  == multiply by 93.69%
            //  == multiply by 9369 then divide by 1000
            // This is done to minimize losses when calculating as we are using ulong not double
            reward_value = (reward_value * 9_369) / 10_000;

            log.trace("allocatedValRewards(height={}): Reduced by 6.31%. Yearly is {} for year {}",
                height, reward_value, y + 2);
        });
        // Now divide this year's reward by number of blocks in a year
        reward_value = reward_value / this.blocks_per_year;

        Amount reward = Amount(reward_value);
        log.trace("allocatedValRewards(height={}): reward is {}", height, reward_value);
        assert(reward.isValid);

        return reward;
    }

    /***************************************************************************

        Returns the total validator reward after applying the penalty for
        missing signatures.

        Params:
            total_allocated = allocated `Amount` to pay the Validators if all
                have signed the block
            percent_signed = (#actual signatures / #expected signatures) * 100

        Returns:
            validator reward adjusted if there are missing signatures

    ***************************************************************************/

    private Amount reducedValRewards (in Amount total_allocated, ubyte percent_signed) nothrow @safe
    {
        assert(percent_signed >= 0 && percent_signed <= 100);
        if (percent_signed < 50)
        {
            log.info("Less than 50% signatures for payout period. The validators will get no rewards this payout!");
            return 0.coins;
        }
        Amount actual = total_allocated;

        if (percent_signed < 100)
        {
            ulong payout_percent = 100 - 2 * (100 - percent_signed); // penalty of `y = 2x`

            if (!actual.percentage(cast(ubyte) payout_percent))
                assert(0, format!"Failed to get percentage %s of Amount %s"(payout_percent, actual));

            log.info("Reduced validator reward is: {} as only {}% signed this block", actual, percent_signed);
            assert(actual.isValid());
        }

        return actual;
    }
}

version (unittest):

// Some Whitepaper constants for Validator payouts
// These values are actually very slightly different from those in appendix
//  5 of the whitepaper. The precision used here is of 10 million coin units
//  whereas the values in the Whitepaper are calculated using double precision.
private const ulong valYear1 = 170_294_400_0000_000;
private const ulong valYear2 = 159_548_823_3600_000;
private const ulong valYear3 = 149_481_292_6059_840;
private const ulong valYear10 = 94_719_526_2704_661;
private const ulong valYear50 = 6_985_042_8604_198;


/// Testing rewards to `Commons Budget` which is always the same until the allocated funds run out
unittest
{
    auto reward = new Reward(144, 600.seconds);

    // first payout block
    assert(reward.commonsBudgetRewards(Height(1)) == 6_000.coins);

    // second payout block
    assert(reward.commonsBudgetRewards(Height(2)) == 6_000.coins);

    // payout block in second year
    assert(reward.commonsBudgetRewards(Height(reward.blocks_per_year + 1)) == 6_000.coins);

    // payout block in 6th year
    assert(reward.commonsBudgetRewards(Height(5 * reward.blocks_per_year + 1)) == 6_000.coins);

    // last payout block
    const ulong totalCommonsPayouts = 1_800_000_000 / 6000;
    assert(reward.commonsBudgetRewards(Height(totalCommonsPayouts)) == 6_000.coins);

    // one after last payout block should be zero
    assert(reward.commonsBudgetRewards(Height(totalCommonsPayouts + 1)) == 0.coins);

    // one way after last payout block should also be zero
    assert(reward.commonsBudgetRewards(Height(10 * reward.blocks_per_year)) == 0.coins);
}

/// Testing total reward allocated to validators
unittest
{

    auto reward = new Reward(144, 600.seconds);

    assert(yearOfSecs == 31_536_000);
    // 27 coins every 5 seconds for one year
    const Amount firstYear = (27 * yearOfSecs / 5).coins;
    assert(firstYear.tupleof[0] == firstYearValRewards);
    Amount a = Amount(firstYearValRewards);
    assert(firstYearValRewards == valYear1);

    // first payout block
    assert(reward.allocatedValRewards(Height(1)) == Amount(valYear1 / reward.blocks_per_year));

    // second payout block
    assert(reward.allocatedValRewards(Height(2)) == Amount(valYear1 / reward.blocks_per_year));

    // last payout block of first year
    assert(reward.allocatedValRewards(Height(reward.blocks_per_year)) == Amount(valYear1 / reward.blocks_per_year));

    // first payout block of second year
    assert(reward.allocatedValRewards(Height(reward.blocks_per_year + 1)) == Amount(valYear2 / reward.blocks_per_year));

    // last payout block of second year
    assert(reward.allocatedValRewards(Height(2 * reward.blocks_per_year)) == Amount(valYear2 / reward.blocks_per_year));

    // first payout block of third year
    assert(reward.allocatedValRewards(Height(2 * reward.blocks_per_year) + 1) == Amount(valYear3 / reward.blocks_per_year));

    // first payout block of tenth year
    assert(reward.allocatedValRewards(Height(9 * reward.blocks_per_year) + 1) == Amount(valYear10 / reward.blocks_per_year));

    // first payout block of year 50
    assert(reward.allocatedValRewards(Height(49 * reward.blocks_per_year) + 1) == Amount(valYear50 / reward.blocks_per_year));
}

/// Testing reduced reward payout to validators
unittest
{
    auto reward = new Reward(144, 600.seconds);

    // 100% of the validators sign then full reward is paid to Validators
    assert(reward.reducedValRewards(1_200.coins, 100) == 1_200.coins);

    // 1% missing then penalty is 2%
    assert(reward.reducedValRewards(1_200.coins, 99) == 1_176.coins);

    // 2% missing then penalty is 4%
    assert(reward.reducedValRewards(1_200.coins, 98) == 1_152.coins);

    // 10% missing then penalty is 20%
    assert(reward.reducedValRewards(1_200.coins, 90) == 960.coins);

    // 25% missing then penalty is 50%
    assert(reward.reducedValRewards(1_200.coins, 75) == 600.coins);

    // 49% missing then penalty is 98%
    assert(reward.reducedValRewards(1_200.coins, 51) == 24.coins);

    // 50 percent signed then no reward is paid to Validators
    assert(reward.reducedValRewards(1_200.coins, 50) == 0.coins);

    // less than half sign also no reward is paid to Validators
    assert(reward.reducedValRewards(1_200.coins, 49) == 0.coins);
}

/// Testing Block Rewards payout to validators and Commons Budget
unittest
{
    auto reward = new Reward(144, 600.seconds);

    // First payout block, all signed
    assert(reward.calculateBlockRewards(Height(1), 100) == BlockRewards(Amount(valYear1 / reward.blocks_per_year), 6_000.coins));

    // First payout block, 75% signed means 25% missing so penalty is 50%
    auto adjusted = Amount(valYear1 / reward.blocks_per_year / 2);
    assert(reward.calculateBlockRewards(Height(1), 75) == BlockRewards(adjusted, 6_000.coins + adjusted));

    // last payout block of first year, all signed
    assert(reward.calculateBlockRewards(Height(reward.blocks_per_year), 100) == BlockRewards(Amount(valYear1 / reward.blocks_per_year), 6_000.coins));

    // first payout block of second year with all signed
    assert(reward.calculateBlockRewards(Height(reward.blocks_per_year + 1), 100) == BlockRewards(Amount(valYear2 / reward.blocks_per_year), 6_000.coins));

    // first payout block of second year with 98% signed means 4% reduction for validators which is added to Commons
    assert(reward.calculateBlockRewards(Height(reward.blocks_per_year + 1), 98) == BlockRewards(Amount((valYear2 / reward.blocks_per_year) * 96 / 100),
        6_000.coins + (Amount((valYear2 / reward.blocks_per_year) * 4 / 100))));

    // first payout block of year 50 with all signed
    assert(reward.calculateBlockRewards(Height(49 * reward.blocks_per_year + 1), 100) == BlockRewards(Amount(valYear50 / reward.blocks_per_year), 0.coins));
}
