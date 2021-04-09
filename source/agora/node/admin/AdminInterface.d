/*******************************************************************************

    Provide a web-based administrative interface to the node

    To ease administration and configuration, users can interact with the node
    using a web interface. This interface is served by Vibe.d,
    usually on a port adjacent to the node port (2827 by default).

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.admin.AdminInterface;

import agora.common.Config;
import agora.crypto.Key;
import agora.node.admin.QRCodeInterface;
import agora.utils.Log;
import agora.network.Clock;

import vibe.core.core;
import vibe.data.json;
import vibe.http.router;
import vibe.http.server;

import std.format;
import std.meta;
import std.traits;

/*******************************************************************************

    Class for Admin interface

    If admin is enabled this interface listens by AdminConfig's address
    of config
    Contains services that include authentication QR.
    This interface must be in a path accessible only to the owner of the node.

    This will added by node management and monitoring interfaces.

    API:
        GET /loginQR : Respond with QR code containing login information.
        GET /encryptionKeyQR : Respond with QR code containing EncryptionKey.

*******************************************************************************/

public class AdminInterface
{
    /// Logger instance
    protected Logger log;

    /// Config instance
    private const Config config;

    /// The keypair of this node
    private const KeyPair key_pair;

    /// Clock instance
    private Clock clock;

    /***************************************************************************

        Constructor

        Params:
            config = config instance
            key_pair = the keypair of this node
            clock = clock instance

    ***************************************************************************/

    public this (const Config config, const KeyPair key_pair, Clock clock)
    {
        this.log = Logger(__MODULE__);
        this.config = config;
        this.key_pair = key_pair;
        this.clock = clock;
    }

    /***************************************************************************

        Start listening for requests

        Begins asynchronous tasks for admin interface

    ***************************************************************************/

    public HTTPListener start ()
    {
        if (!this.config.admin.enabled)
            assert(0, "Admin interface is not enabled in config settings.");

        auto settings = new HTTPServerSettings(this.config.admin.address);
        settings.port = this.config.admin.port;

        auto router = new URLRouter();

        // API endpoints for this validator
        if (this.config.validator.enabled)
        {
            auto qrCode = new QRCodeInterface(this.key_pair, this.clock);

            router.get("/loginQR", &qrCode.loginQRCreate);
            router.get("/encryptionKeyQR", &qrCode.keyQRCreate);
        }

        return listenHTTP(settings, router);
    }
}
