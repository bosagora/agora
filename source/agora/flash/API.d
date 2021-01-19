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
import agora.common.crypto.ECC;
import agora.common.Types;
import agora.flash.Config;
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

        Requests a balance update for a currently open channel.
        The channel ID must already exist, and the sequence ID must be
        greater than the last known succesfully signed sequence ID.

        A node should reject a balance update request for a sequence which
        has already been previously accepted by this call. If the node rejects
        the request due to disagreement about the `BalanceRequest`, the calling
        node may attempt a new request with the same sequence ID.

        This request may be issued by any party in the channel,
        as funds may travel in any direction.

        Params:
            chan_id = an existing channel ID previously opened with
                `openChannel()` and agreed to by the counter-party.
            seq_id = the new sequence ID of the settle / update pair.
                This should always be +1 of a previously successfully
                signed sequence ID.
            balance_req = contains information about the balance request like
                the requested new balance.

        Returns:
            the nonce pair for the next settle & update transactions,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!PublicNonce requestBalanceUpdate (in Hash chan_id,
        in uint seq_id, in BalanceRequest balance_req);

    /***************************************************************************

        Requests a settlement signature for an established channel and a
        previously agreed-upon balance update's sequence ID as set through
        the `requestBalanceUpdate` call.

        Params:
            chan_id = A previously seen pending channel ID provided
                by the funder node through the call to `openChannel()`.
            seq_id = the agreed-upon balance update's sequence ID as
                set in the `requestBalanceUpdate` call.

        Returns:
            the signature for the settlement transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Signature requestSettleSig (in Hash chan_id, in uint seq_id);

    /***************************************************************************

        Requests an update signature for an established channel and a
        previously agreed-upon balance update's sequence ID as set through
        the `requestBalanceUpdate` call.

        The node will reject this call unless it has received a settlement
        signature in the call to `requestSettleSig()`.

        Params:
            chan_id = A previously seen pending channel ID provided
                by the funder node through the call to `openChannel()`
            seq_id = the agreed-upon balance update's sequence ID as
                set in the `requestBalanceUpdate` call, for which a
                settlement signature was received.

        Returns:
            the signature for the update transaction,
            or an error code with an optional error message.

    ***************************************************************************/

    public Result!Signature requestUpdateSig (in Hash chan_id, in uint seq_id);
}
