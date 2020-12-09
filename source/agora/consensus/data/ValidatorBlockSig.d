/*******************************************************************************

    Contains definition for the `ValidatorBlockSig` struct,
    which is used to communicate block signatures between nodes.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.ValidatorBlockSig;

import agora.common.Types;
import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;

/*******************************************************************************

    Define Validator Block Signature information

*******************************************************************************/

public struct ValidatorBlockSig
{
    /// The block height of this signature
    public Height height;

    /// The public key of the validator
    public PublicKey public_key;

    /// The block signature for the validator
    public Signature signature;

}

unittest
{
    import agora.common.Serializer;

    testSymmetry!ValidatorBlockSig();

    Height height = Height(100);
    PublicKey public_key = PublicKey.fromString(`GDD5RFGBIUAFCOXQA246BOUPHCK7ZL2NSHDU7DVAPNPTJJKVPJMNLQFW`);
    Signature signature = Signature("0x0e00a8df701806cb4deac9bb09cc85b097ee713e055b9d2bf1daf668b3f637780e00a8df701806cb4deac9bb09cc85b097ee713e055b9d2bf1daf668b3f63778");
    ValidatorBlockSig sig = {
        height: height,
        public_key: public_key,
        signature: signature,
    };
    testSymmetry(sig);
}
