/*******************************************************************************

    Contains the function to calculate the fees and stores the results in a db.

    Fees are the sum of output values minus the sum of input values.
    We store the calculated fees after each block is externalized as we have all
    the inputs available in the UTXO set at that time.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Fee;

import agora.common.Types;
import agora.common.Amount;
import agora.common.Ensure;
import agora.common.ManagedDatabase;
import agora.consensus.data.Block;
import agora.consensus.data.Params;
import agora.consensus.data.Transaction;
import agora.consensus.data.UTXO;
import agora.consensus.data.ValidatorInfo;
import agora.consensus.Reward;
import agora.consensus.state.UTXOCache;
import agora.crypto.Key;

import std.math;
import std.algorithm;
import std.array;
import std.format;
import std.range;

/// Delegate to check data payload
public alias FeeChecker = string delegate (in Transaction tx,
    Amount sum_unspent) nothrow @safe;

/*******************************************************************************

    Calculates the fee of transaction data to store

    Params:
        data_size = The size of the data
        factor = The factor to calculate for the fee of transaction data

    Returns:
        A fee payable to data storage

*******************************************************************************/

public Amount calculateDataFee (ulong data_size, uint factor) pure nothrow @safe @nogc
{
    const ulong decimal = 100L;
    ulong fee = cast(ulong)(
        round(
            (
                exp((cast(double)data_size / cast(double)factor)) -
                1.0
            ) *
            decimal
        ) * 10_000_000L / decimal

    );
    return Amount(fee);
}

