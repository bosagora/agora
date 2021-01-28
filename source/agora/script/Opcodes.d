/*******************************************************************************

    Contains the supported opcodes for the basic execution engine (non-webASM)

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.script.Opcodes;

import std.traits : EnumMembers;

/*******************************************************************************

    The supported opcodes for the script execution engine.

    Opcodes named `CHECK_*` push their result to the stack,
    whereas `VERIFY_*` opcodes will cause the script execution to fail.

    We can encode up to 255 opcodes (one of which is INVALID to halt execution).

    Note that the range of values between `PUSH_BYTES_1` and `PUSH_BYTES_75`
    encodes a push to the stack between 1 .. 75 bytes. This range was chosen
    to allow pushing one of our largest types (Hash / Signature) in a
    single opcode as well as any associated metadata (e.g. Signature + SigHash).

    For pushes of data longer than 75 bytes use one of the `PUSH_DATA_*`
    opcodes.

*******************************************************************************/

public enum OP : ubyte
{
    /// Used to encode a small data push to the stack (up to 75 bytes),
    /// may be used with `case PUSH_BYTES_1: .. case PUSH_BYTES_64:` syntax.
    PUSH_BYTES_1 = 0x01,

    /// Ditto
    PUSH_BYTES_75 = 0x4B, // 75 decimal

    /// The next 1 byte contains the number of bytes to push onto the stack.
    /// This opcode may not be used to encode data pushes of `<= 75` bytes.
    /// PUSH_BYTES_* must be used for this purpose instead.
    PUSH_DATA_1 = 0x4C,

    /// The next 2 bytes (ushort in LE format) contains the number of bytes to
    /// push onto the stack.
    /// This opcode may not be used to encode data pushes of `<= 255` bytes.
    /// `PUSH_DATA_1` must be used for this purpose instead.
    PUSH_DATA_2 = 0x4D,

    /// This opcode may be reserved for a future PUSH_DATA_4.
    // OP_RESERVED_1 = 0x4E,

    /// Pushes `1` to `5` to the stack. To be used with counts for some opcodes
    /// such as `CHECK_SEQ_SIG`.
    PUSH_NUM_1 = 0x4F,
    /// Ditto
    PUSH_NUM_2 = 0x50,
    /// Ditto
    PUSH_NUM_3 = 0x51,
    /// Ditto
    PUSH_NUM_4 = 0x52,
    /// Ditto
    PUSH_NUM_5 = 0x53,

    /// Pushes True onto the stack. Used by conditional opcodes.
    /// Additionally if after lock + unlock script execution the only
    /// value on the stack is TRUE, the script will be considered valid.
    /// Any other value (FALSE or otherwise) on the top of the stack
    /// after execution will cause the script to fail.
    TRUE = 0x54,

    /// Pushes False onto the stack. Used by conditional opcodes.
    FALSE = 0x00,

    /// Conditionals
    IF = 0x55,
    NOT_IF = 0x56,
    ELSE = 0x57,
    END_IF = 0x58,

    /// Pop the top item on the stack, hash it, and push the hash to the stack.
    /// Note that the item being hashed is a byte array.
    HASH = 0x59,

    /// Duplicate the item on the stack. Equivalent to `value = pop()` and
    /// `push(value); push(value);`
    DUP = 0x5A,

    /// Pops two items from the stack. Checks that the items are equal to each
    /// other, and pushes either `TRUE` or `FALSE` to the stack.
    CHECK_EQUAL = 0x5B,

    /// Ditto, but instead of pushing to the stack it will cause the script
    /// execution to fail if the two items are not equal to each other.
    VERIFY_EQUAL = 0x5C,

    /// Verify the height lock of a spending Transaction. Expects an 8-byte
    /// unsigned integer as the height on the stack, and verifies that the
    /// Transaction's `lock_height` is greater than or equal to this value.
    VERIFY_LOCK_HEIGHT = 0x5D,

