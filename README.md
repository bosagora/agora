# Agora

[Docker Hub image](https://hub.docker.com/r/bosagora/agora)

![Github CI](https://github.com/bosagora/agora/actions/workflows/main.yml/badge.svg)
[![codecov](https://codecov.io/gh/bosagora/agora/branch/v0.x.x/graph/badge.svg)](https://codecov.io/gh/bosagora/agora)
[![License](https://img.shields.io/github/license/bosagora/agora)](LICENSE)
[![Documentation](https://img.shields.io/badge/Docs-Github%20Pages-blue)](https://bosagora.github.io/agora/)

Node implementation for BOA CoinNet

# Docker usage

We provide a public build of this repository (see above).
The easiest way to get agora is to run `docker pull bosagora/agora`.

This will pull the `latest` tag, which is the one our team deploys internally.
Previous versions can be pulled via their version, e.g. `docker pull bosagora/agora:v0.24.0`.

The `Dockerfile` lives at the root of this repository,
so one can run `docker build -t agora .` to build it.
Note that you need to initialize submodules (`git submodule update --init`)
before you first build agora.

# Building on POSIX

## Dependencies

You need a recent `clang++` (with N4387 fixed), a recent (>=1.26.0) version of the LDC compiler, and `dub`.

Additionally, the following are dependencies:
- `libsodium >= 1.0.18`:  Development library
- `pkg-config`: For DUB to find the correct `sqlite3` and other system libraries
- `openssl`:    Binary (to detect the version) and development library
- `sqlite3`:    Development library
- `zlib`:       Development library

Additionally, on OSX, `PKG_CONFIG_PATH` needs to be properly set to pick up `sqlite3` and `openssl`.
Provided you installed those packages via `brew`, you can run the following command prior to building:
```console
export PKG_CONFIG_PATH="/usr/local/opt/sqlite/lib/pkgconfig:/usr/local/opt/openssl@1.1/lib/pkgconfig"
```
Since this setting does not persist, we recommend you follow Homebrew's instructions
and add it to your `.bashrc`, `.zshrc`, etc...

The following can be used on Ubuntu 20.04 to get the required dependencies:
```console
sudo apt-get update && sudo apt-get install build-essential clang libsodium-dev libssl-dev libsqlite3-dev zlib1g-dev
```

On older distributions (e.g. Ubuntu 18.04), `libsodium` might not be at version v1.0.18.

## Build instructions

```console
# First, make sure you have the package listed in the Dependencies section installed.
#
# Then, install the LDC compiler (you might want to use a newer version)
# This will also install dub, the D package manager / build tool
curl https://dlang.org/install.sh | bash -s ldc-1.26.0
# Add LDC to the $PATH
source ~/dlang/ldc-1.26.0/activate
# Clone this repository
git clone https://github.com/bosagora/agora.git
# Use the git root as working directory
cd agora/
# Initialize and update the list of submodules
git submodule update --init
# Build the application
dub build --skip-registry=all
# Build & run the tests
dub test --skip-registry=all
```

## Running tests

Agora comes with plenty of tests. Take a look at the CI configuration for an exact list.
At the moment, the three main ways to run the test are:
- `dub test`: Test the consensus protocol and runs all the unittests
- `rdmd tests/runner.d`: Run a serie of simple integrations tests
- `ci/system_integration_test.d`: Run a full-fledged system integration test, including building the docker image.

## Source code organization

The code is divided into multiple parts:
- The "main" source code lives in [source/agora](source/agora/). Consensus rules and node implementation lives there;
- The extracted SCP code lives in [source/scpp](source/scpp/). See the [README](source/scpp/README.md) for more information;
- Our Dlang binding for SCP's C++ implementation lives in [source/scpd](source/scpd/), along with some C++ helpers;
- The setup interface, Talos, is a React app living in [the talos directory](talos);

The directory `source/agora/` is the root package. Sub-packages include:
- `agora.api`: Defines interfaces that describe the APIs exposed by different types of nodes (FullNode, Validator, Flash...);
- `agora.cli`: Contains various CLI tools used by Agora (see the [`dub.json`](dub.json) sub-configuration to build them);
- `agora.common`: A leaf package that contains various general-purpose utilities which aren't Agora specific;
- `agora.consensus`: Implements Agora's consensus protocol, can be used as a standalone library;
- `agora.crypto`: Contains cryptographic utilities, such as the key type;
- `agora.flash`: Implementation of the Flash layer;
- `agora.network`: Manages a node's view of the network;
- `agora.node`: Implementation of the two main types of nodes (Full node and Validator) and related modules;
- `agora.script`: Implementation of the script engine;
- `agora.stats`: Holds helper modules for statistics exported by Agora and other tools;
- `agora.test`: Contains network tests for the consensus protocol. See [the README](source/agora/README.md) for more details;
- `agora.utils`: Contains utilities that don't fit in other packages, such as a custom tracing GC, Tracy integration, `TxBuilder`...

Additionally, Agora's dependencies live in [`submodules`](submodules/) and are managed via `git submodule`.
Of those submodules, few are internally managed libraries (`crypto`, `serialization`, ...), and some may be forks
of externally managed libraries (either because the library is unmaintained or because specific tweaks were needed).
A [README](submodules/README.md) provides more details.

## Running single test node using TestNet GenesisBlock

For a test of a full node connecting to testnet, try:
```console
docker run -p 2826:2826 -p 9111:9111 -v `pwd`/devel/config-fullnode.yaml:/agora/etc/config.yaml bosagora/agora -c /agora/etc/config.yaml
```
The node API will be locally available. It can be accessed with:
```console
curl http://127.0.0.1:2826/blocks/0
```
Likewise, the metrics endpoint will be exposed:
```console
curl http://127.0.0.1:9111/metrics
```
