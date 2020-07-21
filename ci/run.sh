#!/bin/bash

set -xeu
set -o pipefail

# Only build the unittest binary, but don't run it
# We want to run it ourselves to catch any bug / set timeout, etc...
dub build -b unittest-cov -c unittest --skip-registry=all --compiler=${DC}

dchatty=1
# A run currently (2020-07-21) takes < 6 minutes on Linux
# Try a total of three times
timeout -s SEGV 8m ./build/agora-unittests || timeout -s SEGV 8m ./build/agora-unittests || timeout -s SEGV 8m ./build/agora-unittests

rdmd --compiler=${DC} ./tests/runner.d --compiler=${DC} -cov
dub build --skip-registry=all --compiler=${DC}
dub build -c client --skip-registry=all --compiler=${DC}
