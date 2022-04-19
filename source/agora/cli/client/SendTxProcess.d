/*******************************************************************************

    The Agora client sub-function for sendtx command

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.client.SendTxProcess;

import agora.api.FullNode;
import agora.client.Common;
import agora.common.Amount;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.serialization.Serializer;
import agora.script.Lock;
import agora.script.Signature;

import std.format;
import std.getopt;
import std.stdio;

/// Option required to send transaction
private struct SendTxOption
{
    /// Common arguments
    public ClientCLIArgs base;

    /// For convenience
    public alias base this;

    /// Hash of the previous transaction
    public string txhash;

    /// The index of the output in the previous transaction
    public uint index;

    /// The seed used to sign the new transaction
    public string key;

    /// The address key to send the output
    public string dest;

    /// The amount to spend
    public ulong amount;

    /// dump output option
    public bool dump;

    /// Parse the command-line arguments of sendtx
    public GetoptResult parse (string[] args)
    {
        auto intermediate = this.base.parse(args);
        if (intermediate.helpWanted)
            return intermediate;

        return getopt(
            args,
            "txhash|t",
              "Hash of the previous transaction",
              &this.txhash,

            "index|n",
              "The index of the output in the previous transaction",
              &this.index,

            "amount|a",
              "The amount to spend",
              &this.amount,

            "dest|d",
              "The address key to send the output",
              &this.dest,

            "key|k",
              "The seed used to sign the new transaction",
              &this.key,

            "dump|o",
              "dump output option",
              &this.dump,
        );
    }
}

/// Print help
public void printSendTxHelp (ref string[] outputs)
{
    outputs ~= "usage: agora-client sendtx [--dump] [--address addr] --txhash --index --amount --dest --key";
    outputs ~= "";
    outputs ~= "   sendtx      Send a transaction to node";
    outputs ~= "";
    outputs ~= "        -i --address Address of a node (e.g. http://agora.example.com)";
    outputs ~= "        -t --txhash  Hash of the previous transaction that";
    outputs ~= "                     contains the Output which the new ";
    outputs ~= "                     transaction will spend";
    outputs ~= "        -n --index   The index of the output in the previous";
    outputs ~= "                     transaction which will be spent";
    outputs ~= "        -a --amount  The amount to spend";
    outputs ~= "        -d --dest    The address key to send the output";
    outputs ~= "        -k --key     The seed used to sign the new transaction";
    outputs ~= "        -o --dump    Dump output option";
    outputs ~= "";
}

/*******************************************************************************

    Input an arguments, generate the transaction and send it to the node

    Params:
        args = client command line arguments
        outputs = Array in which to append user-readable output
                  (1 line will be one entry)
        api_maker = A delegate that makes an API object based on the address

    Result:
        0 if successful, otherwise 1

*******************************************************************************/

public int sendTxProcess (string[] args, ref string[] outputs, APIMaker api_maker)
{
    SendTxOption op;

    try
    {
        auto res = op.parse(args);
        if (res.helpWanted)
        {
            printSendTxHelp(outputs);
            return 0;
        }
    }
    catch (Exception ex)
    {
        outputs ~= "Error: " ~ ex.msg;
        printSendTxHelp(outputs);
        return 1;
    }

    bool isValid = true;

    if (op.txhash.length == 0)
    {
        if (isValid) printSendTxHelp(outputs);
        outputs ~= "Previous Transaction hash is not entered.[--txhash]";
        isValid = false;
    }

    if (op.amount == 0)
    {
        if (isValid) printSendTxHelp(outputs);
        outputs ~= "Amount is not entered.[--amount]";
        isValid = false;
    }

    if (op.dest.length == 0)
    {
        if (isValid) printSendTxHelp(outputs);
        outputs ~= "Address is not entered.[--dest]";
        isValid = false;
    }

    if (op.key.length == 0)
    {
        if (isValid) printSendTxHelp(outputs);
        outputs ~= "Key is not entered.[--key]";
        isValid = false;
    }

    if (!isValid)
        return 1;

    // create the transaction
    auto key_pair = KeyPair.fromSeed(SecretKey.fromString(op.key));

    Transaction tx = Transaction([Input(Hash.fromString(op.txhash), op.index)],
        [Output(Amount(op.amount), PublicKey.fromString(op.dest))]);

    auto signature = key_pair.sign(tx.getChallenge());
    tx.inputs[0].unlock = genKeyUnlock(signature);

    if (op.dump)
    {
        outputs ~= format("txhash = %s", op.txhash);
        outputs ~= format("index = %s", op.index);
        outputs ~= format("amount = %s", op.amount);
        outputs ~= format("dest = %s", op.dest);
        outputs ~= format("address = %s", op.address);
        outputs ~= format("key = %s", op.key);
        outputs ~= format("hash of new transaction = %s", hashFull(tx).toString);
        return 0;
    }

    // connect to the node
    auto node = api_maker(op.address);

    // send the transaction
    auto result = node.postTransaction(tx);
    if (result.status != TransactionResult.Status.Accepted)
        return 1;

    return 0;
}

/// Test of send transaction
unittest
{
    // BlackHole auto-implements interface methods and returns typeof(return).init
    import std.typecons;
    class TestCLINode : BlackHole!API
    {
        @safe:

        /// Contains the transaction cache
        private Transaction[Hash] tx_cache;

        public override TransactionResult postTransaction (in Transaction tx) @safe
        {
            this.tx_cache[hashFull(tx)] = tx.serializeFull().deserializeFull!Transaction;
            return TransactionResult(TransactionResult.Status.Accepted);
        }

        /// GET: /hasTransactionHash
        public override bool hasTransactionHash (in Hash tx) @safe
        {
            return (tx in this.tx_cache) !is null;
        }
    }


    import std.format;

    string txhash = `0x893abe59f6640fe10aae19682ba982276e78e155a13e7f3ab377f426330c4732`
    ~ `b4d46a3a6c2a81719dc953dd4d92b493281f8f7a6cef38beca135563d0fdd115`;
    uint index = 0;
    string key = "SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI";
    string address = "boa1xz2t25k5rfdk0jn5lvydaa29p2fvsgpl8adsrflvxxs4dcg48paev8mw3nr";
    ulong amount = 1000;

    string[] args =
        [
            "sendtx",
            "--address=localhost:2826",
            format("--txhash=%s", txhash),
            format("--index=%d", index),
            format("--amount=%d", amount),
            format("--dest=%s", address),
            format("--key=%s", key),
            "--dump=false"
        ];
    string[] outputs;

    auto node = new TestCLINode();
    auto res = sendTxProcess(args, outputs, (address) {
        return node;
    });
    assert (res == 0);

    Transaction tx = Transaction([Input(Hash.fromString(txhash), index)],
        [Output(Amount(amount), PublicKey.fromString(address))]);
    auto key_pair = KeyPair.fromSeed(SecretKey.fromString(key));
    tx.inputs[0].unlock = genKeyUnlock(key_pair.sign(tx.getChallenge()));

    foreach (ref line; outputs)
        writeln(line);

    assert(node.hasTransactionHash(hashFull(tx)));
}