// Test for calculating a fee to store data
unittest
{
    // When the factor is 100
    assert(calculateDataFee(0, 100) == Amount(0L));
    assert(calculateDataFee(10, 100) == Amount(1_100_000L));
    assert(calculateDataFee(20, 100) == Amount(2_200_000L));
    assert(calculateDataFee(30, 100) == Amount(3_500_000L));
    assert(calculateDataFee(40, 100) == Amount(4_900_000L));
    assert(calculateDataFee(50, 100) == Amount(6_500_000L));
    assert(calculateDataFee(60, 100) == Amount(8_200_000L));
    assert(calculateDataFee(70, 100) == Amount(10_100_000L));
    assert(calculateDataFee(80, 100) == Amount(12_300_000L));
    assert(calculateDataFee(90, 100) == Amount(14_600_000L));
    assert(calculateDataFee(100, 100) == Amount(17_200_000L));
    assert(calculateDataFee(110, 100) == Amount(20_000_000L));
    assert(calculateDataFee(120, 100) == Amount(23_200_000L));
    assert(calculateDataFee(130, 100) == Amount(26_700_000L));
    assert(calculateDataFee(140, 100) == Amount(30_600_000L));
    assert(calculateDataFee(150, 100) == Amount(34_800_000L));
    assert(calculateDataFee(160, 100) == Amount(39_500_000L));
    assert(calculateDataFee(170, 100) == Amount(44_700_000L));
    assert(calculateDataFee(180, 100) == Amount(50_500_000L));
    assert(calculateDataFee(190, 100) == Amount(56_900_000L));
    assert(calculateDataFee(200, 100) == Amount(63_900_000L));
    assert(calculateDataFee(210, 100) == Amount(71_700_000L));
    assert(calculateDataFee(220, 100) == Amount(80_300_000L));
    assert(calculateDataFee(230, 100) == Amount(89_700_000L));
    assert(calculateDataFee(240, 100) == Amount(100_200_000L));
    assert(calculateDataFee(250, 100) == Amount(111_800_000L));
    assert(calculateDataFee(260, 100) == Amount(124_600_000L));
    assert(calculateDataFee(270, 100) == Amount(138_800_000L));
    assert(calculateDataFee(280, 100) == Amount(154_400_000L));
    assert(calculateDataFee(290, 100) == Amount(171_700_000L));
    assert(calculateDataFee(300, 100) == Amount(190_900_000L));
    assert(calculateDataFee(310, 100) == Amount(212_000_000L));
    assert(calculateDataFee(320, 100) == Amount(235_300_000L));
    assert(calculateDataFee(330, 100) == Amount(261_100_000L));
    assert(calculateDataFee(340, 100) == Amount(289_600_000L));
    assert(calculateDataFee(350, 100) == Amount(321_200_000L));
    assert(calculateDataFee(360, 100) == Amount(356_000_000L));
    assert(calculateDataFee(370, 100) == Amount(394_500_000L));
    assert(calculateDataFee(380, 100) == Amount(437_000_000L));
    assert(calculateDataFee(390, 100) == Amount(484_000_000L));
    assert(calculateDataFee(400, 100) == Amount(536_000_000L));
    assert(calculateDataFee(410, 100) == Amount(593_400_000L));
    assert(calculateDataFee(420, 100) == Amount(656_900_000L));
    assert(calculateDataFee(430, 100) == Amount(727_000_000L));
    assert(calculateDataFee(440, 100) == Amount(804_500_000L));
    assert(calculateDataFee(450, 100) == Amount(890_200_000L));
    assert(calculateDataFee(460, 100) == Amount(984_800_000L));
    assert(calculateDataFee(470, 100) == Amount(108_9500_000L));
    assert(calculateDataFee(480, 100) == Amount(1_205_100_000L));
    assert(calculateDataFee(490, 100) == Amount(1_332_900_000L));
    assert(calculateDataFee(500, 100) == Amount(1_474_100_000L));

    // When the factor is 200
    assert(calculateDataFee(0, 200) == Amount(0L));
    assert(calculateDataFee(10, 200) == Amount(500_000L));
    assert(calculateDataFee(20, 200) == Amount(1_100_000L));
    assert(calculateDataFee(30, 200) == Amount(1_600_000L));
    assert(calculateDataFee(40, 200) == Amount(2_200_000L));
    assert(calculateDataFee(50, 200) == Amount(2_800_000L));
    assert(calculateDataFee(60, 200) == Amount(3_500_000L));
    assert(calculateDataFee(70, 200) == Amount(4_200_000L));
    assert(calculateDataFee(80, 200) == Amount(4_900_000L));
    assert(calculateDataFee(90, 200) == Amount(5_700_000L));
    assert(calculateDataFee(100, 200) == Amount(6_500_000L));
    assert(calculateDataFee(110, 200) == Amount(7_300_000L));
    assert(calculateDataFee(120, 200) == Amount(8_200_000L));
    assert(calculateDataFee(130, 200) == Amount(9_200_000L));
    assert(calculateDataFee(140, 200) == Amount(10_100_000L));
    assert(calculateDataFee(150, 200) == Amount(11_200_000L));
    assert(calculateDataFee(160, 200) == Amount(12_300_000L));
    assert(calculateDataFee(170, 200) == Amount(13_400_000L));
    assert(calculateDataFee(180, 200) == Amount(14_600_000L));
    assert(calculateDataFee(190, 200) == Amount(15_900_000L));
    assert(calculateDataFee(200, 200) == Amount(17_200_000L));
    assert(calculateDataFee(210, 200) == Amount(18_600_000L));
    assert(calculateDataFee(220, 200) == Amount(20_000_000L));
    assert(calculateDataFee(230, 200) == Amount(21_600_000L));
    assert(calculateDataFee(240, 200) == Amount(23_200_000L));
    assert(calculateDataFee(250, 200) == Amount(24_900_000L));
    assert(calculateDataFee(260, 200) == Amount(26_700_000L));
    assert(calculateDataFee(270, 200) == Amount(28_600_000L));
    assert(calculateDataFee(280, 200) == Amount(30_600_000L));
    assert(calculateDataFee(290, 200) == Amount(32_600_000L));
    assert(calculateDataFee(300, 200) == Amount(34_800_000L));
    assert(calculateDataFee(310, 200) == Amount(37_100_000L));
    assert(calculateDataFee(320, 200) == Amount(39_500_000L));
    assert(calculateDataFee(330, 200) == Amount(42_100_000L));
    assert(calculateDataFee(340, 200) == Amount(44_700_000L));
    assert(calculateDataFee(350, 200) == Amount(47_500_000L));
    assert(calculateDataFee(360, 200) == Amount(50_500_000L));
    assert(calculateDataFee(370, 200) == Amount(53_600_000L));
    assert(calculateDataFee(380, 200) == Amount(56_900_000L));
    assert(calculateDataFee(390, 200) == Amount(60_300_000L));
    assert(calculateDataFee(400, 200) == Amount(63_900_000L));
    assert(calculateDataFee(410, 200) == Amount(67_700_000L));
    assert(calculateDataFee(420, 200) == Amount(71_700_000L));
    assert(calculateDataFee(430, 200) == Amount(75_800_000L));
    assert(calculateDataFee(440, 200) == Amount(80_300_000L));
    assert(calculateDataFee(450, 200) == Amount(84_900_000L));
    assert(calculateDataFee(460, 200) == Amount(89_700_000L));
    assert(calculateDataFee(470, 200) == Amount(94_900_000L));
    assert(calculateDataFee(480, 200) == Amount(10_020_0000L));
    assert(calculateDataFee(490, 200) == Amount(105_900_000L));
    assert(calculateDataFee(500, 200) == Amount(111_800_000L));
}

