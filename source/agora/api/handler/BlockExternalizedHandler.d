/*******************************************************************************

    Definitions of the BlockExternalizedHandler

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.api.handler.BlockExternalizedHandler;

import agora.consensus.data.Block;

import vibe.web.rest;
import vibe.http.common;

public interface BlockExternalizedHandler
{
// The REST generator requires @safe methods
@safe:

    /***************************************************************************

        Externalize block data in JSON format with HTTP POST

        API:
            See config.event_handlers.block_externalized_handler_addresses

    ***************************************************************************/

    @method(HTTPMethod.POST)
    @path("/")
    public void pushBlock (const Block block);
}
