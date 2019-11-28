/*******************************************************************************

    Provide a web-based administrative interface to the node

    To ease administration and configuration, users can interact with the node
    using a web interface. This interface is served by Vibe.d,
    usually on a port adjacent to the node port (2827 by default).

    Currently, only the initial setup phase is implemented.
    The plan is to extend the capabilities to include administration
    and monitoring.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.AdminInterface;

import agora.common.Config;
import agora.common.crypto.Key;
import agora.node.Node;
import agora.utils.Log;

import vibe.core.core;
import vibe.data.json;
import vibe.http.fileserver;
import vibe.http.router;
import vibe.http.server;
import vibe.stream.operations;

import std.meta;
import std.traits;

mixin AddLogger!();

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
    /// Path at with to write the config file
    private string path;
    /// HTTP listener, to stop listening once we wrote the config file
    private HTTPListener listener;
    /// Callback to run after we're done with the initial setup
    private RunFn run;
    /// Ditto
    private alias RunFn = Node function(Config);
    /// The variable in which to store the results of `run`
    private Node* runResult;

    ///
    public this (string config_path, RunFn runNode, Node* result)
    in
    {
        assert(config_path.length);
        assert(runNode !is null);
        assert(result !is null);
    }
    do
    {
        this.path = config_path;
        this.run = runNode;
        this.runResult = result;
    }

    /// Start listening for requests
    public void start ()
    {
        auto settings = new HTTPServerSettings("127.0.0.1");
        settings.port = 2827;
        auto router = new URLRouter;
        router.get("*", serveStaticFiles("public/"));
        router.get("/", (req, res) => res.redirect("/welcome"));
        router.get("/welcome", staticTemplate!("setup/welcome.dt"));
        router.get("/setup", staticTemplate!("setup/setup.dt"));
        router.post("/create", &this.handleCreate);
        this.listener = listenHTTP(settings, router);
    }

    /***************************************************************************

        Receive a config, validate it, and write it to disk

        This is called by the Javascript of the setup part of the
        admin interface once the process has been finalized.
        This function handles JSON deserialization manually, partly for better
        error handling, but mostly because Vibe.d does not handle structs with
        const or immutable members and errors out in a ugly way:
        https://github.com/vibe-d/vibe.d/issues/1536#issuecomment-571076219

    ***************************************************************************/

    private void handleCreate (scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        static import std.file;
        try
        {
            string body = req.bodyReader.readAllUTF8();
            auto config = parseConfigString(body, this.path);
            std.file.write(this.path, body);
            scope (failure) std.file.remove(this.path);
            res.writeVoidBody();
            this.listener.stopListening();
            log.info("Config written to {}, starting node", this.path);
            runTask(() => *this.runResult = this.run(config));
        }
        catch (Exception e)
        {
            log.info("Wrong configuration provided by initialization: {}", e);
            res.writeBody(cast(string)e.message(), HTTPStatus.badRequest);
        }
    }
}
