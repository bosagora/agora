/*******************************************************************************

    Contains the user-facing API used to control the flash node,
    for example creating invoices and paying invoices.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.ControlAPI;

import agora.common.Amount;
import agora.common.Types;
import agora.crypto.ECC;
import agora.flash.API;
import agora.flash.Invoice;
import agora.flash.Route;
import agora.flash.Types;

import core.stdc.time;

/// Ditto
public interface ControlFlashAPI : FlashAPI
{
    /***************************************************************************

        Start the Flash node. This starts timers which monitor the blockchain
        for any setup / trigger / close transactions which will update the
        internal state machine.

    ***************************************************************************/

    public void start();

    /***************************************************************************

        Begin a collaborative closure of a channel with the counter-party
        for the given channel ID.

        Params:
            chan_id = the ID of the channel to close

        Returns:
            true if this channel ID exists and may be closed,
            else an error

    ***************************************************************************/

    public Result!bool beginCollaborativeClose (/* in */ Hash chan_id);

    /***************************************************************************

        If the counter-party rejects a collaborative closure,
        the wallet may initiate a unilateral closure of the channel.

        This will publish the latest update transaction to the blockchain,
        and after the time lock expires the settlement transaction will be
        published too.

        Params:
            chan_id = the ID of the channel to close

        Returns:
            true if this channel ID exists and may be closed,
            else an error

    ***************************************************************************/

    public Result!bool beginUnilateralClose (/* in */ Hash chan_id);

    /***************************************************************************

        Schedule opening a new channel with another flash node.
        If this funding_utxo is already used, an error is returned.
        Otherwise, the Listener will receive a notification through
        the onChannelNotify() API at a later point whenever the channel
        is accepted / rejected by the counter-party.

        Params:
            funding_utxo = the UTXO that will be used to fund the setup tx
            capacity = the amount that will be used to fund the setup tx
            settle_time = closing settle time in number of blocks since last
                setup / update tx was published on the blockchain
            peer_pk = the public key of the counter-party flash node

        Returns:
            The channel ID, or an error if this funding UTXO is
            already used for another pending / open channel.

    ***************************************************************************/

    public Result!Hash openNewChannel (/* in */ Hash funding_utxo,
        /* in */ Amount capacity, /* in */ uint settle_time,
        /* in */ Point peer_pk);

    /***************************************************************************

        Create an invoice that can be paid by another party. A preimage is
        shared through a secure channel to the party which will pay the invoice.
        The hash of the preimage is used in the contract, which is then shared
        across zero or more channel hops. The invoice payer must reveal their
        preimage to prove.

        Params:
            destination = the public key of the destination
            amount = the amount to invoice
            expiry = expiry time of this invoice
            description = optional description

    ***************************************************************************/

    public Invoice createNewInvoice (/* in */ Amount amount,
        /* in */ time_t expiry, /* in */ string description = null);

    /***************************************************************************

        Attempt to find a payment path for the invoice and pay for the
        invoice.

        If a payment path cannot be found, or if the payment fails along
        the payment path then the listener will be notified through the
        `onPaymentFailure` endpoint.

        If the payment succeeds the `onPaymentSuccess` endpoint will be
        called on the listener.

        Params:
            invoice = the invoice to pay

    ***************************************************************************/

    public void payInvoice (/* in */ Invoice invoice);

    /***************************************************************************

        Broadcast a channel update to change the fees

        Params:
            chan_id = channel ID
            fixed_fee = Fixed fee that should paid for each payment
            proportional_fee = Proportional fee that should paid for each BOA

    ***************************************************************************/

    public void changeFees (Hash chan_id, Amount fixed_fee, Amount proportional_fee);
}
