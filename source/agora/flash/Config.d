/*******************************************************************************

    Contains the flash Channel definition

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Config;

import agora.flash.api.FlashAPI;
import agora.flash.Types;

import agora.common.Amount;
import agora.common.ConfigAttributes;
import agora.common.Types;
import agora.consensus.data.Transaction;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;

import core.time;

/// Flash configuration
public struct FlashConfig
{
    /// Whether or not this node should support the Flash API
    public bool enabled;

    /// Flash name registry address
    public string registry_address;

    // Network addresses that will be registered with the associated managed
    // public keys
    public immutable string[] addresses_to_register;

    /// Timeout for requests
    public Duration timeout = 10.seconds;

    /// The address to listen to for the control interface
    public string control_address = "127.0.0.1";

    /// The port to listen to for the control interface
    public ushort control_port = 0xB0C;

    /// Address to the listener which will receive payment / update notifications
    public string listener_address;

    /// Minimum funding allowed for a channel
    public Amount min_funding = Amount(0);

    /// Maximum funding allowed for a channel
    public Amount max_funding = Amount(100_000);

    /// Minimum number of blocks before settling can begin after trigger published
    public uint min_settle_time = 10;

    /// Maximum number of blocks before settling can begin after trigger published
    public uint max_settle_time = 100;

    /// Maximum time spent retrying requests before they're considered failed
    public Duration max_retry_time = 60.seconds;

    /// The maximum retry delay between retrying failed requests. Should be lower
    /// than `max_retry_time`
    public Duration max_retry_delay = 2.seconds;

    /// Multiplier for the truncating exponential backoff retrying algorithm
    public uint retry_multiplier = 10;
}

/***************************************************************************

    Calculate total fee from the given update and payment total

    Params:
        update = latest update for the channel
        total = payment total

    Returns:
        Total Amount of required fee

***************************************************************************/

public Amount getTotalFee (ChannelUpdate update, Amount total) @safe nothrow
{
    Amount fee = update.fixed_fee;
    Amount proportional_fee = total.proportionalFee(update.proportional_fee);
    if (!proportional_fee.isValid())
        return proportional_fee;
    fee.add(proportional_fee);
    return fee;
}

unittest
{
    auto update = ChannelUpdate(Hash.init, PaymentDirection.TowardsOwner, 1.coins, 1.coins);
    assert(update.getTotalFee(10.coins) == 11.coins);
    assert(!update.getTotalFee(Amount.MaxUnitSupply).isValid());
}
