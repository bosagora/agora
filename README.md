# Agora

[Docker Hub image](https://hub.docker.com/r/bpfk/agora)

[![CircleCI](https://circleci.com/gh/bpfkorea/agora.svg?style=svg)](https://circleci.com/gh/bpfkorea/agora)
[![codecov](https://codecov.io/gh/bpfkorea/agora/branch/v0.x.x/graph/badge.svg)](https://codecov.io/gh/bpfkorea/agora)
[![](https://images.microbadger.com/badges/image/bpfk/agora.svg)](https://microbadger.com/images/bpfk/agora)
[![](https://images.microbadger.com/badges/version/bpfk/agora.svg)](https://microbadger.com/images/bpfk/agora)
[![License](https://img.shields.io/github/license/bpfkorea/agora)](LICENSE)
[![Documentation](https://img.shields.io/badge/Docs-Github%20Pages-blue)](https://bpfkorea.github.io/agora/)

Node implementation for BOA CoinNet

# Docker usage

We provide a public build of this repository (see above).
The easiest way to get agora is to run `docker pull bpfk/agora`.

The `Dockerfile` lives at the root of this repository,
so one can run `docker build -t agora .` to build it.
Note that you need to initialize submodules (`git submodule update --init`)
before you first build agora.

For a test run, try:
```console
docker run -p 127.0.0.1:4000:2826/tcp -v `pwd`/doc/:/agora/etc/ agora -c etc/config.example.yaml
```
This will start a node with the example config file,
and make the port locally accessible (See http://127.0.0.1:4000/) .

# Building on POSIX

## Dependencies

You need a recent C++ compiler (g++ with N4387 fixed), a recent (>=1.19.0) version of the LDC compiler, and `dub`.
On Linux, we recommend gcc-9. On OSX, the latest `llvm` package available on Homebrew.

Additionally, the following are dependencies:
- `libsodium`:  Development library
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

## Build instructions

```console
# Install the LDC compiler (you might want to use a newer version)
curl https://dlang.org/install.sh | bash -s ldc-1.24.0
# Add LDC to the $PATH
source ~/dlang/ldc-1.24.0/activate
# Clone this repository
git clone https://github.com/bpfkorea/agora.git
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
- `system_run.d`: to start the system test environment locally for local debugging
