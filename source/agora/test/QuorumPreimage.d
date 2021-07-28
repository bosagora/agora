/*******************************************************************************

    Tests preimage quorum generation behavior.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.QuorumPreimage;

version (unittest):

import agora.api.Validator;
import agora.common.Amount;
import agora.common.Config;
import agora.consensus.data.Params;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;
import agora.consensus.data.genesis.Test;
import agora.crypto.Key;
import agora.node.FullNode;
import agora.test.Base;
import agora.utils.Log;
import agora.utils.PrettyPrinter;

import std.algorithm;
import std.format;
import std.range;

import core.thread;
import core.time;

immutable A = Hash("0x210f6551d648a4da654da116b100e941e434e4f232b8579439c2ef64b04819bd2782eb3524c7a29c38c347cdf26006bccac54a58a58f103ae7eb5b252eb53b64");
immutable B = Hash("0x3b44d65edb3361dd91441ab4f449eeda55644026624c4b8ae12ecf0264fa8a228dbf672ef97e2c4f87fb98ad7099e17b7f9ba7dbe8479672066912b1ea24ba77");
immutable C = Hash("0x7bacc99e9bf827f0fa6dc6a77303d2e6ba6f1591277b896a9305a9e200853986fe9527fd551077a4ac2b511633ada4190a7b82cddaf606171336e1efba87ea8f");
immutable D = Hash("0x9b2726e79f05abc107b6531486a46c977414e13ed9f3ee994ec14504964f86fcf9464055b891b9c34020feb72535c300ff19e8b5167eb9d202db1a053d746b2c");
immutable E = Hash("0xab19131ad8974a20881e2cd0798684a06ca0054160735cdf67fe8ee5a0eb4e28e9bf3f4c735f9ed3da958778978c86b409b8d133f30992141f0ac7e01e7f1255");
immutable F = Hash("0xdb7664caba94c8d4602c10992c13176307e1e05361c150217166ee77fc4af9bf176f31dc61aba61e634dfc0b4c5f729d59e604607f61c9f66b10c6841f972a0a");
immutable G = Hash("0xd6cf49fa79e58f9cb18976516b420111b016c3f945e46337c63a4ee75321a4ce2bfc26e764eb663147184ee4464cb0bb982efd3c7b24f40ba39d0adb6fd718e3");
immutable H = Hash("0xe8d8512b25f8f9d454e5241853c7b107a3b0c8f4860662261a197e592b6e5b6994bf965a5f87671c07b8b2eca6f0e123c7aee0dd653f58544f8dd629a271b821");

/// test preimage changing quorum configs
unittest
{
    import agora.common.Types;
    TestConf conf = {
        recurring_enrollment : false,
        outsider_validators : 2,
    };
    conf.node.max_listeners = 7;
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    auto nodes = network.clients;

    auto validators = GenesisValidators + conf.outsider_validators;

    // generate 18 blocks, 2 short of the enrollments expiring.
    network.generateBlocks(Height(GenesisValidatorCycle - 2));

    void printQuorums (uint line = __LINE__)
    {
        foreach (idx, node; nodes.enumerate)
        {
            import std.string;
            const quorum = node.getQuorumConfig();
            writefln("L%s: Node %s: \n%s", line, idx, quorum.prettify);
        }
    }

    string[Hash] node_to_name = [
        A : "A", B : "B", C : "C", D : "D", E : "E", F : "F", G : "G", H : "H"];

    string printConvQuorum(in QuorumConfig qc)
    {
        return format("%-(%s, %)", qc.nodes.map!(n =>
            (n in node_to_name) ? node_to_name[n]
                : format!"Hash not found in node_to_name: %s"(n)));
    }

    enum quorums_1 = [
        // 0
        QuorumConfig(5, [A, B, C, D, E, F]),

        // 1
        QuorumConfig(5, [A, B, C, D, E, F]),

        // 2
        QuorumConfig(5, [A, B, C, D, E, F]),

        // 3
        QuorumConfig(5, [A, B, C, D, E, F]),

        // 4
        QuorumConfig(5, [A, B, C, D, E, F]),

        // 5
        QuorumConfig(5, [A, B, C, D, E, F]),

        QuorumConfig.init,
        QuorumConfig.init,
    ];

    {
        scope (failure) printQuorums();
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_1[idx], 5.seconds,
                format("Node %s has quorum config [%s]. Expected quorums_1: [%s]",
                    idx, printConvQuorum(node.getQuorumConfig()),
                    printConvQuorum(quorums_1[idx]))));
    }

    const keys = network.nodes.map!(node => node.getPublicKey().key)
        .dropExactly(GenesisValidators).takeExactly(conf.outsider_validators)
        .array;

    // prepare frozen outputs for outsider validators to enroll
    genesisSpendable().dropExactly(1).takeExactly(1)
        .map!(txb => txb.split(keys).sign(OutputType.Freeze))
        .each!(tx => network.clients[0].putTransaction(tx));

    // block 19
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle - 1));

    // Now we enroll new validators and re-enroll the original validators
    iota(validators).each!(idx => network.enroll(idx));

     // Generate the last block of cycle with Genesis validators
    network.generateBlocks(iota(GenesisValidators),
        Height(GenesisValidatorCycle));

    // make sure outsiders are up to date
    network.expectHeight(iota(GenesisValidators, validators),
        Height(GenesisValidatorCycle));

    enum quorums_2 = [
        // 0
        QuorumConfig(6, [A, B, C, D, G, F, H]),

        // 1
        QuorumConfig(6, [A, B, C, D, E, G, H]),

        // 2
        QuorumConfig(6, [A, C, D, E, G, F, H]),

        // 3
        QuorumConfig(6, [A, C, D, E, G, F, H]),

        // 4
        QuorumConfig(6, [B, C, D, E, G, F, H]),

        // 5
        QuorumConfig(6, [A, B, C, E, G, F, H]),

        // 6
        QuorumConfig(6, [A, B, C, D, E, G, H]),

        // 7
        QuorumConfig(6, [A, B, C, D, G, F, H]),
    ];

    static assert(quorums_1 != quorums_2);

    {
        scope (failure) printQuorums();
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_2[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_2: %s",
                    idx, printConvQuorum(node.getQuorumConfig()),
                    printConvQuorum(quorums_2[idx]))));
    }

    // create 19 more blocks with all validators (1 short of end of 2nd cycle)
    network.generateBlocks(iota(validators),
        Height((2 * GenesisValidatorCycle) - 1));

    // Re-enroll
    iota(validators).each!(idx => network.enroll(iota(validators), idx));

    // Generate the last block of cycle with Genesis validators
    network.generateBlocks(iota(validators),
        Height(2 * GenesisValidatorCycle));

    // these changed compared to quorums_2 due to the new enrollments
    // which use a different preimage
    enum quorums_3 = [
        // 0
        QuorumConfig(6, [A, C, D, E, G, F, H]),

        // 1
        QuorumConfig(6, [A, B, C, D, G, F, H]),

        // 2
        QuorumConfig(6, [A, C, D, E, G, F, H]),

        // 3
        QuorumConfig(6, [B, C, D, E, G, F, H]),

        // 4
        QuorumConfig(6, [A, B, C, E, G, F, H]),

        // 5
        QuorumConfig(6, [B, C, D, E, G, F, H]),

        // 6
        QuorumConfig(6, [A, B, D, E, G, F, H]),

        // 7
        QuorumConfig(6, [B, C, D, E, G, F, H]),
    ];

    static assert(quorums_2 != quorums_3);

    {
        scope (failure) printQuorums();
        nodes.enumerate.each!((idx, node) =>
            retryFor(node.getQuorumConfig() == quorums_3[idx], 5.seconds,
                format("Node %s has quorum config %s. Expected quorums_3: %s",
                    idx, printConvQuorum(node.getQuorumConfig()),
                    printConvQuorum(quorums_3[idx]))));
    }
}
