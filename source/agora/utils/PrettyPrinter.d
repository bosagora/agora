/*******************************************************************************

    Defines method to format types to their human readable representation

    This approach allows to take the string formatting out of the type,
    simplifying the implementation and reducing dependencies.
    It is assumed that a human-readable representation will not rely on
    non-visible (`private`, `package`, `protected`) data,
    or data that cannot be accessed without mutation.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.PrettyPrinter;

import agora.common.Amount;
import agora.common.Types;
import agora.common.crypto.Key;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;

import std.algorithm;
import std.format;
import std.range;

/// Ditto
public auto prettify (T) (const ref T input)
{
    static if (is(T : const Amount))
        return AmountFmt(input);
    else static if (is(T : const Hash))
        return HashFmt(input);
    else static if (is(T : const Input))
        return InputFmt(input);
    else static if (is(T : const Output))
        return OutputFmt(input);
    else static if (is(T : const Transaction))
        return TransactionFmt(input);
    else static if (is(T : const Block))
        return BlockFmt(input);
    else
        return input;
}

/// Formatting struct for `Amount`
private struct AmountFmt
{
    private Amount value;

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe
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

    public this (ref const Hash r) @safe
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe
    {
        // Only format `0xABCD..EFGH`
        enum StartUntil = 6;
        enum EndFrom    = Hash.StringBufferSize - 4;
        size_t count;
        scope void delegate(scope const(char)[]) @safe wrapper = (scope data) @safe {
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

    public this (ref const PublicKey r) @safe
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe
    {
        // Public keys are 56 characters, only take the first and last 4
        // Only format `0xABCD..EFGH`
        enum StartUntil = 4;
        enum EndFrom    = 56 - 4;
        size_t count;
        scope void delegate(scope const(char)[]) @safe wrapper = (scope data) @safe {
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
}

@safe unittest
{
    PublicKey pubkey;
    assert(format("%s", PubKeyFmt(pubkey)) == "GAAA...AWHF");

}

/// Formatting struct for `Input`
private struct InputFmt
{
    private const(Input) value;

    public this (ref const Input r) @safe
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe
    {
        formattedWrite(sink, "%s[%d]:%s",
            HashFmt(this.value.previous), this.value.index,
            HashFmt(this.value.signature));
    }
}

@safe unittest
{
    Input input;
    assert(format("%s", InputFmt(input)) == "0x0000...0000[0]:0x0000...0000");
}

/// Formatting struct for `Output`
private struct OutputFmt
{
    private const(Output) value;

    public this (ref const Output r) @safe
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe
    {
        formattedWrite(sink, "%s(%s)",
            PubKeyFmt(this.value.address), AmountFmt(this.value.value));
    }
}

@safe unittest
{
    Output output;
    assert(format("%s", OutputFmt(output)) == "GAAA...AWHF(0)");
}

/// Format a whole transaction
private struct TransactionFmt
{
    private const(Transaction) value;

    public this (ref const Transaction r) @safe
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink)
        @safe
    {
        enum InputPerLine = 3;
        enum OutputPerLine = 3;

        formattedWrite(sink, "Type : %s, Inputs (%d): %(%(%s, %),\n%)\n",
            this.value.type,
            this.value.inputs.length,
            this.value.inputs.map!(v => InputFmt(v)).chunks(InputPerLine));

        formattedWrite(sink, "Outputs (%d): %(%(%s, %),\n%)",
            this.value.outputs.length,
            this.value.outputs.map!(v => OutputFmt(v)).chunks(OutputPerLine));
    }
}

@safe unittest
{
    import agora.consensus.Genesis;
    static immutable ResultStr = `Type : Payment, Inputs (1): 0x0000...0000[0]:0x0000...0000
Outputs (8): GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000),
GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000),
GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000)`;
    assert(ResultStr == format("%s", TransactionFmt(GenesisTransaction)));
}

/// Format a block header
private struct BlockHeaderFmt
{
    private const(BlockHeader) value;

    public this (ref const BlockHeader r) @safe
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink)
        @safe
    {
        formattedWrite(sink, "Height: %d, Prev: %s, Root: %s",
            this.value.height, HashFmt(this.value.prev_block), HashFmt(this.value.merkle_root));
    }
}

@safe unittest
{
    import agora.consensus.Genesis;
    static immutable GenesisHStr = `Height: 0, Prev: 0x0000...0000, Root: 0xdb6e...d2c3`;
    assert(GenesisHStr == format("%s", BlockHeaderFmt(GenesisBlock.header)));
}

/// Format a whole block
private struct BlockFmt
{
    private const(Block) value;

    public this (ref const Block r) @safe
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink)
        @safe
    {
        formattedWrite(sink, "%s, Transactions: %d\n",
            BlockHeaderFmt(this.value.header), this.value.txs.length);
        formattedWrite(sink, "%(%s\n%)", this.value.txs.map!(v => TransactionFmt(v)));
    }
}

@safe unittest
{
    import agora.consensus.Genesis;
    static immutable ResultStr = `Height: 0, Prev: 0x0000...0000, Root: 0xdb6e...d2c3, Transactions: 1
Type : Payment, Inputs (1): 0x0000...0000[0]:0x0000...0000
Outputs (8): GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000),
GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000),
GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000)`;
    assert(ResultStr == format("%s", BlockFmt(GenesisBlock)));
}

@safe unittest
{
    import agora.common.Hash;
    import agora.consensus.Genesis;

    static immutable ResultStr = `Height: 1, Prev: 0xd462...60db, Root: 0xf9f5...fde2, Transactions: 2
Type : Payment, Inputs (1): 0x0000...0000[0]:0x0000...0000
Outputs (8): GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000),
GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000),
GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000)
Type : Payment, Inputs (1): 0x0000...0000[0]:0x0000...0000
Outputs (8): GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000),
GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000),
GCOQ...LRIJ(62,500,000), GCOQ...LRIJ(62,500,000)`;

    immutable MerkleRoot = hashMulti(
        GenesisBlock.header.merkle_root, GenesisBlock.header.merkle_root);
    immutable Block block2tx = {
        header: {
            prev_block: hashFull(GenesisBlock.header),
            height: 1,
            merkle_root: MerkleRoot,
        },
        txs: [ GenesisTransaction, GenesisTransaction ],
        merkle_tree: [
            MerkleRoot,
            GenesisBlock.header.merkle_root, GenesisBlock.header.merkle_root,
        ],
    };
    assert(ResultStr == format("%s", BlockFmt(block2tx)), format("%s", BlockFmt(block2tx)));
}
