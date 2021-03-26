/*******************************************************************************

    Contains primitives related to the genesis block

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.genesis;

import agora.common.Amount;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.validation.Block;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr: Signature;

/*******************************************************************************

    Build a Genesis block from the provided data

    This function is intended to be used when the hard-coded genesis block
    needs to be replaced, e.g. when the parameters are changed or a new network
    is created. It shouldn't be used in non-test code.

*******************************************************************************/

public immutable(Block) makeGenesis (
    Transaction[] txs, Enrollment[] enrolls, Signature delegate(Hash) sigcb)
{
    Block genesis;
    // Add provided txs and generate Merkle tree
    genesis.txs ~= txs;
    genesis.header.merkle_root = genesis.buildMerkleTree();

    // Add all enrollments and their signatures
    genesis.header.enrollments ~= enrolls;
    genesis.header.validators = typeof(BlockHeader.validators)(enrolls.length);
    foreach (cnt; 0 .. enrolls.length)
        genesis.header.validators[cnt] = true;
    genesis.header.signature = sigcb(genesis.header.hashFull());

    if (const reason = genesis.isGenesisBlockInvalidReason())
        assert(0, reason);

    return cast(immutable)(genesis);
}

/// Check the Coinnet Genesis Block enrollments (prints replacement enrollments if needed for agora.consensus.data.genesis.Coinnet.d)
/// This will not be used for the final Coinnet GenesisBlock which will use unknown key secrets. But can be useful for now.
unittest
{
    import agora.consensus.data.genesis.Test;

    checkGenesisEnrollments(GenesisBlock, genesis_validator_keys, 20);
}

/// Check the Test Genesis Block enrollments (prints replacement enrollments if needed for agora.consensus.data.genesis.Test.d)
unittest
{
    import agora.consensus.data.genesis.Coinnet;

    checkGenesisEnrollments(GenesisBlock, genesis_validator_keys, 1008);
}

/// Assert the enrollments of a GenesisBlock match expected values and are sorted by utxo (print the potential replacement set when not matching)
version (unittest) public void checkGenesisEnrollments (
    in Block genesisBlock, in KeyPair[] keys, uint cycle_length)
{
    import agora.consensus.data.Enrollment;
    import agora.consensus.data.Transaction : Transaction, TxType;
    import agora.consensus.data.UTXO;
    import agora.consensus.EnrollmentManager;
    import std.format;
    import std.range;
    import std.conv;
    import std.algorithm;

    static struct NodeEnrollment
    {
        Enrollment enrol;
        PublicKey key;
    }
    Hash txhash = hashFull(genesisBlock.txs.filter!(tx => tx.type == TxType.Freeze).front);
    Hash[] utxos = iota(6).map!(i => UTXO.getHash(txhash, i)).array;
    auto enrollments = utxos.enumerate.map!(en =>
        NodeEnrollment(EnrollmentManager.makeEnrollment(en.value, keys[en.index], cycle_length, 0),
            keys[en.index].address)).array;
    auto sorted_enrollments = enrollments.sort!((a,b) => a.enrol.utxo_key < b.enrol.utxo_key).array;
    assert(genesisBlock.header.enrollments == sorted_enrollments.map!(e => e.enrol).array,
        format!"%s\n    ],\n"(
            sorted_enrollments
                .fold!((s, e) =>
                    format!"%s\n%s"
                    (s, format!"    // %s\n    Enrollment(\n        Hash(`%s`),\n        Hash(`%s`),\n        %s,\n        Signature.fromString(`%s`)),"
                        (e.key, e.enrol.utxo_key, e.enrol.random_seed, e.enrol.cycle_length, e.enrol.enroll_sig.toString())))
                    ("\n    enrollments: [")));
}

/// Can be used to update the config.yaml (e.g. tests/system/node/2/config.yaml)
/// files used for system integration tests
version (none) unittest
{
    import std.algorithm;
    import std.stdio;

    genesis_validator_keys.each!( k =>
        writefln("  # Public address:  %s\n  seed: %s\n",
            k.address, k.secret.toString(PrintMode.Clear) ));
}
