#!/bin/bash

set -xeu
set -o pipefail

mkdir -p $HOME/bin/
ln -s `which gcc-9` $HOME/bin/gcc # /usr/bin/gcc-9
ln -s `which g++-9` $HOME/bin/g++ # /usr/bin/g++-9
