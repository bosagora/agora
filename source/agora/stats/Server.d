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

class StatsServer
{
    private HTTPListener http_listener;

    /***************************************************************************

            Constructs a StatsServer instance

            Params
                port = port on which the server will listen on,
                -1 to disable listening

    ***************************************************************************/

    public this (int port)
    {
        if (port == -1)
            return;

        assert(port > 0 && port < 65536, "port number for stats server has to be between 1 and 65535");

        auto router = new URLRouter;
        router.get("/metrics", &handle_metrics);

        auto settings = new HTTPServerSettings;
        settings.port = cast(ushort) port;
        http_listener = listenHTTP(settings, router);
    }

    ///
    public void shutdown ()
    {
        if (http_listener !is HTTPListener.init)
            http_listener.stopListening();
    }

    ///
    private void handle_metrics (HTTPServerRequest req, HTTPServerResponse res)
    {
        res.writeBody(cast(const(ubyte[])) Utils.getCollectorRegistry().collect(),"text/plain");
    }
}
