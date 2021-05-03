/*******************************************************************************

    Provide a web-based setup interface to the node (Talos)

    To ease onboarding, users can setup a node via a web interface.
    This interface is a React app, served by Vibe.d, which can be enabled by
    providing the `--initialize=ADDRESS` CLI argument to Agora.
    `ADDRESS` defines on which port Talos will be served.

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

static import std.file;
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
    and the user can restart Agora through the regular booting process.

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
        // If the user asked for the admin interface, make sure it exists
        // It can be located in a few places (to accomodate for different setups),
        // however if it can't be found in any of them, this will throw.
        string path = this.getStaticFilePath();

        auto settings = new HTTPServerSettings(url.host);
        settings.port = url.port;
        auto router = new URLRouter;

        // Convenience redirect, as users expect that accessing '/' redirect to index.html
        router.match(HTTPMethod.GET, "/", staticRedirect("/index.html", HTTPStatus.movedPermanently));
        // Called when the config file is created
        router.post("/writeConfig", &this.handleConfig);
        // Handle CORS
        router.match(HTTPMethod.OPTIONS, "*", &this.handleAllOptions);
        // By default, match the underlying files
        router.match(HTTPMethod.GET, "*", serveStaticFiles(path));

        this.listener = listenHTTP(settings, router);
    }

    /// Returns: The path at which the Talos files are located
    private string getStaticFilePath () const
    {
        // First check working directory
        if (std.file.exists("talos/index.html"))
            return std.file.getcwd() ~ "/talos/";

        if (std.file.exists("/usr/share/agora/talos/index.html"))
            return "/usr/share/agora/talos/";

        throw new Exception("Talos files not found. " ~
                            "This might mean your node is not installed correctly. " ~
                            "Searched for `index.html` in '" ~ std.file.getcwd() ~
                            "/talos/' and '/usr/share/agora/talos/'.");
    }

    /***************************************************************************

        Validate and write a received config file to disk

        This hook is called as the last step of the setup process,
        and will return a user-friendly error message if any problem happens.

    ***************************************************************************/

    private void handleConfig (scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        string body = req.bodyReader.readAllUTF8();
        // Don't do this by default as it could log the private key to the logs
        version (none)
            log.info("Received configuration from admin interface: {}", body);

        try
        {
            auto config = parseConfigString(body, this.path);
            res.writeJsonBody(Response(true, "Configuration successfully parsed"));
        }
        catch (Exception e)
            res.writeJsonBody(Response(false, e.msg), HTTPStatus.badRequest);

        // Now try to write it and exit
        try
        {
            std.file.write(path, body);
            this.listener.stopListening();
            exitEventLoop();
        }
        catch (Exception e)
            res.writeJsonBody(Response(false, e.msg), HTTPStatus.internalServerError);
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
