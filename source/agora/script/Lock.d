/*******************************************************************************

    Contains the Lock / Unlock definitions

    These are the types that will ultimately
    replace the `signature` in the `Input` and the `address` in the `Output`.

    The Lock type contains a tag, allowing 4 different types of lock scripts:

    Key => lock is a 64-byte public key,
           unlock is expected to be a signature.
    KeyHash => lock is a hash of a 64-byte public key,
               unlock is expected to be a pair of
               <signature, public-key>.
               This form may be used for better privacy.
    Script => lock is a script that will be evaluated
              by the engine. The unlock script may either
              be empty or only contain stack push opcodes.
    Redeem => lock is a <redeem-hash>, and unlock may
              only contain stack push opcodes, where the
              last push will be read as the redeem script.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.script.Lock;

import agora.common.Types;
import agora.crypto.ECC;
import agora.crypto.Key;
import agora.crypto.Schnorr: Signature;
import agora.script.Script;
import agora.script.Signature;
import agora.utils.Utility;
import std.format;
import std.traits : EnumMembers;

/// Contains a tag and either a Hash or set of opcodes
public struct Lock
{
    /// Specifies the type of lock script
    public LockType type;

    /// May either be a Hash, or a sequence of opcodes
    public const(ubyte)[] bytes;

    ///
    public void toString (scope void delegate (scope const(char)[]) @safe sink)
        const @safe
    {
        final switch (this.type)
        {
        case LockType.Key:
            const pub = PublicKey(this.bytes);
            pub.toString(sink);
            break;
        case LockType.KeyHash:
        case LockType.Script:
        case LockType.Redeem:
            // Mimic default behavior
            formattedWrite(sink, "Lock(%s, %s)", this.type, UbyteHexString(this.bytes));
            break;
        }
    }

    /// The size of the Lock object
    public ulong sizeInBytes () const nothrow pure @safe @nogc
    {
        return this.type.sizeof + this.bytes.length * this.bytes[0].sizeof;
    }

    /// Support for sorting
    public int opCmp (in typeof(this) rhs) const nothrow @safe @nogc
    {
        import std.algorithm;

        if (cast(int)this.type == cast(int)rhs.type)
            return cmp(this.bytes, rhs.bytes);
        return cast(int)this.type < cast(int)rhs.type ? -1 : 1;
    }
}

unittest
{
    import std.algorithm;
    import std.array;

    auto lock1 = Lock(LockType.Key,     [153, 223, 171, 200, 195, 76, 197, 30, 122, 135, 199, 165, 59, 248, 20, 63, 104, 203, 140, 183, 177, 199, 208, 11, 136, 169, 69, 145, 67, 250, 64, 156]);
    auto lock2 = Lock(LockType.Key,     [153, 223, 171, 100, 195, 76, 197, 30, 122, 135, 199, 165, 59, 248, 20, 63, 104, 203, 140, 183, 177, 199, 208, 11, 136, 169, 69, 145, 67, 250, 64, 156]);
    auto lock3 = Lock(LockType.KeyHash, [153, 223, 171, 250, 195, 76, 197, 30, 122, 135, 199, 165, 59, 248, 20, 63, 104, 203, 140, 183, 177, 199, 208, 11, 136, 169, 69, 145, 67, 250, 64, 156]);
    auto lock4 = Lock(LockType.Key,     [153, 223, 171, 250, 195, 76, 197, 30, 122, 135, 199, 165, 59, 248, 20, 63, 104, 203, 140, 183, 177, 199, 208, 11, 136, 169, 69, 145, 67, 250, 64, 156]);
    auto locks = [ lock1, lock2, lock3, lock4];
    locks.sort();
    assert(locks == [ lock2, lock1, lock4, lock3 ]);
}

unittest
{
    auto kp = KeyPair.random();
    assert(format("%s", Lock(LockType.Key, kp.address[])) ==
           format("%s", kp.address));
    assert(format("%s", Lock(LockType.Script, [42, 69, 250])) == "Lock(Script, 2a45fa)");
}


/*******************************************************************************

    Validates the Lock script's syntax on its own. For user's safety,
    Agora's protocol rules disallow accepting an Output with a syntactically
    invalid Lock script. This prevents accidental loss of funds, for example
    in cases where the lock script is ill-formed (e.g. missing END blocks,
    dangling ELSE statements, etc).

    The semantics of the lock script are not checked here as it requires
    an unlock script to run it with. This responsibility lies within the
    script execution engine.

    Params:
        lock = the lock to validate
        StackMaxItemSize = maximum allowed payload size for a
            stack push operation

    Returns:
        null if the lock is syntactically valid,
        otherwise the string explaining the reason why it's invalid

*******************************************************************************/

public string validateLockSyntax (in Lock lock, in ulong StackMaxItemSize)
    /*pure*/ nothrow @safe @nogc
{
    // assumed sizes
    static assert(Point.sizeof == 32);
    static assert(Hash.sizeof == 64);

    final switch (lock.type)
    {
    case LockType.Key:
        if (lock.bytes.length != Point.sizeof)
            return "LockType.Key requires 32-byte key argument in the lock script";
        const Point key = Point(lock.bytes);
        if (!key.isValid())
            return "LockType.Key 32-byte public key in lock script is invalid";

        return null;

    case LockType.KeyHash:
        if (lock.bytes.length != Hash.sizeof)
            return "LockType.KeyHash requires a 64-byte key hash argument in the lock script";

        return null;

    case LockType.Script:
        Script _lock_script;
        return validateScriptSyntax(ScriptType.Lock, lock.bytes, StackMaxItemSize,
            _lock_script);

    case LockType.Redeem:
        if (lock.bytes.length != Hash.sizeof)
            return "LockType.Redeem requires 64-byte script hash in the lock script";
        return null;
    }
}

