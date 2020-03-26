#!/bin/bash

set -xeu
set -o pipefail

mkdir -p $HOME/Dependencies/
wget -P $HOME/Dependencies/ https://homebrew.bintray.com/bottles/libsodium-1.0.18.high_sierra.bottle.tar.gz
tar -C /usr/local/Cellar/ -xf $HOME/Dependencies/libsodium-1.0.18.high_sierra.bottle.tar.gz
brew link libsodium

# enable core dumps
ulimit -c unlimited -S
sudo mkdir /cores/ && sudo chmod 777 /cores/
sudo sysctl -w kern.corefile=/cores/%E.%p
