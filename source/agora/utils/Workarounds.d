/*******************************************************************************

    Workarounds for compiler / runtime / upstream issues

    Live in this module so they can be imported by code that imports other
    module in Agora, such as the system integration test.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Workarounds;

// Workaround https://issues.dlang.org/show_bug.cgi?id=19937
private void workaround19937 ()
{
    import core.internal.dassert;
    _d_assert_fail!("", int)._d_assert_fail(const(int).init);
    _d_assert_fail!("==", ulong, ulong)._d_assert_fail(const(ulong).init, const(ulong).init);
    const bool byRef;
    _d_assert_fail!("", bool)._d_assert_fail(byRef);
    miniFormatFakeAttributes!(bool).miniFormatFakeAttributes(byRef);
    _d_assert_fail!("", int)._d_assert_fail(const(int).init);
    _d_assert_fail!("!", bool)._d_assert_fail(const(bool).init);
    _d_assert_fail!("<", ulong, ulong)._d_assert_fail(const(ulong).init, const(ulong).init);
}
