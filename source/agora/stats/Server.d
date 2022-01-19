/*******************************************************************************

    Starts up a HTTP server and listen to queries from Prometheus

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Server;

import agora.stats.Utils;

import ocean.util.prometheus.collector.CollectorRegistry;
import vibe.http.server;
import vibe.http.router;

import core.time;

public class StatsServer
{
    private HTTPListener http_listener;

    /***************************************************************************

        Constructs a StatsServer instance

        Params:
            port = port on which the server will listen on

    ***************************************************************************/

    public this (string address, ushort port)
    {
        auto router = new URLRouter;
        router.get("/metrics", &handle_metrics);

        auto settings = new HTTPServerSettings(address);
        settings.port = port;
        // The following correspond to your scraping interval in Prometheus
        // The default value for Prometheus is 1 minute:
        // https://prometheus.io/docs/prometheus/latest/configuration/configuration/
        // We set it to 70 seconds to avoid a bit of jitter.
        // See https://github.com/bosagora/agora/issues/2380 and the linked Vibe.d
        // issue for short-comings of this approach.
        settings.keepAliveTimeout = 70.seconds;
        this.http_listener = listenHTTP(settings, router);
    }

    ///
    public void shutdown () @safe
    {
        this.http_listener.stopListening();
    }

    ///
    private void handle_metrics (
        scope HTTPServerRequest, scope HTTPServerResponse res)
    {
        res.writeBody(cast(const(ubyte[])) Utils.getCollectorRegistry().collect(),
                      "text/plain");
    }
}
