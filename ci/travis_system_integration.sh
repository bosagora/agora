#!/bin/bash

set -xeu
set -o pipefail

docker build -t agora .
docker run agora --help
