/*******************************************************************************

    Contains the script definition and syntactical opcode validation.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.script.Script;

import agora.common.crypto.ECC;
import agora.common.Hash;
import agora.script.Opcodes;
import agora.script.Stack;

import ocean.core.Test;

import std.bitmanip;
import std.conv;
import std.range;
import std.traits;

/// The type of script
public enum ScriptType
{
    /// may contain any opcodes
    Lock,

    /// redeem is treated as a lock script (all opcodes allowed)
    Redeem = Lock,

    /// may only contain stack push opcodes
    Unlock,
}

/// Contains a syntactically validated set of script opcodes
public struct Script
{
    /// opcodes + any associated data for each push opcode
    private const(ubyte)[] opcodes;

    /***************************************************************************

        Internal. Use the `validateScript()` free function to construct
        a validated Script out of a byte array of opcodes.

        Params:
            opcodes = the set of validated opcodes for this script type

    ***************************************************************************/

    private this (const(ubyte)[] opcodes) pure nothrow @safe @nogc
    {
        this.opcodes = opcodes;
    }

    /***************************************************************************

        Returns:
            the byte array of the script

    ***************************************************************************/

    public const(ubyte)[] opSlice () const pure nothrow @safe @nogc
    {
        return this.opcodes[];
    }
}

/*******************************************************************************

    Validates the set of given opcodes syntactically, but not semantically.
    Each opcode is checked if it's one of the known opcodes, and any push
    opcodes have payloads checked for size constraints.

    The semantics of the script are not checked here. This responsibility
    lies within the script execution engine.

    Lock scripts may contain any of the supported opcodes,
    whereas unlocks scripts may only consist of stack push opcodes.
    This is for security reasons. If any opcodes were allowed, the unlock script
    could potentially cause premature successfull script evaluation without
    satisfying the constraints of the lock script.

    Redeem scripts are treated the same as lock scripts.

    Params:
        type = the type of the script (lock / unlock / redeem)
        opcodes = the set of opcodes to validate
        StackMaxItemSize = maximum allowed payload size for a
            stack push operation
        script = will contain the validated Script if there were no errors

    Returns:
        null if the set of opcodes are syntactically valid,
        otherwise the string explaining the reason why they're invalid

*******************************************************************************/

public string validateScript (in ScriptType type, in ubyte[] opcodes,
    in ulong StackMaxItemSize, out Script script) pure nothrow @safe @nogc
{
    const(ubyte)[] bytes = opcodes[];
    if (bytes.empty)
        return null;  // empty scripts are syntactically valid

    // todo: add script size checks (based on consensus params)

    while (!bytes.empty())
    {
        OP opcode;
        if (!bytes.front.toOPCode(opcode))
            return "Script contains an unrecognized opcode";

        bytes.popFront();
        switch (opcode)
        {
        case OP.PUSH_DATA_1:
            if (auto reason = isInvalidPushReason!(OP.PUSH_DATA_1)(bytes,
                StackMaxItemSize))
                return reason;
            else break;

        case OP.PUSH_DATA_2:
            if (auto reason = isInvalidPushReason!(OP.PUSH_DATA_2)(bytes,
                StackMaxItemSize))
                return reason;
            else break;

        case OP.PUSH_BYTES_1: .. case OP.PUSH_BYTES_75:
            const payload_size = opcode;  // encoded in the opcode
            if (bytes.length < payload_size)
                return "PUSH_BYTES_* opcode exceeds total script size";

            bytes.popFrontN(payload_size);
            break;

        case OP.PUSH_NUM_1: .. case OP.PUSH_NUM_5:
            break;

        default:
            break;
        }

        final switch (type)
        {
        case ScriptType.Lock:
            break;
        case ScriptType.Unlock:
            if (opcode > OP.TRUE)
                return "Unlock script may only contain stack pushes";
            break;
        }
    }

    script = Script(opcodes);
    return null;
}

