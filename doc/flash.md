# Flash

Flash is a second-layer scaling solution for the Bosagora blockchain network.

Flash requires a minimum amount of interaction with the blockchain in order
to work. In particular the on-chain actions performed by a Flash node are as
follows:

- Opening a Flash channel collaboratively with a counter-party.
- Closing a Flash channel collaboratively with a counter-party.
- Closing a Flash channel unilaterally when the counter-party is unresponsive
    or does not collaborate.
- Submitting the latest Flash channel state if the counter-party tried to
    unilaterally close a channel by submitting an older Flash channel state.

## Collaborative and Unilateral transactions

### Collaborative on-chain transactions

In the most common case when there are no disputes, the amount of transactions
on-chain will be only two:

- A funding transaction which marks the beginning of the Flash channel.
  After this transaction is detected by Flash nodes they will start using
  the Flash channel to submit transactions through it.
- A closing transaction which marks the end of the Flash channel.
  After this transaction is detected by Flash nodes they will reject any
  further channel transactions and updates to this channel.

### Non-collaborative / Unilateral on-chain transactions

Either participant of a Flash channel may initiate a unilateral closure of
the Flash channel. There are several reasons why a unilateral closure would
be made by a participant:

- The participant attempted the collaboratively close the channel,
  but the counter-party was unresponsive for a long time.
- The participant attempted the collaboratively close the channel,
  but the counter-party rejected all attempts to close the channel.
- The participant attempts to cheat by publishing an older state of the
  Flash channel to the blockchain. The counter-party will then have
  enough time to react and publish the latest Channel state to the blockchain,
  effectively replacing the previous state with the latest state. Further
  state updates are then not possible to replace.

To initiate a unilateral closure of a Flash channel, the participant must
first publish the `Trigger` transaction to the blockchain. This special
type of transaction spends from the Funding transaction and may subsequently
only be spent by another `Update` transaction. The `Update` transaction is then
encumbered by a time-lock. This time-lock gives enough time for the
counter-party to publish any newer `Update` transaction, which will restart
the time-lock. Finally, if the time-lock is expired then a Settlement
transaction may be published to the blochchain. This transaction spends
from the outputs of the Funding transaction's and creates new outputs
into each participants account based on the final Flash channel state.

## Types of on-chain transactions

There are several types of Flash on-chain transactions that may be present on
the blockchain. For the vast majority of Flash channel, it is expected that
only two of these types of transactions are published for the opening and
closing of each Flash channel. For disputes, several other types of
transaction types may be present on the blockchain.

### Funding transaction

The Funding transaction marks the start of the channel. The initiator (also
termed "owner") of the channel is the provider of the initial liquidity
of the channel. He must publish a Funding transaction to the blockchain to
mark the Flash channel as being open.

The funding transaction spends from a UTXO which the initiator owns, and has
a special lock script in its output. There are only two ways a funding
transaction's outputs may be spent:
- By submitting a Close transaction, which settles the latest Flash channel
  state on-chain. This is done in the collaborative case.
- By submitting a `Trigger` transaction, which begins a timeout. Within this
  timeout an `Update` transaction may be submitted, which restarts the
  timeout. If any of the `Trigger` / `Update` transaction's timeouts expire,
  a Settlement transaction may be attached which will settle how the funding
  transaction's funds will be routed to each of the Flash channel participants.

### Close transaction

This is a multi-sig transaction which spends directly from the Funding
transaction. It requires both of the channel participants' signatures.
Once externalized on the blockchain, this will mark the associated Flash
channel as being closed. No further channel updates will be accepted,
and the Close transaction cannot be replaced on the blockchain.

The close transaction will contain the final settled outputs based on the
associated Flash channel's final state. Visually the on-chain transactions
will look as follows:

```
                                                       +--------------+
                                                       |              |
                                          ------------->   Party A    |
                                          |            |              |
  +--------------+    +--------------+    |            +--------------+
  |              |    |              |    |
  |  Funding Tx  |---->  Closing Tx  |----+
  |              |    |              |    |
  +--------------+    +--------------+    |            +--------------+
                                          |            |              |
                                          ------------->   Party B    |
                                                       |              |
                                                       +--------------+
```

### Trigger / Update / Settle transactions (unilateral channel closures)

If a `Trigger` transaction is published to the blockchain, it begins a timeout.
Before this timeout expires, a newer `Update` transaction may be published to
the blockchain which will overwrite the `Trigger` transaction and restart the
timeout. Furthermore, if multiple `Update` transactions are published, each
one of them will restart the timeout.

