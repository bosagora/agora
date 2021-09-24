/*******************************************************************************

    Encapsulate utilities related to Quorum configuration

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.protocol.Config;

import agora.common.Types;

import scpd.types.Stellar_SCP;
import scpd.types.Stellar_types : NodeID;
import scpd.types.Utils;

import std.conv;

/*******************************************************************************

    Convert a `QuorumConfig` to an `SCPQuorum` struct, used by the SCP code.

    Params:
        quorum_conf = the quorum config

    Returns:
        An `SCPQuorumSet` instance derived from `quorum_conf`

*******************************************************************************/

public SCPQuorumSet toSCPQuorumSet (in QuorumConfig quorum_conf) @safe nothrow
{
    SCPQuorumSet quorum;
    quorum.threshold = quorum_conf.threshold;

    foreach (ref const node; quorum_conf.nodes)
    {
        quorum.validators.push_back(node);
    }

    foreach (ref const sub_quorum; quorum_conf.quorums)
    {
        auto scp_quorum = toSCPQuorumSet(sub_quorum);
        quorum.innerSets.push_back(scp_quorum);
    }

    return quorum;
}

/*******************************************************************************

    Convert an `SCPQuorum` to a `QuorumConfig`

    Params:
        scp_quorum = the quorum set to convert

    Returns:
        An `QuorumConfig` instance derived from `scp_quorum`

*******************************************************************************/

public QuorumConfig toQuorumConfig (const ref SCPQuorumSet scp_quorum)
    @safe nothrow
{
    ulong[] nodes;

    foreach (node; scp_quorum.validators.constIterator)
        nodes ~= node;

    QuorumConfig[] quorums;
    foreach (ref sub_quorum; scp_quorum.innerSets.constIterator)
        quorums ~= toQuorumConfig(sub_quorum);

    QuorumConfig quorum =
    {
        threshold : scp_quorum.threshold,
        nodes : nodes,
        quorums : quorums,
    };

    return quorum;
}

///
unittest
{
    import agora.crypto.Hash;

    auto quorum = QuorumConfig(2, [0, 1, 2],
        [QuorumConfig(2, [0, 2],
            [QuorumConfig(2, [0, 1, 1])])]);

    auto scp_quorum = toSCPQuorumSet(quorum);
    assert(scp_quorum.toQuorumConfig() == quorum);
}
