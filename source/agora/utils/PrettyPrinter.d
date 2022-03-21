/*******************************************************************************

    Defines method to format types to their human readable representation

    This approach allows to take the string formatting out of the type,
    simplifying the implementation and reducing dependencies.
    It is assumed that a human-readable representation will not rely on
    non-visible (`private`, `package`, `protected`) data,
    or data that cannot be accessed without mutation.

    Note:
      This module currently does not use `in` sink as Phobos does not recognize
      them when `-preview=in` is used.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.PrettyPrinter;

import agora.common.Amount;
import agora.common.BitMask;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.protocol.Data;
import agora.consensus.data.Enrollment;
version (unittest) import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;
import agora.crypto.Key;
import agora.crypto.Schnorr: Signature;

import std.algorithm;
import std.format;
import std.range;

///
unittest
{
    import agora.utils.Log;

    void myFunction (T) (T data)
    {
        Logger log = Log.lookup(__MODULE__);
        // Supported types: Amount, Hash, Input, Output, Block, Transaction, ...
        // If a type is not supported it is returned verbatim
        log.info("Got a {} of value: {}", T.stringof, prettify(data));
    }
}

/// Returns:
/// A formatting struct for a type, or the value if no such struct exists
public auto prettify (T) (const auto ref T input) nothrow
{
    static if (is(T : const Amount))
        return AmountFmt(input);
    else static if (is(T : const Hash))
        return HashFmt(input);
    else static if (is(T : const PublicKey))
        return PubKeyFmt(input);
    else static if (is(T : const Input))
        return InputFmt(input);
    else static if (is(T : const Output))
        return OutputFmt(input);
    else static if (is(T : const Transaction))
        return TransactionFmt(input);
    else static if (is(T : const Block))
        return BlockFmt(input);
    else static if (isInputRange!T)
        return RangeFmt!T(input);
    else static if (is(T : const Enrollment))
        return EnrollmentFmt(input);
    else static if (is(T : const ConsensusData))
        return ConsensusDataFmt(input);
    else static if (is(T : const QuorumConfig))
        return QuorumConfigFmt(input);
    else static if (is(T == struct))  // recurse into fields and auto-prettify
    {
        struct Formatted
        {
            public void toString (scope void delegate (in char[]) @safe sink)
                const @safe nothrow
            {
                import std.traits;
                try
                {
                    sink("{ ");
                    foreach (idx, field; FieldNameTuple!T)
                    {
                        formattedWrite(sink, "%s: %s", field,
                            prettify(__traits(getMember, input, field)));
                        if (idx + 1 < FieldNameTuple!T.length)
                            sink(", ");
                    }
                    sink(" }");
                }
                catch (Exception ex)
                {
                    assert(0, ex.msg);
                }
            }
        }

        return Formatted();
    }
    else
        return input;
}

unittest
{
    static struct S
    {
        static struct Nested
        {
            Hash hash;
            Amount amount;
        }

        static struct A
        {
            int x;
        }

        Nested nested;
        PublicKey pubkey;
        A a = A(32);
        A b = A(64);
    }

    static immutable Hash SomeHash =
        "0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
        ~ "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f";
    assert(format("%s", prettify(S(S.Nested(SomeHash, Amount(1))))) ==
        "{ nested: { hash: 0x0000...e26f, amount: 0.0,000,001 }, pubkey: boa1xqqqqqqq...jq8m, a: { x: 32 }, b: { x: 64 } }");
}

/// Formatting struct for `Amount`
private struct AmountFmt
{
    private Amount value;

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            formattedWrite(sink, "%,d", this.value.integral());
            if (auto dec = this.value.decimal())
            {
                sink(".");
                size_t mask = 1_000_000;
                while (dec)
                {
                    if (mask == 100_000 || mask == 100)
                        sink(",");
                    sink("0123456789"[dec / mask .. (dec / mask) + 1]);
                    dec %= mask;
                    mask /= 10;
                }
            }
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    immutable one = Amount(1);
    assert(format("%s", AmountFmt(Amount.MaxUnitSupply)) == "4,950,000,000");
    assert(format("%s", AmountFmt(one)) == "0.0,000,001", format("%s", AmountFmt(one)));
    assert(format("%s", AmountFmt(Amount.UnitPerCoin)) == "1");
    assert(format("%s", AmountFmt(Amount(50_000))) == "0.0,05");
}

/// Formatting struct for `Hash` and `Signature`
private struct HashFmt
{
    private const(Hash) value;

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            // Only format `0xABCD..EFGH`
            enum StartUntil = 6;
            enum EndFrom    = Hash.StringBufferSize - 4;
            size_t count;
            scope void delegate (in char[]) @safe wrapper = (in data) @safe {
                    if (count < StartUntil)
                    {
                        sink(data);
                        if (count + data.length >= StartUntil)
                            sink("...");
                    }
                    if (count >= EndFrom)
                        sink(data);
                    count += data.length;
                };
            this.value.toString(wrapper);
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    static immutable Hash SomeHash =
        "0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"
        ~ "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f";
    assert(format("%s", HashFmt(SomeHash)) == "0x0000...e26f");
}

/// Formatting struct for `PublicKey`
private struct PubKeyFmt
{
    private const(PublicKey) value;

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            // Public keys are 63 characters, only take the first 12 and last 4
            // Only format `boa1acdefghi..6789`
            enum StartUntil = 12;
            enum EndFrom = 4;
            scope void delegate (in char[]) @safe wrapper = (in data) @safe {
                if (data.length <= StartUntil + EndFrom)
                {
                    sink(data);
                }
                else
                {
                    sink(data[0 .. StartUntil]);
                    sink("...");
                    sink(data[$ - EndFrom .. $]);
                }
            };
            this.value.toString(wrapper);
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    PublicKey pubkey;
    immutable expected = format("%s", PubKeyFmt(pubkey));
    assert(expected == "boa1xqqqqqqq...jq8m", "Expected: " ~ expected);
}

/// Formatting struct for `Input`
private struct InputFmt
{
    private const(Input) value;

    public this (ref const Input r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            // todo: use better formatting for byte arrays
            import agora.crypto.Hash;
            formattedWrite(sink, "%s:%s",
                HashFmt(this.value.utxo),
                HashFmt(hashFull(this.value.unlock)));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    Input input;
    assert(format("%s", InputFmt(input)) == "0x0000...0000:0x9e8b...81b6",
        format("%s", InputFmt(input)));
}

/// Formatting struct for `Output`
private struct OutputFmt
{
    private const(Output) value;

    public this (ref const Output r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            formattedWrite(sink, "%s(%s)<%s>",
                PubKeyFmt(this.value.address), AmountFmt(this.value.value), this.value.type);
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    Output output;
    assert(format("%s", OutputFmt(output)) == "boa1xqqqqqqq...jq8m(0)<Payment>");
}

/// Format a whole transaction
private struct TransactionFmt
{
    private const(Transaction) value;

    public this (ref const Transaction r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            enum InputPerLine = 3;
            enum OutputPerLine = 3;

            if (this.value.inputs.length)
                formattedWrite(sink, "Inputs (%d):%s%(%(%s, %),\n%)\n",
                    this.value.inputs.length,
                    this.value.inputs.length > InputPerLine ? "\n" : " ",
                    this.value.inputs.map!(v => InputFmt(v)).chunks(InputPerLine));
            else
                formattedWrite(sink, "Inputs: None\n");

            formattedWrite(sink, "Outputs (%d):%s%(%(%s, %),\n%)",
                this.value.outputs.length,
                this.value.outputs.length > OutputPerLine ? "\n" : " ",
                this.value.outputs.map!(v => OutputFmt(v)).chunks(OutputPerLine));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    import agora.utils.Test;

    auto frozen = Transaction(
    [
        // If we want these in order NODE2, NODE3 .. NODE7
        // then we need to make sure the value of the Public key is in same order
        Output(2_000_000.coins, WK.Keys.NODE2.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE3.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE4.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE5.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE6.address, OutputType.Freeze),
        Output(2_000_000.coins, WK.Keys.NODE7.address, OutputType.Freeze),
    ]);

    static immutable ResultStr0 = `Inputs: None
Outputs (6):
boa1xzval2a3...gsh2(2,000,000)<Freeze>, boa1xzval3ah...tv9n(2,000,000)<Freeze>, boa1xzval4nv...6gfy(2,000,000)<Freeze>,
boa1xrval5rz...jkm8(2,000,000)<Freeze>, boa1xrval6hd...34l5(2,000,000)<Freeze>, boa1xrval7gw...scrh(2,000,000)<Freeze>`;
    const actual0 = format("%s", TransactionFmt(frozen));
    assert(ResultStr0 == actual0, actual0);

    auto payment = Transaction(
    [
        Output(61_000_000.coins, WK.Keys.Genesis.address),
        Output(61_000_000.coins, WK.Keys.Genesis.address),
        Output(61_000_000.coins, WK.Keys.Genesis.address),
        Output(61_000_000.coins, WK.Keys.Genesis.address),
        Output(61_000_000.coins, WK.Keys.Genesis.address),
        Output(61_000_000.coins, WK.Keys.Genesis.address),
        Output(61_000_000.coins, WK.Keys.Genesis.address),
        Output(61_000_000.coins, WK.Keys.Genesis.address),
    ]);

    static immutable ResultStr1 = `Inputs: None
Outputs (8):
boa1xzgenes5...gm67(61,000,000)<Payment>, boa1xzgenes5...gm67(61,000,000)<Payment>, boa1xzgenes5...gm67(61,000,000)<Payment>,
boa1xzgenes5...gm67(61,000,000)<Payment>, boa1xzgenes5...gm67(61,000,000)<Payment>, boa1xzgenes5...gm67(61,000,000)<Payment>,
boa1xzgenes5...gm67(61,000,000)<Payment>, boa1xzgenes5...gm67(61,000,000)<Payment>`;
    const actual1 = format("%s", TransactionFmt(payment));
    assert(ResultStr1 == actual1, actual1);
}

/// Format a block header
private struct BlockHeaderFmt
{
    private const(BlockHeader) value;

    public this (ref const BlockHeader r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            formattedWrite(sink, "Height: %d, Prev: %s, Root: %s, Enrollments: [%s]\nSignature: %s,\nValidators: %d/%d !(%(%s, %)),\nPre-images: [%(%s, %)]",
                this.value.height.value, HashFmt(this.value.prev_block),
                HashFmt(this.value.merkle_root),
                this.value.enrollments.fold!((a, b) =>
                    format!"%s\n%s"(a, prettify(b)))(""),
                this.value.signature, this.value.validators.setCount, this.value.validators.count, this.value.validators.notSetIndices,
                this.value.preimages.map!(h => HashFmt(h)));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    static immutable GenesisHStr = `Height: 0, Prev: 0x0000...0000, Root: 0x0923...3f72, Enrollments: [
{ utxo: 0x0666...89a4, seed: 0x12f7...7ab3, sig: 0x6d7a...50b4 }
{ utxo: 0x2b1f...7495, seed: 0x6594...00a0, sig: 0xa669...4133 }
{ utxo: 0x6bce...116a, seed: 0x3c4e...94f0, sig: 0x221c...4f8c }
{ utxo: 0x84da...3493, seed: 0x2ef9...c3b3, sig: 0x8ff3...bead }
{ utxo: 0x94b7...7177, seed: 0xbdb4...00c2, sig: 0x7702...ef12 }
{ utxo: 0xa3c2...b4e1, seed: 0x5666...d6c3, sig: 0x0c71...4028 }]
Signature: 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
Validators: 0/0 !(),
Pre-images: []`;
    const actual = format("%s", BlockHeaderFmt(GenesisBlock.header));
    assert(GenesisHStr == actual);
}

/// Format a whole block
private struct BlockFmt
{
    private const(Block) value;

    public this (ref const Block r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            formattedWrite(sink, "%s,\nTransactions: %d\n",
                BlockHeaderFmt(this.value.header), this.value.txs.length);
            formattedWrite(sink, "%(%s\n%)", this.value.txs.map!(v => TransactionFmt(v)));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    static immutable ResultStr = "Height: 0, Prev: 0x0000...0000, Root: 0x0923...3f72, Enrollments: [
{ utxo: 0x0666...89a4, seed: 0x12f7...7ab3, sig: 0x6d7a...50b4 }
{ utxo: 0x2b1f...7495, seed: 0x6594...00a0, sig: 0xa669...4133 }
{ utxo: 0x6bce...116a, seed: 0x3c4e...94f0, sig: 0x221c...4f8c }
{ utxo: 0x84da...3493, seed: 0x2ef9...c3b3, sig: 0x8ff3...bead }
{ utxo: 0x94b7...7177, seed: 0xbdb4...00c2, sig: 0x7702...ef12 }
{ utxo: 0xa3c2...b4e1, seed: 0x5666...d6c3, sig: 0x0c71...4028 }]
Signature: 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
Validators: 0/0 !(),
Pre-images: [],
Transactions: 3
Inputs: None
Outputs (6):
boa1xzval2a3...gsh2(2,000,000)<Freeze>, boa1xzval3ah...tv9n(2,000,000)<Freeze>, boa1xzval4nv...6gfy(2,000,000)<Freeze>,
boa1xrval5rz...jkm8(2,000,000)<Freeze>, boa1xrval6hd...34l5(2,000,000)<Freeze>, boa1xrval7gw...scrh(2,000,000)<Freeze>
Inputs: None
Outputs (6):
boa1xqvalc7v...tcay(2,000,000)<Freeze>, boa1xqvala34...8ejz(2,000,000)<Freeze>, boa1xpval9gv...epv9(2,000,000)<Freeze>,
boa1xzval8mq...l0dm(2,000,000)<Freeze>, boa1xzvale54...ah4d(2,000,000)<Freeze>, boa1xrvaldd5...2u5x(2,000,000)<Freeze>
Inputs: None
Outputs (8):
boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>,
boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>,
boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>";
    const actual = format("%s", BlockFmt(GenesisBlock));
    assert(ResultStr == actual);
}

/// Format inputRange (e.g. range of blocks)
private struct RangeFmt (R)
{
    private const(R) value;

    public this (ref const R r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            formattedWrite(sink, "\n====================================================\n");
            formattedWrite(sink, "%(%s\n====================================================\n%|%)",
                this.value.map!(b => prettify(b)));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    static immutable ResultStr = `
====================================================
Height: 0, Prev: 0x0000...0000, Root: 0x0923...3f72, Enrollments: [
{ utxo: 0x0666...89a4, seed: 0x12f7...7ab3, sig: 0x6d7a...50b4 }
{ utxo: 0x2b1f...7495, seed: 0x6594...00a0, sig: 0xa669...4133 }
{ utxo: 0x6bce...116a, seed: 0x3c4e...94f0, sig: 0x221c...4f8c }
{ utxo: 0x84da...3493, seed: 0x2ef9...c3b3, sig: 0x8ff3...bead }
{ utxo: 0x94b7...7177, seed: 0xbdb4...00c2, sig: 0x7702...ef12 }
{ utxo: 0xa3c2...b4e1, seed: 0x5666...d6c3, sig: 0x0c71...4028 }]
Signature: 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
Validators: 0/0 !(),
Pre-images: [],
Transactions: 3
Inputs: None
Outputs (6):
boa1xzval2a3...gsh2(2,000,000)<Freeze>, boa1xzval3ah...tv9n(2,000,000)<Freeze>, boa1xzval4nv...6gfy(2,000,000)<Freeze>,
boa1xrval5rz...jkm8(2,000,000)<Freeze>, boa1xrval6hd...34l5(2,000,000)<Freeze>, boa1xrval7gw...scrh(2,000,000)<Freeze>
Inputs: None
Outputs (6):
boa1xqvalc7v...tcay(2,000,000)<Freeze>, boa1xqvala34...8ejz(2,000,000)<Freeze>, boa1xpval9gv...epv9(2,000,000)<Freeze>,
boa1xzval8mq...l0dm(2,000,000)<Freeze>, boa1xzvale54...ah4d(2,000,000)<Freeze>, boa1xrvaldd5...2u5x(2,000,000)<Freeze>
Inputs: None
Outputs (8):
boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>,
boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>,
boa1xzgenes5...gm67(59,500,000)<Payment>, boa1xzgenes5...gm67(59,500,000)<Payment>
====================================================
Height: 1, Prev: 0x8365...3175, Root: 0xb434...e22f, Enrollments: []
Signature: 0x000000000000000000016f605ea9638d7bff58d2c0cc2467c18e38b36367be78000000000000000000016f605ea9638d7bff58d2c0cc2467c18e38b36367be78,
Validators: 4/6 !(1, 4),
Pre-images: [0x4f7f...5563, 0x2026...6d96, 0xcd81...26c3, 0xe703...5571, 0x8c7e...0cf7, 0x1592...afd1],
Transactions: 2
Inputs (1): 0xb75a...9257:0x9e8b...81b6
Outputs (1): boa1xzgenes5...gm67(59,499,999.9,920,9)<Payment>
Inputs (1): 0x840b...b279:0x9e8b...81b6
Outputs (1): boa1xzgenes5...gm67(59,499,999.9,920,9)<Payment>
====================================================
`;
    import agora.utils.Test : genesisSpendable;
    import agora.consensus.data.Block;

    // need reproducible unlocks for test (signing generates unique nonces)
    import agora.script.Lock;
    import agora.utils.Test;
    static Unlock unlocker (in Transaction, in OutputRef) @safe nothrow
    {
        return Unlock.init;
    }

    Block second_block = makeNewBlock(GenesisBlock,
        genesisSpendable().take(2).map!(txb => txb.unlockSigner(&unlocker).sign()),
        WK.PreImages.at(GenesisBlock.header.height + 1, genesis_validator_keys));

    auto validators = BitMask(6);
    only(0,2,3,5).each!(i => validators[i] = true);
    const signature = Signature.fromString("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    second_block.updateSignature(signature, validators);
    const(Block)[] blocks = [GenesisBlock, second_block];
    const actual = format("%s", prettify(blocks));
    assert(ResultStr == actual);
}

/// Formatting struct for `Enrollment`
private struct EnrollmentFmt
{
    private const(Enrollment) enroll;

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            formattedWrite(sink, "{ utxo: %s, seed: %s, sig: %s }",
                HashFmt(this.enroll.utxo_key),
                HashFmt(this.enroll.commitment),
                HashFmt(this.enroll.enroll_sig.toBlob()));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}
///
unittest
{
    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash seed = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    Signature sig = Signature.fromString("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    Enrollment enrollment =
    {
        utxo_key: key,
        commitment: seed,
        enroll_sig: sig,
    };

    static immutable Res1 = `{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }`;

    assert(Res1 == format("%s", prettify(enrollment)),
                   format("%s", prettify(enrollment)));
}

/// Formatting struct for `ConsensusData`
private struct ConsensusDataFmt
{
    private const(ConsensusData) data;

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            formattedWrite(sink, "{ tx_set: %s, enrolls: %s, missing_validators: %s }",
                HashFmt(this.data.tx_set),
                this.data.enrolls.map!(enroll => EnrollmentFmt(enroll)),
                this.data.missing_validators);
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

///
unittest
{
    import agora.common.Set;
    import agora.crypto.Hash;
    import agora.serialization.Serializer;

    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash seed = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    Signature sig = Signature.fromString("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    const Enrollment record =
    {
        utxo_key: key,
        commitment: seed,
        enroll_sig: sig,
    };

    const(ConsensusData) cd =
    {
        tx_set: hashFull(37),
        enrolls: [ record, record, ],
        missing_validators: [0, 2, 4],
    };

    static immutable Res1 = `{ tx_set: 0x992e...6694, enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, sig: 0x0000...be78 }], missing_validators: [0, 2, 4] }`;

    assert(Res1 == format("%s", prettify(cd)),
                   format("%s", prettify(cd)));
}

/// Formatting struct for `QuorumConfig`
private struct QuorumConfigFmt
{
    private const(QuorumConfig) data;

    public void toString (scope void delegate (in char[]) @safe sink)
        const @safe nothrow
    {
        try
        {
            formattedWrite(sink, "{ thresh: %s, nodes: %s, subqs: %s }",
                this.data.threshold,
                this.data.nodes,
                this.data.quorums.map!(subq => QuorumConfigFmt(subq)));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

///
unittest
{
    auto quorum = immutable(QuorumConfig)(2, [0, 1],
        [immutable(QuorumConfig)(3, [0, 1],
            [immutable(QuorumConfig)(4, [0, 1, 1])])]);

    static immutable Res1 = `{ thresh: 2, nodes: [0, 1], subqs: [{ thresh: 3, nodes: [0, 1], subqs: [{ thresh: 4, nodes: [0, 1, 1], subqs: [] }] }] }`;

    assert(Res1 == format("%s", prettify(quorum)),
                   format("%s", prettify(quorum)));
}