Once the timeout expires, an associated Settlement transaction may be published
to the blockchain.

```
  +--------------+    +--------------+                              +--------------+                             +--------------+
  |              |    |              |                              |              |                             |              |
  |  Funding Tx  |---->  Trigger Tx  |------------------------------>  Update #10  |----------------------------->  Update #20  |
  |              |    |              |                              |              |                             |              |
  +--------------+    +--------------+                              +--------------+                             +--------------+
                              |                                            |                                             |
                              |           +--------------+                 |           +--------------+                  |           +--------------+
                              |           |              |                 |           |              |                  |           |              |
                              ------------>   Settle #0  |                 ------------>  Settle #10  |                  ------------>  Settle #20  |
                                          |              |                             |              |                              |              |
                                          +--------------+                             +--------------+                              +--------------+
                                                 |                                             |                                             |
                                                 |                                             |                                             |
                             +--------------+    |    +--------------+     +--------------+    |    +--------------+     +--------------+    |    +--------------+
                             |              |    |    |              |     |              |    |    |              |     |              |    |    |              |
                             |    Party A   <--------->    Party B   |     |    Party A   <--------->    Party B   |     |    Party A   <--------->    Party B   |
                             |              |         |              |     |              |         |              |     |              |         |              |
                             +--------------+         +--------------+     +--------------+         +--------------+     +--------------+         +--------------+
```

As seen in the diagram above, the `Trigger Tx` spends from the `Funding Tx` and
creates a lock script in its output. This lock can be unlocked by either
an `Update` transaction, or a `Settlement` transaction if the timeout on the lock
has expired.

In the above case, either `Settle #0` OR `Update #10` will be externalized. They
cannot both be externalized as they both spend from the same `Trigger` transaction's
UTXO.

In the same way, either `Settle #10` OR `Update #20` will be externalized because
they both try to spend from the UTXO of `Update #10`.

There may be numerous other `Update` / `Settle` transaction pairs, however in
case of disputes each counter-party only needs to care about a few things:
- If a `Trigger` transaction is detected, make sure to publish the latest
  `Update` transaction to the blockchain. If there was no `Update` transaction
  ever made, then the user can safely publish the `Settle #0` transaction.
- If a counter-party publishes an older `Update` transaction, make sure to
  publish the latest one to the blockchain. This newer `Update` transaction
  will spend the older `Update` transaction's UTXO.
- After the timeout is expired, publish the associated Settlement transaction
  which spends from that externalized `Update` transaction.

## Settlement time

In the previous section the Settlement transaction was described as attaching
to a `Trigger` or `Update` transaction, but only after a timelock has expired.

This is the settlement time as set in the `ChannelConfig.settle_time`
config options.

To initiate opening a channel with a counter-party, the settlement time
must be agreed upon by both parties in order to be able to sign the
`Trigger` / `Update` transactions.

## APIs

### FlashAPI

Each Flash node must implement the `FlashAPI`, a set of RPC methods which
support opening and closing Flash channels, requesting updates to its internal
state, and reporting any errors.

See the `agora/flash/api/FlashAPI.d` for more info.

### FlashControlAPI

For Wallets or other control software, the `FlashControlAPI` allows the
software to control the behavior of the Flash node. This API contains methods
which support opening Flash channels, collaboratively or unilaterally
closing Flash channels, creating invoices, paying invoices by routing a payment,
and changing each channel's fees.

See the `agora/flash/api/FlashControlAPI.d` for more info.

### FlashListenerAPI

Wallets or other control software must implement the `FlashListenerAPI`.
This allows the Flash node to notify the software of any changes to the
Flash channels which it is a part of. This includes methods for notifying
when channels are opened or rejected opening by the counter-party, closed,
notification when a counter-party initiates opening a new channel and the
ability to accept or reject it by the software, and notifications about
successfull and failed payments.

See the `agora/flash/api/FlashListenerAPI.d` for more info.

## Flash Node Wallet configuration

In order for the Flash node to communicate with the Wallet software,
it needs to know how to connect to the Wallet which implements the
`FlashListenerAPI` interface.

The `FlashConfig.listener_address` sets the URL to the Wallet software.

Additional config options are listed in `agora/flash/Config.d`

## Types of Flash nodes

The Agora codebase currently supports two types of Flash nodes:

- `FlashFullNode`
- `FlashValidator`

These implement the `FlashAPI` and the `FullNode` / `Validator` APIs,
respectively.

