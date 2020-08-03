# Agora dependencies

This folder contains all the dependencies of Agora.

Unlike traditional `dub` dependencies, we manage them using `git submodule`.
Thus, an update requires changing the submodule, not the `dub.selections.json`,
which always points to the path of those submodules.

Due to [a bug in `dub`](https://github.com/dlang/dub/issues/1706), some folders have to be dummy packages
(they are unused dependency, but `dub` tries to fetch all dependencies for all configurations anyways).

We have write access to - or ownership of - most of those dependencies,
and will attempt to upstream any bugfix made for the sake of Agora.
In the event that it isn't possible (e.g. `base32` where the author is AWOL),
we will fork the dependency in the `bpfkorea` organization.
