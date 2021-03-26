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

module agora.node.admin.Setup;

import agora.common.Config;
import agora.crypto.Key;
import agora.node.FullNode;
import agora.node.Runner;
import agora.utils.Log;

import vibe.core.core;
import vibe.data.json;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;
import vibe.inet.url;
import vibe.stream.operations;

import std.format;
import std.meta;
import std.traits;

/*******************************************************************************

    Class dedicated to the setup part of the administrative interface

    When a user starts the node with the `--initialize` argument,
    the node enters the 'setup' phase: instead of normally starting,
    this interface listens on 127.0.0.1:2827 for connection,
    and guide the user through a setup process.

    Once the setup process is complete, the config file is written to disk,
    and the node starts a normal booting process, where the file is read,
    and the network interface is initialized along with the 'real'
    administrative / monitoring interface (if enabled).

*******************************************************************************/

public class SetupInterface
{
    /// Logger instance
    protected Logger log;
    /// Path at with to write the config file
    private string path;
    /// HTTP listener, to stop listening once we wrote the config file
    private HTTPListener listener;

    ///
    public this (string config_path)
    in
    {
        assert(config_path.length);
    }
    do
    {
        this.path = config_path;
        this.log = Logger(__MODULE__);
    }

    /// Start listening for requests
    public void start (URL url)
    {
        auto settings = new HTTPServerSettings(url.host);
        settings.port = url.port;
        auto router = new URLRouter;
        router.post("/check", &this.handleCheck);
        router.match(HTTPMethod.OPTIONS, "*", &this.handleAllOptions);
        this.listener = listenHTTP(settings, router);
    }

    /***************************************************************************

        Validate a received config file

        This can be used by client code to check whether a configuration
        is valid, and get a user-friendly error message if not.

    ***************************************************************************/

    private void handleCheck (scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        string body = req.bodyReader.readAllUTF8();
        log.error("Received configuration from admin interface: {}", body);
        try
        {
            auto config = parseConfigString(body, this.path);
            res.writeJsonBody(Response(true, "Configuration successfully parsed"));
        }
        catch (Exception e)
            res.writeJsonBody(Response(false, e.msg), HTTPStatus.badRequest);
    }

    private void handleAllOptions (scope HTTPServerRequest req, scope HTTPServerResponse res)
	{
        res.headers["Allow"] = "OPTIONS, POST";

        res.headers["Access-Control-Allow-Origin"] = "*";
        res.headers["Access-Control-Allow-Methods"] = "OPTIONS, POST";
        // Just allow whatever the client requested
        if (auto headers = "Access-Control-Request-Headers" in req.headers)
            res.headers["Access-Control-Allow-Headers"] = *headers;
        res.headers["Access-Control-Max-Age"] = "1728000";
        res.writeVoidBody();
    }
}

/// The response that will be JSON serialized then sent to the client
private struct Response
{
    /// Whether the config file parsed successfully
    public bool success;
    /// If `success == false`, the error message to show the user
    public string status;
}
