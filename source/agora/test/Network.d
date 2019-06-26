/*******************************************************************************

    Contains tests for the node network (P2P) behavior

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.test.Network;

version (unittest):

import agora.test.Base;

///
unittest
{
    auto network = makeTestNetwork!TestNetwork(NetworkTopology.Simple, 4);
    network.start();
    network.waitUntilConnected();
}
