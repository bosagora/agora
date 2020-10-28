/*******************************************************************************

    Keeps track of scopes and their conditions (TRUE or FALSE).
    This struct can be used to implement conditional (IF/ELSE/ENDIF) logic.

    It does this by pushing a new scope for each visited `IF` opcode,
    popping a scope for every visited `END_IF` opcode, and toggling the scope's
    condition for every visited `ELSE` opcode.

    Unlike C-like programming languages we do not support GOTO and therefore
    may only increment the program counter one instruction at a time.
    This constraint makes this ScopeCondition design possible.

    This implementation is largely based on Bitcoin's `ConditionStack`,
    as it's the most optimal O(1) solution we could think of using.

    For a description on how code flow control works (for a previous version),
    see: https://building-on-bitcoin.com/docs/slides/Thomas_Kerin_BoB_2018.pdf

    Copyright:
        Copyright (c) 2009-2010 Satoshi Nakamoto
        Copyright (c) 2009-2020 The Bitcoin Core developers
        Copyright (c) 2020 BOS Platform Foundation Korea

    License:
        Distributed under the MIT software license, see the accompanying
        file LICENSE or http://www.opensource.org/licenses/mit-license.php.

*******************************************************************************/

module agora.script.ScopeCondition;

/// Ditto
public struct ScopeCondition
{
    /// Current number of scopes
    private uint scope_count;

    /// The scope index at which the earliest FALSE is found, or -1 if none
    private int false_idx = -1;

    /***************************************************************************

        Returns:
            true if there are any scopes left

    ***************************************************************************/

    public bool empty () const pure nothrow @safe @nogc
    {
        return this.scope_count == 0;
    }

    /***************************************************************************

        Returns:
            true if there are no scopes with a FALSE condition.
            Also returns true if there are no scopes (IOW global scope)

    ***************************************************************************/

    public bool isTrue () const pure nothrow @safe @nogc
    {
        return this.false_idx == -1;
    }

    /***************************************************************************

        Push a new scope with the given condition.
        If this is the first scope with a FALSE condition then
        it sets the earliest FALSE scope index to the current scope.

        Params:
            cond = the evaluated condition of a visited `IF` / `NOT_IF` opcode

    ***************************************************************************/

    public void push (bool cond) nothrow @safe @nogc
    {
        if (!cond && this.false_idx == -1)  // first false condition
            this.false_idx = this.scope_count;

        this.scope_count++;
    }

    /***************************************************************************

        Pops the current scope, and toggles the condition to TRUE
        if the outer scope we entered was the earliest FALSE scope.

        Call this after an `ENDIF` opcode, but check `empty()` first.

    ***************************************************************************/

    public void pop () nothrow @safe @nogc
    {
        assert(this.scope_count > 0);

        if (this.false_idx == this.scope_count - 1)
            this.false_idx = -1;  // earliest false => toggle to true
        this.scope_count--;
    }

    /***************************************************************************

        Try toggling the current scope's condition.

        If the current scope's condition is TRUE then set it to FALSE.
        If the current scope's condition is FALSE then it's toggled to TRUE
        only if the earliest FALSE condition is the current scope.

        Call this after an `ELSE` opcode but check `empty()` first.
        Note that `ScopeCondition` does not handle any dangling / duplicate
        `ELSE` opcodes, this is the client code's responsibility.

    ***************************************************************************/

    public void tryToggle () nothrow @safe @nogc
    {
        assert(this.scope_count > 0);

        if (this.false_idx == -1)  // all scopes are true, mark earliest false
            this.false_idx = this.scope_count - 1;
        else if (this.false_idx == this.scope_count - 1)
            this.false_idx = -1;  // we're at earliest false scope, toggle to true
    }
}

///
nothrow @safe @nogc unittest
{
    import ocean.core.Test;

    ScopeCondition sc;
    assert(sc.empty());
    assert(sc.isTrue());

    // IF
    //     DO <- pc
    sc.push(true);
    assert(!sc.empty());
    assert(sc.isTrue());

    // IF
    //     DO
    // ELSE
    //     DO <- pc
    sc.tryToggle();
    assert(!sc.empty());
    assert(!sc.isTrue());

    // IF
    //     IF
    //         DO <- pc
    //     ENDIF
    //     DO
    // ENDIF
    sc = ScopeCondition.init;
    sc.push(true);
    sc.push(true);
    assert(!sc.empty());
    assert(sc.isTrue());

    // IF
    //     IF
    //         DO
    //     ENDIF
    //     DO  <- pc
    // ENDIF
    sc.pop();
    assert(!sc.empty());
    assert(sc.isTrue());

    // IF
    //     IF
    //         DO
    //     ENDIF
    //     DO
    // ENDIF  <- pc
    sc.pop();
    assert(sc.empty());
    assert(sc.isTrue());

    // OP_TRUE
    // IF -> true
    //     DO -> executed
    //     OP_0
    //     IF
    //         DO -> skipped
    //         OP_TRUE <- false as previous scope was false
    //         IF
    //             DO -> skipped
    //             OP_TRUE <- false, ditto
    //             IF
    //                 DO -> skipped
    //                 OP_TRUE <- false, ditto
    //                 IF
    //                      DO -> skipped
    //                 ENDIF
    //                 DO -> skipped
    //             ENDIF
    //             DO -> skipped
    //         ENDIF
    //         DO -> skipped
    //     ENDIF
    //     DO -> executed (no false scopes left)
    // ENDIF
    sc = ScopeCondition.init;
    sc.push(true);
    sc.push(false);
    sc.push(true);
    sc.push(true);
    sc.push(false);
    assert(!sc.empty());
    assert(!sc.isTrue());
    sc.pop();
    assert(!sc.empty());
    assert(!sc.isTrue());
    sc.pop();
    assert(!sc.empty());
    assert(!sc.isTrue());
    sc.pop();
    assert(!sc.empty());
    assert(!sc.isTrue());
    sc.pop();
    assert(sc.isTrue());
    sc.pop();
    assert(sc.empty());
    assert(sc.isTrue());
}