//
unittest
{
    immutable StackMaxItemSize = 512;
    Script result;

    // empty scripts are syntactically valid
    test!"=="(validateScript(
        ScriptType.Lock, [], StackMaxItemSize, result), null);
    test!"=="(validateScript(
        ScriptType.Unlock, [], StackMaxItemSize, result), null);

    // only pushes are allowed for unlock
    test!"=="(validateScript(ScriptType.Unlock, [OP.FALSE], StackMaxItemSize,
        result),
        null);
    test!"=="(validateScript(ScriptType.Unlock,
        [OP.PUSH_NUM_1, OP.PUSH_NUM_2, OP.PUSH_NUM_3, OP.PUSH_NUM_4, OP.PUSH_NUM_5],
        StackMaxItemSize, result),
        null);
    test!"=="(validateScript(ScriptType.Unlock, [OP.PUSH_BYTES_1, 1],
        StackMaxItemSize, result), null);
    test!"=="(validateScript(ScriptType.Unlock, [OP.PUSH_BYTES_1, 1, OP.HASH],
        StackMaxItemSize, result),
        "Unlock script may only contain stack pushes");

    test!"=="(validateScript(ScriptType.Lock, [255], StackMaxItemSize, result),
        "Script contains an unrecognized opcode");

    // PUSH_BYTES_*
    test!"=="(validateScript(ScriptType.Lock, [1], StackMaxItemSize, result),
        "PUSH_BYTES_* opcode exceeds total script size");
    // 1-byte data payload
    test!"=="(.validateScript(ScriptType.Lock, [1, 255], StackMaxItemSize,
        result), null);
    test!"=="(validateScript(ScriptType.Lock, [2], StackMaxItemSize, result),
        "PUSH_BYTES_* opcode exceeds total script size");
    test!"=="(validateScript(ScriptType.Lock, [2, 255], StackMaxItemSize,
        result),
        "PUSH_BYTES_* opcode exceeds total script size");
    // 2-byte data payload
    test!"=="(validateScript(ScriptType.Lock, [2, 255, 255], StackMaxItemSize,
        result), null);
    ubyte[75] payload_75;
    test!"=="(validateScript(ScriptType.Lock, [ubyte(75)] ~ payload_75[0 .. 74],
        StackMaxItemSize, result),
        "PUSH_BYTES_* opcode exceeds total script size");
    // 75-byte data payload
    test!"=="(validateScript(ScriptType.Lock, [ubyte(75)] ~ payload_75,
        StackMaxItemSize, result), null);

    // PUSH_DATA_*
    const ubyte[2] size_1 = nativeToLittleEndian(ushort(1));
    const ubyte[2] size_max = nativeToLittleEndian(ushort(StackMaxItemSize));
    const ubyte[StackMaxItemSize] max_payload;
    const ubyte[2] size_overflow = nativeToLittleEndian(
        ushort(StackMaxItemSize + 1));

    test!"=="(validateScript(ScriptType.Lock, [OP.PUSH_DATA_1],
        StackMaxItemSize, result),
        "PUSH_DATA_1 opcode requires 1 byte(s) for the payload size");
    test!"=="(validateScript(ScriptType.Lock, [OP.PUSH_DATA_1, 0],
        StackMaxItemSize, result),
        "PUSH_DATA_1 opcode payload size is not within StackMaxItemSize limits");
    test!"=="(validateScript(ScriptType.Lock, [OP.PUSH_DATA_1, 1],
        StackMaxItemSize, result),
        "PUSH_DATA_1 opcode payload size exceeds total script size");
    test!"=="(validateScript(ScriptType.Lock, [OP.PUSH_DATA_1, 1, 1],
        StackMaxItemSize, result), null);
    test!"=="(validateScript(ScriptType.Lock, [OP.PUSH_DATA_2],
        StackMaxItemSize, result),
        "PUSH_DATA_2 opcode requires 2 byte(s) for the payload size");
    test!"=="(validateScript(ScriptType.Lock, [OP.PUSH_DATA_2, 0],
        StackMaxItemSize, result),
        "PUSH_DATA_2 opcode requires 2 byte(s) for the payload size");
    test!"=="(validateScript(ScriptType.Lock, [OP.PUSH_DATA_2, 0, 0],
        StackMaxItemSize, result),
        "PUSH_DATA_2 opcode payload size is not within StackMaxItemSize limits");
    test!"=="(validateScript(ScriptType.Lock, [ubyte(OP.PUSH_DATA_2)] ~ size_1,
        StackMaxItemSize, result),
        "PUSH_DATA_2 opcode payload size exceeds total script size");
    test!"=="(validateScript(ScriptType.Lock,
        [ubyte(OP.PUSH_DATA_2)] ~ size_1 ~ [ubyte(1)], StackMaxItemSize,
        result), null);
    test!"=="(validateScript(ScriptType.Lock,
        [ubyte(OP.PUSH_DATA_2)] ~ size_max ~ max_payload, StackMaxItemSize,
        result), null);
    test!"=="(validateScript(ScriptType.Lock,
        [ubyte(OP.PUSH_DATA_2)] ~ size_overflow ~ max_payload,
        StackMaxItemSize, result),
        "PUSH_DATA_2 opcode payload size is not within StackMaxItemSize limits");
    test!"=="(validateScript(ScriptType.Lock,
        [ubyte(OP.PUSH_DATA_2)] ~ size_max ~ max_payload ~ OP.HASH,
        StackMaxItemSize, result),
        null);
    test!"=="(validateScript(ScriptType.Lock,
        [ubyte(OP.PUSH_DATA_2)] ~ size_max ~ max_payload ~ ubyte(255),
        StackMaxItemSize, result),
        "Script contains an unrecognized opcode");
}

/*******************************************************************************

    Checks the validity of a `PUSH_DATA_*` opcode and advances
    the `bytes` array if the payload does not exceed the array.

    Params:
        OP = the associated `PUSH_DATA_*` opcode
        bytes = the opcode byte array
        StackMaxItemSize = maximum allowed payload size for a
            stack push operation

    Returns:
        null if the opcode is syntactically valid,
        otherwise the string explaining the reason why it's invalid

*******************************************************************************/

