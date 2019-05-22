# Stellar Consensus Protocol code

This code has been extracted from [stellar-core](https://github.com/stellar/stellar-core).
It is built as a dependency to `constrictor`, and bindings are written in [the D Programming Language](https://dlang.org/) to interact with it.

The path of each file matches the path in `stellar-core` relative to the root of the git repository, in order to make comparison and updating simpler.
Files in `extra` are extra C++ files added to the build (e.g. to instantiate templates so the D side can use it).

Commit used for extraction: [324c1bd61b0e9bada63e0d696d799421b00a7950](https://github.com/stellar/stellar-core/commit/324c1bd61b0e9bada63e0d696d799421b00a7950)
Timestamp of commit: Monday 2019-05-20 21:24:29 UTC

# Update process

- Checkout stellar-core
- Perform a full build (not an installation) using [Stellar's instructions](https://github.com/stellar/stellar-core/blob/master/INSTALL.md)
- Copy the required files
- Update the bindings

The full build step is required to make sure the `.h` for XDR are up to date, as there is no XDR -> D converter, we use XDR -> C++ -> D instead.
Alternatively, one can use the experimental `update.d` update script.

# LICENSE

This code is distributed under the Apache License 2.0, as the rest of `stellar-core`.
