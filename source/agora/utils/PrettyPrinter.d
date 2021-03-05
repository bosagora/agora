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
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.PrettyPrinter;

import agora.common.Amount;
import agora.common.BitField;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.protocol.Data;
import agora.consensus.data.Enrollment;
version (unittest) import agora.consensus.data.genesis.Test;
import agora.consensus.data.Transaction;

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
    else
        return input;
}

/// Formatting struct for `Amount`
private struct AmountFmt
{
    private Amount value;

    public void toString (scope void delegate (scope const char[]) @safe sink) @safe nothrow
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
    assert(format("%s", AmountFmt(Amount.MaxUnitSupply)) == "500,000,000");
    assert(format("%s", AmountFmt(one)) == "0.0,000,001", format("%s", AmountFmt(one)));
    assert(format("%s", AmountFmt(Amount.UnitPerCoin)) == "1");
    assert(format("%s", AmountFmt(Amount(50_000))) == "0.0,05");
}

/// Formatting struct for `Hash` and `Signature`
private struct HashFmt
{
    private const(Hash) value;

    public void toString (scope void delegate (scope const char[]) @safe sink) @safe nothrow
    {
        try
        {
            // Only format `0xABCD..EFGH`
            enum StartUntil = 6;
            enum EndFrom    = Hash.StringBufferSize - 4;
            size_t count;
            scope void delegate (scope const char[]) @safe wrapper = (scope const data) @safe {
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

    public void toString (scope void delegate (scope const char[]) @safe sink) @safe nothrow
    {
        try
        {
            // Public keys are 56 characters, only take the first 8 and last 4
            // Only format `0xABCDEFGH..JKLM`
            enum StartUntil = 8;
            enum EndFrom    = 56 - 4;
            size_t count;
            scope void delegate (scope const char[]) @safe wrapper = (scope const data) @safe {
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
    PublicKey pubkey;
    immutable expected = format("%s", PubKeyFmt(pubkey));
    assert(expected == "GAAAAAAA...AWHF", "Expected: " ~ expected);
}

/// Formatting struct for `Input`
private struct InputFmt
{
    private const(Input) value;

    public this (ref const Input r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (scope const char[]) @safe sink) @safe nothrow
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
    assert(format("%s", InputFmt(input)) == "0x0000...0000:0xcee2...6a78",
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

    public void toString (scope void delegate (scope const char[]) @safe sink) @safe nothrow
    {
        try
        {
            formattedWrite(sink, "%s(%s)",
                PubKeyFmt(this.value.address), AmountFmt(this.value.value));
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
    assert(format("%s", OutputFmt(output)) == "GAAAAAAA...AWHF(0)");
}

/// Format a whole transaction
private struct TransactionFmt
{
    private const(Transaction) value;

    public this (ref const Transaction r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (scope const char[]) @safe sink)
        @safe nothrow
    {
        try
        {
            enum InputPerLine = 3;
            enum OutputPerLine = 3;

            if (this.value.inputs.length)
                formattedWrite(sink, "Type : %s, Inputs (%d):%s%(%(%s, %),\n%)\n",
                    this.value.type,
                    this.value.inputs.length,
                    this.value.inputs.length > InputPerLine ? "\n" : " ",
                    this.value.inputs.map!(v => InputFmt(v)).chunks(InputPerLine));
            else
                formattedWrite(sink, "Type : %s, Inputs: None\n", this.value.type);

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
    static immutable ResultStr0 = `Type : Freeze, Inputs: None
Outputs (6):
GDNODE2I...LVHQ(2,000,000), GDNODE3E...EACM(2,000,000), GDNODE4K...OSNY(2,000,000),
GDNODE5T...JQC2(2,000,000), GDNODE6Z...T6GH(2,000,000), GDNODE7J...IX2U(2,000,000)`;
    const actual0 = format("%s", TransactionFmt(GenesisBlock.frozens.front));
    assert(ResultStr0 == actual0, actual0);

    static immutable ResultStr1 = `Type : Payment, Inputs: None
Outputs (8):
GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000),
GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000),
GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000)`;
    const actual1 = format("%s", TransactionFmt(GenesisBlock.payments.front));
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

    public void toString (scope void delegate (scope const char[]) @safe sink) nothrow
        @safe
    {
        try
        {
            formattedWrite(sink, "Height: %d, Prev: %s, Root: %s, Enrollments: [%s]\nSignature: %s,\nValidators: %s,\nRandom seed: [%s],\nSlashed validators: [%s]",
                this.value.height.value, HashFmt(this.value.prev_block),
                HashFmt(this.value.merkle_root),
                this.value.enrollments.fold!((a, b) =>
                    format!"%s\n%s"(a, prettify(b)))(""),
                this.value.signature, this.value.validators,
                HashFmt(this.value.random_seed),
                this.value.missing_validators.fold!((a, b) =>
                    format!"%s, %s"(a, prettify(b)))(""));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    static immutable GenesisHStr = `Height: 0, Prev: 0x0000...0000, Root: 0xb126...3364, Enrollments: [
{ utxo: 0x1a1a...e751, seed: 0xaf43...fceb, cycles: 20, sig: 0x02ef...1304 }
{ utxo: 0x25f5...8cf1, seed: 0xdd1b...7bfa, cycles: 20, sig: 0x0d51...4fe2 }
{ utxo: 0x4fab...acff, seed: 0xa050...2cb4, cycles: 20, sig: 0x0f8f...6b31 }
{ utxo: 0xbf15...0aef, seed: 0x0a82...4328, cycles: 20, sig: 0x06b3...7422 }
{ utxo: 0xc0ab...0e5f, seed: 0xd034...97c1, cycles: 20, sig: 0x0e17...5c01 }
{ utxo: 0xd827...bc8d, seed: 0xa24b...12bc, cycles: 20, sig: 0x06bf...6634 }]
Signature: 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
Validators: [0],
Random seed: [0x0000...0000],
Slashed validators: []`;
    const actual = format("%s", BlockHeaderFmt(GenesisBlock.header));
    assert(GenesisHStr == actual, actual);
}

/// Format a whole block
private struct BlockFmt
{
    private const(Block) value;

    public this (ref const Block r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (scope const char[]) @safe sink)
        @safe nothrow
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
    static immutable ResultStr = `Height: 0, Prev: 0x0000...0000, Root: 0xb126...3364, Enrollments: [
{ utxo: 0x1a1a...e751, seed: 0xaf43...fceb, cycles: 20, sig: 0x02ef...1304 }
{ utxo: 0x25f5...8cf1, seed: 0xdd1b...7bfa, cycles: 20, sig: 0x0d51...4fe2 }
{ utxo: 0x4fab...acff, seed: 0xa050...2cb4, cycles: 20, sig: 0x0f8f...6b31 }
{ utxo: 0xbf15...0aef, seed: 0x0a82...4328, cycles: 20, sig: 0x06b3...7422 }
{ utxo: 0xc0ab...0e5f, seed: 0xd034...97c1, cycles: 20, sig: 0x0e17...5c01 }
{ utxo: 0xd827...bc8d, seed: 0xa24b...12bc, cycles: 20, sig: 0x06bf...6634 }]
Signature: 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
Validators: [0],
Random seed: [0x0000...0000],
Slashed validators: [],
Transactions: 2
Type : Freeze, Inputs: None
Outputs (6):
GDNODE2I...LVHQ(2,000,000), GDNODE3E...EACM(2,000,000), GDNODE4K...OSNY(2,000,000),
GDNODE5T...JQC2(2,000,000), GDNODE6Z...T6GH(2,000,000), GDNODE7J...IX2U(2,000,000)
Type : Payment, Inputs: None
Outputs (8):
GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000),
GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000),
GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000)`;
    const actual = format("%s", BlockFmt(GenesisBlock));
    assert(ResultStr == actual, actual);
}

/// Format inputRange (e.g. range of blocks)
private struct RangeFmt (R)
{
    private const(R) value;

    public this (ref const R r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate (scope const char[]) @safe sink)
        @safe nothrow
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
Height: 0, Prev: 0x0000...0000, Root: 0xb126...3364, Enrollments: [
{ utxo: 0x1a1a...e751, seed: 0xaf43...fceb, cycles: 20, sig: 0x02ef...1304 }
{ utxo: 0x25f5...8cf1, seed: 0xdd1b...7bfa, cycles: 20, sig: 0x0d51...4fe2 }
{ utxo: 0x4fab...acff, seed: 0xa050...2cb4, cycles: 20, sig: 0x0f8f...6b31 }
{ utxo: 0xbf15...0aef, seed: 0x0a82...4328, cycles: 20, sig: 0x06b3...7422 }
{ utxo: 0xc0ab...0e5f, seed: 0xd034...97c1, cycles: 20, sig: 0x0e17...5c01 }
{ utxo: 0xd827...bc8d, seed: 0xa24b...12bc, cycles: 20, sig: 0x06bf...6634 }]
Signature: 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000,
Validators: [0],
Random seed: [0x0000...0000],
Slashed validators: [],
Transactions: 2
Type : Freeze, Inputs: None
Outputs (6):
GDNODE2I...LVHQ(2,000,000), GDNODE3E...EACM(2,000,000), GDNODE4K...OSNY(2,000,000),
GDNODE5T...JQC2(2,000,000), GDNODE6Z...T6GH(2,000,000), GDNODE7J...IX2U(2,000,000)
Type : Payment, Inputs: None
Outputs (8):
GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000),
GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000),
GCOQEOHA...LRIJ(61,000,000), GCOQEOHA...LRIJ(61,000,000)
====================================================
Height: 1, Prev: 0x2451...7377, Root: 0xd437...e2c9, Enrollments: []
Signature: 0x000000000000000000016f605ea9638d7bff58d2c0cc2467c18e38b36367be78000000000000000000016f605ea9638d7bff58d2c0cc2467c18e38b36367be78,
Validators: [64],
Random seed: [0x0000...0000],
Slashed validators: [],
Transactions: 2
Type : Payment, Inputs (1): 0x533f...5e2e:0xac4d...b604
Outputs (1): GCOQEOHA...LRIJ(61,000,000)
Type : Payment, Inputs (1): 0x915d...fde1:0x4b11...5f86
Outputs (1): GCOQEOHA...LRIJ(61,000,000)
====================================================
`;
    import agora.utils.Test : genesisSpendable;
    import agora.consensus.data.Block;

    const Block second_block = makeNewBlock(GenesisBlock,
        genesisSpendable().take(2).map!(txb => txb.sign()), 0, Hash.init);

    auto validators = BitField!ubyte(2);
    validators[1] = true;
    const signature = Signature("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    const block2 = second_block.updateSignature(signature, validators);
    const(Block)[] blocks = [GenesisBlock, block2];
    const actual = format("%s", prettify(blocks));
    assert(ResultStr == actual, actual);
}

/// Formatting struct for `Enrollment`
private struct EnrollmentFmt
{
    private const(Enrollment) enroll;

    public void toString (scope void delegate (scope const char[]) @safe sink)
        @safe nothrow
    {
        try
        {
            formattedWrite(sink, "{ utxo: %s, seed: %s, cycles: %s, sig: %s }",
                HashFmt(this.enroll.utxo_key),
                HashFmt(this.enroll.random_seed),
                this.enroll.cycle_length,
                HashFmt(this.enroll.enroll_sig));
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
    Hash quorumSetHash;

    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash seed = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    Signature sig = Signature("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    Enrollment enrollment =
    {
        utxo_key: key,
        random_seed: seed,
        cycle_length: 1008,
        enroll_sig: sig,
    };

    static immutable Res1 = `{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }`;

    assert(Res1 == format("%s", prettify(enrollment)),
                   format("%s", prettify(enrollment)));
}

/// Formatting struct for `ConsensusData`
private struct ConsensusDataFmt
{
    private const(ConsensusData) data;

    public void toString (scope void delegate (scope const char[]) @safe sink)
        @safe nothrow
    {
        try
        {
            formattedWrite(sink, "{ tx_set: %s, enrolls: %s }",
                this.data.tx_set.map!(tx => HashFmt(tx)),
                this.data.enrolls.map!(enroll => EnrollmentFmt(enroll)));
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
    import agora.common.Serializer;
    import agora.common.Set;
    import agora.crypto.Hash;

    Hash quorumSetHash;

    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash seed = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    Signature sig = Signature("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    const Enrollment record =
    {
        utxo_key: key,
        random_seed: seed,
        cycle_length: 1008,
        enroll_sig: sig,
    };

    const(ConsensusData) cd =
    {
        tx_set: GenesisBlock.txs.map!(tx => tx.hashFull()).array,
        enrolls: [ record, record, ],
    };

    static immutable Res1 = `{ tx_set: [0x5208...074c, 0xb3aa...873b], enrolls: [{ utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }, { utxo: 0x0000...e26f, seed: 0x4a5e...a33b, cycles: 1008, sig: 0x0000...be78 }] }`;

    assert(Res1 == format("%s", prettify(cd)),
                   format("%s", prettify(cd)));
}

/// Formatting struct for `QuorumConfig`
private struct QuorumConfigFmt
{
    private const(QuorumConfig) data;

    public void toString (scope void delegate (scope const char[]) @safe sink)
        @safe nothrow
    {
        try
        {
            formattedWrite(sink, "{ thresh: %s, nodes: %s, subqs: %s }",
                this.data.threshold,
                this.data.nodes.map!(node => PubKeyFmt(node)),
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
    auto quorum = immutable(QuorumConfig)(2,
        [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
         PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")],
        [immutable(QuorumConfig)(3,
            [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
             PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")],
            [immutable(QuorumConfig)(4,
                [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
                 PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5"),
                 PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")])])]);

    static immutable Res1 = `{ thresh: 2, nodes: [GBFDLGQQ...CEWN, GBYK4I37...QCY5], subqs: [{ thresh: 3, nodes: [GBFDLGQQ...CEWN, GBYK4I37...QCY5], subqs: [{ thresh: 4, nodes: [GBFDLGQQ...CEWN, GBYK4I37...QCY5, GBYK4I37...QCY5], subqs: [] }] }] }`;

    assert(Res1 == format("%s", prettify(quorum)),
                   format("%s", prettify(quorum)));
}
