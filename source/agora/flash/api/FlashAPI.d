/*******************************************************************************

    Contains the Flash API.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.api.FlashAPI;

import agora.common.Amount;
import agora.common.Types;
import agora.crypto.ECC;
import agora.crypto.Key;
import agora.crypto.Schnorr: Signature;
import agora.flash.Config;
import agora.flash.ErrorCode;
import agora.flash.Invoice;
import agora.flash.OnionPacket;
import agora.flash.Types;
import agora.script.Signature;

import vibe.data.serialization;
import vibe.http.common;
import vibe.web.rest;

/// This is the API that each Flash node must implement.
@path("/")
@serializationPolicy!(Base64ArrayPolicy)
public interface FlashAPI
{
@safe:
    /***************************************************************************

        Requests opening a channel with the provided peer,
        if it's managed by this Flash node.

        Params:
            recv_pk = the receiving public key. If the receiving flash node
                does not manage this key it will return an error.
            chan_conf = contains all the static configuration for this channel.
            peer_nonce = the nonce pair that will be used for signing the
                initial settlement & trigger transactions.

        Returns:
            the nonce pair for the initial settle & trigger transactions,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!PublicNonce openChannel (
        PublicKey recv_pk, /* in */ ChannelConfig chan_conf,
        /* in */ PublicNonce peer_nonce);

    /***************************************************************************

        Requests collaboratively closing an existing channel with this peer.

        If the called node accepts the close request and plans to return the
        signature, it should mark the channel as `PendingClose` and should
        reject all subsequent attempts at updating the channel state.

        If the peer unreasonably rejects or ignores closure requests for up to
        `cooperative_close_timeout` as set up in the config,
        the counter-party might trigger a unilateral close of the channel.

        Note that `cooperative_close_timeout` is not enforceable, it's only
        used as an intended timeout used by both peers. The `settle_time` of
        the settlement branch in the trigger / update transactions is the only
        enforcable parameter by the blockchain, therefore the node should always
        monitor the blockchain for any premature publishing of the trigger
        transaction.

        Params:
            sender_pk = the sender public key as managed by the counter-party.
                (note: will be used for signature authentication later)
            recv_pk = the receiving public key. If the receiving flash node
                does not manage this key it will return an error.
            chan_id = the channel ID to close
            seq_id = the sequence ID
            peer_nonce = the nonce the calling peer will use
            fee = the proposed fee

        Returns:
            the signature for the closing transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Point closeChannel (PublicKey sender_pk, PublicKey recv_pk,
        /* in */ Hash chan_id, /* in */ uint seq_id, /* in */ Point peer_nonce,
        /* in */ Amount fee);

    /***************************************************************************

        Gossips open channels to this node.

        Note that there is no 'gossipChannelsClosed' as the called node can
        derive whether the channel is closed by monitoring when the funding
        transaction has been spent on the blockchain (todo: not yet implemented)

        Params:
            chan_configs = the list of channel configs

    ***************************************************************************/

    public void gossipChannelsOpen (ChannelConfig[] chan_configs);

    /***************************************************************************

        Gossips channels attribute updates to this node.

        Params:
            chan_updates = the list of channel updates

    ***************************************************************************/

    public void gossipChannelUpdates (ChannelUpdate[] chan_updates);

    /***************************************************************************

        Proposes a payment through this channel. This may be a direct payment,
        or an indirect routed payment. Both types of payments use this API.

        Params:
            sender_pk = the sender public key as managed by the counter-party.
                (note: will be used for signature authentication later)
            recv_pk = the receiving public key. If the receiving flash node
                does not manage this key it will return an error.
            chan_id = an existing channel ID previously opened with
                `openChannel()` and agreed to by the counter-party.
            seq_id = the new sequence ID
            payment_hash = the hash of the secret that's included in the
                HTLC. The destination node reveals this value.
            amount = the amount that the sender wants to send to this node
            lock_height = the lock height of the HTLC
            packet = the encrypted packet and any further destinations
            peer_nonce = the nonce the calling peer will use
            height = the block height of the calling node. This is needed
                in order to properly resolve any pending HTLCs in the channel.
                For example, timed-out HTLCs should be replaced with a payout
                back to the funder. If the called node's local block height
                does not match the provided block height, an error will be
                returned.

        Returns:
            the nonce the receiving node will use, or an error code in case the
            HTLC is rejected

    ***************************************************************************/

    public Result!PublicNonce proposePayment (PublicKey sender_pk,
        PublicKey recv_pk, /* in */ Hash chan_id, /* in */ uint seq_id,
        /* in */ Hash payment_hash,
        /* in */ Amount amount, /* in */ Height lock_height,
        /* in */ OnionPacket packet, /* in */ PublicNonce peer_nonce,
        /* in */ Height height);

    /***************************************************************************

        Proposes updating the channel by resolving all pending HTLCs with
        the secrets the counter-party offers.

        When there is a payment route from A => B => C using proposePayment(),
        there will also be an update route from C => B => A using
        proposeUpdate() in order to settle HTLCs.

        Note that this API is fee-less. There is no associated fee involved
        as there are no payments being routed through this call, only the
        HTLCs are consolidated into their respective outputs.

        Params:
            sender_pk = the sender public key as managed by the counter-party.
                (note: will be used for signature authentication later)
            recv_pk = the receiving public key. If the receiving flash node
                does not manage this key it will return an error.
            chan_id = an existing channel ID
            seq_id = the new sequence ID
            secrets = the secrets the proposer wishes to disclose
            rev_htlcs = the htlcs the proposer wishes to drop
            peer_nonce = the nonce the calling peer will use
            height = the block height of the calling node. This is needed
                in order to properly resolve any pending HTLCs in the channel.
                For example, timed-out HTLCs should be replaced with a payout
                back to the funder. If the called node's local block height
                does not match the provided block height, an error will be
                returned.

        Returns:
            the nonce the receiving node will use, or an error code if the
            secrets are unrecognized

    ***************************************************************************/

    public Result!PublicNonce proposeUpdate (PublicKey sender_pk,
        PublicKey recv_pk, /* in */ Hash chan_id, /* in */ uint seq_id,
        /* in */ Hash[] secrets, /* in */ Hash[] rev_htlcs,
        /* in */ PublicNonce peer_nonce,
        /* in */ Height height);

    /***************************************************************************

        Requests a settlement signature for an established channel and a
        previously agreed-upon balance update's sequence ID as set through
        the `proposePayment` / `proposeUpdate` call.

        Params:
            sender_pk = the sender public key as managed by the counter-party.
                (note: will be used for signature authentication later)
            recv_pk = the receiving public key. If the receiving flash node
                does not manage this key it will return an error.
            chan_id = A previously seen pending channel ID provided
                by the funder node through the call to `openChannel()`.
            seq_id = the agreed-upon balance update's sequence ID as
                set in the `proposePayment` / `proposeUpdate` call.

        Returns:
            the signature for the settlement transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Signature requestSettleSig (PublicKey sender_pk,
        PublicKey recv_pk, /* in */ Hash chan_id, /* in */ uint seq_id);

    /***************************************************************************

        Requests an update signature for an established channel and a
        previously agreed-upon balance update's sequence ID as set through
        the `proposePayment` / `proposeUpdate` call.

        The node will reject this call unless it has received a settlement
        signature in the call to `requestSettleSig()`.

        Params:
            sender_pk = the sender public key as managed by the counter-party.
                (note: will be used for signature authentication later)
            recv_pk = the receiving public key. If the receiving flash node
                does not manage this key it will return an error.
            chan_id = A previously seen pending channel ID provided
                by the funder node through the call to `openChannel()`
            seq_id = the agreed-upon balance update's sequence ID as
                set in the `proposePayment` / `proposeUpdate` call, for which a
                settlement signature was received.

        Returns:
            the signature for the update transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!SigPair requestUpdateSig (PublicKey sender_pk,
        PublicKey recv_pk, /* in */ Hash chan_id, /* in */ uint seq_id);

    /***************************************************************************

        Called by the peer when it has finished collecting the
        settlement & update transactions. It signals to the called node
        that the peer is ready for any new payments / updates.

        Params:
            sender_pk = the sender public key as managed by the counter-party.
                (note: will be used for signature authentication later)
            recv_pk = the receiving public key. If the receiving flash node
                does not manage this key it will return an error.
            chan_id = A previously seen pending channel ID provided
                by the funder node through the call to `openChannel()`
            seq_id = the sequence ID just used for signing

        Returns:
            An error if the counter-party cannot accept this confirmation.
            This may happen in case of synchronization issues.

    ***************************************************************************/

    public Result!bool confirmChannelUpdate (PublicKey sender_pk,
        PublicKey recv_pk, /* in */ Hash chan_id, /* in */ uint seq_id);

    /***************************************************************************

        Requests a closing signature for an established channel and a
        previously agreed-upon `closeChannel` request with the given
        sequence ID.

        Params:
            sender_pk = the sender public key as managed by the counter-party.
                (note: will be used for signature authentication later)
            recv_pk = the receiving public key. If the receiving flash node
                does not manage this key it will return an error.
            chan_id = A previously open channel ID
            seq_id = the agreed-upon sequence ID in a previous
                `closeChannel` call

        Returns:
            the signature for the closing transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!SigPair requestCloseSig (PublicKey sender_pk,
        PublicKey recv_pk, /* in */ Hash chan_id, /* in */ uint seq_id);

    /***************************************************************************

        Report a failed payment

        Params:
            recv_pk = the receiving public key. If the receiving flash node
                does not manage this key it will return an error.
            chan_id = ID of the receiver channel
            err = Description of the failure

    ***************************************************************************/

    public void reportPaymentError (PublicKey recv_pk,
        /* in */ Hash chan_id, /* in */ OnionError err);
}
