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
public auto prettify (T) (const ref T input) nothrow
{
    static if (is(T : const Amount))
        return AmountFmt(input);
    else static if (is(T : const Hash))
        return HashFmt(input);
    else static if (is(T : const PublicKey))
        return PublicKeyFmt(input);
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

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
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

    public this (ref const Hash r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
    {
        try
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
private struct PublicKeyFmt
{
    private const(PublicKey) value;

    public this (ref const PublicKey r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
    {
        try
        {
            // e.g. GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW
            enum StringBufferSize = 56;
            enum StartUntil = 4;  // Only format `ABCD..EFGH`
            enum EndFrom    = StringBufferSize - 4;
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
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }
}

@safe unittest
{
    static immutable PublicKey SomeKey =
        PublicKey.fromString(
            "GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW");
    assert(format("%s", PublicKeyFmt(SomeKey)) == "GDD5...LQFW");
}

/// Formatting struct for `PublicKey`
private struct PubKeyFmt
{
    private const(PublicKey) value;

    public this (ref const PublicKey r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
    {
        try
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
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
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

    public this (ref const Input r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
    {
        try
        {
            formattedWrite(sink, "%s[%d]:%s",
                HashFmt(this.value.previous), this.value.index,
                HashFmt(this.value.signature));
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
    assert(format("%s", InputFmt(input)) == "0x0000...0000[0]:0x0000...0000");
}

/// Formatting struct for `Output`
private struct OutputFmt
{
    private const(Output) value;

    public this (ref const Output r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) @safe nothrow
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
    assert(format("%s", OutputFmt(output)) == "GAAA...AWHF(0)");
}

/// Format a whole transaction
private struct TransactionFmt
{
    private const(Transaction) value;

    public this (ref const Transaction r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink)
        @safe nothrow
    {
        try
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
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
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

    public this (ref const BlockHeader r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink) nothrow
        @safe
    {
        try
        {
            formattedWrite(sink, "Height: %d, Prev: %s, Root: %s",
                this.value.height, HashFmt(this.value.prev_block), HashFmt(this.value.merkle_root));
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
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

    public this (ref const Block r) @safe nothrow
    {
        this.value = r;
    }

    public void toString (scope void delegate(scope const(char)[]) @safe sink)
        @safe nothrow
    {
        try
        {
            formattedWrite(sink, "%s, Transactions: %d\n",
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
