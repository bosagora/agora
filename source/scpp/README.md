# Stellar Consensus Protocol code

This code has been extracted from [stellar-core](https://github.com/stellar/stellar-core).
It is built as a dependency of `agora`, and bindings are written in [the D Programming Language](https://dlang.org/) to interact with it.

The path of each file matches the path in `stellar-core` relative to the root of the git repository, in order to make comparison and updating simpler.
Files in `extra` are extra C++ files added to the build (e.g. to instantiate templates so the D side can use it).

Commit used for extraction: [f31c8f90d7abc634fc89818e013a32dc5f2badc8](https://github.com/stellar/stellar-core/commit/f31c8f90d7abc634fc89818e013a32dc5f2badc8)
Timestamp of commit: Tue Jun 15 02:40:38 2021 -0700

# Porting notes

Some files have been modified after porting:

- Some `private` declarations were changed to `public`. This allows us to test size & layout checks for our D glue layer, for example: https://github.com/bosagora/agora/blob/76e4ca7d77b123ef867d3ce99c1c1b26afab761d/source/scpp/src/crypto/ByteSlice.h#L21 used in https://github.com/bosagora/agora/blob/76e4ca7d77b123ef867d3ce99c1c1b26afab761d/source/scpp/extra/DSizeChecks.cpp and https://github.com/bosagora/agora/blob/76e4ca7d77b123ef867d3ce99c1c1b26afab761d/source/scpp/extra/DLayoutChecks.cpp.

- Stellar-specific definitions are in `src/xdr/`. Notably, the `.x` files are XDR definitions files which `xdrcpp` processes to generate the `.h` file. Since we don't have a similar tool for D, we generated the `.h` files from the XDR and copied both over. `xdrpp` also provides some base types (e.g. `xvector`) which are binded in D.
  We use a different hash and public key type than Stellar. Fortunately, all those types are confined to `Stellar-types.h`.

# Update process

- Checkout stellar-core
- Perform a full build (not an installation) using [Stellar's instructions](https://github.com/stellar/stellar-core/blob/master/INSTALL.md)
- Copy the required files
- Update the bindings

The full build step is required to make sure the `.h` for XDR are up to date, as there is no XDR -> D converter, we use XDR -> C++ -> D instead.
Alternatively, one can use the experimental `update.d` update script.

# LICENSE

This code is distributed under the Apache License 2.0, as the rest of `stellar-core`.
