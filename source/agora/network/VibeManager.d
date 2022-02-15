/*******************************************************************************

    A `NetworkManager` implementation based on Vibe.d

    See `agora.network.Manager` for a complete description of the
    `NetworkManager` role and responsibilities.

    Copyright:
        Copyright (c) 2019-2022 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.VibeManager;

static import agora.api.FullNode;
import agora.api.Handlers;
import agora.api.Registry;
static import agora.api.Validator;
import agora.common.Ensure;
import agora.common.Task;
import agora.common.Types;
import agora.common.ManagedDatabase;
import agora.consensus.state.Ledger;
import agora.network.Clock;
import agora.network.DNSResolver;
public import agora.network.Manager;
import agora.network.RPC;
import agora.node.Config;

import vibe.http.client;
import vibe.web.rest;

import std.algorithm.searching : startsWith;
import core.time;

/// The 'default' DNS resolver if none is provided
public immutable Address[] DefaultDNS;

shared static this ()
{
    // Cannot be a manifest constant as `Address` will read the common schema
    // when instantiated.
    DefaultDNS = [
        // Cloudflare
        Address("dns://1.1.1.1"), Address("dns://1.0.0.1"),
        // Google public DNS
        Address("dns://8.8.8.8"), Address("dns://8.8.4.4"),
        // CISCO OpenDNS
        Address("dns://208.67.222.222"), Address("dns://208.67.220.220"),
        // Quad9
        Address("dns://9.9.9.9"), Address("dns://149.112.112.112"),
    ];
}

/// And implementation of `agora.network.Manager : NetworkManager` using Vibe.d
public final class VibeNetworkManager : NetworkManager
{
    /// Construct an instance of this object
    public this (in Config config, ManagedDatabase cache, ITaskManager taskman,
                 Clock clock, agora.api.FullNode.API owner_node, Ledger ledger)
    {
        super(config, cache, taskman, clock, owner_node, ledger);
    }

    /// See `NetworkManager.makeDNSResolver`
    public override DNSResolver makeDNSResolver (Address[] peers = null)
    {
        return new VibeDNSResolver(peers.length ? peers : DefaultDNS);
    }

    /// See `NetworkManager.makeClient`
    protected override agora.api.Validator.API makeClient (Address url)
    {
        const timeout = this.config.node.timeout;
        if (url.schema == "agora")
        {
            auto owner_validator = cast (agora.api.Validator.API) this.owner_node;

            return owner_validator ?
                new RPCClient!(agora.api.Validator.API)(
                url.host, url.port,
                /* Disabled, we have our own method: */ 0.seconds, 1,
                timeout, timeout, timeout, 3 /* Hard coded max tcp connections*/,
                owner_validator)
                :
                new RPCClient!(agora.api.Validator.API)(
                url.host, url.port,
                /* Disabled, we have our own method: */ 0.seconds, 1,
                timeout, timeout, timeout, 3 /* Hard coded max tcp connections*/,
                this.owner_node);
        }

        if (url.schema.startsWith("http"))
            return new RestInterfaceClient!(agora.api.Validator.API)(
                this.makeRestInterfaceSettings(url));

        assert(0, "Unknown agora schema: " ~ url.toString());
    }

    /// See `NetworkManager.makeRegistryClient`
    public override NameRegistryAPI makeRegistryClient (Address address)
    {
        assert(address.schema.startsWith("http"));
        return new RestInterfaceClient!NameRegistryAPI(
            this.makeRestInterfaceSettings(address));
    }

    /// See `NetworkManager.makeBlockExternalizedHandler`
    public override BlockExternalizedHandler makeBlockExternalizedHandler (Address address)
    {
        return new RestInterfaceClient!BlockExternalizedHandler(
            this.makeRestInterfaceSettings(address));
    }

    /// See `NetworkManager.makeBlockHeaderUpdatedHandler`
    public override BlockHeaderUpdatedHandler makeBlockHeaderUpdatedHandler (Address address)
    {
        return new RestInterfaceClient!BlockHeaderUpdatedHandler(
            this.makeRestInterfaceSettings(address));
    }

    /// See `NetworkManager.makePreImageReceivedHandler`
    public override PreImageReceivedHandler makePreImageReceivedHandler(Address address)
    {
        return new RestInterfaceClient!PreImageReceivedHandler(
            this.makeRestInterfaceSettings(address));
    }

    /// See `NetworkManager.makeTransactionReceivedHandler`
    public override TransactionReceivedHandler makeTransactionReceivedHandler (Address address)
    {
        return new RestInterfaceClient!TransactionReceivedHandler(
            this.makeRestInterfaceSettings(address));
    }

    /// Returns: A `RestInterfaceSettings` with the content of the `config`
    ///          pointing to `address`
    private RestInterfaceSettings makeRestInterfaceSettings (Address address)
    {
        auto settings = new RestInterfaceSettings;
        settings.baseURL = address;
        settings.httpClientSettings = new HTTPClientSettings;
        settings.httpClientSettings.connectTimeout = this.config.node.timeout;
        settings.httpClientSettings.readTimeout = this.config.node.timeout;
        settings.httpClientSettings.proxyURL = this.config.proxy.url;
        return settings;
    }
}

