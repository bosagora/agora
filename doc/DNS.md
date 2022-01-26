## DNS localization scheme

Agora is a distributed, decentralized network, where nodes enter by "enrolling".
Once a node is enrolled, it is expected to participate in the consensus process.
Without participation, no reward will be provided. In the event a node having enrolled
becomes completely unreachable for an extended period of time,
it will be financially penalized ("slashed").

The protocol is designed so that the risk of being unduly penalized is minimal,
and safeguards can be put in place to prevent penalization, such as a watchtower
system that will take over if the primary server becomes unreachable.
Such safeties do not require a publicly accessible server, nor access to the private key,
however they do not lead to the validator being rewarded.

In order to fully participate in the consensus protocol and earn rewards,
a node must be publicly reachable on the Internet. The most common example would be a node
running on a server, virtualized or not, with a public interface without any intermediary.
Running a node on a home computer, while possible, requires more advanced configuration.

As the blockchain is a permanent storage, it is not a suitable place to put volatile data
such as a node's IP address, which may change unpredictably.
However, there is a need for nodes to find one another after a node has enrolled.

For this purpose, Agora embeds a "registry", which is a caching DNS server.
Agora can optionally make this caching DNS server publicly available.
The exact scheme used is defined below from the point of view of each actors.

### Actors

The following actors are used through this document:
- The (name) registry;
- Node A, already established and registered;
- Node B, new member of the network which wish to enroll;
- User B, the operator of Node B;

### Start-up procedure: Seeding

When Node B starts up from a first time, from a blank state, it needs to locate other nodes in the network.
This is to allow it to catch-up with the current state of the network. Its peerage should be wide enough
that it has reasonable confidence it has at least one honest peer.

To contact the network, the node first looks up which "realm" it is part of.
A "realm" is a domain name that uniquely identify the network the node will be part of.
For the purpose of this example, the realm we use will be `testnet.bosagora.io`.

Using normal DNS resolution mechanisms, Node B queries its realm for `A` or `AAAA` records (IP addresses).
A properly configured network will have one or more registry configured to answer DNS queries for
a realm and its subdomain. The registry should answer such queries with a well distributed list
of addresses, pointing the new client to a few trustworthy peers. This is known as seeding.

Once it receives its response, Node B connects to one or more of the nodes present in the response.
It then starts its IBD (initial block download), synchronizing itself with the network.

The manner in which the registry chooses which nodes to include in its response,
the number of records, and the variability of the response are not defined.
The registry MUST either not answer anything, if it has no records,
or include at least one currently enrolled validator if it is authoritative.

### Well known zones

A node, having established its realm, relies on two well-known zones for operation:
`validators` and `flash`. With the aforementioned `testnet.bosagora.io` realm,
it means the registry MUST respond to requests for `validators.testnet.bosagora.io`
and `flash.testnet.bosagora.io`.

The `validators` zone holds information about currently (and potentially past)
eligible nodes, while `flash` holds information about eligible `flash` nodes.

It is expected that on the long run `flash` would hold orders of magnitude more
nodes than `validators`, although this might not be the case early on.

### Becoming a validator: Freezing, Enrollment, and registration

Becoming a validator requires a certain data structure (`Enrollment`)
to be included ("externalized") in the `BlockHeader` by other nodes.
A validator becomes active the block immediately after its `Enrollment` has been externalized,
for a duration set in the consensus parameter of the network (e.g. 2016 blocks).

The externalization must be preceded, or happen at the same time as, the act of "freezing".
Freezing is submitting a special transaction, with an output of the `Freeze` type,
fulfilling a minimum amount requirement, which ensures a misbehaving validator can be "slashed".

While it is preferable and better supported to enroll after the freezing transaction has been externalized,
externalizing both freezing and enrollment in the same block MUST be supported.

In addition to enrollment, a node SHOULD ensure that it performs registration in a timely
manner to ensure it can be reached by other peers. Registration is performed by sending
a query to the authoritative name server for the realm.

Currently this registration is performed via an HTTP POST request on `/validator` with
the `registry_payload` query parameter.
A future improvement aims to use a DNS-based system.

To ensure a node is able to enroll timely, the registry MUST accept registration for any
public key that owns a frozen UTXO, not only for already enrolled nodes.

Consequently, clients MUST NOT rely on `validators` zone membership to test for validator status.

### Locating another node

When Node A wants to contact newly-enrolled Node B, it issues a request to its configured name server.
The request has `QTYPE=URI` (256, defined in RFC 7553), `_service=agora`, `_proto=tcp`,
and is for the public key of Node B.

For example, considering the previously mentioned realm, and assuming that Node B public key is:
`boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2`
The query would be for:
`_agora._tcp.boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2.validators.testnet.bosagora.io.`

The registry MUST then answer, if it has a matching record, with an URI record, for example:
`_agora._tcp.boa1xzval2a3cdxv28n6slr62wlczslk3juvk7cu05qt3z55ty2rlfqfc6egsh2.validators.testnet.bosagora.io.   3600 IN URI 10 1 "https://v2.bosagora.io/rest_api/"`

### Flash zone

The flash zone works similarly to the `validators` zone, except for two key details:
- Registration is done through another endpoint (currently `POST /flash_node`);
- Eligibility criteria is looser: Any public key with a potential flash channel may register;