/*******************************************************************************

    A class that provides the ability to verify the `payload` field stored
    in a `Transaction`.

*******************************************************************************/

public class FeeManager
{
    /// SQLite db instance
    private ManagedDatabase db;

    /// Parameters for consensus-critical constants
    public immutable(ConsensusParams) params;

    /// Block fees at each height
    private Amount[Height] block_fees;

    /// Block data fees at each height
    private Amount[Height] block_data_fees;

    /// Ctor
    public this (ManagedDatabase db, immutable(ConsensusParams) params)
    {
        this.db = db;
        this.params = params;
        this.init();
    }

    /// Init DB and rebuild the in-memory state
    private void init ()
    {
        this.db.execute("CREATE TABLE IF NOT EXISTS block_fees " ~
            "(height INTEGER, fee INTEGER, data_fee INTEGER)");

        auto results = this.db.execute("SELECT height, fee, data_fee FROM block_fees");

        foreach (ref row; results)
        {
            const height = Height(row.peek!(ulong)(0));
            const fee = Amount(row.peek!(ulong)(1));
            const data_fee = Amount(row.peek!(ulong)(2));
            this.block_fees[height] = fee;
            this.block_data_fees[height] = data_fee;
        }
    }

    /***************************************************************************

        Checks the given transaction has the required fees

        The transaction fees must be sufficient to pay the data payload fee and
        also the minimum fee for the size of the transaction. The size of the
        data payload is also checked to be less than maximum allowed.

        Params:
            tx = `Transaction`
            tx_fee = transaction fee

        Return:
            `null` if the transaction is valid otherwise a string explaining the
            reason it is not.

    ***************************************************************************/

    public string check (in Transaction tx, Amount tx_fee) nothrow @safe
    {
        Amount minimumFee = params.MinFee;
        if (!minimumFee.mul(tx.sizeInBytes()))
            return "Fee: Transaction size overflows fee cap";
        if (tx_fee < minimumFee)
            return "Transaction: Fee rate is less than minimum";

        if (tx.payload.length == 0)
            return null;

        if (tx.payload.length > this.params.TxPayloadMaxSize)
            return "Transaction: The size of the data payload is too large";

        auto required_fee = calculateDataFee(tx.payload.length,
            this.params.TxPayloadFeeFactor);

        if (!required_fee.isValid)
            return "The data fee is more than maximum Amount allowed";

        if (!required_fee.add(minimumFee))
            return "The sum of minimum fee and data fee is more than maximum Amount allowed";

        if (tx_fee < required_fee)
            return "Transaction: There is not enough data fee";

        return null;
    }

    /// Calculates the fee of data payloads
    public Amount getDataFee (ulong data_size) pure nothrow @safe @nogc
    {
        return calculateDataFee(data_size, this.params.TxPayloadFeeFactor);
    }

    /***************************************************************************

        Calculate the `Amount` of fees that should be paid to each
        Validator for the given block height

        The actual payment height which contains the Coinbase tx will be the
        height of the last block in the next payout period.

        Params:
            height = reward and fees are for this block height
            validators = enrolled Validators who signed the block

        Return:
            `Amount` of fees that should be paid to each Validator

    ***************************************************************************/