///
private final class VibeDNSResolver : DNSResolver
{
    import agora.common.DNS;
    import agora.serialization.Serializer;

    /// The list of base DNS resolver (e.g. read from resolv.conf)
    private PeerInfo[] resolvers;

    /***************************************************************************

        Instantiate a new object of this type

        Params:
          peers = The 'seed' peers, which are the first point of contact
                  of the resolver.

    ***************************************************************************/

    public this (const Address[] peers)
    {
        assert(peers.length);
        this.resolvers.length = peers.length;
        // "Connect" to each of the resolvers
        // UDP is not connection-oriented, but this binds the socket to the
        // underlying address.
        foreach (idx, ref res; this.resolvers)
        {
            res.address = resolveHost(peers[idx].host);
            res.address.port = peers[idx].port;
        }
    }

    /***************************************************************************

        Query the server over UDP with given `msg` and return the response

        Params:
            msg = DNS message

    ***************************************************************************/

    public override Message queryUDP (Message msg) @trusted
    {
        ubyte[16384] buffer;
        foreach (ref peer; this.resolvers)
        {
            auto conn = listenUDP(0, "0.0.0.0",
                UDPListenOptions.reuseAddress | UDPListenOptions.reusePort);
            conn.connect(peer.address);

            try
            {
                conn.send(msg.serializeFull);
                auto response = conn.recv(5.seconds, buffer);
                auto answer = response.deserializeFull!Message();
                log.trace("Got response from '{}' for '{}' : {}",
                          peer.address, msg, answer);
                return answer;
            }
            catch (Exception exc)
            {
                log.warn("Network error while resolving '{}' using '{}': {}",
                         msg, peer.address, exc);
                continue;
            }
        }

        log.trace("None of the {} peers had an answer for message: {}",
            this.resolvers.length, msg);
        return Message.init;
    }

    /***************************************************************************

        Query the server over TCP with given `msg` and return the response

        Params:
            msg = DNS message

    ***************************************************************************/

    public override Message queryTCP (Message msg) @trusted
    {
        ubyte[16384] buffer;

        ushort length = 2;
        scope writer = (in ubyte[] data) @safe {
            ensure(data.length <= (buffer.length - length),
                "Buffer overflow: Trying to write {} bytes in a {} buffer ({} used)",
                data.length, buffer.length, length);
            buffer[length .. length + data.length] = data[];
            length += data.length;
        };

        foreach (ref peer; this.resolvers)
        {
            auto conn = connectTCP(peer.address, anyAddress, 5.seconds);
            if (conn.connected)
            {
                try
                {
                    // Write length ~ serialized msg
                    msg.serializePart(writer, CompactMode.No);
                    assert(length >= 2);
                    ushort copy = cast(ushort) (length - 2);
                    length = 0;
                    copy.serializePart(writer, CompactMode.No);
                    conn.write(buffer[0 .. copy + 2]);

                    conn.read(buffer[0 .. 2]);
                    const ushort size = deserializeFull!ushort(
                        buffer[0 .. 2], DeserializerOptions(DefaultMaxLength, CompactMode.No));

                    // DNS TCP message size is not limited from Agora registry while sending
                    // but here received message size is not in our control,
                    // limited to a buffer for preventing DOS attack
                    conn.read(buffer[0 .. size]);
                    conn.close();

                    auto answer = deserializeFull!Message(buffer[0 .. size]);
                    log.trace("Got response from '{}' for '{}' : {}",
                          peer.address, msg, answer);

                    return answer;
                }
                catch (Exception exc)
                {
                    log.warn("Network error while resolving '{}' using '{}': {}",
                            msg, peer.address, exc);
                    conn.close();
                }
                break;
            }
        }
        log.trace("None of the {} peers had an answer for message: {}",
            this.resolvers.length, msg);
        return Message.init;
    }
}

/// Hold information about DNS resolvers
private struct PeerInfo
{
    /// Address of the peer (IP)
    public NetworkAddress address;

    /// Number of messages sent to this peer
    public size_t queries;
}

version (AgoraStandaloneDNSResolver)
{
    import agora.common.DNS;
    import vibe.core.core;
    import std.stdio;

    private int main (string[] args)
    {
        assert(args.length > 1, "Need at least one argument");

        runTask(() @trusted nothrow {
            scope (failure) assert(0);
            DNSResolver resolver = new VibeDNSResolver(DefaultDNS);
            resolver.log.enableConsole();

            foreach (host; args[1 .. $])
            {
                try
                    writeln(resolver.query(host, QTYPE.NS));
                catch (Exception exc)
                    writeln("Exception caught while try to resolve addresses: ", exc);
            }
        });

        return runEventLoop();
    }
}
