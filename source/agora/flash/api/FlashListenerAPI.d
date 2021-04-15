/*******************************************************************************

    Contains the Flash API.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.api.FlashListenerAPI;

import agora.common.Types;
import agora.flash.ErrorCode;
import agora.flash.Invoice;
import agora.flash.Types;

import vibe.data.serialization;
import vibe.http.common;
import vibe.web.rest;

/// This is the API that each Flash listener must implement, for example wallets
/// or other front-ends to Agora.
@path("/")
@serializationPolicy!(Base64ArrayPolicy)
public interface FlashListenerAPI
{
@safe:
    /***************************************************************************

        Called when the state of a channel changes, for example when the
        channel is accepted / rejected by the counter-party.

        Params:
            chan_id = channel ID
            state = the current state of the channel
            error = if state is rejected, it will contain any error stating the
                reason why a channel was rejected

    ***************************************************************************/

    public void onChannelNotify (Hash chan_id, ChannelState state,
        ErrorCode error);

    /***************************************************************************

        Called when the payment for the given invoice has been successful.

        Params:
            invoice = the invoice that was paid

    ***************************************************************************/

    public void onPaymentSuccess (Invoice invoice);

    /***************************************************************************

        Called when the payment for the given invoice has failed.
        The payment can be retried again with the `payInvoice()` Flash API.

        Params:
            invoice = the invoice that was paid

    ***************************************************************************/

    public void onPaymentFailure (Invoice invoice, ErrorCode error);
}
