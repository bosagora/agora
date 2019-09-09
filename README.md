# Agora

[![Build Status](https://travis-ci.com/bpfkorea/agora.svg?branch=v0.x.x)](https://travis-ci.com/bpfkorea/agora)
[![CircleCI](https://circleci.com/gh/bpfkorea/agora.svg?style=svg)](https://circleci.com/gh/bpfkorea/agora)
[![codecov](https://codecov.io/gh/bpfkorea/agora/branch/v0.x.x/graph/badge.svg)](https://codecov.io/gh/bpfkorea/agora)
[![](https://images.microbadger.com/badges/image/bpfk/agora.svg)](https://microbadger.com/images/bpfk/agora)
[![](https://images.microbadger.com/badges/version/bpfk/agora.svg)](https://microbadger.com/images/bpfk/agora)

Node implementation for BOA CoinNet

# Building on POSIX

You need a recent C++ compiler (g++ with N4387 fixed), a recent D compiler, and `dub`.
On Linux, we recommend you install gcc-9 so that you can also get `gdc`.
On OSX, the latest `llvm` package should do the job.

```console
# Install the latest DMD compiler
curl https://dlang.org/install.sh | bash -s
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

Note: on OSX, it's necessary to have `pkg-config` installed, and to export the `PKG_CONFIG_PATH` envirnoment variable so it can find the `sqlite3` library to link to.

```console
brew install pkg-config

# or ~/.zshrc, etc
echo export PKG_CONFIG_PATH="/usr/local/opt/sqlite/lib/pkgconfig" >> ~/.bashrc
```

You can also check our [CI configuration](./.travis.yml).
