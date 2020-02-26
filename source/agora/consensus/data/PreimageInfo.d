/*******************************************************************************

    Contains supporting code for enrollment process.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.PreimageInfo;

import agora.common.Types;

/*******************************************************************************

    Define pre-image information

*******************************************************************************/

public struct PreimageInfo
{
    /// The key for the enrollment
    public Hash enroll_key;

    /// A pre-image at a certain height
    public Hash hash;

    /// The height number
    public ulong height;
}

unittest
{
    testSymmetry!PreimageInfo();

    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash hash = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    PreimageInfo img = {
        enroll_key: key,
        hash: hash,
        height: 42,
    };
    testSymmetry(img);
}
