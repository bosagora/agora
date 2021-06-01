/*******************************************************************************

    Contains the script execution engine.

    Note that Bitcoin-style P2SH scripts are not detected,
    instead one should use LockType.Redeem in the Lock script tag.

    Things not currently implemented:
        - opcode weight calculation
        - opcode total cost limit

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.script.Engine;

import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.script.Lock;
import agora.script.Opcodes;
import agora.script.ScopeCondition;
import agora.script.Script;
import agora.script.Stack;

import std.bitmanip;
import std.conv;
import std.range;
import std.traits;

version (unittest)
{
    import agora.crypto.Schnorr;
    import agora.utils.Test;
    import ocean.core.Test;
    import std.stdio : writefln, writeln;  // avoid importing LockType
}

/// Ditto
public class Engine
{
    /// Opcodes cannot be pushed on the stack. We use a byte array as a marker.
    /// Conditional opcodes require the top item on the stack to be one of these
    private static immutable ubyte[1] TrueValue = [OP.TRUE];
    /// Ditto
    private static immutable ubyte[1] FalseValue = [OP.FALSE];

    /// Maximum total stack size
    private immutable ulong StackMaxTotalSize;

    /// Maximum size of an item on the stack
    private immutable ulong StackMaxItemSize;

    /***************************************************************************

        Initializes the script execution engine with the configured consensus
        limits.

        Params:
            StackMaxTotalSize = the maximum allowed stack size before a
                stack overflow, which would cause the script execution to fail.
                the script execution fails.
            StackMaxItemSize = maximum allowed size for a single item on
                the stack. If exceeded, script execution will fail during the
                syntactical validation of the script.

    ***************************************************************************/

    public this (ulong StackMaxTotalSize, ulong StackMaxItemSize)
    {
        assert(StackMaxItemSize > 0 && StackMaxTotalSize >= StackMaxItemSize);
        this.StackMaxTotalSize = StackMaxTotalSize;
        this.StackMaxItemSize = StackMaxItemSize;
    }

    /***************************************************************************

        Main dispatch execution routine.

        The lock type will be examined, and based on its type execution will
        proceed to either simple script-less payments, or script-based payments.

        Params:
            lock = the lock
            unlock = may contain a `signature`, `signature, key`,
                     or `script` which only contains stack push opcodes
            tx = the spending transaction
            input = the input which contained the unlock

        Returns:
            null if there were no errors,
            or a string explaining the reason execution failed

    ***************************************************************************/

    public string execute (in Lock lock, in Unlock unlock, in Transaction tx,
        in Input input) nothrow @safe
    {
        if (auto reason = validateLockSyntax(lock, this.StackMaxItemSize))
            return reason;

        final switch (lock.type)
        {
        case LockType.Key:
        case LockType.KeyHash:
            if (auto error = this.handleBasicPayment(lock, unlock, tx))
                return error;
            break;

        case LockType.Script:
            if (auto error = this.executeBasicScripts(lock, unlock, tx, input))
                return error;
            break;

        case LockType.Redeem:
            if (auto error = this.executeRedeemScripts(lock, unlock, tx, input))
                return error;
            break;
        }

        return null;
    }

    /***************************************************************************

        Handle stack-less and script-less basic payments.

        If the lock is a `Lock.Key` type, the unlock must only
        contain a `signature`.
        If the lock is a `Lock.KeyHash` type, the unlock must contain a
        `signature, key` tuple.

        Params:
            lock = must contain a `pubkey` or a `hash`
            unlock = must contain a `signature` or `signature, key` tuple
            tx = the spending transaction

        Returns:
            null if there were no errors,
            or a string explaining the reason execution failed

    ***************************************************************************/

    private string handleBasicPayment (in Lock lock, in Unlock unlock,
        in Transaction tx) nothrow @safe
    {
        // assumed sizes
        static assert(Point.sizeof == 32);
        static assert(Hash.sizeof == 64);

        switch (lock.type)
        {
        case LockType.Key:
            const Point key = Point(lock.bytes);
            if (unlock.bytes.length != Signature.sizeof)
                return "LockType.Key requires a 64-byte signature in the unlock script";
            const sig = unlock.bytes.toSignature();
            if (!verify(key, sig, tx))
                return "LockType.Key signature in unlock script failed validation";

            break;

        case LockType.KeyHash:
            const Hash key_hash = Hash(lock.bytes);
            const(ubyte)[] bytes = unlock.bytes;
            if (bytes.length != Signature.sizeof + Point.sizeof)
                return "LockType.KeyHash requires a 64-byte signature "
                     ~ "and a 32-byte key in the unlock script";
            const sig = bytes[0 .. Signature.sizeof].toSignature();
            bytes.popFrontN(Signature.sizeof);

            const Point key = Point(bytes);
            if (!key.isValid())
                return "LockType.KeyHash public key in unlock script is invalid";

            if (hashFull(key) != key_hash)
                return "LockType.KeyHash hash of key does not match key hash set in lock script";

            if (!verify(key, sig, tx))
                return "LockType.KeyHash signature in unlock script failed validation";

            break;

        default:
            assert(0);
        }

        return null;
    }

    /***************************************************************************

        Execute a `LockType.Script` type of lock script with the associated
        unlock script.

        The unlock script may only contain stack pushes.
        The unlock script is ran, producing a stack.
        Thereafter, the lock script will run with the stack of the
        unlock script.

        For security reasons, the two scripts are not concatenated together
        before execution. You may read more about it here:
        https://bitcoin.stackexchange.com/q/80258/93682

        Params:
            lock = the lock script
            unlock = the unlock script
            tx = the spending transaction
            input = the input which contained the unlock

        Returns:
            null if there were no errors,
            or a string explaining the reason execution failed

    ***************************************************************************/

    private string executeBasicScripts (in Lock lock,
        in Unlock unlock, in Transaction tx, in Input input) nothrow @safe
    {
        assert(lock.type == LockType.Script);

        Script unlock_script;
        if (auto error = validateScriptSyntax(ScriptType.Unlock, unlock.bytes,
            this.StackMaxItemSize, unlock_script))
            return error;

        Script lock_script = Script.assumeValidated(lock.bytes);
        Stack stack = Stack(this.StackMaxTotalSize, this.StackMaxItemSize);
        if (auto error = this.executeScript(unlock_script, stack, tx, input))
            return error;

        if (auto error = this.executeScript(lock_script, stack, tx, input))
            return error;

        if (this.hasScriptFailed(stack))
            return "Script failed";

        return null;
    }

    /***************************************************************************

        Execute a `LockType.Redeem` type of lock script with the associated
        lock script.

        The 64-byte hash of the redeem script is read from `lock_bytes`,
        `unlock_bytes` is evaluated as a set of pushes to the stack where
        the last push is the redeem script. The redeem script is popped from the
        stack, hashed, and compared to the previously extracted hash from the
        lock script. If the hashes match, the redeem script is evaluated with
        any leftover stack items of the unlock script.

        Params:
            lock = must contain a 64-byte hash of the redeem script
            unlock = must contain only stack push opcodes, where the last
                     push is the redeem script itself
            tx = the associated spending transaction
            input = the input which contained the unlock

        Returns:
            null if there were no errors,
            or a string explaining the reason execution failed

    ***************************************************************************/

    private string executeRedeemScripts (in Lock lock, in Unlock unlock,
        in Transaction tx, in Input input) nothrow @safe
    {
        assert(lock.type == LockType.Redeem);
        const Hash script_hash = Hash(lock.bytes);

        Script unlock_script;
        if (auto error = validateScriptSyntax(ScriptType.Unlock, unlock.bytes,
            this.StackMaxItemSize, unlock_script))
            return error;

        Stack stack = Stack(this.StackMaxTotalSize, this.StackMaxItemSize);
        if (auto error = this.executeScript(unlock_script, stack, tx, input))
            return error;

        if (stack.empty())
            return "LockType.Redeem requires unlock script to push a redeem script to the stack";

        const redeem_bytes = stack.pop();
        if (hashFull(redeem_bytes) != script_hash)
            return "LockType.Redeem unlock script pushed a redeem script "
                 ~ "which does not match the redeem hash in the lock script";

        Script redeem;
        if (auto error = validateScriptSyntax(ScriptType.Redeem, redeem_bytes,
            this.StackMaxItemSize, redeem))
            return error;

        if (auto error = this.executeScript(redeem, stack, tx, input))
            return error;

        if (this.hasScriptFailed(stack))
            return "Script failed";

        return null;
    }

    /***************************************************************************

        Execute the script with the given stack and the associated spending
        transaction. This routine may be called for all types of scripts,
        lock, unlock, and redeem scripts.

        An empty script will not fail execution. It's up to the calling code
        to differentiate when this is an allowed condition.

        Params:
            script = the script to execute
            stack = the stack to use for the script. May be non-empty.
            tx = the associated spending transaction
            input = the input which contained the unlock

        Returns:
            null if there were no errors,
            or a string explaining the reason execution failed

    ***************************************************************************/

    private string executeScript (in Script script, ref Stack stack,
        in Transaction tx, in Input input) nothrow @safe
    {
        // tracks executable condition of scopes for use with IF / ELSE / etc
        ScopeCondition sc;
        const(ubyte)[] bytes = script[];
        while (!bytes.empty())
        {
            OP opcode;
            if (!bytes.front.toOPCode(opcode))
                assert(0, "Script should have been syntactically validated");
            bytes.popFront();

            if (opcode.isConditional())
            {
                if (auto error = this.handleConditional(opcode, stack, sc))
                    return error;
                continue;
            }

            // must consume payload even if the scope is currently false
            const(ubyte)[] payload;
            switch (opcode)
            {
            case OP.PUSH_DATA_1:
                if (auto reason = this.readPayload!(OP.PUSH_DATA_1)(
                    bytes, payload))
                    return reason;
                break;

            case OP.PUSH_DATA_2:
                if (auto reason = this.readPayload!(OP.PUSH_DATA_2)(
                    bytes, payload))
                    return reason;
                break;

            case 1: .. case OP.PUSH_BYTES_75:
                const payload_size = opcode;  // encoded in the opcode
                if (bytes.length < payload_size)
                    assert(0);  // should have been validated

                payload = bytes[0 .. payload_size];
                bytes.popFrontN(payload.length);
                break;

            default:
                assert(!opcode.isPayload());  // missing cases
                break;
            }

            // whether the current scope is executable
            // (all preceeding outer conditionals were true)
            if (!sc.isTrue())
                continue;

            switch (opcode)
            {
            case OP.TRUE:
                if (!stack.canPush(TrueValue))
                    return "Stack overflow while pushing TRUE to the stack";
                stack.push(TrueValue);
                break;

            case OP.FALSE:
                if (!stack.canPush(FalseValue))
                    return "Stack overflow while pushing FALSE to the stack";
                stack.push(FalseValue);
                break;

            case OP.PUSH_DATA_1:
                if (!stack.canPush(payload))
                    return "Stack overflow while executing PUSH_DATA_1";
                stack.push(payload);
                break;

            case OP.PUSH_DATA_2:
                if (!stack.canPush(payload))
                    return "Stack overflow while executing PUSH_DATA_2";
                stack.push(payload);
                break;

            case 1: .. case OP.PUSH_BYTES_75:
                if (!stack.canPush(payload))
                    return "Stack overflow while executing PUSH_BYTES_*";

                stack.push(payload);
                break;

            case OP.PUSH_NUM_1: .. case OP.PUSH_NUM_5:
                static const ubyte[1] OneByte = [0];
                if (!stack.canPush(OneByte))
                    return "Stack overflow while executing PUSH_NUM_*";

                // note: must be GC-allocated!
                // todo: replace with preallocated values just like
                // `TrueValue` and `FalseValue`
                const ubyte[] number
                    = [cast(ubyte)((opcode + 1) - OP.PUSH_NUM_1)];
                stack.push(number);
                break;

            case OP.DUP:
                if (stack.empty)
                    return "DUP opcode requires an item on the stack";

                const top = stack.peek();
                if (!stack.canPush(top))
                    return "Stack overflow while executing DUP";
                stack.push(top);
                break;

            case OP.HASH:
                if (stack.empty)
                    return "HASH opcode requires an item on the stack";

                const ubyte[] top = stack.pop();
                const Hash hash = HashNoLength(top).hashFull();
                if (!stack.canPush(hash[]))  // e.g. hash(1 byte) => 64 bytes
                    return "Stack overflow while executing HASH";
                stack.push(hash[]);
                break;

            case OP.CHECK_EQUAL:
                if (stack.count() < 2)
                    return "CHECK_EQUAL opcode requires two items on the stack";

                const a = stack.pop();
                const b = stack.pop();
                stack.push(a == b ? TrueValue : FalseValue);  // canPush() check unnecessary
                break;

            case OP.VERIFY_EQUAL:
                if (stack.count() < 2)
                    return "VERIFY_EQUAL opcode requires two items on the stack";

                const a = stack.pop();
                const b = stack.pop();
                if (a != b)
                    return "VERIFY_EQUAL operation failed";
                break;

            case OP.CHECK_SIG:
                bool is_valid;
                if (auto error = this.verifySignature!(OP.CHECK_SIG)(
                    stack, tx, is_valid))
                    return error;

                // canPush() check unnecessary
                stack.push(is_valid ? TrueValue : FalseValue);
                break;

            case OP.VERIFY_SIG:
                bool is_valid;
                if (auto error = this.verifySignature!(OP.VERIFY_SIG)(
                    stack, tx, is_valid))
                    return error;

                if (!is_valid)
                    return "VERIFY_SIG signature failed validation";
                break;

            case OP.CHECK_MULTI_SIG:
                bool is_valid;
                if (auto error = this.verifyMultiSig!(OP.CHECK_MULTI_SIG)(
                    stack, tx, is_valid))
                    return error;

                // canPush() check unnecessary
                stack.push(is_valid ? TrueValue : FalseValue);
                break;

            case OP.VERIFY_MULTI_SIG:
                bool is_valid;
                if (auto error = this.verifyMultiSig!(OP.VERIFY_MULTI_SIG)(
                    stack, tx, is_valid))
                    return error;

                if (!is_valid)
                    return "VERIFY_MULTI_SIG signature failed validation";
                break;

            case OP.CHECK_SEQ_SIG:
                bool is_valid;
                if (auto error = this.verifySequenceSignature!(OP.CHECK_SEQ_SIG)(
                    stack, tx, input, is_valid))
                    return error;

                // canPush() check unnecessary
                stack.push(is_valid ? TrueValue : FalseValue);
                break;

            case OP.VERIFY_SEQ_SIG:
                bool is_valid;
                if (auto error = this.verifySequenceSignature!(OP.VERIFY_SEQ_SIG)(
                    stack, tx, input, is_valid))
                    return error;

                if (!is_valid)
                    return "VERIFY_SEQ_SIG signature failed validation";
                break;

            case OP.VERIFY_LOCK_HEIGHT:
                if (stack.empty())
                    return "VERIFY_LOCK_HEIGHT opcode requires a lock height on the stack";

                const height_bytes = stack.pop();
                if (height_bytes.length != ulong.sizeof)
                    return "VERIFY_LOCK_HEIGHT height lock must be an 8-byte number";

                const Height lock_height = Height(littleEndianToNative!ulong(
                    height_bytes[0 .. ulong.sizeof]));
                if (lock_height > tx.lock_height)
                    return "VERIFY_LOCK_HEIGHT height lock of transaction is too low";

                break;

            case OP.VERIFY_UNLOCK_AGE:
                if (stack.empty())
                    return "VERIFY_UNLOCK_AGE opcode requires an unlock age on the stack";

                const age_bytes = stack.pop();
                if (age_bytes.length != uint.sizeof)
                    return "VERIFY_UNLOCK_AGE unlock age must be a 4-byte number";

                const uint unlock_age = littleEndianToNative!uint(
                    age_bytes[0 .. uint.sizeof]);
                if (unlock_age > input.unlock_age)
                    return "VERIFY_UNLOCK_AGE unlock age of input is too low";

                break;

            default:
                assert(0);  // should have been handled
            }
        }

        if (!sc.empty())
            return "IF / NOT_IF requires a closing END_IF";

        return null;
    }

    /***************************************************************************

        Handle a conditional opcode like `OP.IF` / `OP.ELSE` / etc.

        The initial scope is implied to be true. When a new scope is entered
        via `OP.IF` / `OP.NOT_IF`, the condition is checked. If the condition
        is false, then all the code inside the `OP.IF` / `OP.NOT_IF`` block
        will be skipped until we exit into the first scope where the condition
        is true.

        Execution will fail if there is an `OP.ELSE` or `OP.END_IF` opcode
        without an associated `OP.IF` / `OP.NOT_IF` opcode.

        Currently trailing `OP.ELSE` opcodes are not rejected.
        This is also a quirk in the Bitcoin language, and should
        be fixed here later.
        (e.g. `IF { } ELSE {} ELSE {} ELSE {}` is allowed).

        Params:
            opcode = the current conditional
            stack = the stack to evaluate for the conditional
            sc = the scope condition which may be toggled by a condition change

        Returns:
            null if there were no errors,
            or a string explaining the reason execution failed

    ***************************************************************************/

    private string handleConditional (in OP opcode,
        ref Stack stack, ref ScopeCondition sc) nothrow @safe
    {
        switch (opcode)
        {
        case OP.IF:
        case OP.NOT_IF:
            if (!sc.isTrue())
            {
                sc.push(false);  // enter new scope, remain false
                break;
            }

            if (stack.empty())
                return "IF/NOT_IF opcode requires an item on the stack";

            const top = stack.pop();
            if (top != TrueValue && top != FalseValue)
                return "IF/NOT_IF may only be used with OP.TRUE / OP.FALSE values";

            sc.push((opcode == OP.IF) ^ (top == FalseValue));
            break;

        case OP.ELSE:
            if (sc.empty())
                return "Cannot have an ELSE without an associated IF / NOT_IF";
            sc.tryToggle();
            break;

        case OP.END_IF:
            if (sc.empty())
                return "Cannot have an END_IF without an associated IF / NOT_IF";
            sc.pop();
            break;

        default:
            assert(0);
        }

        return null;
    }

    /***************************************************************************

        Checks if the script has failed execution by examining its stack.
        The script is considered sucessfully executed only if its stack
        contains exactly one item, and that item being `TrueValue`.

        Params:
            stack = the stack to check

        Returns:
            true if the script is considered to have failed execution

    ***************************************************************************/

    private bool hasScriptFailed (/*in*/ ref Stack stack) // peek() is not const
        pure nothrow @safe
    {
        return stack.empty() || stack.peek() != TrueValue;
    }

    /***************************************************************************

        Reads the length and payload of the associated `PUSH_DATA_*` opcode,
        and advances the `opcodes` array to the next opcode.

        The length is read in little endian format.

        Params:
            OP = the associated `PUSH_DATA_*` opcode
            opcodes = the opcode / data byte array
            payload = will contain the payload if successfull

        Returns:
            null if reading the payload was successfull,
            otherwise the string explaining why it failed

    ***************************************************************************/

    private string readPayload (OP op)(ref const(ubyte)[] opcodes,
        out const(ubyte)[] payload) nothrow @safe /*@nogc*/
    {
        static assert(op == OP.PUSH_DATA_1 || op == OP.PUSH_DATA_2);
        alias T = Select!(op == OP.PUSH_DATA_1, ubyte, ushort);
        if (opcodes.length < T.sizeof)
            assert(0);  // script should have been validated

        const T size = littleEndianToNative!T(opcodes[0 .. T.sizeof]);
        if (size == 0 || size > this.StackMaxItemSize)
            assert(0);  // ditto

        opcodes.popFrontN(T.sizeof);
        if (opcodes.length < size)
            assert(0);  // ditto

        payload = opcodes[0 .. size];
        opcodes.popFrontN(size);  // advance to next opcode
        return null;
    }

    /***************************************************************************

        Reads the Signature and Public key from the stack,
        and validates the signature against the provided
        spending transaction.

        If the Signature and Public key are missing or in an invalid format,
        an error string is returned.

        Otherwise the signature is validated and the `sig_valid` parameter
        is set to the validation result.

        Params:
            OP = the opcode
            stack = should contain the Signature and Public Key
            tx = the transaction that should have been signed

        Returns:
            an error string if the Signature and Public key are missing or
            invalid, otherwise returns null.

    ***************************************************************************/

    private string verifySignature (OP op)(ref Stack stack, in Transaction tx,
        out bool sig_valid) nothrow @safe //@nogc  // stack.pop() is not @nogc
    {
        static assert(op == OP.CHECK_SIG || op == OP.VERIFY_SIG);

        // if changed, check assumptions
        static assert(Point.sizeof == 32);
        static assert(Signature.sizeof == 64);

        if (stack.count() < 2)
        {
            static immutable err1 = op.to!string
                ~ " opcode requires two items on the stack";
            return err1;
        }

        const key_bytes = stack.pop();
        if (key_bytes.length != Point.sizeof)
        {
            static immutable err2 = op.to!string
                ~ " opcode requires 32-byte public key on the stack";
            return err2;
        }

        const point = Point(key_bytes);
        if (!point.isValid())
        {
            static immutable err3 = op.to!string
                ~ " 32-byte public key on the stack is invalid";
            return err3;
        }

        const sig_bytes = stack.pop();
        if (sig_bytes.length != Signature.sizeof)
        {
            static immutable err4 = op.to!string
                ~ " opcode requires 64-byte signature on the stack";
            return err4;
        }

        const sig = sig_bytes.toSignature();
        sig_valid = verify(point, sig, tx);
        return null;
    }

    /***************************************************************************

        Verifies a threshold multi-signature. Any `N of M` configuration up to
        5 keys and 5 signatures is allowed.

        Reads a `count` from the stack, then reads `count` number of Public
        keys from the stack, then reads `req_count` from the stack, then reads
        `req_count` number of signatures from the stack.

        There need to be exactly `req_count` valid signatures on the stack.

        For each key it will try to validate against the first signature.
        When validation fails, it tries the next key with the same signature.
        When validation succeeds, it moves on to the next signature.

        The keys and signatures must be placed in the same order on the stack.

        If any of the Signatures or Public keys are missing or in an
        invalid format, an error string is returned.

        Otherwise the mult-sig is checked and the `sig_valid` parameter
        is set to the validation result.

        Params:
            OP = the opcode
            stack = should contain the count, the public keys,
                the count of required signatures
            tx = the transaction that should have been signed

        Returns:
            an error string if the Signature and Public key are missing or
            invalid, otherwise returns null.

    ***************************************************************************/

    private string verifyMultiSig (OP op)(ref Stack stack, in Transaction tx,
        out bool sig_valid) nothrow @safe //@nogc  // stack.pop() is not @nogc
    {
        static assert(op == OP.CHECK_MULTI_SIG || op == OP.VERIFY_MULTI_SIG);

        // if changed, check assumptions
        static assert(Point.sizeof == 32);
        static assert(Signature.sizeof == 64);

        // todo: move to consensus params?
        enum MAX_PUB_KEYS = 5;
        alias MAX_SIGNATURES = MAX_PUB_KEYS;

        // two counts plus the pubkeys and the signatures
        enum MAX_STACK_ITEMS = 2 + MAX_PUB_KEYS + MAX_SIGNATURES;

        // smallest possible stack is: <sig> <1> <pubkey> <1>
        if (stack.count() < 4)
        {
            static immutable err1 = op.to!string
                ~ " opcode requires at minimum four items on the stack";
            return err1;
        }

        if (stack.count() > MAX_STACK_ITEMS)
        {
            static immutable err2 = op.to!string
                ~ " opcode cannot accept more than " ~ MAX_PUB_KEYS.to!string
                ~ " keys and " ~ MAX_SIGNATURES.to!string
                ~ " signatures on the stack";
            return err2;
        }

        const pubkey_count_arr = stack.pop();
        if (pubkey_count_arr.length != 1)
        {
            static immutable err3 = op.to!string
                ~ " opcode requires 1-byte public key count on the stack";
            return err3;
        }

        const ubyte key_count = pubkey_count_arr[0];
        if (key_count < 1 || key_count > MAX_PUB_KEYS)
        {
            static immutable err4 = op.to!string
                ~ " opcode can accept between 1 to " ~ MAX_PUB_KEYS.to!string
                ~ " keys on the stack";
            return err4;
        }

        if (key_count > stack.count())
        {
            static immutable err5 = op.to!string
                ~ " not enough keys on the stack";
            return err5;
        }

        // buffer
        Point[MAX_PUB_KEYS] pub_keys_buffer;
        foreach (idx, ref key; pub_keys_buffer[0 .. key_count])
        {
            const key_bytes = stack.pop();
            if (key_bytes.length != Point.sizeof)
            {
                static immutable err6 = op.to!string
                    ~ " opcode requires 32-byte public key on the stack";
                return err6;
            }

            key = Point(key_bytes);
            if (!key.isValid())
            {
                static immutable err7 = op.to!string
                    ~ " 32-byte public key on the stack is invalid";
                return err7;
            }
        }

        // slice
        Point[] keys = pub_keys_buffer[0 .. key_count];

        const sig_count_arr = stack.pop();
        if (sig_count_arr.length != 1)
        {
            static immutable err8 = op.to!string
                ~ " opcode requires 1-byte signature count on the stack";
            return err8;
        }

        const ubyte sig_count = sig_count_arr[0];
        if (sig_count < 1 || sig_count > MAX_SIGNATURES)
        {
            static immutable err9 = op.to!string
                ~ " opcode can accept between 1 to "
                ~ MAX_SIGNATURES.to!string ~ " signatures on the stack";
            return err9;
        }

        if (sig_count > stack.count())
        {
            static immutable err10 = op.to!string
                ~ " not enough signatures on the stack";
            return err10;
        }

        if (sig_count > key_count)
        {
            static immutable err11 = op.to!string
                ~ " opcode cannot accept more signatures than there are keys";
            return err11;
        }

        // buffer
        Signature[MAX_SIGNATURES] sigs_buffer;
        foreach (idx, ref sig; sigs_buffer[0 .. sig_count])
        {
            const sig_bytes = stack.pop();
            if (sig_bytes.length != Signature.sizeof)
            {
                static immutable err12 = op.to!string
                    ~ " opcode requires 64-byte signature on the stack";
                return err12;
            }

            sig = sig_bytes.toSignature();
        }

        // slice
        Signature[] sigs = sigs_buffer[0 .. sig_count];

        // if there are no sigs left, validation succeeded.
        // if there are more sigs left than keys left it means we cannot reach
        // the minimum required signatures as there's not enough keys to
        // compare with.
        while (sigs.length > 0 && sigs.length <= keys.length)
        {
            if (verify(keys.front, sigs.front, tx))
                sigs.popFront();

            keys.popFront();
        }

        sig_valid = sigs.length == 0;
        return null;
    }

    /***************************************************************************

        Checks floating-transaction signatures for use with the Flash layer.

        Verifies the sequence signature by blanking the input, reading the
        minimum sequence, the key, the new sequence, and the signature off
        the stack and validates the signature.

        If any of the arguments expected on the stack are missing,
        an error string is returned.

        The `sig_valid` parameter will be set to the validation result
        of the signature.

        Params:
            OP = the opcode
            stack = should contain the Signature and Public Key
            tx = the transaction that should have been signed
            input = the associated Input to blank when signing
            sig_valid = will contain the signature validation result

        Returns:
            an error string if the needed arguments on the stack are missing,
            otherwise returns null

    ***************************************************************************/

    private string verifySequenceSignature (OP op)(ref Stack stack,
        in Transaction tx, in Input input, out bool sig_valid)
        nothrow @safe //@nogc  // stack.pop() is not @nogc
    {
        static assert(op == OP.CHECK_SEQ_SIG || op == OP.VERIFY_SEQ_SIG);

        // if changed, check assumptions
        static assert(Point.sizeof == 32);
        static assert(Signature.sizeof == 64);

        // top to bottom: <min_seq> <key> <new_seq> <sig>
        // lock script typically pushes <min_seq> <key>
        // while the unlock script pushes <new_seq> <sig>
        if (stack.count() < 4)
        {
            static immutable err1 = op.to!string
                ~ " opcode requires 4 items on the stack";
            return err1;
        }

        const min_seq_bytes = stack.pop();
        if (min_seq_bytes.length != ulong.sizeof)
        {
            static immutable err2 = op.to!string
                ~ " opcode requires 8-byte minimum sequence on the stack";
            return err2;
        }

        const ulong min_sequence = littleEndianToNative!ulong(
            min_seq_bytes[0 .. ulong.sizeof]);

        const key_bytes = stack.pop();
        if (key_bytes.length != Point.sizeof)
        {
            static immutable err3 = op.to!string
                ~ " opcode requires 32-byte public key on the stack";
            return err3;
        }

        const Point point = Point(key_bytes);
        if (!point.isValid())
        {
            static immutable err4 = op.to!string
                ~ " 32-byte public key on the stack is invalid";
            return err4;
        }

        const seq_bytes = stack.pop();
        if (seq_bytes.length != ulong.sizeof)
        {
            static immutable err5 = op.to!string
                ~ " opcode requires 8-byte sequence on the stack";
            return err5;
        }

        const ulong sequence = littleEndianToNative!ulong(
            seq_bytes[0 .. ulong.sizeof]);
        if (sequence < min_sequence)
        {
            static immutable err6 = op.to!string
                ~ " sequence is not equal to or greater than min_sequence";
            return err6;
        }

        const sig_bytes = stack.pop();
        if (sig_bytes.length != Signature.sizeof)
        {
            static immutable err7 = op.to!string
                ~ " opcode requires 64-byte signature on the stack";
            return err7;
        }

        const sig = sig_bytes.toSignature();

        // workaround: input index not explicitly passed in
        import std.algorithm : countUntil;
        const long input_idx = tx.inputs.countUntil(input);
        assert(input_idx != -1, "Input does not belong to this transaction");

        const Hash challenge = getSequenceChallenge(tx, sequence, input_idx);
        sig_valid = verify(point, sig, challenge);
        return null;
    }
}