private string isInvalidPushReason (OP op)(ref const(ubyte)[] bytes,
    in ulong StackMaxItemSize) pure nothrow @safe @nogc
{
    static assert(op == OP.PUSH_DATA_1 || op == OP.PUSH_DATA_2);
    alias T = Select!(op == OP.PUSH_DATA_1, ubyte, ushort);
    if (bytes.length < T.sizeof)
    {
        static immutable err1 = op.to!string ~ " opcode requires "
            ~ T.sizeof.to!string ~ " byte(s) for the payload size";
        return err1;
    }

    const T size = littleEndianToNative!T(bytes[0 .. T.sizeof]);
    if (size == 0 || size > StackMaxItemSize)
    {
        static immutable err2 = op.to!string
            ~ " opcode payload size is not within StackMaxItemSize limits";
        return err2;
    }

    bytes.popFrontN(T.sizeof);
    if (bytes.length < size)
    {
        static immutable err3 = op.to!string
            ~ " opcode payload size exceeds total script size";
        return err3;
    }

    bytes.popFrontN(size);
    return null;
}

/*******************************************************************************

    Create a bitcoin-style P2PKH lock script.

    Params:
        key_hash = the key hash to encode in the P2PKH lock script

    Returns:
        a P2PKH lock script which can be unlocked with the matching
        public key & signature

*******************************************************************************/

version (unittest)
public Script createLockP2PKH (Hash key_hash) pure nothrow @safe
{
    return Script([ubyte(OP.DUP), ubyte(OP.HASH)]
        ~ [ubyte(64)] ~ key_hash[]
        ~ [ubyte(OP.VERIFY_EQUAL), ubyte(OP.CHECK_SIG)]);
}

/*******************************************************************************

    Create a bitcoin-style P2PKH unlock script.

    Params:
        sig = the signature
        pub_key = the public key

    Returns:
        a P2PKH unlock script which can be used with the associated lock script

*******************************************************************************/

version (unittest)
public Script createUnlockP2PKH (Signature sig, Point pub_key)
    pure nothrow @safe
{
    return Script([ubyte(64)] ~ sig[] ~ [ubyte(32)] ~ pub_key[]);
}

///
unittest
{
    import agora.common.crypto.Schnorr;
    import agora.utils.Test;

    Script result;
    Pair kp = Pair.random();
    auto sig = sign(kp, "Hello world");

    // sanity checks
    const key_hash = hashFull(kp.V);
    Script lock_script = createLockP2PKH(key_hash);
    assert(validateScript(ScriptType.Lock, lock_script[], 512, result) is null);
    Script unlock_script = createUnlockP2PKH(sig, kp.V);
    assert(validateScript(ScriptType.Unlock, unlock_script[], 512, result)
        is null);
}

/*******************************************************************************

    Creates a `PUSH_BYTES_*` or `PUSH_DATA_*` opcode based on the length of
    the data. It does not verify data limits for the stack, as this check
    belongs in the Stack and the Engine. Additionally it's useful to be able to
    create exceeding data buffers with this function for testing purposes.

    Params:
        data = the data to create the opcode and payload for

    Returns:
        a byte array containing the opcode and the payload

*******************************************************************************/

version (unittest)
public ubyte[] toPushOpcode (in ubyte[] data) pure nothrow @safe
{
    assert(data.length > 0);
    if (data.length <= 75)
    {
        return [cast(ubyte)data.length] ~ data;
    }
    else if (data.length <= ubyte.max)
    {
        return [ubyte(OP.PUSH_DATA_1), cast(ubyte)data.length] ~ data;
    }
    else if (data.length <= ushort.max)
    {
        return [ubyte(OP.PUSH_DATA_2)]
            ~ nativeToLittleEndian(cast(ushort)data.length) ~ data;
    }
    else
    {
        assert(0);  // size too big
    }
}

///
/*pure @safe nothrow*/ // test!() is missing attributes
unittest
{
    import std.array;
    import std.range;
    test!("==")(ubyte(42).repeat(75).array.toPushOpcode(),
        [75] ~ 42.repeat(75).array);
    test!("==")(ubyte(42).repeat(255).array.toPushOpcode(),
        [76, 255] ~ 42.repeat(255).array);
    test!("==")(ubyte(42).repeat(500).array.toPushOpcode(),
        [77, 244, 1] ~ 42.repeat(500).array);  // little-endian form
}

/*******************************************************************************

    Create a non-validated script. Purposefully used in tests to ensure
    the script execution engine behaves well when fed invalid scripts.

    Params:
        opcodes = the opcodes to initialize the script with

    Returns:
        a Script instance

*******************************************************************************/

version (unittest)
public Script makeScript (in ubyte[] opcodes) pure nothrow @safe @nogc
{
    return Script(opcodes);
}