    /// Verify the time lock of the associated spending Input. Expects a
    /// 4-byte unsigned integer as the unlock age on the stack, and verifies
    /// that the Input's `unlock_age` is greater than or equal to this value.
    VERIFY_UNLOCK_AGE = 0x5E,

    /// Pops two items from the stack. The two items must be a Point (Schnorr),
    /// and a Signature. If the items cannot be deserialized as a Point and
    /// Signature, the script validation fails.
    /// The signature is then validated using Schnorr, if the signature is
    /// valid then `TRUE` is pushed to the stack.
    CHECK_SIG = 0x5F,

    /// Ditto, but instead of pushing the result to the stack it will cause the
    /// script execution to fail if the signature is invalid
    VERIFY_SIG = 0x60,

    /// Expects a new sequence ID on the stack and an expected sequence ID
    /// on the stack. Verifies `sequence_id >= expected_id`, and adds
    /// `sequence_id` to the signature hash. The matching Input is blanked
    /// to implement floating transactions, as defined in Eltoo.
    CHECK_SEQ_SIG = 0x63,

    /// Ditto
    VERIFY_SEQ_SIG = 0x64,
}

/*******************************************************************************

    Converts the byte to an opcode,
    or returns false if it's an unrecognized opcode.

    Params:
        value = the byte containing the opcode
        opcode = will contain the opcode if it was recognized

    Returns:
        true if the value is a recognized opcode

*******************************************************************************/

public bool toOPCode (in ubyte value, out OP opcode) pure nothrow @safe @nogc
{
    switch (value)
    {
        foreach (member; EnumMembers!OP)
        {
            case member:
            {
                opcode = member;
                return true;
            }
        }

        default:
            break;
    }

    if (value >= 1 && value <= 75)  // PUSH_BYTES_1 .. PUSH_BYTES_64
    {
        opcode = cast(OP)value;  // dirty, but avoids having to define all pushes
        return true;
    }

    return false;
}

///
pure nothrow @safe @nogc unittest
{
    OP op;
    assert(0x00.toOPCode(op) && op == OP.FALSE);
    assert(0x59.toOPCode(op) && op == OP.HASH);
    assert(!255.toOPCode(op));
    assert(1.toOPCode(op) && op == OP.PUSH_BYTES_1);
    assert(32.toOPCode(op) && op == cast(OP)32);
    assert(75.toOPCode(op) && op == OP.PUSH_BYTES_75);
}

/*******************************************************************************

    Check if the opcode is a conditional

    Params:
        opcode = opcode to check

    Returns:
        true if the opcode is one of the conditional opcodes

*******************************************************************************/

public bool isConditional (in OP opcode) pure nothrow @safe @nogc
{
    switch (opcode)
    {
        case OP.IF, OP.NOT_IF, OP.ELSE, OP.END_IF:
            return true;
        default:
            return false;
    }
}

///
pure nothrow @safe @nogc unittest
{
    assert(OP.IF.isConditional);
    assert(OP.NOT_IF.isConditional);
    assert(OP.ELSE.isConditional);
    assert(OP.END_IF.isConditional);
    assert(!OP.TRUE.isConditional);
    assert(!OP.HASH.isConditional);
}

/*******************************************************************************

    Check if the opcode contains a payload

    Params:
        opcode = opcode to check

    Returns:
        true if the opcode contains a payload

*******************************************************************************/

public bool isPayload (in OP opcode) pure nothrow @safe @nogc
{
    return opcode >= OP.PUSH_BYTES_1 && opcode <= OP.PUSH_DATA_2;
}

///
pure nothrow @safe @nogc unittest
{
    assert(OP.PUSH_BYTES_1.isPayload);
    assert(OP.PUSH_BYTES_75.isPayload);
    assert(OP.PUSH_DATA_1.isPayload);
    assert(OP.PUSH_DATA_2.isPayload);
    assert(!OP.IF.isPayload);
    assert(!OP.NOT_IF.isPayload);
    assert(!OP.TRUE.isPayload);
}