/*******************************************************************************

    Gets the challenge hash for the provided transaction, sequence ID.

    Params:
        tx = the transaction to sign
        sequence = the sequence ID to hash
        input_idx = the associated input index we're signing for

    Returns:
        the challenge as a hash

*******************************************************************************/

public Hash getSequenceChallenge (in Transaction tx, in ulong sequence,
    in ulong input_idx) nothrow @safe
{
    assert(input_idx < tx.inputs.length, "Input index is out of range");

    Transaction cloned;
    // it's ok, we'll dupe the array before modification
    () @trusted { cloned = *cast(Transaction*)&tx; }();
    cloned.inputs = cloned.inputs.dup;
    cloned.inputs[input_idx] = Input.init;  // blank out matching input
    return hashMulti(cloned, sequence);
}

version (unittest)
{
    // sensible defaults
    private const TestStackMaxTotalSize = 16_384;
    private const TestStackMaxItemSize = 512;
}

// OP.DUP
unittest
{
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.DUP]), Unlock.init, Transaction.init,
            Input.init),
        "DUP opcode requires an item on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [1, 2, OP.CHECK_EQUAL]), Unlock.init,
            Transaction.init, Input.init),
        "CHECK_EQUAL opcode requires two items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [1, 1, OP.DUP, OP.CHECK_EQUAL]), Unlock.init,
            Transaction.init, Input.init),
        null);  // CHECK_EQUAL will always succeed after an OP.DUP
}

