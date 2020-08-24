#!/bin/bash

set -xeu
set -o pipefail

# Only build the unittest binary, but don't run it
# We want to run it ourselves to catch any bug / set timeout, etc...
dub build -b unittest-cov -c unittest --skip-registry=all --compiler=${DC}

export dchatty=1
./build/agora-unittests

rdmd --compiler=${DC} ./tests/runner.d --compiler=${DC} -cov
dub build --skip-registry=all --compiler=${DC}
dub build -c client --skip-registry=all --compiler=${DC}
