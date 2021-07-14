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
import vibe.http.common;
import vibe.web.rest;

import ocean.util.log.ILogger;

import std.typecons;


@path("/admin/")
@serializationPolicy!(Base64ArrayPolicy)
public interface NodeControlAPI
{
    @safe:

    /***************************************************************************

        Set the configuration of a Logger

    ***************************************************************************/

    public void postLogger (
        @viaQuery("name") string name,
        @viaQuery("propagate") bool propagate = true,
        @viaQuery("level") Nullable!(ILogger.Level) level = Nullable!(ILogger.Level).init,
        @viaQuery("additive") Nullable!bool additive = Nullable!(bool).init,
        @viaQuery("console") Nullable!bool console = Nullable!(bool).init,
        @viaQuery("file") Nullable!string file = Nullable!(string).init);

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

    @method(HTTPMethod.GET)
    public string loginQR (@viaHeader("Content-Type") out string contentType,
                           @viaHeader("Vary") out string vary);

    /***************************************************************************

        Respond with QR code containing EncryptionKey.

        Enter the name of the APP & height where the encryptionKey will be used
        as the get query.

    ***************************************************************************/

    @method(HTTPMethod.GET)
    public string encryptionKeyQR (string app, ulong height,
                                   @viaHeader("Content-Type") out string contentType,
                                   @viaHeader("Vary") out string vary);
}
