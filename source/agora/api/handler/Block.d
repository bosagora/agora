/*******************************************************************************

    Definitions of the BlockExternalizedHandler

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.api.handler.Block;

import agora.consensus.data.Block;

import vibe.data.serialization;
import vibe.web.rest;
import vibe.http.common;

@serializationPolicy!(Base64ArrayPolicy)
public interface BlockExternalizedHandler
{
// The REST generator requires @safe methods
@safe:

    /***************************************************************************

        Externalize block data in JSON format with HTTP POST

        API:
            See config.event_handlers.block_externalized_handler_addresses

    ***************************************************************************/

    @path("/")
    public void pushBlock (const Block block);
}
