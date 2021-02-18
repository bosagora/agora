/*******************************************************************************

    Contains the Flash API.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.API;

import agora.common.Amount;
import agora.common.Types;
import agora.crypto.ECC;
import agora.flash.Config;
import agora.flash.OnionPacket;
import agora.flash.Types;

/// This is the API that each Flash node must implement.
public interface FlashAPI
{
    /***************************************************************************

        Requests opening a channel with this Flash node.

        Params:
            chan_conf = contains all the static configuration for this channel.
            peer_nonce = the nonce pair that will be used for signing the
                initial settlement & trigger transactions.

        Returns:
            the nonce pair for the initial settle & trigger transactions,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!PublicNonce openChannel (in ChannelConfig chan_conf,
        in PublicNonce peer_nonce);

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
            chan_id = the channel ID to close
            seq_id = the sequence ID
            peer_nonce = the nonce the calling peer will use
            fee = the proposed fee

        Returns:
            the signature for the closing transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Point closeChannel (in Hash chan_id, in uint seq_id,
        in Point peer_nonce, in Amount fee);

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

        Get the state of a channel with the given channel ID.

        Note that the node reports its own view of this channel.

        For example, when waiting for a funding transaction to be externalized
        one peer may detect the externalization event sooner than the
        counter-party. In this case one peer will report the channel as being
        open, while the counter-party might report the channel's state
        as `State.WaitingForFunding`.

        Params:
            chan_id = the channel ID to look up.

        Returns:
            the channel state for this channel ID,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!ChannelState getChannelState (in Hash chan_id);

    /***************************************************************************

        Checks whether the counter-party is still collecting signatures for
        the given channel ID. Until it collects all signatures, the calling
        node cannot initiate any new payment / update proposals.

        Params:
            chan_id = an open channel ID

        Returns:
            true if the node is busy collecting signatures

    ***************************************************************************/

    public Result!bool isCollectingSignatures (in Hash chan_id);

    /***************************************************************************

        Proposes a payment through this channel. This may be a direct payment,
        or an indirect routed payment. Both types of payments use this API.

        Params:
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

    public Result!PublicNonce proposePayment (in Hash chan_id, in uint seq_id,
        in Hash payment_hash, in Amount amount, in Height lock_height,
        in OnionPacket packet, in PublicNonce peer_nonce, in Height height);

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
            chan_id = an existing channel ID
            seq_id = the new sequence ID
            secrets = the secrets the proposer wishes to disclose
            rev_htlcs = the htlcs the proposer wishes to drop
            peer_nonce = the nonce the calling peer will use
            block_height = the block height of the calling node. This is needed
                in order to properly resolve any pending HTLCs in the channel.
                For example, timed-out HTLCs should be replaced with a payout
                back to the funder. If the called node's local block height
                does not match the provided block height, an error will be
                returned.

        Returns:
            the nonce the receiving node will use, or an error code if the
            secrets are unrecognized

    ***************************************************************************/

    public Result!PublicNonce proposeUpdate (in Hash chan_id, in uint seq_id,
        in Hash[] secrets, in Hash[] rev_htlcs, in PublicNonce peer_nonce,
        in Height block_height);

    /***************************************************************************

        Requests a settlement signature for an established channel and a
        previously agreed-upon balance update's sequence ID as set through
        the `proposePayment` / `proposeUpdate` call.

        Params:
            chan_id = A previously seen pending channel ID provided
                by the funder node through the call to `openChannel()`.
            seq_id = the agreed-upon balance update's sequence ID as
                set in the `proposePayment` / `proposeUpdate` call.

        Returns:
            the signature for the settlement transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Signature requestSettleSig (in Hash chan_id, in uint seq_id);

    /***************************************************************************

        Requests an update signature for an established channel and a
        previously agreed-upon balance update's sequence ID as set through
        the `proposePayment` / `proposeUpdate` call.

        The node will reject this call unless it has received a settlement
        signature in the call to `requestSettleSig()`.

        Params:
            chan_id = A previously seen pending channel ID provided
                by the funder node through the call to `openChannel()`
            seq_id = the agreed-upon balance update's sequence ID as
                set in the `proposePayment` / `proposeUpdate` call, for which a
                settlement signature was received.

        Returns:
            the signature for the update transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Signature requestUpdateSig (in Hash chan_id, in uint seq_id);

    /***************************************************************************

        Requests a closing signature for an established channel and a
        previously agreed-upon `closeChannel` request with the given
        sequence ID.

        Params:
            chan_id = A previously open channel ID
            seq_id = the agreed-upon sequence ID in a previous
                `closeChannel` call

        Returns:
            the signature for the closing transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Signature requestCloseSig (in Hash chan_id, in uint seq_id);

    /***************************************************************************

        Report a failed payment

        Params:
            chan_id = ID of the receiver channel
            err = Description of the failure

    ***************************************************************************/

    public void reportPaymentError (in Hash chan_id, in OnionError err);
}
