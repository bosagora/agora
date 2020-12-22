/*******************************************************************************

    Contains the function to calculate the fees used to store the data

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.Fee;

import agora.common.Amount;
import agora.common.crypto.Key;
import agora.consensus.data.Transaction;

import std.math;

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

    A class that provides the ability to verify `DataPayload` stored
    in a `Transaction`.

*******************************************************************************/

public class FeeManager
{
    /// The address of commons budget
    public PublicKey CommonsBudgetAddress;

    /// The maximum size of data payload
    public uint TxPayloadMaxSize;

    /// The factor to calculate for the fee of data payload
    public uint TxPayloadFeeFactor;

    /// Ctor
    public this (in PublicKey commons_budget_address,
                 uint tx_payload_max_size,
                 uint tx_payload_fee_factor)
    {
        this.CommonsBudgetAddress = commons_budget_address,
        this.TxPayloadMaxSize = tx_payload_max_size;
        this.TxPayloadFeeFactor = tx_payload_fee_factor;
    }

    /***************************************************************************

        Checks the following in the data payload:

            Checks that the size of the data does not exceed
            the maximum size allowed.
            Checks if a commons budget address exists in the output.
            Checks if the appropriate fee is paid by commons budget address.

        Params:
            tx = `Transaction`

        Return:
            `null` if the transaction is valid, a string explaining the reason it
            is invalid otherwise.

    ***************************************************************************/

    public string check (in Transaction tx, Amount sum_unspent) nothrow @safe
    {
        if (tx.payload.data.length == 0)
            return null;

        if (tx.payload.data.length > this.TxPayloadMaxSize)
            return "Transaction: The size of the data payload is too large";

        const required_fee = calculateDataFee(tx.payload.data.length, this.TxPayloadFeeFactor);
        if (sum_unspent < required_fee)
            return "Transaction: There is not enough fee.";

        return null;
    }

    /// Calculates the fee of data payloads
    public Amount getDataFee (ulong data_size) pure nothrow @safe @nogc
    {
        return calculateDataFee(data_size, this.TxPayloadFeeFactor);
    }

    /// For unittest
    version (unittest) public this (
        uint tx_payload_max_size = 1024,
        uint tx_payload_fee_factor = 200)
    {
        import agora.utils.WellKnownKeys;
        this(CommonsBudget.address, tx_payload_max_size, tx_payload_fee_factor);
    }
}
