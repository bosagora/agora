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
${DC} -i -run ./tests/runner.d ${DC} -cov

# Run a single test at a time to prevent resource issues and also see which test failed
export dchatty=true
export dsinglethreaded=true
# Our unittests sometimes locks up - It might be a localrest bug
# The Github workflow timeout is set to 60m, but that accounts for the second run
# if the first one fails.
timeout -v --preserve-status -s SEGV 35m ./build/agora-unittests || timeout -v --preserve-status -s SEGV 35m ./build/agora-unittests
