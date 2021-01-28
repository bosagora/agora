/*******************************************************************************

    The Agora client sub-function for sendtx command

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.client.SendTxProcess;

import agora.api.FullNode;
import agora.client.Result;
import agora.common.Amount;
import agora.common.crypto.Key;
import agora.common.Hash;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Transaction;

import std.format;
import std.getopt;
import std.stdio;

public alias APIMaker = API delegate (string address);

/// Option required to send transaction
private struct SendTxOption
{
    /// IP address of node
    public string host = "localhost";

    /// Port of node
    public ushort port = 2826;

    /// Hash of the previous transaction
    public string txhash;

    /// The index of the output in the previous transaction
    public uint index;

    /// The seed used to sign the new transaction
    public string key;

    /// The address key to send the output
    public string address;

    /// The amount to spend
    public ulong amount;

    /// dump output option
    public bool dump;
}

/// Parse the ommand-line arguments of sendtx (--version, --help)
public GetoptResult parseSendTxOption (ref SendTxOption op, string[] args)
{
    return getopt(
        args,
        "ip|i",
            "IP address of node (default: localhost)",
            &op.host,

        "port|p",
            "Port of node (default: 2826)",
            &op.port,

        "txhash|t",
            "Hash of the previous transaction",
            &op.txhash,

        "index|n",
            "The index of the output in the previous transaction",
            &op.index,

        "amount|a",
            "The amount to spend",
            &op.amount,

        "dest|d",
            "The address key to send the output",
            &op.address,

        "key|k",
            "The seed used to sign the new transaction",
            &op.key,

        "dump|o",
            "dump output option",
            &op.dump
            );

}

/// Print help
public void printSendTxHelp (ref string[] outputs)
{
    outputs ~= "usage: agora-client sendtx [--dump] [--ip addr] [--port port] --txhash --index --amount --dest --key";
    outputs ~= "";
    outputs ~= "   sendtx      Send a transaction to node";
    outputs ~= "";
    outputs ~= "        -i --ip      IP address of node";
    outputs ~= "        -p --port    Port of node";
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

*******************************************************************************/

public int sendTxProcess (string[] args, ref string[] outputs,
                            APIMaker api_maker)
{
    SendTxOption op;
    GetoptResult res;

    try
    {
        res = parseSendTxOption(op, args);
        if (res.helpWanted)
        {
            printSendTxHelp(outputs);
            return CLIENT_SUCCESS;
        }
    }
    catch (Exception ex)
    {
        printSendTxHelp(outputs);
        return CLIENT_EXCEPTION;
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

    if (op.address.length == 0)
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
        return CLIENT_INVALID_ARGUMENTS;

    // create the transaction
    auto key_pair = KeyPair.fromSeed(Seed.fromString(op.key));

    Transaction tx =
    {
        TxType.Payment,
        [Input(Hash.fromString(op.txhash), op.index)],
        [Output(Amount(op.amount), PublicKey.fromString(op.address))]
    };

    auto signature = key_pair.secret.sign(hashFull(tx)[]);
    tx.inputs[0].signature = signature;

    if (op.dump)
    {
        outputs ~= format("txhash = %s", op.txhash);
        outputs ~= format("index = %s", op.index);
        outputs ~= format("amount = %s", op.amount);
        outputs ~= format("address = %s", op.address);
        outputs ~= format("key = %s", op.key);
        outputs ~= format("hash of new transaction = %s", hashFull(tx).toString);
        return CLIENT_SUCCESS;
    }

    // connect to the node
    string ip_address = format("http://%s:%s", op.host, op.port);
    auto node = api_maker(ip_address);

    // send the transaction
    node.putTransaction(tx);

    return CLIENT_SUCCESS;
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

        public override void putTransaction (Transaction tx) @safe
        {
            this.tx_cache[hashFull(tx)] = tx;
        }

        /// GET: /hasTransactionHash
        public override bool hasTransactionHash (Hash tx) @safe
        {
            return (tx in this.tx_cache) !is null;
        }
    }


    import std.format;

    string txhash = `0x893abe59f6640fe10aae19682ba982276e78e155a13e7f3ab377f426330c4732`
    ~ `b4d46a3a6c2a81719dc953dd4d92b493281f8f7a6cef38beca135563d0fdd115`;
    uint index = 0;
    string key = "SCT4KKJNYLTQO4TVDPVJQZEONTVVW66YLRWAINWI3FZDY7U4JS4JJEI4";
    string address = "GCKLKUWUDJNWPSTU7MEN55KFBKJMQIB7H5NQDJ7MGGQVNYIVHB5ZM5XP";
    ulong amount = 1000;

    string[] args =
        [
            "program-name",
            "sendtx",
            "--ip=localhost",
            "--port=2826",
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
    assert (res == CLIENT_SUCCESS);

    Transaction tx =
    {
        TxType.Payment,
        [Input(Hash.fromString(txhash), index)],
        [Output(Amount(amount), PublicKey.fromString(address))]
    };
    Hash send_txhash = hashFull(tx);
    auto key_pair = KeyPair.fromSeed(Seed.fromString(key));
    tx.inputs[0].signature = key_pair.secret.sign(send_txhash[]);

    foreach (ref line; outputs)
        writeln(line);

    assert(node.hasTransactionHash(send_txhash));
}
