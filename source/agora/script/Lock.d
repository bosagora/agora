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
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.script.Lock;

import std.traits : EnumMembers;

/// Contains a tag and either a Hash or set of opcodes
public struct Lock
{
    /// Specifies the type of lock script
    public LockType type;

    /// May either be a Hash, or a sequence of opcodes
    public const(ubyte)[] bytes;
}

/// Contains a data tuple or a set of push opcodes
public struct Unlock
{
    /// May be: <signature>, <signature, key>, <push opcodes>
    public const(ubyte)[] bytes;
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
