#!/bin/bash

set -xeu
set -o pipefail

dub test -b unittest-cov --skip-registry=all --compiler=${DC}
rdmd --compiler=${DC} ./tests/runner.d --compiler=${DC} -cov
dub build --skip-registry=all --compiler=${DC}
dub build -c cli --skip-registry=all --compiler=${DC}