// OP.HASH
unittest
{
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.HASH]), Unlock.init, Transaction.init,
            Input.init),
        "HASH opcode requires an item on the stack");
    const ubyte[] bytes = [42];
    const Hash hash = HashNoLength(bytes).hashFull();
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(bytes)
            ~ [ubyte(OP.HASH)]
            ~ toPushOpcode(hash[])
            ~ [ubyte(OP.CHECK_EQUAL)]),
        Unlock.init, Transaction.init, Input.init),
        null);
}

// OP.CHECK_EQUAL
unittest
{
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Transaction tx;
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.CHECK_EQUAL]), Unlock.init, tx, Input.init),
        "CHECK_EQUAL opcode requires two items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script, [1, 1, OP.CHECK_EQUAL]),
        Unlock.init, tx, Input.init),
        "CHECK_EQUAL opcode requires two items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [1, 1, 1, 1, OP.CHECK_EQUAL]),
        Unlock.init, tx, Input.init),
        null);
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [1, 2, 1, 1, OP.CHECK_EQUAL]),
        Unlock.init, tx, Input.init),
        "Script failed");
}

// OP.VERIFY_EQUAL
unittest
{
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Transaction tx;
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.VERIFY_EQUAL]), Unlock.init, tx, Input.init),
        "VERIFY_EQUAL opcode requires two items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script, [1, 1, OP.VERIFY_EQUAL]),
        Unlock.init, tx, Input.init),
        "VERIFY_EQUAL opcode requires two items on the stack");
    test!("==")(engine.execute(   // OP.TRUE needed as VERIFY does not push to stack
        Lock(LockType.Script,
            [1, 1, 1, 1, OP.VERIFY_EQUAL, OP.TRUE]),
        Unlock.init, tx, Input.init),
        null);
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [1, 2, 1, 1, OP.VERIFY_EQUAL, OP.TRUE]),
        Unlock.init, tx, Input.init),
        "VERIFY_EQUAL operation failed");
}

