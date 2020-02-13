/*******************************************************************************

    Contains supporting code for enrollment process.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.PreimageInfo;

import agora.common.Hash;

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
