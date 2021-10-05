/*******************************************************************************

    Contains definition for the `ValidatorBlockSig` struct,
    which is used to communicate block signatures between nodes.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.ValidatorBlockSig;

import agora.common.Types;
import agora.crypto.ECC;

/*******************************************************************************

    Define Validator Block Signature information

*******************************************************************************/

public struct ValidatorBlockSig
{
    /// The block height of this signature
    public Height height;

    /// The stake of the validator
    public Hash utxo;

    /// The block signature as `R` of Signature (R, s) for the validator
    public Point signature;
}

unittest
{
    import agora.serialization.Serializer;
    testSymmetry!ValidatorBlockSig();
}