    public Amount[] getValidatorPayouts (Height height, ValidatorInfo[] validators) @safe
    {
        import std.numeric : gcd;
        // no stakes, no fees
        if (validators.length == 0)
            return [];

        // tx_fees = (tot_fee - tot_data_fee) * (ValidatorTXFeeCut / 100)
        Amount tx_fees = this.block_fees.get(height, 0.coins);
        tx_fees -= this.block_data_fees.get(height, 0.coins);
        tx_fees.percentage(this.params.ValidatorTXFeeCut);

        // A Validator with MinFreezeAmount of coins staked will get 100 "shares"
        // this fixes the stake amount that is needed to get a share
        Amount share_stake = Amount.MinFreezeAmount;
        share_stake.div(100);
        // this will ignore any remaning part of the stake that is not worth a share
        auto shares = validators.map!(val => val.stake.count(share_stake));
        auto shares_gcd = shares.fold!((a, b) => gcd(a,b));
        auto normalized_shares = shares.map!(share => share / shares_gcd);

        // tx_fees now equals "share value", which is the amount each share will get
        // Ignore remainder as any left over after `Validator` payouts goes to `Commons Budget`
        tx_fees.div(normalized_shares.sum());

        Amount[] validator_fees;
        foreach (share; normalized_shares)
        {
            auto validator_fee = tx_fees;
            if (!validator_fee.mul(share))
                assert(0, "getValidatorPayouts: Overflow when multiplying validator fee with share");
            validator_fees ~= validator_fee;
        }
        return validator_fees;
    }

    /***************************************************************************

        Calculate the `Amount` of fees that should be paid to
        `CommonsBudgetAddress`

        First we sum up all the rewards and fees to be made to both `Validators`
        and `Commons Budget`. Next we subtract the payouts to each `Validator`.
        Finally we return what ever if left. This means any change due to
        divisions is donated to the `Commons Budget` to prevent loss of coins.

        Params:
            height = reward and fees are for this block height
            validator_payouts = payouts to Validators for given height

        Return:
            `Amount` of fees that should be paid to `CommonsBudgetAddress`

    ***************************************************************************/

    public Amount getCommonsBudgetPayout (Height height, in Amount[] validator_payouts) @safe
    {
        // Initailize total with block fees
        Amount total_payout = this.block_fees.get(height, 0.coins);

        // Subtract each validator payout
        validator_payouts.each!((payout)
        {
            if (!total_payout.sub(payout))
                assert(0, "getCommonsBudgetPayout: Failed to subtract validator payout");
        });
        return total_payout;
    }

    /***************************************************************************

        Calculate the `Amount` of fees included in a block's transaction set

        Params:
            block = Block to calculate the fees
            peekUTXO = delegate to find the UTXOs

        Return:
            `Amount` of fees that should be paid to each Validator

    ***************************************************************************/

    public void storeBlockFees (in Block block, scope UTXOFinder peekUTXO)
    @trusted
    {
        if (block.header.height == 0) // No fees for Genesis Block
            return;

        Amount txs_fees;
        Amount txs_data_fees;
        this.getTXSetFees(block.txs, peekUTXO, txs_fees, txs_data_fees);

        this.block_fees[block.header.height] = txs_fees;
        this.block_data_fees[block.header.height] = txs_data_fees;
        this.db.execute(
                "REPLACE INTO block_fees (height, fee, data_fee) VALUES (?, ?, ?)",
                block.header.height, txs_fees, txs_data_fees);
    }

    /***************************************************************************

        Returns the total `Amount` of fees in the transaction set of a block

        This includes any `data_fees` which are based on the size of the
        `payload` in a `Transaction`.
        The transaction fee rate is calculated after the data fee is subtracted
        from the total fees, which is `sum of transactions input values`
        minus `sum of output values`.

        Params:
            height = height of block

        Return:
            `Amount` of fees included at given height

    ***************************************************************************/

    public Amount getBlockFees (in Height height) @safe
    {
        return this.block_fees.get(height, 0.coins);
    }

    /***************************************************************************

        Returns the `Amount` of data fees included in the transaction set of a
        block

        Params:
            height = height of block

        Return:
            `Amount` of data fees required at given height

    ***************************************************************************/

    public Amount getBlockDataFees (in Height height) @safe
    {
        return this.block_data_fees.get(height, 0.coins);
    }

    /***************************************************************************

        Clear stored fees for heights already paid

        This removes the records from the database and also `this.block_fees`

        Params:
            height = height of last block in the paid out period

    ***************************************************************************/

    public void clearBlockFeesBefore (in Height height) nothrow @trusted
    {
        try
        {
            const firstHeight = height - this.params.PayoutPeriod;
            this.db.execute("DELETE FROM block_fees where height <= ?", height);
            iota(firstHeight, height + 1)
                .map!(h => Height(h)).each!((Height h)
                    {
                        this.block_fees.remove(h);
                        this.block_data_fees.remove(h);
                    }
                );
        }
        catch (Exception e)
        {
            assert(0, e.msg); // Should never happen
        }
    }