///
unittest
{
    import agora.script.Opcodes;
    import std.bitmanip;
    immutable StackMaxItemSize = 512;

    /* LockType.Key */
    Lock lock = { type : LockType.Key };
    assert(validateLockSyntax(lock, StackMaxItemSize) ==
        "LockType.Key requires 32-byte key argument in the lock script");
    lock.bytes.length = Point.sizeof;
    assert(validateLockSyntax(lock, StackMaxItemSize) ==
        "LockType.Key 32-byte public key in lock script is invalid");
    const rand_key = Scalar.random().toPoint();
    lock.bytes = rand_key[];
    assert(validateLockSyntax(lock, StackMaxItemSize) == null);

    /* LockType.KeyHash */
    lock.type = LockType.KeyHash;
    lock.bytes.length = 0;
    assert(validateLockSyntax(lock, StackMaxItemSize) ==
        "LockType.KeyHash requires a 64-byte key hash argument in the lock script");
    lock.bytes.length = Hash.sizeof;  // any 64-byte number is a valid hash
    assert(validateLockSyntax(lock, StackMaxItemSize) == null);

    /* LockType.Script */
    lock.type = LockType.Script;
    lock.bytes.length = 0;
    assert(validateLockSyntax(lock, StackMaxItemSize) ==
        "Lock script must not be empty");
    const ubyte[2] no_overflow = nativeToLittleEndian(
        ushort(StackMaxItemSize));
    const ubyte[2] size_overflow = nativeToLittleEndian(
        ushort(StackMaxItemSize + 1));
    const ubyte[StackMaxItemSize] max_payload;
    lock.bytes = [ubyte(OP.PUSH_DATA_2)] ~ size_overflow ~ max_payload;
    assert(validateLockSyntax(lock, StackMaxItemSize) ==
        "PUSH_DATA_2 opcode payload size is not within StackMaxItemSize limits");
    lock.bytes = [ubyte(OP.PUSH_DATA_2)] ~ no_overflow ~ max_payload;
    assert(validateLockSyntax(lock, StackMaxItemSize) == null);

    /* LockType.Redeem */
    lock.type = LockType.Redeem;
    lock.bytes.length = 0;
    assert(validateLockSyntax(lock, StackMaxItemSize) ==
        "LockType.Redeem requires 64-byte script hash in the lock script");
    lock.bytes.length = Hash.sizeof;  // any 64-byte number is a valid hash
    assert(validateLockSyntax(lock, StackMaxItemSize) == null);
}

/// Contains a data tuple or a set of push opcodes
public struct Unlock
{
    /// May be: <signature>, <signature, key>, <push opcodes>
    public const(ubyte)[] bytes;

    ///
    public void toString (scope void delegate (scope const(char)[]) @safe sink)
        const @safe
    {
        sink("0x");
        UbyteHexString(this.bytes).toString(sink);
    }

    /// The size of the Unlock object
    public ulong sizeInBytes () const nothrow pure @safe @nogc
    {
        return this.bytes.length * this.bytes[0].sizeof;
    }
}

unittest
{
    assert(format("%s", Unlock([250, 69, 42])) == "0xfa452a");
}

/// The input lock types.
public enum LockType : ubyte
{
    /// lock is a 64-byte public key, unlock is the signature
    Key = 0x0,

    /// lock is a 64-byte public key hash, unlock is a (sig, key) pair
    KeyHash = 0x01,

    /// lock is a script, unlock may be anything required by the lock script
    Script = 0x02,

    /// lock is a 64-byte hash of a script, unlock is the script containing
    /// only stack pushes which will push the redeem script last
    Redeem = 0x03,
}

/*******************************************************************************

    Converts the byte to one of the recognized lock types.

    Params:
        value = the byte containing the lock type
        lock = will contain the lock type if it was recognized

    Returns:
        true if the value is a recognized opcode

*******************************************************************************/

public bool toLockType (in ubyte value, out LockType lock)
    pure nothrow @safe @nogc
{
    switch (value)
    {
        foreach (member; EnumMembers!LockType)
        {
            case member:
            {
                lock = member;
                return true;
            }
        }

        default:
            return false;
    }
}

///
pure nothrow @safe @nogc unittest
{
    LockType lt;
    assert(0x00.toLockType(lt) && lt == LockType.Key);
    assert(0x01.toLockType(lt) && lt == LockType.KeyHash);
    assert(!255.toLockType(lt));
}

/*******************************************************************************

    Generates a LockType.Key lock script.

    Params:
        key = the public key which can unlock this lock script

    Returns:
        the lock script

*******************************************************************************/

public Lock genKeyLock (in Point key) pure nothrow @safe
{
    // must create a copy because we're slicing a static array
    return Lock(LockType.Key, key[].dup);
}

/// Compatibility (however may only be signed with Schnorr)
public Lock genKeyLock (in PublicKey key) pure nothrow @safe
{
    // must create a copy because we're slicing a static array
    return Lock(LockType.Key, key[].dup);
}

/*******************************************************************************

    Generates a LockType.Key unlock script.

    Params:
        sig = the signature that will be embedded in the script

    Returns:
        the unlock script

*******************************************************************************/

public Unlock genKeyUnlock (in Signature sig, in SigHash sig_hash = SigHash.All) pure nothrow @safe
{
    // must dupe because it's a value on the stack..
    return Unlock(SigPair(sig, sig_hash)[].dup);
}
