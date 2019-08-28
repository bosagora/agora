/*******************************************************************************

    Contains a URL router which can filter incoming requests.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.FilteredURLRouter;

import agora.common.BanManager;

import vibe.http.router;
import vibe.http.server;


/*******************************************************************************

    URL router which implements filtering of incoming requests if the
    address of the connecting client is considered banned by the
    ban manager of the node.

*******************************************************************************/

class FilteredURLRouter : URLRouter
{
    /// BanManager instance
    private BanManager banman;


    /***************************************************************************

        Constructor

        Params:
            banman = the ban manager

    ***************************************************************************/

    public this (BanManager banman)
    {
        this.banman = banman;
    }


    /***************************************************************************

        Handle a request. If the IP of the client is considered banned by
        the ban manager, ignore the request. Otherwise, forward the request
        to URLRouter's default implementation of handleRequest().

        Params:
            req = the HTTP request
            res = the response

    ***************************************************************************/

    public override void handleRequest (scope HTTPServerRequest req,
        scope HTTPServerResponse res) @safe
    {
        //static int count;
        //import std.stdio;

        //static char[] ip_buffer;  // ip without the port
        //ip_buffer.length = 0;
        //ip_buffer.assumeSafeAppend();
        //req.clientAddress.toAddressString(str => ip_buffer ~= str);

        //// todo: should we respond with a 403? might not be important once
        //// we move away from using HTTP
        //if (this.banman.isBanned(ip_buffer))
        //    return;

        super.handleRequest(req, res);
    }
}

