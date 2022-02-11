# Introduction

This document will guide you through the steps required to try out Agora, BOSAGORA's node,
and in particular how to interact with Foundation nodes in the test network ("TestNet").

## Validator vs full nodes

Agora can run in one of two major modes: Full node, and validator. We recommend one to familiarize themselves with running
a full node before attempting to run a validator, as misconfiguration could lead to network instability and likely result
in one's inability to run a validator as the fund will get slashed.

A validator also requires to be publicly accessible on the internet, making the configuration more complicated.
All the instructions that apply to full nodes apply to validators as well.
For brevity, instructions will simply refer to full nodes as "node(s)".

## System requirements

The following are minimum requirements to run a node:
- x86_64 processor or compatible, > 2 GHz
- 4 GBs of RAM;
- 1 GB of free space;
- Linux, Mac, or Windows with either Docker or WSL;
- Internet connection;

In practice, most consumer computers built after 2010 will satisfy those requirements.

## Docker or native binaries

The recommended way to run Agora is via the docker image.
Native binaries for Ubuntu Linux 20.04 and MacOS-11 (Big Sur) are also available.
One may also elect to compile Agora on their own machine using the instructions [here](https://github.com/bosagora/agora#build-instructions).

For Docker users, if Docker is not yet installed, head [here](https://www.docker.com/get-started).
Agora download will be automatically done on first run, you do not have anything to do at this point.

For native binaries, head over to [Agora's release page](https://github.com/bosagora/agora/releases) and grab the binary matching your system.
For example, as of this writing, the last release is `v0.33.0`. Look for the `agora` binary matching your system:

![Asset list for v0.33.0](./Release.v0.33.0.png)

Clicking on the name will download it. Other binaries (`agora-config-dumper`, `agora-client`) are side tools
and cannot be used to run a node.

## Running a full node under Docker

Open a terminal and use the command `docker run bosagora/agora --testnet`.

The node should start, and print a bunch of messages to the screen. It should start synchronizing
with the network about a few seconds, downloading the current state of the chain.
The messages should look like this:

![Initial Block Download log messages](./IBD.png)

Bear in mind that this is the minimum required to run a node that synchronize with the network.
Your node will not be contacted by other nodes - it is not a validator, just a full node.
Additionally, because we are using Docker, stopping the program (press `Ctrl` + `C` or `Command` + `C` on Mac)
will completely wipe out the state: the next time you start the node, it will re-download the blockchain.

A simple way to avoid re-downloading the blockchain is to "mount" the current directory inside Docker
with the following command:
```shell
docker run -v $(pwd):/agora/ bosagora/agora --testnet
```

As long as you use this command to start Agora, you will not have to always re-download the chain.

## Configuring a full node further

Agora can be extensively configured via the use of a configuration file.
By default, Agora will look for `config.yaml` in the directory it is started in, but using the `-c`
command line option, you can give Agora any configuration file.
Using `--testnet` is a special way to make Agora start without a configuration file.

You can find a [simple configuration file in this directory](./config.yaml), which you may modify to suit your own needs,
using the directives listed in the [example configuration file](/doc/config.example.yaml)

To use it, simply copy it in the directory where you run Agora and use the following command:
```shell
# Use this if your file is named `config.yaml`
docker run -v $(pwd):/agora/ bosagora/agora
# Or use the following for a file named `my_config.yaml`:
docker run -v $(pwd):/agora/ bosagora/agora -c my_config.yaml
```

## Running a validator

Before you can run a validator, you must be familiar with the basics of running a server.
In particular, you **MUST** have a publicly-accessible computer or server,
as a non-accessible node will eventually be slashed by the network, resulting in your
inability to continue running a validator.

The first step to run a validator is generate a public / private key pair.
This can be done on the [testnet wallet](https://testnet.boawallet.io/)

![Example of a private / public key pair being created](./Wallet.Account.Creation.png)

As you can see, the key pair comes in two parts:
The private part which starts with `S` and is all uppercase, should never be shared.
The public part starts with `boa1` and can be freely shared with third party.
The private part is sometimes also refered to as a "seed".
The following examples use the above values for seed and public key.
In your own commands and configuration, they should be replaced with your own values.

Once you have generated a suitable key pair, you need to get a frozen stake worth
40,000 coins to be able to register. We've made it easy by providing a page that
will create the stake for you: [Faucet](https://faucet.bosagora.io/).

![Requesting a stake on Faucet](./Faucet.png)

Once this is done, all you have to do is to change your configuration file
to the following:
```yaml
validator:
  enabled: true
  seed: SB3EENDWPUGQZL7KLWGJS2ILMGRBB2MLVLRBUVKDYTO6A4WYLPIQWEE3
```

Make sure you use the **seed** for the configuration and the **public key** for Faucet.

Once you start the node, and wait up to a few minutes, it should enroll by itself
and start validating. You can also make sure your node is accessible by checking
that `boa1xrwuel4csj4acdfdr5c6xufewa7r5l5g83cp5uax2lyxaakkhwc27aghk7m.validators.testnet.bosagora.io`
points to your own IP address.

## Updating your node

As we are constantly improving Agora, new versions will be released periodically.
For native binary users, follow the Agora repository to get a notification.
For `docker` users, doing `docker pull bosagora/agora` from time to time,
especially if your node starts to show errors, should help.

## Reporting issues

You can report issues you find [here](https://github.com/bosagora/agora/issues).
Make sure what you are reporting is an issue, and there isn't an existing issue covering yours.
If you aren't sure if the behavior you are seeing is an issue, the best way is to ask [here](https://github.com/bosagora/agora/discussions/categories/q-a).
