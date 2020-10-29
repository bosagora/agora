/*******************************************************************************

    Starts up a HTTP server and listen to queries from Prometheus

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Server;

import agora.stats.Utils;

import ocean.util.prometheus.collector.CollectorRegistry;
import vibe.http.server;
import vibe.http.router;

public class StatsServer
{
    private HTTPListener http_listener;

    /***************************************************************************

        Constructs a StatsServer instance

        Params:
            port = port on which the server will listen on

    ***************************************************************************/

    public this (ushort port)
    {
        auto router = new URLRouter;
        router.get("/metrics", &handle_metrics);

        auto settings = new HTTPServerSettings;
        settings.port = port;
        this.http_listener = listenHTTP(settings, router);
    }

    ///
    public void shutdown ()
    {
        this.http_listener.stopListening();
    }

    ///
    private void handle_metrics (
        scope HTTPServerRequest req, scope HTTPServerResponse res)
    {
        res.writeBody(cast(const(ubyte[])) Utils.getCollectorRegistry().collect(),
                      "text/plain");
    }
}
