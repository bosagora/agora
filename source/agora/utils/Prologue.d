/*******************************************************************************

    Fiber utilities

    Many of our code run within a fiber, but D is not yet safe w.r.t. them:
    It is possible to stack overflow, leading to the OS killing us.
    This is highly undesireable, especially as it can happen anywhere in
    the program where a function is called, and as a result of another portion
    of the code being modified.
    Hence this module goal is to provide epilogue, prologues, and utilities
    to ensure

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/