// OP.CHECK_SIG
unittest
{
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Transaction tx;
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.CHECK_SIG]), Unlock.init, tx, Input.init),
        "CHECK_SIG opcode requires two items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script, [1, 1, OP.CHECK_SIG]),
        Unlock.init, tx, Input.init),
        "CHECK_SIG opcode requires two items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [1, 1, 1, 1, OP.CHECK_SIG]),
        Unlock.init, tx, Input.init),
        "CHECK_SIG opcode requires 32-byte public key on the stack");

    // invalid key (crypto_core_ed25519_is_valid_point() fails)
    Point invalid_key;
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(1), ubyte(1)]
            ~ [ubyte(32)] ~ invalid_key[]
            ~ [ubyte(OP.CHECK_SIG)]), Unlock.init, tx, Input.init),
        "CHECK_SIG 32-byte public key on the stack is invalid");

    Point valid_key = Point.fromString(
        "0x44404b654d6ddf71e2446eada6acd1f462348b1b17272ff8f36dda3248e08c81");
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(1), ubyte(1)]
            ~ [ubyte(32)] ~ valid_key[]
            ~ [ubyte(OP.CHECK_SIG)]), Unlock.init, tx, Input.init),
        "CHECK_SIG opcode requires 64-byte signature on the stack");

    Signature invalid_sig;
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(64)] ~ invalid_sig.toBlob()[]
            ~ [ubyte(32)] ~ valid_key[]
            ~ [ubyte(OP.CHECK_SIG)]), Unlock.init, tx, Input.init),
        "Script failed");
    const Pair kp = Pair.random();
    const sig = sign(kp, tx);
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(64)] ~ sig.toBlob()[]
            ~ [ubyte(32)] ~ kp.V[]
            ~ [ubyte(OP.CHECK_SIG)]), Unlock.init, tx, Input.init),
        null);
}

// OP.VERIFY_SIG
unittest
{
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Transaction tx;
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.VERIFY_SIG]), Unlock.init, tx, Input.init),
        "VERIFY_SIG opcode requires two items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.PUSH_BYTES_1, 1, OP.VERIFY_SIG]),
        Unlock.init, tx, Input.init),
        "VERIFY_SIG opcode requires two items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.PUSH_BYTES_1, 1, OP.PUSH_BYTES_1, 1, OP.VERIFY_SIG]),
        Unlock.init, tx, Input.init),
        "VERIFY_SIG opcode requires 32-byte public key on the stack");

    // invalid key (crypto_core_ed25519_is_valid_point() fails)
    Point invalid_key;
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(OP.PUSH_BYTES_1), ubyte(1)]
            ~ [ubyte(32)] ~ invalid_key[]
            ~ [ubyte(OP.VERIFY_SIG)]), Unlock.init, tx, Input.init),
        "VERIFY_SIG 32-byte public key on the stack is invalid");

    Point valid_key = Point.fromString(
        "0x44404b654d6ddf71e2446eada6acd1f462348b1b17272ff8f36dda3248e08c81");
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(OP.PUSH_BYTES_1), ubyte(1)]
            ~ [ubyte(32)] ~ valid_key[]
            ~ [ubyte(OP.VERIFY_SIG)]), Unlock.init, tx, Input.init),
        "VERIFY_SIG opcode requires 64-byte signature on the stack");

    Signature invalid_sig;
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(64)] ~ invalid_sig.toBlob()[]
            ~ [ubyte(32)] ~ valid_key[]
            ~ [ubyte(OP.VERIFY_SIG)]), Unlock.init, tx, Input.init),
        "VERIFY_SIG signature failed validation");
    const Pair kp = Pair.random();
    const sig = sign(kp, tx);
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(64)] ~ sig.toBlob()[]
            ~ [ubyte(32)] ~ kp.V[]
            ~ [ubyte(OP.VERIFY_SIG)]), Unlock.init, tx, Input.init),
        "Script failed");  // VERIFY_SIG does not push TRUE to the stack
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(64)] ~ sig.toBlob()[]
            ~ [ubyte(32)] ~ kp.V[]
            ~ [ubyte(OP.VERIFY_SIG)]), Unlock([ubyte(OP.TRUE)]), tx, Input.init),
        null);
}

