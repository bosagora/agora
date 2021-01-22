/*******************************************************************************

    Definitions of the TransactionReceivedHandler

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.api.handler.TransactionReceivedHandler;

import agora.consensus.data.Transaction;

import vibe.data.serialization;
import vibe.web.rest;
import vibe.http.common;

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