    /***************************************************************************

        Calculate the transaction fee rate.

        This calculates the fee rate of the transaction, and can be used to
        compare two transactions for inclusion in a block / pool eviction.
        If the fee is not an exact multiplicator of the tx size,
        the remainder will be ignored.

        Params:
            tx = transaction for which we want to calculate the fee rate
            peekUTXO = UTXO finder (with or without replay protection)
            rate = The effective fee rate of this transaction

        Returns: string describing the error, if an error happened, null otherwise

    ***************************************************************************/

    public string getTxFeeRate (in Transaction tx, scope UTXOFinder peekUTXO,
        out Amount rate) nothrow @safe
    {
        try
            // At this point, we get a fee, not a rate, but we divide it below.
            rate = tx.getFee(peekUTXO);
        catch (Exception exc)
            return "Exception happened while calling `getTxFeeRate`";

        rate.div(tx.sizeInBytes());
        return null;
    }

    /***************************************************************************

        Calculate total fees of a Transaction set

        Params:
            tx_set = Transaction set
            peekUTXO = A delegate to query UTXOs
            tot_fee = Total fee (incl. data fees)
            tot_data_fee = Total data fee

        Returns: string describing the error, if an error happened, null otherwise

    ***************************************************************************/

    private void getTXSetFees (in Transaction[] tx_set,
        scope UTXOFinder peekUTXO, ref Amount tot_fee, ref Amount tot_data_fee) @safe
    {
        foreach (const ref tx; tx_set)
        {
            tot_fee += tx.getFee(peekUTXO);
            tot_data_fee += this.getDataFee(tx.payload.length);
        }
    }

    /// For unittest
    version (unittest) public this ()
    {
        this(new ManagedDatabase(":memory:"), new immutable(ConsensusParams));
    }

    unittest
    {
        import agora.crypto.Hash;
        import agora.utils.Test;

        auto man = new FeeManager();
        auto utxoset = new TestUTXOSet();

        Amount double_stake = Amount.MinFreezeAmount * 2;
        Amount stake_with_excess = Amount.MinFreezeAmount + Amount(19); // this should not change distribution
        auto frozen_txs = [
            Transaction([], [Output(Amount.MinFreezeAmount,
                WK.Keys[0].address, OutputType.Freeze)]),
            Transaction([], [Output(stake_with_excess,
                WK.Keys[0].address, OutputType.Freeze)]),
            Transaction([], [Output(double_stake,
                WK.Keys[0].address, OutputType.Freeze)]),
        ];

        frozen_txs.each!(tx => utxoset.put(tx));
        auto keys = frozen_txs.map!(tx => UTXO.getHash(tx.hashFull(), 0));

        ValidatorInfo[] validators;
        foreach (key; keys)
        {
            UTXO utxo;
            assert(utxoset.peekUTXO(key, utxo));
            validators ~= ValidatorInfo(Height(1), utxo.output.address, utxo.output.value);
        }

        // Create block with some fees
        Transaction gen_tx = Transaction(
            [ Output(Amount(20_000_000L), WK.Keys.NODE2.address) ]);
        utxoset.put(gen_tx);

        Transaction spend_tx = Transaction(
            [ Input(gen_tx.hashFull(), 0) ],
            [ Output(Amount(15_000_000L), WK.Keys.NODE3.address) ]);

        UTXO utxo;
        assert(utxoset.peekUTXO(spend_tx.inputs[0].utxo, utxo));

        Block block;
        block.header.height = Height(1);
        block.txs ~= spend_tx;

        // store the fees from this block
        man.storeBlockFees(block, &utxoset.peekUTXO);

        // When stakes are equal they should receive the same amount
        assert(man.getValidatorPayouts(Height(1), validators[0..$-1])
            .uniq.array.length == 1);

        // 1 2X stake, 2 1X stakes
        auto val_payouts = man.getValidatorPayouts(Height(1), validators);
        assert(val_payouts.length == validators.length);

        auto fees = val_payouts.uniq.array;
        assert(fees.length == 2);
        // Should be exactly double
        assert(fees[1].count(fees[0]) == 2);
        assert(fees[1].div(2) == Amount(0));

        ubyte[20] data_paylod;

        // Create block with some fees and data fees
        Transaction txs_with_data = Transaction(
            [ Input(gen_tx.hashFull(), 0) ],
            [ Output(Amount(15_000_000L), WK.Keys.NODE3.address) ],
            data_paylod);
        assert(utxoset.peekUTXO(txs_with_data.inputs[0].utxo, utxo));

        Block block_with_data;
        block_with_data.header.height = Height(2);
        block_with_data.txs ~= txs_with_data;

        // store the fees from this block
        man.storeBlockFees(block_with_data, &utxoset.peekUTXO);

        // Initialize tot_fee as fees (which includes the data fees)
        Amount tot_fee = man.getBlockFees(Height(2));
        assert(tot_fee > 0.coins);

        // get the payouts for the validators
        auto w_data_fees = man.getValidatorPayouts(Height(2), validators);
        // get the payout for the Commons Budget
        auto commons_fee = man.getCommonsBudgetPayout(Height(2), w_data_fees);

        // Subtract the fees paid to the commons budget
        tot_fee -= commons_fee;

        // Subtract for each fee paid to validators
        foreach (fee; w_data_fees)
            tot_fee -= fee;

        // None wasted, none created
        assert(tot_fee == Amount(0));
    }
}

