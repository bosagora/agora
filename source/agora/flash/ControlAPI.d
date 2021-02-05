/*******************************************************************************

    Contains the user-facing API used to control the flash node,
    for example creating invoices and paying invoices.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
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

    ***************************************************************************/

    public void beginCollaborativeClose (in Hash chan_id);

    /***************************************************************************

        Open a new channel with another flash node.

        Params:
            funding_utxo = the UTXO that will be used to fund the setup tx
            capacity = the amount that will be used to fund the setup tx
            settle_time = closing settle time in number of blocks since last
                setup / update tx was published on the blockchain
            peer_pk = the public key of the counter-party flash node

    ***************************************************************************/

    public Hash openNewChannel (in Hash funding_utxo, in Amount capacity,
        in uint settle_time, in Point peer_pk);

    /***************************************************************************

        Block the calling fiber until the channel with the given ID becomes
        open. If the channel is already open then it returns immediately.
        The channel is considered open once the setup tx has been
        externalized in the blockchain.

        TODO: does not handle

        Params:
            chan_id = the ID of the channel to wait until it's open

    ***************************************************************************/

    public void waitChannelOpen (in Hash chan_id);

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

    public Invoice createNewInvoice (in Amount amount,
        in time_t expiry, in string description = null);

    /***************************************************************************

        Attempt to pay an invoice for the target peer's wallet key and the
        given invoice, using the given (indirect) channel.

        Params:
            invoice = the invoice to pay
            peer_pk =

    ***************************************************************************/

    public void payInvoice (in Invoice invoice);
}
