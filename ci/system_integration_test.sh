#!/bin/bash

set -xeu
set -o pipefail

docker build --build-arg DUB_OPTIONS="-b cov" -t agora .
docker run agora --help
