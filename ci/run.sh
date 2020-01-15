#!/bin/bash

set -xeu
set -o pipefail

ulimit -Ss 16384
ulimit -Hs
ulimit -Ss

dub test -b unittest-cov --skip-registry=all --compiler=${DC}
rdmd --compiler=${DC} ./tests/runner.d --compiler=${DC} -cov
dub build --skip-registry=all --compiler=${DC}