// OP.CHECK_MULTI_SIG / OP.VERIFY_MULTI_SIG
unittest
{
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Transaction tx;
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.CHECK_MULTI_SIG]), Unlock.init, tx, Input.init),
        "CHECK_MULTI_SIG opcode requires at minimum four items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.PUSH_NUM_1, OP.PUSH_NUM_1, OP.PUSH_NUM_1, OP.CHECK_MULTI_SIG]),
        Unlock.init, tx, Input.init),
        "CHECK_MULTI_SIG opcode requires at minimum four items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.PUSH_NUM_1, OP.PUSH_NUM_1, OP.PUSH_NUM_1, OP.PUSH_NUM_1,
                OP.CHECK_MULTI_SIG]),
        Unlock.init, tx, Input.init),
        "CHECK_MULTI_SIG opcode requires 32-byte public key on the stack");
    // invalid key (crypto_core_ed25519_is_valid_point() fails)
    Point invalid_key;
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_1)]  // required sigs
            ~ [ubyte(32)] ~ invalid_key[]
            ~ [ubyte(OP.PUSH_NUM_1)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ Signature.init.toBlob()[]),
        tx, Input.init),
        "CHECK_MULTI_SIG 32-byte public key on the stack is invalid");
    // valid key, invalid signature
    Point valid_key = Point.fromString(
        "0x44404b654d6ddf71e2446eada6acd1f462348b1b17272ff8f36dda3248e08c81");
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_1)]  // required sigs
            ~ [ubyte(32)] ~ valid_key[]
            ~ [ubyte(OP.PUSH_NUM_1)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ Signature.init.toBlob()[]),
        tx, Input.init),
        "Script failed");

    const Pair kp1 = Pair.random();
    const sig1 = sign(kp1, tx);
    const Pair kp2 = Pair.random();
    const sig2 = sign(kp2, tx);
    const Pair kp3 = Pair.random();
    const sig3 = sign(kp3, tx);
    const Pair kp4 = Pair.random();
    const sig4 = sign(kp4, tx);
    const Pair kp5 = Pair.random();
    const sig5 = sign(kp5, tx);

    // valid key + signature
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_1)]  // required sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(OP.PUSH_NUM_1)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]),
        tx, Input.init),
        null);
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // fails: more sigs than keys
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(OP.PUSH_NUM_1)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]
             ~ [ubyte(64)] ~ sig2.toBlob()[]),
        tx, Input.init),
        "CHECK_MULTI_SIG opcode cannot accept more signatures than there are keys");
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(OP.PUSH_NUM_2)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]),  // fails: not enough sigs pushed
        tx, Input.init),
        "CHECK_MULTI_SIG not enough signatures on the stack");
    // valid
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(OP.PUSH_NUM_2)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]
             ~ [ubyte(64)] ~ sig2.toBlob()[]),
        tx, Input.init),
        null);
    // invalid order
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // number of sigs
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(OP.PUSH_NUM_2)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]
             ~ [ubyte(64)] ~ sig2.toBlob()[]),
        tx, Input.init),
        "Script failed");
    // ditto invalid order
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(OP.PUSH_NUM_2)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig2.toBlob()[]
             ~ [ubyte(64)] ~ sig1.toBlob()[]),
        tx, Input.init),
        "Script failed");
    // 1 of 2 is ok
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_1)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(OP.PUSH_NUM_2)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]),
        tx, Input.init),
        null);
    // ditto 1 of 2 is ok
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_1)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(OP.PUSH_NUM_2)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig2.toBlob()[]),
        tx, Input.init),
        null);
    // 1 of 5: any sig is enough
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_1)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp3.V[]
            ~ [ubyte(32)] ~ kp4.V[]
            ~ [ubyte(32)] ~ kp5.V[]
            ~ [ubyte(OP.PUSH_NUM_5)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]),
        tx, Input.init),
        null);
    // 1 of 5: ditto
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_1)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp3.V[]
            ~ [ubyte(32)] ~ kp4.V[]
            ~ [ubyte(32)] ~ kp5.V[]
            ~ [ubyte(OP.PUSH_NUM_5)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig2.toBlob()[]),
        tx, Input.init),
        null);
    // 2 of 5: ok when sigs are in the same order
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp3.V[]
            ~ [ubyte(32)] ~ kp4.V[]
            ~ [ubyte(32)] ~ kp5.V[]
            ~ [ubyte(OP.PUSH_NUM_5)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]
             ~ [ubyte(64)] ~ sig5.toBlob()[]),
        tx, Input.init),
        null);
    // 2 of 5: fails when sigs are in the wrong order
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp3.V[]
            ~ [ubyte(32)] ~ kp4.V[]
            ~ [ubyte(32)] ~ kp5.V[]
            ~ [ubyte(OP.PUSH_NUM_5)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig5.toBlob()[]
             ~ [ubyte(64)] ~ sig1.toBlob()[]),
        tx, Input.init),
        "Script failed");
    // 3 of 5: ok when sigs are in the same order
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp3.V[]
            ~ [ubyte(32)] ~ kp4.V[]
            ~ [ubyte(32)] ~ kp5.V[]
            ~ [ubyte(OP.PUSH_NUM_5)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]
             ~ [ubyte(64)] ~ sig3.toBlob()[]
             ~ [ubyte(64)] ~ sig5.toBlob()[]),
        tx, Input.init),
        null);
    // 3 of 5: fails when sigs are in the wrong order
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp3.V[]
            ~ [ubyte(32)] ~ kp4.V[]
            ~ [ubyte(32)] ~ kp5.V[]
            ~ [ubyte(OP.PUSH_NUM_5)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]
             ~ [ubyte(64)] ~ sig5.toBlob()[]
             ~ [ubyte(64)] ~ sig3.toBlob()[]),
        tx, Input.init),
        "Script failed");
    // 5 of 5: ok when sigs are in the same order
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_5)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp3.V[]
            ~ [ubyte(32)] ~ kp4.V[]
            ~ [ubyte(32)] ~ kp5.V[]
            ~ [ubyte(OP.PUSH_NUM_5)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]
             ~ [ubyte(64)] ~ sig2.toBlob()[]
             ~ [ubyte(64)] ~ sig3.toBlob()[]
             ~ [ubyte(64)] ~ sig4.toBlob()[]
             ~ [ubyte(64)] ~ sig5.toBlob()[]),
        tx, Input.init),
        null);
    // 5 of 5: fails when sigs are in the wrong order
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_5)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp3.V[]
            ~ [ubyte(32)] ~ kp4.V[]
            ~ [ubyte(32)] ~ kp5.V[]
            ~ [ubyte(OP.PUSH_NUM_5)]  // number of keys
            ~ [ubyte(OP.CHECK_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]
             ~ [ubyte(64)] ~ sig3.toBlob()[]
             ~ [ubyte(64)] ~ sig2.toBlob()[]
             ~ [ubyte(64)] ~ sig4.toBlob()[]
             ~ [ubyte(64)] ~ sig5.toBlob()[]),
        tx, Input.init),
        "Script failed");
    // ditto but with VERIFY_MULTI_SIG
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(OP.PUSH_NUM_2)]  // number of sigs
            ~ [ubyte(32)] ~ kp1.V[]
            ~ [ubyte(32)] ~ kp2.V[]
            ~ [ubyte(32)] ~ kp3.V[]
            ~ [ubyte(32)] ~ kp4.V[]
            ~ [ubyte(32)] ~ kp5.V[]
            ~ [ubyte(OP.PUSH_NUM_5)]  // number of keys
            ~ [ubyte(OP.VERIFY_MULTI_SIG)]),
        Unlock([ubyte(64)] ~ sig1.toBlob()[]
             ~ [ubyte(64)] ~ sig5.toBlob()[]
             ~ [ubyte(64)] ~ sig3.toBlob()[]),
        tx, Input.init),
        "VERIFY_MULTI_SIG signature failed validation");
}

