# Debugging memory usage

Agora integrates its own GC in [agora.utils.gc.GC](source/agora/utils/gc/), which is mostly a copy of
[the default D garbage collector](https://github.com/dlang/druntime/blob/84db3c620dfe1b17e63645a64b55ddffd455bad5/src/core/internal/gc/impl/conservative/gc.d).

This GC comes with a [Tracy](https://github.com/wolfpld/tracy) integration,
allowing one to monitor what and where memory is allocated and freed.
It is not enabled by default, but can be by starting agora with `--DRT-gcopt="gc:tracking-conservative"` or
`--DRT-gcopt="gc:tracking-precise"` if you wish to use the precise GC.

For example:
```shell
$ ./build/agora --DRT-gcopt="gc:tracking-conservative" -c /etc/agora.conf
```
