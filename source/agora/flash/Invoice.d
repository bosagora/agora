/*******************************************************************************

    Contains the invoice definition.

    A randomly-generated secret is generated, and the hash of it is stored
    in the invoice together with the invoice's amount, expiry,
    and any description.

    The secret should be shared with the party which will pay the invoice.
    The hash of the secret is used in the contract which is shared across
    zero or more channel hops. The payment is realized once the payer reveals
    the secret, and all the channel pairs in the multi-hop channel layout
    have their settle/update transactions signed.

    Copyright:
        Copyright (c) 2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.flash.Invoice;

import agora.common.Amount;
import agora.crypto.ECC;
import agora.crypto.Hash;

import libsodium.randombytes;

import core.stdc.time;

/// Ditto
public struct Invoice
{
    /// Hash of the secret. Also known as the payment hash.
    public Hash payment_hash;

    /// Payment destination
    public Point destination;

    /// The amount to pay for this invoice.
    public Amount amount;

    /// The expiry time of this invoice. A node will (?) reject payments to an
    /// invoice if the payment is received after the expiry time.
    /// TODO: check if byzantine nodes can abuse this.
    public time_t expiry;

    /// Invoice description. Useful for user-facing UIs (kiosks), may be empty.
    public string description;
}

struct InvoicePair
{
    Invoice invoice;
    Hash secret;
}

/*******************************************************************************

    Creates a new invoice with the given properties, and shares the secret
    with the caller.

    Params:
        secret = will contain the secret on return
        amount = the amount to pay
        expiry = the expiry time
        description = optional description

    Returns:
        the Invoice

*******************************************************************************/

public InvoicePair createInvoice (in Point destination, in Amount amount,
    in time_t expiry, in string description = null) @safe @nogc nothrow
{
    Hash secret;
    () @trusted { randombytes_buf(secret[].ptr, Hash.sizeof); }();

    Invoice invoice =
    {
        payment_hash : hashFull(secret),
        destination : destination,
        amount : amount,
        expiry : expiry,
        description : description,
    };

    InvoicePair pair =
    {
        invoice : invoice,
        secret : secret
    };

    return pair;
}

///
@safe @nogc nothrow unittest
{
    const pair = createInvoice(Point.init, Amount(100), 1611121934, "desc");
    assert(pair.secret.hashFull() == pair.invoice.payment_hash);
}