// OP.CHECK_SEQ_SIG / OP.VERIFY_SEQ_SIG
unittest
{
    // Expected top to bottom on stack: <min_seq> <key> [<new_seq> <sig>]
    //
    // Unlock script pushes in order: [<sig>, <new_seq>]
    // Lock script pushes in order: <key>, <min_seq>
    //
    // Stack:
    //   <min_seq>
    //   <key>
    //   <new_seq>
    //   <sig>

    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Transaction tx = Transaction([Input.init], null);
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.CHECK_SEQ_SIG]), Unlock.init, tx, tx.inputs[0]),
        "CHECK_SEQ_SIG opcode requires 4 items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.VERIFY_SEQ_SIG]), Unlock.init, tx, tx.inputs[0]),
        "VERIFY_SEQ_SIG opcode requires 4 items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script, [1, 42, 1, 42, 1, 42, OP.CHECK_SEQ_SIG]),
        Unlock.init, tx, tx.inputs[0]),
        "CHECK_SEQ_SIG opcode requires 4 items on the stack");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [1, 42, 1, 42, 1, 42, 1, 42, OP.CHECK_SEQ_SIG]),
        Unlock.init, tx, tx.inputs[0]),
        "CHECK_SEQ_SIG opcode requires 8-byte minimum sequence on the stack");

    const seq_0 = ulong(0);
    const seq_1 = ulong(1);
    const seq_0_bytes = nativeToLittleEndian(seq_0);
    const seq_1_bytes = nativeToLittleEndian(seq_1);

    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(1), ubyte(1)]  // wrong pubkey size
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ Signature.init.toBlob()[]
            ~ toPushOpcode(seq_0_bytes)), tx, tx.inputs[0]),
        "CHECK_SEQ_SIG opcode requires 32-byte public key on the stack");

    // invalid key (crypto_core_ed25519_is_valid_point() fails)
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ Point.init[]  // size ok, form is wrong
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ Signature.init.toBlob()[]
            ~ toPushOpcode(seq_0_bytes)), tx, tx.inputs[0]),
        "CHECK_SEQ_SIG 32-byte public key on the stack is invalid");

    Point rand_key = Point.fromString(
        "0x44404b654d6ddf71e2446eada6acd1f462348b1b17272ff8f36dda3248e08c81");
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ rand_key[]
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ Signature.init.toBlob()[]
            // wrong sequence size
            ~ toPushOpcode(nativeToLittleEndian(ubyte(1)))), tx, tx.inputs[0]),
        "CHECK_SEQ_SIG opcode requires 8-byte sequence on the stack");

    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ rand_key[]
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ Signature.init.toBlob()[]
            ~ toPushOpcode(seq_0_bytes)), tx, tx.inputs[0]),
        "Script failed");

    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ rand_key[]
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(1)] ~ [ubyte(1)]  // wrong signature size
            ~ toPushOpcode(seq_0_bytes)), tx, tx.inputs[0]),
        "CHECK_SEQ_SIG opcode requires 64-byte signature on the stack");

    const Pair kp = Pair.random();
    const bad_sig = sign(kp, tx);
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ rand_key[]
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ bad_sig.toBlob()[]
            ~ toPushOpcode(seq_0_bytes)), tx, tx.inputs[0]),
        "Script failed");  // still fails, signature didn't hash the sequence

    // create the proper signature which blanks the input and encodes the sequence
    const challenge_0 = getSequenceChallenge(tx, seq_0, 0);
    const seq_0_sig = sign(kp, challenge_0);
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ kp.V[]
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ seq_0_sig.toBlob()[]
            ~ toPushOpcode(seq_0_bytes)), tx, tx.inputs[0]),
        null);

    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ kp.V[]
            ~ toPushOpcode(seq_1_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ seq_0_sig.toBlob()[]
            ~ toPushOpcode(seq_0_bytes)), tx, tx.inputs[0]),
        "CHECK_SEQ_SIG sequence is not equal to or greater than min_sequence");

    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ kp.V[]
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ seq_0_sig.toBlob()[]
            ~ toPushOpcode(seq_1_bytes)), tx, tx.inputs[0]),
        "Script failed");

    const challenge_1 = getSequenceChallenge(tx, seq_1, 0);
    const seq_1_sig = sign(kp, challenge_1);
    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ kp.V[]
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.CHECK_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ seq_1_sig.toBlob()[]
            ~ toPushOpcode(seq_1_bytes)), tx, tx.inputs[0]),
        null);

    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ rand_key[]  // key mismatch
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.VERIFY_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ seq_1_sig.toBlob()[]
            ~ toPushOpcode(seq_1_bytes)), tx, tx.inputs[0]),
        "VERIFY_SEQ_SIG signature failed validation");

    test!("==")(engine.execute(
        Lock(LockType.Script,
              [ubyte(32)] ~ kp.V[]
            ~ toPushOpcode(seq_0_bytes)
            ~ [ubyte(OP.VERIFY_SEQ_SIG)]),
        Unlock(
            [ubyte(64)] ~ seq_0_sig.toBlob()[]
            ~ toPushOpcode(seq_1_bytes)), tx, tx.inputs[0]),  // sig mismatch
        "VERIFY_SEQ_SIG signature failed validation");
}

// OP.VERIFY_LOCK_HEIGHT
unittest
{
    const height_9 = nativeToLittleEndian(ulong(9));
    const height_10 = nativeToLittleEndian(ulong(10));
    const height_11 = nativeToLittleEndian(ulong(11));

    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Transaction tx_10 = Transaction(Height(10));
    const Transaction tx_11 = Transaction(Height(11));
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(height_9)
            ~ [ubyte(OP.VERIFY_LOCK_HEIGHT), ubyte(OP.TRUE)]),
        Unlock.init, tx_10, Input.init),
        null);
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(height_10)
            ~ [ubyte(OP.VERIFY_LOCK_HEIGHT), ubyte(OP.TRUE)]),
        Unlock.init, tx_10, Input.init),  // tx with matching unlock height
        null);
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(height_11)
            ~ [ubyte(OP.VERIFY_LOCK_HEIGHT), ubyte(OP.TRUE)]),
        Unlock.init, tx_10, Input.init),
        "VERIFY_LOCK_HEIGHT height lock of transaction is too low");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(height_11)
            ~ [ubyte(OP.VERIFY_LOCK_HEIGHT), ubyte(OP.TRUE)]),
        Unlock.init, tx_11, Input.init),  // tx with matching unlock height
        null);
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(nativeToLittleEndian(ubyte(9)))
            ~ [ubyte(OP.VERIFY_LOCK_HEIGHT), ubyte(OP.TRUE)]),
        Unlock.init, tx_10, Input.init),
        "VERIFY_LOCK_HEIGHT height lock must be an 8-byte number");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [ubyte(OP.VERIFY_LOCK_HEIGHT), ubyte(OP.TRUE)]),
        Unlock.init, tx_10, Input.init),
        "VERIFY_LOCK_HEIGHT opcode requires a lock height on the stack");
}

// OP.VERIFY_UNLOCK_AGE
unittest
{
    const age_9 = nativeToLittleEndian(uint(9));
    const age_10 = nativeToLittleEndian(uint(10));
    const age_11 = nativeToLittleEndian(uint(11));
    const age_overflow = nativeToLittleEndian(ulong.max);

    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Input input_10 = Input(Hash.init, 0, 10 /* unlock_age */);
    const Input input_11 = Input(Hash.init, 0, 11 /* unlock_age */);
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(age_9)
            ~ [ubyte(OP.VERIFY_UNLOCK_AGE), ubyte(OP.TRUE)]),
        Unlock.init, Transaction.init, input_10),
        null);
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(age_10)
            ~ [ubyte(OP.VERIFY_UNLOCK_AGE), ubyte(OP.TRUE)]),
        Unlock.init, Transaction.init, input_10),  // input with matching unlock age
        null);
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(age_11)
            ~ [ubyte(OP.VERIFY_UNLOCK_AGE), ubyte(OP.TRUE)]),
        Unlock.init, Transaction.init, input_10),
        "VERIFY_UNLOCK_AGE unlock age of input is too low");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(age_11)
            ~ [ubyte(OP.VERIFY_UNLOCK_AGE), ubyte(OP.TRUE)]),
        Unlock.init, Transaction.init, input_11),  // input with matching unlock age
        null);
    test!("==")(engine.execute(
        Lock(LockType.Script,
            toPushOpcode(age_overflow)
            ~ [ubyte(OP.VERIFY_UNLOCK_AGE), ubyte(OP.TRUE)]),
        Unlock.init, Transaction.init, input_10),
        "VERIFY_UNLOCK_AGE unlock age must be a 4-byte number");
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [ubyte(OP.VERIFY_UNLOCK_AGE), ubyte(OP.TRUE)]),
        Unlock.init, Transaction.init, input_10),
        "VERIFY_UNLOCK_AGE opcode requires an unlock age on the stack");
}

// LockType.Key (Native P2PK - Pay to Public Key), consumes 33 bytes
unittest
{
    const Pair kp = Pair.random();
    const Transaction tx;
    const sig = sign(kp, tx);

    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    test!("==")(engine.execute(
        Lock(LockType.Key, kp.V[]), Unlock(sig.toBlob()[]), tx, Input.init),
        null);
    const bad_sig = sign(kp, "foobar");
    test!("==")(engine.execute(
        Lock(LockType.Key, kp.V[]), Unlock(bad_sig.toBlob()[]), tx, Input.init),
        "LockType.Key signature in unlock script failed validation");
    const bad_key = Pair.random().V;
    test!("==")(engine.execute(
        Lock(LockType.Key, bad_key[]), Unlock(sig.toBlob()[]), tx, Input.init),
        "LockType.Key signature in unlock script failed validation");
    test!("==")(engine.execute(
        Lock(LockType.Key, ubyte(42).repeat(64).array),
        Unlock(sig.toBlob()[]), tx, Input.init),
        "LockType.Key requires 32-byte key argument in the lock script");
    test!("==")(engine.execute(
        Lock(LockType.Key, ubyte(0).repeat(32).array),
        Unlock(sig.toBlob()[]), tx, Input.init),
        "LockType.Key 32-byte public key in lock script is invalid");
    test!("==")(engine.execute(
        Lock(LockType.Key, kp.V[]),
        Unlock(ubyte(42).repeat(32).array), tx, Input.init),
        "LockType.Key requires a 64-byte signature in the unlock script");
    test!("==")(engine.execute(
        Lock(LockType.Key, kp.V[]),
        Unlock(ubyte(42).repeat(65).array), tx, Input.init),
        "LockType.Key requires a 64-byte signature in the unlock script");
}