/*******************************************************************************

    Returns the transaction fees (not including data fees) of a transaction

    Transactions have two kinds of fee: regular fees are the difference between
    the inputs and the outputs. On the other hand, "data" fees are used to pay
    for `payload`, and are explicit (to the commons budget).

    This function returns the transaction fee of `tx`. If `tx` is not a valid
    transaction, this function will throw.

    Params:
      tx = The transaction to get the fee of
      peekUTXO = A delegate to look up UTXOs (can have replay protection or not)

*******************************************************************************/

private Amount getFee (in Transaction tx, scope UTXOFinder peekUTXO) @safe
{
    // Coinbase TXs are not subject to fees
    if (tx.isCoinbase)
        return Amount(0);

    Amount tot_in, tot_out;
    foreach (input; tx.inputs)
    {
        UTXO utxo;
        ensure(peekUTXO(input.utxo, utxo), "Unable to find input for UTXO: {}", input.utxo);
        tot_in += utxo.output.value;
    }

    ensure(tx.getSumOutput(tot_out), "Transaction output value is invalid: {}", tx.outputs);
    // sum(inputs) - sum(outputs)
    return tot_in - tot_out;
}

unittest
{
    import agora.consensus.state.UTXOCache;
    import agora.crypto.Hash;
    import agora.utils.Test;
    import std.exception;

    auto fee_man = new FeeManager();

    Transaction freeze_tx = Transaction(
        [ Output(Amount(2_000_000L * 10_000_000L), WK.Keys.NODE2.address, OutputType.Freeze) ]);

    auto utxo_set = new TestUTXOSet;
    utxo_set.put(freeze_tx);

    Hash txhash = hashFull(freeze_tx);
    Hash stake_hash = UTXO.getHash(txhash, 0);

    Transaction gen_tx = Transaction(
        [ Output(Amount(2_000_000L), WK.Keys.NODE2.address) ]);
    utxo_set.put(gen_tx);

    Transaction spend_tx = Transaction(
        [ Input(gen_tx.hashFull(), 0)],
        [ Output(Amount(1_000_000L), WK.Keys.NODE2.address) ]);

    UTXO utxo;
    assert(utxo_set.peekUTXO(spend_tx.inputs[0].utxo, utxo));
    assert(utxo_set.peekUTXO(stake_hash, utxo));

    Block block;
    block.txs ~= spend_tx;

    block.header.height = Height(1);
    fee_man.storeBlockFees(block , &utxo_set.peekUTXO);

    immutable Params = new immutable(ConsensusParams);
    auto fee_man_2 = new FeeManager(fee_man.db, Params);

    auto fees = fee_man.getBlockFees(Height(1));
    assert(fees > Amount(0));

    // fee_man_2 should recover from DB
    assert(fee_man.getBlockFees(Height(1)) ==
        fee_man_2.getBlockFees(Height(1)));

    // check exception when utxo not found as we did not add to utxo_set
    Transaction tx = Transaction(
        [ Input(spend_tx.hashFull(), 0)],
        [ Output(Amount(1_000_000L), WK.Keys.NODE3.address) ]);
    assertThrown(getFee(tx, &utxo_set.peekUTXO));
}
