/*******************************************************************************

   Defines a monetary type used in the blockchain

   This struct can hold an amount between 0 and 500_000_000 * 10^7,
   as there is an absolute maximum supply of 500M and each coin can be divided
   in up to 10^7 units.

   This struct does not expose operation overloading on purpose.
   Having operator overloading would mean that any error should be reported
   as either an `assert` being triggered or an `Exception` being thrown.
   The convenience of using `a + b` would likely mean some places wouldn't
   be properly bound checked, which would in turn open a DoS.
   Instead, we provide two kind of functions for operations:
   `bool OPNAME(ref Amount res, Type)` and `Amount mustOPNAME(Type)`

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Amount;

/// Defines a monetary type used in the blockchain
public struct Amount
{
    import core.checkedint;

    /// Number of units ('cents') per coins
    public static immutable Amount UnitPerCoin   = Amount(10_000_000, true);
    /// Maximum number of BOA coins that can ever be in circulation
    public static immutable ulong  MaxCoinSupply = 500_000_000;
    /// Maximum amount of money that can ever be in circulation
    public static immutable Amount MaxUnitSupply =
        Amount(UnitPerCoin.value * MaxCoinSupply, true);
    /// Exact amount that needs to be staked to make a freezing transaction
    public static immutable Amount FreezeAmount =
        Amount(UnitPerCoin.value * 40_000, true);

    /// Helper type for `toString`
    private alias SinkT = void delegate(scope const(char)[] v) @safe;

    /// Internal data storage
    private ulong value;

    /***************************************************************************

        Construct an instance of an `Amount`

        Params:
            units = The monetary amount this new instance represent.
                    The unit is the smaller unit of currency (see `UnitPerCoin`)

    ***************************************************************************/

    public this (ulong units) nothrow pure @nogc @safe
    {
        assert(Amount.isInRange(units));
        this.value = units;
    }

    /// Pretty-print this value
    public void toString (SinkT dg) const @safe
    {
        import std.format;
        formattedWrite(dg, "%d", this.value);
    }

    /// Also support for Vibe.d serialization to JSON
    public string toString () const @safe
    {
        string ret;
        scope SinkT dg = (scope v) { ret ~= v; };
        this.toString(dg);
        return ret;
    }

    /// Support for Vibe.d deserialization
    public static Amount fromString (scope const(char)[] str) pure @safe
    {
        import std.conv : to;
        immutable ul = str.to!ulong;
        if (!Amount.isInRange(ul))
            throw new Exception("Invalid input value to Amount");
        return Amount(ul, true);
    }

    nothrow pure @nogc @safe:

    /***************************************************************************

        Returns:
            `true` if `value` is in the range `[0; Amount.MaxUnitSupply]`
            and can be safely used to make an `Amount`

    ***************************************************************************/

    pragma(inline, true)
    public static bool isInRange (ulong value)
    {
        return value <= MaxUnitSupply.value;
    }

    /// `isInRange` but as member function
    pragma(inline, true)
    public bool isValid () const
    {
        return isInRange(this.value);
    }

    /***************************************************************************

        Add another value to `this` `Amount`

        Params:
            other = Another `Amount` value. If the value is invalid,
                    `false` will be returned.
        Returns:
            `true` if the addition returned a number within bounds.
            `false` if the number is out of the [0; MaxUnitSupply] bound.

    ***************************************************************************/

    pragma(inline, true)
    public bool add (Amount other)
    {
        bool overflow;
        this.value = addu(this.value, other.value, overflow);
        if (overflow || !this.isValid())
        {
            // If we overflow, make sure to poison the return value
            this.value = ulong.max;
            return false;
        }
        return true;
    }

    /***************************************************************************

        Substract another value from `this` `Amount`

        Params:
            other = Another `Amount` value. If the value is invalid,
                    `false` will be returned.
        Returns:
            `true` if the addition returned a number within bounds.
            `false` if the number is out of the [0; MaxUnitSupply] bound.

    ***************************************************************************/

    pragma(inline, true)
    public bool sub (Amount other)
    {
        // Check for validity before calling `addu`,
        // because the value could be invalid and the substraction
        // would make it valid - but `underflow` is sticky
        bool underflow = !this.isValid();
        this.value = subu(this.value, other.value, underflow);
        if (underflow || !this.isValid())
        {
            // If we underflow, make sure to poison the return value
            this.value = ulong.max;
            return false;
        }
        return true;
    }

    /// Returns: The integral part of the amount (value / 1 BOA)
    public ulong integral () const
    {
        return this.value / UnitPerCoin.value;
    }

    /// Returns: The decimal part of the amount (value % 1 BOA)
    public ulong decimal () const
    {
        return this.value % UnitPerCoin.value;
    }

    /// Convenience version of `add` which asserts in case of overflow
    /// Prefer using this only in `unittest`s
    public ref Amount mustAdd (Amount other)
    {
        this.add(other) || assert(0);
        return this;
    }

    /// Convenience version of `sub` which asserts in case of underflow
    /// Prefer using this only in `unittest`s
    public ref Amount mustSub (Amount other)
    {
        this.sub(other) || assert(0);
        return this;
    }

    /// Make a value without checking bounds
    /// Used to initialize the bounds themselves, and to make invalid values
    /// in unittests
    private this (ulong units, bool dummy) { this.value = units; }
    /// Ditto
    version (unittest)
    public static Amount invalid (ulong units) { return Amount(units, true); }
}

///
nothrow pure @nogc @safe unittest
{
    // Typical use case is to do `if (!op) error_handling;`
    Amount two = Amount.UnitPerCoin;
    assert(two.add(two));
    assert(two.sub(two));

    // The value is still valid
    assert(two.isValid());

    // This should error
    assert(!two.sub(Amount(1)));

    // The value was poisoned
    assert(!two.isValid());
    // Even substracting it to itself (which should yield 0) doesn't work
    assert(!two.sub(two));
    // But can be reset to a sane value if needed
    two = Amount(1);
    assert(two.sub(Amount(1)));

    // mustAdd / mustSub coverage
    two.mustAdd(Amount(1));
    assert(two == Amount(1));
    two.mustSub(Amount(1));
    assert(two == Amount(0));
}

pure @safe unittest
{
    import std.exception;
    assert(Amount.fromString(`5000000000000000`) == Amount.MaxUnitSupply);
    assertThrown!Exception(Amount.fromString(`5000000000000001`));
    Amount maxv = Amount.MaxUnitSupply;
    assert(maxv.isValid());
    assert(!maxv.add(Amount(1)));
    assert(!maxv.isValid());
}

pure @safe nothrow @nogc unittest
{
    assert(Amount.UnitPerCoin.integral() == 1);
    assert(Amount.UnitPerCoin.decimal() == 0);

    assert(Amount.MaxUnitSupply.integral() == 500_000_000);
    assert(Amount.MaxUnitSupply.decimal() == 0);

    assert(Amount(500).integral() == 0);
    assert(Amount(500).decimal() == 500);

    assert(Amount(100_500_000).integral() == 10);
    assert(Amount(100_500_000).decimal() == 500_000);

    assert(Amount.FreezeAmount.decimal() == 0);
    assert(Amount.FreezeAmount.integral() == 40_000);
}

unittest
{
    import agora.common.Deserializer;
    import agora.common.Serializer;

    Amount val = Amount.UnitPerCoin;
    ubyte[] serialized = val.serializeFull();
    assert(serialized.deserializeFull!Amount() == val);
}
