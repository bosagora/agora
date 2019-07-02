/*******************************************************************************

    Defines common data types used by the node

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Data;

import geod24.bitblob;


/// An array of const characters
public alias cstring = const(char)[];

/// 256 bits hash type, binary compatible with Stellar's definition
public alias Hash = BitBlob!256;

/// A network address
public alias Address = string;

/// The type of a signature
public alias Signature = BitBlob!256;
