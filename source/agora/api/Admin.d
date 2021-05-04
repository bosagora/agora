/*******************************************************************************

    An API to control a node's behavior and perform useful administrative tasks

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.api.Admin;

import vibe.data.serialization;
import vibe.web.rest;

import std.typecons;


@path("/admin/")
@serializationPolicy!(Base64ArrayPolicy)
public interface NodeControlAPI
{
    @safe:

    /***************************************************************************

        Respond with QR code containing login information.

        Enter the name of the APP where the login information will be
        used as the get query.

        Convert LoginInfo to JSON format and respond with the QR code
        of SVG format.
        All public key cryptography is done on Curve25519.
        The signature of the vectorCard provides verification function in the SDK.
        This LoginInfo has an expiration time.
        It provide a randomly generated temporary private key encoded
        in strings on demand.
        In the future, there is a need to enter a temporary key.

    ***************************************************************************/

    public string loginQR (@viaHeader("Content-Type") out string contentType,
                           @viaHeader("Vary") out string vary);

    /***************************************************************************

        Respond with QR code containing EncryptionKey.

        Enter the name of the APP & height where the encryptionKey will be used
        as the get query.

    ***************************************************************************/

    public string encryptionKeyQR (string app, ulong height,
                                   @viaHeader("Content-Type") out string contentType,
                                   @viaHeader("Vary") out string vary);
}
