/*******************************************************************************

    Definitions of the PreImageReceivedHandler

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.api.handler.PreImage;

import agora.consensus.data.PreImageInfo;

import vibe.data.serialization;
import vibe.web.rest;
import vibe.http.common;

@serializationPolicy!(Base64ArrayPolicy)
public interface PreImageReceivedHandler
{
// The REST generator requires @safe methods
@safe:

    /***************************************************************************

        Push a preImage in JSON format with HTTP POST

        API:
            See config.event_handlers.preimage_updated_handler_addresses

    ***************************************************************************/

    @path("/")
    public void pushPreImage (const PreImageInfo preimage);
}
