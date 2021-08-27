/*******************************************************************************

    Contains functions to calculate the block reward.

    Block reward are given to validators for the first 128 years for verifying
    transactions and signing blocks. This serves as an incentive for coin
    holders to participate in the network as validators. The more active
    validators the network has, the more signatures are on the blocks, and
    ultimately the more secure the overall network is.

    Block reward is also sent to the Commons Budget address for the first
    6.7 years. After that period, the Commons Budget projects will be funded
    from the transaction fees.

    Here are some finer details of the block reward calculation

    $(UL

    $(LI Block rewards will be distributed in every Coinbase payout block which
    is also used to payout the transaction fees and data fees.)

    $(LI The distribution of the block rewards will be delayed by one payout
    period as is the case for fees. The rational behind this is that enough
    time must be given to validators to share block signatures.)

    $(LI Each validator will be rewarded based on the percentage of the
    actual / maximum possible block signatures for the payout period.)

    $(LI The total block reward for a particular height is fixed, however this
    doesn't mean that the total validator reward is fixed. The total validator
    reward is based on the total number of signatures on the blocks in question.
    The total validator reward is a nonlinear function of the the total
    signatures, meaning that half the number of signatures will decrease the
    validator reward by a factor of 4. This is to encourage validators to share
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
import agora.common.Types;
import agora.utils.Log;


import std.algorithm;
import std.array;
import std.math;
import std.range;

mixin AddLogger!();

///
public class Reward
{
    private const YearOfSecs = 365 * 24 * 60 * 60;

    /// As defined in the Whitepaper this is the total rewards to be sent to
    /// Commons Budget over about 6.7 years
    private const Amount totalCommonsBudgetRewards = 1_800_000_000.coins;

    /// As defined in the Whitepaper this is the total rewards allocated to be
    /// distributed to all the Validators over about 128 years
    private const Amount totalValidatorRewards = 2_700_000_000.coins;

    /// Every 5 secs 50 coins are rewarded equals 10 per second (Block interval of 600 secs)
    private const Amount commonsBudgetCoinsPerBlock = 6000.coins;

    /// Factors for reward reduction function f(x) = b*e^(a*x) + c
    private immutable double block_reward_factor_a = 0.046;
    private immutable double block_reward_factor_b = 1;
    private immutable double block_reward_factor_c = 1;

    private uint payout_period;
    private uint block_interval_sec;

    public this (in uint payout_period = 144, in uint block_interval_sec = 600)
    {
        this.payout_period = payout_period;
        this.block_interval_sec = block_interval_sec;
    }

    /***************************************************************************

        Returns the total whitepaper validator reward.

        Params:
            height = block height that will contain the CoinBase transaction

        Returns:
            validator whitepaper reward

    ***************************************************************************/

    public Amount totalValidatorReward (in Height height) const @safe nothrow
    {
        assert(height % this.payout_period == 0, "This is not a payout block height");
        assert (height >= 2 * this.payout_period,
            "We can not payout before the end of the second period");
        const payouts = height / this.payout_period;
        const payoutYear = this.block_interval_sec * height / YearOfSecs;
        auto yearly_rewards = 27 * YearOfSecs / 5;
        iota(payoutYear).each!((y)
        {
            yearly_rewards -= yearly_rewards * 0.0631;
            log.trace("totalValidatorReward: Reduce yearly payout by 6.31%. Rewards for year {} is {}",
                y, yearly_rewards);
        });
        return Amount(yearly_rewards).div(YearOfSecs / (this.payout_period * this.block_interval_sec));
    }

    /***************************************************************************

        Returns the total validator reward after applying the penalty for
        missing signatures.

        Params:
            signatures = (#actual signatures / #expected signatures) * 100
                          on all the blocks for payout period

        Returns:
            validator reward - penalty on validators due to missing signature

    ***************************************************************************/

    public Amount reducedValidatorReward (in Amount total_validator_reward, double comply_perc) const @safe nothrow
    {
        if (comply_perc < 50)
        {
            log.error("Less than 50% signatures for payout period. The validators will get no rewards this payout!");
            return 0.coins;
        }
        ushort reduce_perc = cast(ushort) round(
            this.block_reward_factor_b * exp(comply_perc * this.block_reward_factor_a) + this.block_reward_factor_c);
        ushort hundred = 100;
        if (reduce_perc == hundred)
            return total_validator_reward;
        Amount actual_validator_reward = total_validator_reward;
        ushort percent = cast(ushort) (hundred - reduce_perc);
        actual_validator_reward.percentage(percent);
        log.trace("Reduced validator reward is: {}", actual_validator_reward);
        assert(actual_validator_reward.isValid());

        return actual_validator_reward;
    }

    /***************************************************************************

        Returns the Commons Budget reward as defined in the Whitepaper.

        Params:
            height = block height of coinbase payout block

        Returns:
            Reward amount

    ***************************************************************************/

    public Amount commonsBudgetReward (in Height height) const @safe nothrow
    {
        assert(height % this.payout_period == 0, "This is not a payout block height");
        assert (height >= 2 * this.payout_period,
            "We can not payout before the end of the second period");

        Amount rewards_till_now = this.commonsBudgetCoinsPerBlock;
        rewards_till_now.mul(height - 2 * this.payout_period);
        if (rewards_till_now >= this.totalCommonsBudgetRewards)
        {
            log.trace("No more rewards for Commons Budget");
            return 0.coins;
        }
        Amount coinsPerPayoutPeriod = this.commonsBudgetCoinsPerBlock;
        coinsPerPayoutPeriod.mul(this.payout_period);
        Amount remainder = totalCommonsBudgetRewards;
        remainder.sub(rewards_till_now);
        return min(remainder, coinsPerPayoutPeriod);
    }
}

unittest
{
    auto reward = new Reward();
    // 100 percent of the validators comply with the consensus rules
    assert(Amount(600) == reward.reducedValidatorReward(Amount(1200), 100));

    // 50 percent of the validators comply with the consensus rules
    assert(Amount(66) == reward.reducedValidatorReward(Amount(1200), 50));
}