// LockType.KeyHash (Native P2PKH - Pay to Public Key Hash), consumes 65 bytes
unittest
{
    const Pair kp = Pair.random();
    const key_hash = hashFull(kp.V);
    const Transaction tx;
    const sig = sign(kp, tx);
    const Pair kp2 = Pair.random();
    const sig2 = sign(kp2, tx);  // valid sig, but for a different key-pair

    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, key_hash[]), Unlock(sig.toBlob()[] ~ kp.V[]), tx, Input.init),
        null);
    const bad_sig = sign(kp, "foo");
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, key_hash[]), Unlock(bad_sig.toBlob()[] ~ kp.V[]), tx, Input.init),
        "LockType.KeyHash signature in unlock script failed validation");
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, key_hash[]), Unlock(sig2.toBlob()[] ~ kp2.V[]), tx, Input.init),
        "LockType.KeyHash hash of key does not match key hash set in lock script");
    const bad_key = Pair.random().V;
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, key_hash[]), Unlock(sig.toBlob()[] ~ bad_key[]), tx, Input.init),
        "LockType.KeyHash hash of key does not match key hash set in lock script");
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, ubyte(42).repeat(63).array),
        Unlock(sig.toBlob()[] ~ kp.V[]), tx, Input.init),
        "LockType.KeyHash requires a 64-byte key hash argument in the lock script");
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, ubyte(42).repeat(65).array),
        Unlock(sig.toBlob()[] ~ kp.V[]), tx, Input.init),
        "LockType.KeyHash requires a 64-byte key hash argument in the lock script");
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, key_hash[]), Unlock(sig.toBlob()[]), tx, Input.init),
        "LockType.KeyHash requires a 64-byte signature and a 32-byte key in the unlock script");
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, key_hash[]), Unlock(kp.V[]), tx, Input.init),
        "LockType.KeyHash requires a 64-byte signature and a 32-byte key in the unlock script");
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, key_hash[]), Unlock(sig.toBlob()[] ~ kp.V[] ~ [ubyte(0)]),
        tx, Input.init),
        "LockType.KeyHash requires a 64-byte signature and a 32-byte key in the unlock script");
    test!("==")(engine.execute(
        Lock(LockType.KeyHash, key_hash[]),
        Unlock(sig.toBlob()[] ~ ubyte(0).repeat(32).array), tx, Input.init),
        "LockType.KeyHash public key in unlock script is invalid");
}

// LockType.Script
unittest
{
    const Pair kp = Pair.random();
    const Transaction tx;
    const sig = sign(kp, tx);
    const key_hash = hashFull(kp.V);
    // emulating bitcoin-style P2PKH
    const Script lock = createLockP2PKH(key_hash);
    const Script unlock = createUnlockP2PKH(sig, kp.V);

    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    test!("==")(engine.execute(
        Lock(LockType.Script, lock[]), Unlock(unlock[]), tx, Input.init),
        null);
    // simple push
    test!("==")(engine.execute(
        Lock(LockType.Script,
            ubyte(42).repeat(65).array.toPushOpcode
            ~ ubyte(42).repeat(65).array.toPushOpcode
            ~ [ubyte(OP.CHECK_EQUAL)]),
        Unlock(unlock[]), tx, Input.init),
        null);

    Script bad_key_unlock = createUnlockP2PKH(sig, Pair.random.V);
    test!("==")(engine.execute(
        Lock(LockType.Script, lock[]), Unlock(bad_key_unlock[]), tx, Input.init),
        "VERIFY_EQUAL operation failed");

    // native script stack overflow test
    scope small = new Engine(TestStackMaxItemSize * 2, TestStackMaxItemSize);
    test!("==")(small.execute(
        Lock(LockType.Script, lock[]),
        Unlock(
            ubyte(42).repeat(TestStackMaxItemSize).array.toPushOpcode()
            ~ ubyte(42).repeat(TestStackMaxItemSize).array.toPushOpcode()
            ~ ubyte(42).repeat(TestStackMaxItemSize).array.toPushOpcode()), tx,
        Input.init),
        "Stack overflow while executing PUSH_DATA_2");
}

// LockType.Redeem (Pay to Script Hash)
unittest
{
    const Pair kp = Pair.random();
    const Transaction tx;
    const Script redeem = makeScript(
        [ubyte(32)] ~ kp.V[] ~ [ubyte(OP.CHECK_SIG)]);
    const redeem_hash = hashFull(redeem);
    const sig = sign(kp, tx);

    // lock is: <redeem hash>
    // unlock is: <push(sig)> <redeem>
    // redeem is: check sig against the key embedded in the redeem script
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    test!("==")(engine.execute(
        Lock(LockType.Redeem, redeem_hash[]),
        Unlock([ubyte(64)] ~ sig.toBlob()[] ~ toPushOpcode(redeem[])),
        tx, Input.init),
        null);
    test!("==")(engine.execute(
        Lock(LockType.Redeem, ubyte(42).repeat(32).array),
        Unlock([ubyte(64)] ~ sig.toBlob()[] ~ toPushOpcode(redeem[])),
        tx, Input.init),
        "LockType.Redeem requires 64-byte script hash in the lock script");
    test!("==")(engine.execute(
        Lock(LockType.Redeem, ubyte(42).repeat(65).array),
        Unlock([ubyte(64)] ~ sig.toBlob()[] ~ toPushOpcode(redeem[])),
        tx, Input.init),
        "LockType.Redeem requires 64-byte script hash in the lock script");
    test!("==")(engine.execute(
        Lock(LockType.Redeem, redeem_hash[]),
        Unlock(null),
        tx, Input.init),
        "LockType.Redeem requires unlock script to push a redeem script to the stack");
    scope small = new Engine(TestStackMaxItemSize * 2, TestStackMaxItemSize);
    test!("==")(small.execute(
        Lock(LockType.Redeem, redeem_hash[]),
        Unlock(ubyte(42).repeat(TestStackMaxItemSize * 2).array.toPushOpcode()),
        tx, Input.init),
        "PUSH_DATA_2 opcode payload size is not within StackMaxItemSize limits");
    test!("==")(small.execute(
        Lock(LockType.Redeem, redeem_hash[]),
        Unlock(
            ubyte(42).repeat(TestStackMaxItemSize).array.toPushOpcode()
            ~ ubyte(42).repeat(TestStackMaxItemSize).array.toPushOpcode()
            ~ ubyte(42).repeat(TestStackMaxItemSize).array.toPushOpcode()),
        tx, Input.init),
        "Stack overflow while executing PUSH_DATA_2");
    const Script wrong_redeem = makeScript([ubyte(32)] ~ Pair.random.V[]
        ~ [ubyte(OP.CHECK_SIG)]);
    test!("==")(engine.execute(
        Lock(LockType.Redeem, redeem_hash[]),
        Unlock([ubyte(64)] ~ sig.toBlob()[] ~ toPushOpcode(wrong_redeem[])),
        tx, Input.init),
        "LockType.Redeem unlock script pushed a redeem script which does "
        ~ "not match the redeem hash in the lock script");
    auto wrong_sig = sign(kp, "bad");
    test!("==")(engine.execute(
        Lock(LockType.Redeem, redeem_hash[]),
        Unlock([ubyte(64)] ~ wrong_sig.toBlob()[] ~ toPushOpcode(redeem[])),
        tx, Input.init),
        "Script failed");

    // note: a redeem script cannot contain an overflown payload size
    // which exceeds `MaxItemSize` because the redeem script itself would need
    // to contain this payload, but since the redeem script itself is pushed by
    // the unlock script then the unlock script validation would have already
    // failed before the redeem script validation could ever fail.
    const Script bad_opcode_redeem = makeScript([ubyte(255)]);
    test!("==")(small.execute(
        Lock(LockType.Redeem, bad_opcode_redeem.hashFull()[]),
        Unlock(toPushOpcode(bad_opcode_redeem[])),
        tx, Input.init),
        "Script contains an unrecognized opcode");

    // however it may include opcodes which overflow the stack during execution.
    // here 1 byte => 64 bytes, causing a stack overflow
    scope tiny = new Engine(10, 10);
    const Script overflow_redeem = makeScript([OP.TRUE, OP.HASH]);
    test!("==")(tiny.execute(
        Lock(LockType.Redeem, overflow_redeem.hashFull()[]),
        Unlock(toPushOpcode(overflow_redeem[])),
        tx, Input.init),
        "Stack overflow while executing HASH");
}

// Basic invalid script verification
unittest
{
    Pair kp = Pair.random();
    Transaction tx;
    const sig = sign(kp, tx);

    const key_hash = hashFull(kp.V);
    Script lock = createLockP2PKH(key_hash);
    Script unlock = createUnlockP2PKH(sig, kp.V);

    const invalid_script = makeScript([255]);
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    test!("==")(engine.execute(
        Lock(LockType.Script, lock[]), Unlock(unlock[]), tx, Input.init),
        null);
    // invalid scripts / sigs
    test!("==")(engine.execute(
        Lock(LockType.Script, []), Unlock(unlock[]), tx, Input.init),
        "Lock script must not be empty");
    test!("==")(engine.execute(
        Lock(LockType.Script, invalid_script[]), Unlock(unlock[]), tx, Input.init),
        "Script contains an unrecognized opcode");
    test!("==")(engine.execute(
        Lock(LockType.Script, lock[]), Unlock(invalid_script[]), tx, Input.init),
        "Script contains an unrecognized opcode");
}

