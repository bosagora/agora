/*******************************************************************************

    Contains tests which should shut down the node due to misconfiguration.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Failures;

version (unittest):

import agora.api.Validator;
import agora.consensus.data.Transaction;
import agora.consensus.Genesis;
import agora.test.Base;
import agora.utils.Log;

///
unittest
{
    import std.algorithm;
    import std.range;
    import core.thread;

    TestConf conf = { threshold : 100, timeout : 1_000 };
    auto network = makeTestNetwork(conf);

    try
    {
        network.start();
        assert(0);
    }
    catch (Exception ex)
    {
        // misconfiguration made the node throw in call to start()

        // note: cannot check logs because they can only be accessed through
        // TestAPI.printLog(), but RemoteAPI has already shut down when
        // the node threw an exception in its constructor
    }
}
