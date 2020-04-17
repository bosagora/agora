/*******************************************************************************

    Contains definition for the `PreImageInfo` struct,
    which is used to communicate new pre-image informations between nodes.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.PreImageInfo;

import agora.common.Types;

/*******************************************************************************

    Define pre-image information

*******************************************************************************/

public struct PreImageInfo
{
    /// The key for the enrollment, used to look the commitment up
    public Hash enroll_key;

    /// The value of the pre-image at the distance from the commitment
    public Hash hash;

    /// The distance between this pre-image and the initial commitment
    public ulong distance;
}

unittest
{
    import agora.common.Serializer;

    testSymmetry!PreImageInfo();

    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash hash = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    PreImageInfo img = {
        enroll_key: key,
        hash: hash,
        distance: 42,
    };
    testSymmetry(img);
}
