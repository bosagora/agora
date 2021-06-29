/*******************************************************************************

    Definitions of the Handlers for pushing to Stoa

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.api.Handlers;

import agora.consensus.data.Block;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;

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

@serializationPolicy!(Base64ArrayPolicy)
public interface TransactionReceivedHandler
{
// The REST generator requires @safe methods
@safe:

    /***************************************************************************

        Push a transaction in JSON format with HTTP POST

        API:
            See config.event_handlers.transaction_received_handler_addresses

    ***************************************************************************/

    @path("/")
    public void pushTransaction (const Transaction tx);
}
