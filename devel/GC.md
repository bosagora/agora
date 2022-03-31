# Debugging memory usage

Agora integrates a [Tracy profiler](https://github.com/bosagora/tracyd) when
compiled with `traced-server` configuration.

```
dub build --config="traced-server"
```

This profiler integration comes with a custom GC,
allowing one to monitor what and where memory is allocated and freed.
It is not enabled by default, but can be by starting agora with `--DRT-gcopt="gc:tracking-conservative"` or
`--DRT-gcopt="gc:tracking-precise"` if you wish to use the precise GC.

For example:
```shell
$ ./build/agora --DRT-gcopt="gc:tracking-conservative" -c /etc/agora.conf
```
