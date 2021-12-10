/*******************************************************************************

    The creation of a block must stop immediately just before all the
    active validators is expired.
    This is to allow additional enrollment of validators.
    Enrollment's cycle is `ConsensusParams.validator_cycle`,
    If none of the active validators exist at height `validator_cycle`,
    block generation must stop at height `validator_cycle`-1.

    This code tests these.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.ValidatorCount;

version (unittest):

import agora.consensus.data.Params;
import agora.test.Base;

import core.thread;
import core.exception : AssertError;
import std.exception : assertThrown;

/// ditto
unittest
{
    const TestConf conf = { recurring_enrollment : false };
    auto network = makeTestNetwork!TestAPIManager(conf);
    network.start();
    scope(exit) network.shutdown();
    scope(failure) network.printLogs();
    network.waitForDiscovery();

    // create GenesisValidatorCycle - 1 blocks
    network.generateBlocks(Height(GenesisValidatorCycle - 1));

    // New block was not created because all validators would expire
    assertThrown!AssertError(network.generateBlocks(Height(GenesisValidatorCycle)),
        "Block should not have been externalized as there will be no active validators for next block");

}
