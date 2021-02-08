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

export dchatty=true
export dsinglethreaded=true
# Run a single test at a time to prevent resource issues and also see which test failed
gdb -batch -ex "handle SIGUSR1 noprint" -ex "handle SIGUSR2 noprint" -ex run -ex bt ./build/agora-unittests
