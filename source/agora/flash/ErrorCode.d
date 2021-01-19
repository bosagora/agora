/*******************************************************************************

    Contains error codes for the Flash API.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.ErrorCode;

/// Lists possible error codes for the API calls.
public enum ErrorCode : ushort
{
    /// No error.
    None = 0,

    /// Requested an update transaction before the matching settlement was signed.
    SettleNotReceived,

    /// This sequence ID was not agreed upon, or it's outdated.
    InvalidSequenceID,

    /// Signature is invalid.
    InvalidSignature,

    /// Channel ID does not exist / unknown.
    InvalidChannelID,

    /// Channel ID exists but the channel is not open.
    ChannelNotOpen,

    /// Channel ID exists but it's not closing / closed.
    ChannelNotClosing,

    /// Tried to create a new channel ID with the same ID as an existing channel ID.
    DuplicateChannelID,

    /// Mismatching genesis hash. E.g. if one node is running on TestNet and the
    /// other on CoinNet.
    InvalidGenesisHash,

    /// Counter-party disagrees with the funding amount for this channel.
    /// The message in the `Result` may have the node's specific reasoning
    /// as to the minimum funding limits of the node.
    FundingTooLow,

    /// A new balance update request cannot be made until the active signing
    /// process is complete.
    SigningInProcess,

    /// The new balance request has been rejected, e.g. trying to spend more
    /// than allocated in the funding transaction.
    RejectedBalanceRequest,
}