// Item size & stack size limits checks
unittest
{
    import std.algorithm;
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Transaction tx;
    const StackMaxItemSize = 512;
    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(1), ubyte(42)] ~ [ubyte(OP.TRUE)]),
        Unlock.init, tx, Input.init),
        null);

    test!("==")(engine.execute(
        Lock(LockType.Script, ubyte(42).repeat(TestStackMaxItemSize + 1)
            .array.toPushOpcode()
            ~ [ubyte(OP.TRUE)]),
        Unlock.init, tx, Input.init),
        "PUSH_DATA_2 opcode payload size is not within StackMaxItemSize limits");

    const MaxItemPush = ubyte(42).repeat(TestStackMaxItemSize).array
        .toPushOpcode();
    const MaxPushes = TestStackMaxTotalSize / TestStackMaxItemSize;
    // strict power of two to make the tests easy to write
    assert(TestStackMaxTotalSize % TestStackMaxItemSize == 0);

    // overflow with PUSH_DATA_1
    scope tiny = new Engine(120, 77);
    test!("==")(tiny.execute(
        Lock(LockType.Script,
            ubyte(42).repeat(76).array.toPushOpcode()
            ~ ubyte(42).repeat(76).array.toPushOpcode()
            ~ ubyte(42).repeat(76).array.toPushOpcode()
            ~ [ubyte(OP.TRUE)]),
        Unlock.init, tx, Input.init),
        "Stack overflow while executing PUSH_DATA_1");

    // ditto with PUSH_DATA_2
    test!("==")(engine.execute(
        Lock(LockType.Script, MaxItemPush.repeat(MaxPushes + 1).joiner.array
            ~ [ubyte(OP.TRUE)]),
        Unlock.init, tx, Input.init),
        "Stack overflow while executing PUSH_DATA_2");

    // within limit, but missing OP.TRUE on stack
    test!("==")(engine.execute(
        Lock(LockType.Script, MaxItemPush.repeat(MaxPushes).joiner.array),
        Unlock.init, tx, Input.init),
        "Script failed");

    test!("==")(engine.execute(
        Lock(LockType.Script, MaxItemPush.repeat(MaxPushes).joiner.array
            ~ [ubyte(OP.TRUE)]),
        Unlock.init, tx, Input.init),
        "Stack overflow while pushing TRUE to the stack");

    test!("==")(engine.execute(
        Lock(LockType.Script, MaxItemPush.repeat(MaxPushes).joiner.array
            ~ [ubyte(OP.FALSE)]),
        Unlock.init, tx, Input.init),
        "Stack overflow while pushing FALSE to the stack");

    test!("==")(engine.execute(
        Lock(LockType.Script, MaxItemPush.repeat(MaxPushes).joiner.array
            ~ [ubyte(1), ubyte(1)]),
        Unlock.init, tx, Input.init),
        "Stack overflow while executing PUSH_BYTES_*");

    test!("==")(engine.execute(
        Lock(LockType.Script, MaxItemPush.repeat(MaxPushes).joiner.array
            ~ [ubyte(1), ubyte(1)]),
        Unlock.init, tx, Input.init),
        "Stack overflow while executing PUSH_BYTES_*");

    test!("==")(engine.execute(
        Lock(LockType.Script, MaxItemPush.repeat(MaxPushes).joiner.array
            ~ [ubyte(OP.DUP)]),
        Unlock.init, tx, Input.init),
        "Stack overflow while executing DUP");

    // will fit, pops TestStackMaxItemSize and pushes 64 bytes
    test!("==")(engine.execute(
        Lock(LockType.Script, MaxItemPush.repeat(MaxPushes).joiner.array
            ~ [ubyte(OP.HASH), ubyte(OP.TRUE)]),
        Unlock.init, tx, Input.init),
        null);

    test!("==")(engine.execute(
        Lock(LockType.Script, MaxItemPush.repeat(MaxPushes - 1).joiner.array
            ~ [ubyte(1), ubyte(1)].repeat(TestStackMaxItemSize).joiner.array
            ~ ubyte(OP.HASH) ~ [ubyte(OP.TRUE)]),
        Unlock.init, tx, Input.init),
        "Stack overflow while executing HASH");

    // stack overflow in only one of the branches.
    // will only overflow if that branch is taken, else payload is discarded.
    // note that syntactical validation is still done for the entire script,
    // so `StackMaxItemSize` is still checked
    Lock lock_if = Lock(LockType.Script,
        [ubyte(OP.IF)]
            ~ ubyte(42).repeat(76).array.toPushOpcode()
            ~ ubyte(42).repeat(76).array.toPushOpcode()
            ~ ubyte(42).repeat(76).array.toPushOpcode()
         ~ [ubyte(OP.ELSE),
            ubyte(OP.TRUE),
         ubyte(OP.END_IF)]);

    test!("==")(tiny.execute(
        lock_if, Unlock([ubyte(OP.TRUE)]), tx, Input.init),
        "Stack overflow while executing PUSH_DATA_1");
    test!("==")(tiny.execute(
        lock_if, Unlock([ubyte(OP.FALSE)]), tx, Input.init),
        null);
}

// IF, NOT_IF, ELSE, END_IF conditional logic
unittest
{
    scope engine = new Engine(TestStackMaxTotalSize, TestStackMaxItemSize);
    const Transaction tx;

    // IF true => execute if branch
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.TRUE, OP.IF, OP.TRUE, OP.ELSE, OP.FALSE, OP.END_IF]),
        Unlock.init, tx, Input.init),
        null);

    // IF false => execute else branch
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.FALSE, OP.IF, OP.TRUE, OP.ELSE, OP.FALSE, OP.END_IF]),
        Unlock.init, tx, Input.init),
        "Script failed");

    // NOT_IF true => execute if branch
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.FALSE, OP.NOT_IF, OP.TRUE, OP.ELSE, OP.FALSE, OP.END_IF]),
        Unlock.init, tx, Input.init),
        null);

    // NOT_IF false => execute else branch
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.TRUE, OP.NOT_IF, OP.TRUE, OP.ELSE, OP.FALSE, OP.END_IF]),
        Unlock.init, tx, Input.init),
        "Script failed");

    // dangling IF / NOT_IF
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.TRUE, OP.IF]),
        Unlock.init, tx, Input.init),
        "IF / NOT_IF requires a closing END_IF");

    // ditto
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.TRUE, OP.NOT_IF]),
        Unlock.init, tx, Input.init),
        "IF / NOT_IF requires a closing END_IF");

    // unmatched ELSE
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.TRUE, OP.ELSE]),
        Unlock.init, tx, Input.init),
        "Cannot have an ELSE without an associated IF / NOT_IF");

    // unmatched END_IF
    test!("==")(engine.execute(
        Lock(LockType.Script,
            [OP.TRUE, OP.END_IF]),
        Unlock.init, tx, Input.init),
        "Cannot have an END_IF without an associated IF / NOT_IF");

    /* nested conditionals */

    // IF true => IF true => OP.TRUE
    const Lock lock_1 =
        Lock(LockType.Script,
            [OP.IF,
                 OP.IF,
                    OP.TRUE,
                 OP.ELSE,
                    OP.FALSE,
                 OP.END_IF,
             OP.ELSE,
                 OP.IF,
                    OP.FALSE,
                 OP.ELSE,
                    OP.FALSE,
                 OP.END_IF,
             OP.END_IF]);

    test!("==")(engine.execute(lock_1, Unlock([OP.TRUE, OP.TRUE]), tx, Input.init),
        null);
    test!("==")(engine.execute(lock_1, Unlock([OP.TRUE, OP.FALSE]), tx, Input.init),
        "Script failed");
    test!("==")(engine.execute(lock_1, Unlock([OP.FALSE, OP.TRUE]), tx, Input.init),
        "Script failed");
    test!("==")(engine.execute(lock_1, Unlock([OP.FALSE, OP.FALSE]), tx, Input.init),
        "Script failed");

    // IF true => NOT_IF true => OP.TRUE
    const Lock lock_2 =
        Lock(LockType.Script,
            [OP.IF,
                 OP.NOT_IF,
                    OP.TRUE,
                 OP.ELSE,
                    OP.FALSE,
                 OP.END_IF,
             OP.ELSE,
                 OP.IF,
                    OP.FALSE,
                 OP.ELSE,
                    OP.FALSE,
                 OP.END_IF,
             OP.END_IF]);

    // note: remember that it's LIFO, second push is evaluted first!
    test!("==")(engine.execute(lock_2, Unlock([OP.TRUE, OP.TRUE]), tx, Input.init),
        "Script failed");
    test!("==")(engine.execute(lock_2, Unlock([OP.TRUE, OP.FALSE]), tx, Input.init),
        "Script failed");
    test!("==")(engine.execute(lock_2, Unlock([OP.FALSE, OP.TRUE]), tx, Input.init),
        null);
    test!("==")(engine.execute(lock_2, Unlock([OP.FALSE, OP.FALSE]), tx, Input.init),
        "Script failed");

    /* syntax checks */
    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.IF]),
        Unlock.init, tx, Input.init),
        "IF/NOT_IF opcode requires an item on the stack");

    test!("==")(engine.execute(
        Lock(LockType.Script, [ubyte(1), ubyte(2), OP.IF]),
        Unlock.init, tx, Input.init),
        "IF/NOT_IF may only be used with OP.TRUE / OP.FALSE values");

    test!("==")(engine.execute(
        Lock(LockType.Script, [OP.TRUE, OP.IF]),
        Unlock.init, tx, Input.init),
        "IF / NOT_IF requires a closing END_IF");
}
