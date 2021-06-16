/*******************************************************************************

    Holds related informations about a validator.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.ValidatorInfo;

import agora.common.Types;
import agora.consensus.data.PreImageInfo;
import agora.crypto.Key;

/// Ditto
public struct ValidatorInfo
{
    /// Height at which the `Enrollment` was accepted
    public Height enrolled;

    /// Convenience alias
    public ref inout(Hash) utxo () inout scope return @safe pure nothrow @nogc
    {
        return this.preimage.utxo;
    }

    /// Public key associated with the UTXO
    public PublicKey address;

    /// The most up-to-date pre-image
    public PreImageInfo preimage;
}