## FlashControlAPI interface

This section describes how a Wallet should use the `FlashControlAPI`.

### FlashControlAPI.start()

This starts internal fibers which are used for event handling.
It must be called before any other function.

### FlashControlAPI.openNewChannel()

This can be used to schedule starting a new channel with the given UTXO hash.
If there are any errors with the parameters, an error will be returned.
If the parameters are OK, the channel opening will be scheduled.

The Wallet will receive notifications about success / failure to open a channel
through the `FlashListenerAPI.onChannelNotify()` API.

### FlashControlAPI.beginCollaborativeClose()

This can be used to schedule a collaborative closure of a channel.
If there are any errors with the parameters, an error will be returned.
If the parameters are OK, the channel closing will be scheduled.

The Wallet will receive notifications about success / failure to close the channel
through the `FlashListenerAPI.onChannelNotify()` API.

If closing the channel collaboratively repeatedly fails, the Wallet may try
to use the `FlashListenerAPI.beginUnilateralClose()` API instead.

### FlashControlAPI.beginUnilateralClose()

This can be used to schedule a unilateral closure of a channel.
If there are any errors with the parameters, an error will be returned.
If the parameters are OK, the channel closing will be scheduled.

The Wallet will receive notifications about success / failure to close the channel
through the `FlashListenerAPI.onChannelNotify()` API.

This API should only be used if calling `FlashListenerAPI.beginUnilateralClose()`
has lead to reported failure (failures are reported through
`FlashListenerAPI.onChannelNotify()`).

Note that unilateral channel closures take a longer time than collaborative
closures, as a set of `Trigger` / `Update` / and `Settle` transactions must
each be externalized with a settlement delay as described in previous sections.

### FlashControlAPI.createNewInvoice()

This creates a new unique invoice and returns it. The invoice may then
be converted into some other form by the wallet, for example QR code.

The Invoice should then be shared with the Payer through some form, for example
the Payer wallet's UI or kiosk display. When the Payer wishes to pay for the
Invoice their wallet will need to use the `FlashControlAPI.payInvoice()` API.

### FlashControlAPI.changeFees()

This changes the fixed and proportional fees for the given channel ID.
The Wallet may adjust these dynamically over time to either increase profits
from fees, or to make that channel more attractive for other users to route
their payments through.

## FlashListenerAPI interface

This section describes how the Wallet should respond to messages received via
the `FlashListenerAPI`.

### FlashListenerAPI.onChannelNotify()

This Wallet's API will be called each time a channel's state changes.

For example, a channel could be accepted by a counter-party and ready to
be opened. Or it might be in the process of being closed down.

See the `ChannelState` in the `agora.flash.Types` module for a list of all
possible channel states.

### FlashListenerAPI.onRequestedChannelOpen()

This Wallet's API will be called when another user wishes to open a channel
with this node. If the Wallet wants to accept this channel, it should return
an empty string. If the Wallet wants to reject this channel, it should
return an error string with a description of why the channel was rejected.

### FlashListenerAPI.onPaymentSuccess()

This Wallet's API will be called when a payment initiated through the
`FlashControlAPI.payInvoice()` API has succeeded.

### FlashListenerAPI.onPaymentFailure()

This Wallet's API will be called when a payment initiated through the
`FlashControlAPI.payInvoice()` API has failed. There is an error code
parameter which will determine why the payment failed.

If the timeout in the invoice has not expired, the wallet may attempt to
initiate the payment again through the `FlashControlAPI.payInvoice()` API.

Otherwise if the timeout has expired, the invoice should be discarded.
The Payee (recevier of the payment / merchant) should then generate a new
invoice and share it with the Payer and restart the entire payment process.

## Invoice

The invoice contains the set of information that is needed for the Flash
node to be able to route a payment through the Flash network.

It contains:

- payment_hash: This is a unique and randomly generated number by the Payee
  (Merchant) through the `FlashControlAPI.createNewInvoice()` API.
- destination: This is the destination public key for the payment.
  This is equivalent to the destination Flash node's public key.
- amount: The amount of BOA to route to the destination. Note that the
  user needs to have `amount + fees` in his channel's capacity in order to
  route the payment.
- expiry: A Unix timestamp for the expiry of the invoice. If the payment is
  not successful by this time then the receiver will reject further payment
  attempts with this specific invoice.
- description: An informative description for the invoice. This can be any
  string set by the Payee (Merchant), and may for example be displayed by
  the Wallet software to the User to make the payment invoice informative.
