#!/bin/bash

set -xeu
set -o pipefail

export AGORA_VERSION="HEAD"

dub build --skip-registry=all --compiler=${DC}
dub build -c client --skip-registry=all --compiler=${DC}

# Only build the unittest binary, but don't run it
# We want to run it ourselves to catch any bug / set timeout, etc...
dub build -b unittest-cov -c unittest --skip-registry=all --compiler=${DC}

# Run this after unit tests have proven to compile ok
rdmd --compiler=${DC} ./tests/runner.d --compiler=${DC} -cov

export dchatty=1
export dsinglethreaded=1
# A run currently (2020-07-21) takes < 6 minutes on Linux
# Run a single test at a time to prevent resource issues and also see which test failed
timeout -s SEGV 20m ./build/agora-unittests
