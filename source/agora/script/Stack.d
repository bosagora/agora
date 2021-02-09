/*******************************************************************************

    Contains a stack implementation for use with the script execution engine.

    It uses a linked-list rather than a vector to avoid unnecessary copying
    due to stomping prevention as the same item may be popped and later pushed
    to the stack. In addition, this makes it very cheap to copy the stack as
    all internal items are immutable anyway.

    The stack must be initialized with a set of size constraints,
    the maximum size of the stack, and the maximum size of any one item
    on the stack.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.script.Stack;

import agora.crypto.Serializer;

import std.container : SList;
import std.range;

version (unittest)
{
    import ocean.core.Test;
    import std.stdio;
}

/// Ditto
public struct Stack
{
    /// Maximum total stack size
    private immutable ulong StackMaxTotalSize;

    /// Maximum size of an item on the stack
    private immutable ulong StackMaxItemSize;

    /// The actual stack
    private SList!(const(ubyte)[]) stack;

    /// The number of items on the stack
    private ulong num_items;

    /// Total used bytes for this stack. Used to track stack overflows.
    private size_t used_bytes;

    /// Stack must always be initialized with the right size constraints
    public @disable this ();

    /***************************************************************************

        Initializes the Stack with the configured consensus limits.

        Params:
            StackMaxTotalSize = the maximum allowed stack size before a
                stack overflow. It affects routines such as `canPush()`,
                and `push()` in non-release mode. Must be at least
                big enough to fit `StackMaxItemSize`.
            StackMaxItemSize = maximum allowed size for a single item on
                the stack. Must be greater than 0.

    ***************************************************************************/

    public this (ulong StackMaxTotalSize, ulong StackMaxItemSize)
        pure nothrow @safe @nogc
    {
        assert(StackMaxItemSize > 0 && StackMaxTotalSize >= StackMaxItemSize);
        this.StackMaxTotalSize = StackMaxTotalSize;
        this.StackMaxItemSize = StackMaxItemSize;
    }

    /***************************************************************************

        Internal. Used with `copy()` to make it safer to avoid leaving
        out any fields when copying stacks.

    ***************************************************************************/

    private this (typeof(Stack.init.tupleof) members) pure nothrow @safe @nogc
    {
        this.tupleof = members;
    }

    /***************************************************************************

        Checks if the provided data can be pushed to the stack.

        Params:
            data = the data to check if it fits onto the stack

        Returns:
            true if data is within `StackMaxItemSize` limit and adding it
            to the stack does not exceed the `StackMaxTotalSize` stack size.

    ***************************************************************************/

    public bool canPush (const(ubyte)[] data) const pure nothrow @safe @nogc
    {
        return data.length <= StackMaxItemSize &&
            this.used_bytes + data.length <= StackMaxTotalSize;
    }

    /***************************************************************************

        Pushes the value to the stack.

        Call `canPush()` first to ensure the data can fit on the stack
        based on the configured limits.

        Params:
            data = the data to push to the stack

    ***************************************************************************/

    public void push (const(ubyte)[] data) @safe nothrow
    {
        assert(this.canPush(data));
        this.stack.insertFront(data);
        this.used_bytes += data.length;
        this.num_items++;
    }

    /***************************************************************************

        Returns the top item from the stack without popping it.
        Client code must check `empty()` first.

        Returns:
            the top item on the stack, without popping it

    ***************************************************************************/

    public const(ubyte)[] peek () /*const*/ // phobos lacks const
        pure nothrow @safe @nogc
    {
        assert(!this.stack.empty());
        return this.stack.front();
    }

    /***************************************************************************

        Pops an item from the stack and returns it.
        Client code must check `empty()` first.

        Returns:
            the popped value from the stack

    ***************************************************************************/

    public const(ubyte)[] pop () @safe nothrow
    {
        assert(!this.stack.empty());
        assert(this.num_items > 0);
        auto value = this.stack.front();
        this.stack.removeFront();
        this.used_bytes -= value.length;
        this.num_items--;
        return value;
    }

    /***************************************************************************

        Get the number of items on the stack. It's typed as a ulong to prevent
        introducing platform-dependent behavior if the count ends up being
        used in any opcodes (for example hashing).

        Returns:
            the number of items on the stack

    ***************************************************************************/

    public ulong count () const pure nothrow @safe @nogc
    {
        return this.num_items;
    }

    /***************************************************************************

        Returns:
            true if the stack is empty

    ***************************************************************************/

    public bool empty () const pure nothrow @safe @nogc
    {
        return this.stack.empty();
    }

    /// SList uses reference semantics by default. Either use a
    /// `ref` parameter or explicitly copy the stack via `copy()`.
    public @disable this(this);

    /***************************************************************************

        Returns:
            a copy of the stack. The two stacks may then be modified
            independently of each other.

    ***************************************************************************/

    public Stack copy () /*const @nogc*/   // phobos lacks const @nogc
        pure nothrow @safe
    {
        auto dup = Stack(this.tupleof);
        dup.stack = dup.stack.dup();  // must dup to avoid ref semantics
        return dup;
    }

    /***************************************************************************

        Returns:
            a range over the stack items, from the top item to bottom item

    ***************************************************************************/

    public auto opSlice () /*const @nogc*/  // phobos lacks const @nogc
        pure nothrow @safe
    {
        return this.stack[];
    }
}

///
//@safe nothrow
unittest
{
    import std.array;
    const StackMaxTotalSize = 16_384;
    const StackMaxItemSize = 512;
    Stack stack = Stack(StackMaxTotalSize, StackMaxItemSize);
    assert(stack.empty());
    assert(stack.count() == 0);
    assert(stack.used_bytes == 0);
    stack.push([1, 2, 3]);
    assert(stack.count() == 1);
    test!"=="(stack.used_bytes, 3);
    stack.push([255]);
    assert(stack.count() == 2);
    test!"=="(stack.used_bytes, 4);
    assert(stack.peek() == [255]);
    assert(stack.count() == 2);     // did not consume
    assert(stack.peek() == [255]);  // ditto
    assert(stack[].array == [[255], [1, 2, 3]]);
    assert(!stack.empty());
    // copies disabled: either use 'ref' or explicitly do a 'copy()'
    static assert(!is(typeof( { Stack nogo = stack; } )));
    Stack copy = stack.copy();
    test!("==")(copy.StackMaxTotalSize, stack.StackMaxTotalSize);
    test!("==")(copy.StackMaxItemSize, stack.StackMaxItemSize);
    test!("==")(copy.stack.empty(), stack.stack.empty());
    test!("==")(copy.num_items, stack.num_items);
    test!("==")(copy.used_bytes, stack.used_bytes);
    assert(stack.pop() == [255]);
    assert(stack.count() == 1);
    test!"=="(stack.used_bytes, 3);
    assert(!stack.empty());
    assert(stack.pop() == [1, 2, 3]);
    assert(stack.count() == 0);
    test!"=="(stack.used_bytes, 0);
    assert(stack.empty());
    assert(copy.count() == 2);     // did not consume copy
    assert(copy.used_bytes == 4);  // ditto
    assert(!copy.empty());         // ditto
    assert(stack.canPush(ubyte(42).repeat(100).array));
    assert(!stack.canPush(ubyte(42).repeat(StackMaxItemSize + 1).array));

    // overflow checks
    Stack over = Stack(4, 2);
    assert(!over.canPush([1, 2, 3]));  // item overflow
    over.push([1, 2]);
    over.push([1, 2]);
    assert(!over.canPush([1, 2]));  // stack overflow
}
