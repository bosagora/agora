/*******************************************************************************

    Check that the node does not break in the situation where a nomination
    and regenerating quorums are interleaved, especially when a block is
    externalized from periodic catchup.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.NominatingCatchup;

version (unittest):

import agora.consensus.protocol.Nominator;
import agora.test.Base;

import scpd.types.Stellar_types : NodeID;

import core.thread;

private class CustomNominator : Nominator
{
extern (D):
    /// Ctor
    mixin ForwardCtor!();

    ///
    public override void setQuorumConfig (ref const(NodeID) node_id,
        const(QuorumConfig)[NodeID] quorums) nothrow @safe
    {
        scope(failure) assert (0);
        this.checkNominate();
        super.setQuorumConfig(node_id, quorums);
    }
}

private class CustomValidator : TestValidatorNode
{
    mixin ForwardCtor!();

    ///
    protected override CustomNominator makeNominator (
        Parameters!(TestValidatorNode.makeNominator) args)
    {
        return new CustomNominator(
            this.params, this.config.validator.key_pair, args,
            this.cacheDB, this.config.validator.nomination_interval,
            &this.acceptBlock);
    }
}

private class CustomAPIManager : TestAPIManager
{
    mixin ForwardCtor!();

    ///
    public override void createNewNode (Config conf, string file, int line)
    {
        if (this.nodes.length == 0)
            this.addNewNode!CustomValidator(conf, file, line);
        else
            super.createNewNode(conf, file, line);
    }
}

/// On a block being externalized, the timer for a nomination process
/// stops and the newly constructed quorums is set. But there is a
/// situation where the previously called nomination process is running
/// while setting new quorums, which is a probable situation but we did
/// not account for in our code. Setting new quorums should be completed
/// at the situation without a crach.
unittest
{
    auto network = makeTestNetwork!CustomAPIManager(TestConf.init);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();
    auto nodes = network.clients;
    auto catchup_node = 0;

    network.generateBlocks(Height(GenesisValidatorCycle - 1));
    network.expectHeight(iota(GenesisValidators), Height(GenesisValidatorCycle - 1));

    // restart a node and make the node, which contains a `CustomNominator`,
    // catch up regenerating a quorum set, and set them to SCP while trying
    // to nominate.
    network.restart(nodes[catchup_node]);
    network.expectHeight([catchup_node], Height(GenesisValidatorCycle - 1));
}
