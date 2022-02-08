/*******************************************************************************

    Contains code used to communicate with another remote node

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.network.Client;

import agora.api.Validator;
import agora.common.BanManager;
import agora.common.Set;
import agora.common.Task;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.Transaction;
import agora.consensus.data.ValidatorBlockSig;
import agora.crypto.Key;
import scpd.types.Stellar_SCP;

import agora.utils.Log;

import std.algorithm;
import std.array;
import std.container : DList;
import std.format;
import std.random;

import core.time;

/// Used for communicating with a remote node
public class NetworkClient
{
    /// Gossip type
    enum GossipType
    {
        Tx,
        Envelope,
        ValidatorBlockSig,
        Enrollment,
        Preimage,
    }

    /// Outgoing gossip event
    static struct GossipEvent
    {
        /// Union flag
        GossipType type;

        union
        {
            Transaction tx;
            SCPEnvelope envelope;
            ValidatorBlockSig block_sig;

            struct PostEnrollmentData
            {
                Enrollment enrollment;
                Height avail_height;
            }
            PostEnrollmentData enrollment;

            PreImageInfo preimage;
        }

        this (Transaction tx) nothrow
        {
            this.type = GossipType.Tx;
            this.tx = tx;
        }

        this (SCPEnvelope envelope) nothrow
        {
            this.type = GossipType.Envelope;
            this.envelope = envelope;
        }

        this (ValidatorBlockSig sig) nothrow
        {
            this.type = GossipType.ValidatorBlockSig;
            this.block_sig = sig;
        }

        this (Enrollment enr, Height avail_height) nothrow
        {
            this.type = GossipType.Enrollment;
            this.enrollment = PostEnrollmentData(enr, avail_height);
        }

        this (PreImageInfo preimage) nothrow
        {
            this.type = GossipType.Preimage;
            this.preimage = preimage;
        }
    }

    /// Whether to throw an exception when attemptRequest() fails
    protected enum Throw
    {
        ///
        No,

        ///
        Yes,
    }

    ///
    private struct ConnectionInfo
    {
        /// Address of the node we're interacting with (for logging)
        public Address address;

        /// API client to the node
        public API api;
    }

    /// Caller's retry delay
    /// TODO: This should be done at the client object level,
    /// so whatever implements `API` should be handling this
    private const Duration retry_delay;

    /// Max request retries before a request is considered failed
    private const size_t max_retries;

    /// Task manager
    private ITaskManager taskman;

    /// Ban manager
    private BanManager banman;

    /// The list of clients that we can communicate with
    package ConnectionInfo[] connections;

    /// Reusable exception
    private Exception exception;

    /// List of outgoing gossip events
    private DList!GossipEvent gossip_queue;

    /// Timer used for gossiping
    private ITimer gossip_timer;

    /// Logger uniquely identifying this client
    private Logger log;

    /// The identity associated with this node - may be empty
    private Identity identity_;

    /// Gossip delay
    private enum GossipDelay = 10.msecs;

    /// Heights of last gossiped pre-images for staked UTXOs
    private Height[Hash] last_preimages;

    /***************************************************************************

        Constructor.

        Params:
            taskman = used for creating new tasks
            banman = ban manager
            retry = the amout to wait between retrying failed requests
            max_retries = max number of times a failed request should be retried

    ***************************************************************************/

    public this (ITaskManager taskman, BanManager banman,
                 Duration retry, size_t max_retries)
    {
        // By default, use the module, but if we can identify a validator,
        // this logger will be replaced with a more specialized one.
        this.log = Log.lookup(__MODULE__);
        this.taskman = taskman;
        this.banman = banman;
        this.retry_delay = retry;
        this.max_retries = max_retries;
        this.exception = new Exception(
            format("Request failure after %s attempts", max_retries));
        // Create and stop timer immediately
        this.gossip_timer = this.taskman.setTimer(GossipDelay, &this.gossipTask, Periodic.No);
        this.gossip_timer.stop();
    }

    /// Shut down the gossiping timer
    public void shutdown () @safe
    {
        this.gossip_timer.stop();
    }

    /// For gossiping we don't want to block the calling fiber, so we use
    /// request queueing and a separate fiber to handle all the outgoing requests.
    private void gossipTask ()
    {
        while (!this.gossip_queue.empty)
        {
            auto event = this.gossip_queue.front;
            this.gossip_queue.removeFront();
            this.handleGossip(event);
            // yield and reschedule for next event
        }
    }

    /// Handle an outgoing gossip event
    private void handleGossip (GossipEvent event) nothrow
    {
        switch (event.type) with (GossipType)
        {
        case Tx:
            this.attemptRequest!(API.postTransaction, Throw.No)(event.tx);
            break;

        case Envelope:
            this.attemptRequest!(API.postEnvelope, Throw.No)(event.envelope);
            break;

        case ValidatorBlockSig:
            this.attemptRequest!(API.postBlockSignature, Throw.No)(event.block_sig);
            break;

        case Enrollment:
            this.attemptRequest!(API.postEnrollment, Throw.No)(event.enrollment.enrollment,
                event.enrollment.avail_height);
            break;

        case Preimage:
            // Clean up the `last_preimages` periodically
            // Note: It clears `last_preimages` everyday based on the CoinNet.
            if (event.preimage.height % Height(144) == 0)
                this.last_preimages.clear();

            // We do not post the preimage if it is already posted in order to
            // prevent calls of `postPreimage` from flooding
            Height last_height;
            try
            {
                last_height = this.last_preimages.get(event.preimage.utxo, Height(0));
            }
            catch (Exception e)
            {
                log.trace("Exception caught while calling on last_preimages: ", e.msg);
            }
            if (event.preimage.height > last_height)
            {
                auto height = this.attemptRequest!(API.postPreimage, Throw.No)(event.preimage);
                if (height >= event.preimage.height)
                    this.last_preimages[event.preimage.utxo] = event.preimage.height;
            }
            break;

        default:
            assert(0);
        }
    }

    /// Convenience function to access all known addresses for this client
    public auto addresses () const scope @safe pure nothrow @nogc
    {
        return this.connections.map!(c => c.address);
    }

    /***************************************************************************

        Set/get the node's identity

        The identity of a node can be accessed through the `identity` property.
        The logger is also changed to make it easier  to identify peers
        and selectively enable or disable logging.

        Identity has two components: public key and UTXO. Because nodes
        are configured with their public key, a node can have a public key but
        no UTXO (no stake yet), and later gain one.
        To account for this case, `setIdentity` can be called twice: Once with
        just a public key and the UTXO being `Hash.init`, and a second time
        with the same `PublicKey` but a non-init UTXO.

        Params:
          utxo = UTXO used as collateral by this peer
          key  = Public key of this peer

    ***************************************************************************/

    public void setIdentity (in Hash utxo, in PublicKey key)
    {
        if (this.identity.key !is PublicKey.init)
        {
            assert(this.identity.key is key);
            assert(this.identity.utxo is Hash.init);
            assert(utxo !is Hash.init);
        }
        else
            assert(this.identity.utxo is Hash.init);

        this.identity_ = Identity(key, utxo);
        this.log = Log.lookup(format("%s.%s", __MODULE__, key));
        this.log.info("Peer identity established (UTXO: {}, Key: {})", utxo, key);
    }

    /// Get the identity of this node. Full nodes return `Identity.init`.
    public Identity identity () const scope @safe pure nothrow @nogc
    {
        // Need to return a new instance as `MAC` is a dynamic array,
        // hence it disables `const` to mutable conversion for `Identity`,
        // but we never store `MAC`.
        return Identity(this.identity_.key, this.identity_.utxo);
    }

    ///
    public bool isAuthenticated () const scope @safe pure nothrow @nogc
    {
        return this.identity.key != PublicKey.init;
    }

    /***************************************************************************

        Params:
            key = key of the peer

        Returns:
            The public key of this node and a secret to prove identity

        Throws:
            `Exception` if the request failed.

    ***************************************************************************/

    public Identity getPublicKey (PublicKey key = PublicKey.init) @trusted
    {
        return this.attemptRequest!(API.getPublicKey, Throw.Yes)(key);
    }

    ///
    public Identity handshake (PublicKey key) @trusted
    {
        return this.attemptRequest!(API.handshake, Throw.Yes)(key);
    }

    /***************************************************************************

        Get the network info of the node, stored in the
        `node_info` parameter if the request succeeded.

        Returns:
            `NodeInfo` if successful

        Throws:
            `Exception` if the request failed.

    ***************************************************************************/

    public NodeInfo getNodeInfo ()
    {
        return this.attemptRequest!(API.getNodeInfo, Throw.Yes)();
    }

    /***************************************************************************

        Get the local time of the node

        Returns:
            the local time of the node, or 0 if the request failed

    ***************************************************************************/

    public TimePoint getLocalTime () @trusted nothrow
    {
        return this.attemptRequest!(API.getLocalTime, Throw.No)();
    }

    /***************************************************************************

        Send a transaction asynchronously to the node.
        Any errors are reported to the debugging log.

        The request is retried up to 'this.max_retries',
        any failures are logged and ignored.

        Params:
            tx = the transaction to send

    ***************************************************************************/

    public void sendTransaction (Transaction tx) @trusted nothrow
    {
        this.gossip_queue.insertBack(GossipEvent(tx));
        this.gossip_timer.rearm(GossipDelay, Periodic.No);
    }


    /***************************************************************************

        Sends an SCP envelope to another node.

        Params:
            envelope = the envelope to send

    ***************************************************************************/

    public void sendEnvelope (SCPEnvelope envelope) nothrow
    {
        this.gossip_queue.insertBack(GossipEvent(envelope));
        this.gossip_timer.rearm(GossipDelay, Periodic.No);
    }

    /***************************************************************************

        Sends a Validator Block Signature to the node.

        Params:
            block_sig = the details of the block signature

    ***************************************************************************/

    public void sendBlockSignature (ValidatorBlockSig block_sig) @trusted nothrow
    {
        this.gossip_queue.insertBack(GossipEvent(block_sig));
        this.gossip_timer.rearm(GossipDelay, Periodic.No);
    }

    /***************************************************************************

        Returns:
            the height of the node's ledger,
            or ulong.max if the request failed

        Throws:
            Exception if the request failed.

    ***************************************************************************/

    public ulong getBlockHeight ()
    {
        return this.attemptRequest!(API.getBlockHeight, Throw.Yes)();
    }

    /***************************************************************************

        Get the array of blocks starting from the provided block height.
        The block at height is included in the array.

        Params:
            height = the starting block height to begin retrieval from
            max_blocks   = the maximum blocks to return at once

        Returns:
            the array of blocks starting from height,
            up to `max_blocks`.

            If the request failed, returns an empty array

    ***************************************************************************/

    public const(Block)[] getBlocksFrom (ulong height, uint max_blocks)
        nothrow
    {
        return this.attemptRequest!(API.getBlocksFrom, Throw.No)(height, max_blocks);
    }

    /***************************************************************************

        Send a enrollment request asynchronously to the node.
        Any errors are reported to the debugging log.

        The request is retried up to 'this.max_retries',
        any failures are logged and ignored.

        Params:
            enroll = the enrollment data to send
            avail_height = Height we target to externalize the enrollment

    ***************************************************************************/

    public void sendEnrollment (Enrollment enroll, Height avail_height) @trusted nothrow
    {
        this.gossip_queue.insertBack(GossipEvent(enroll, avail_height));
        this.gossip_timer.rearm(GossipDelay, Periodic.No);
    }

    /***************************************************************************

        Send a preimage asynchronously to the node.
        Any errors are reported to the debugging log.

        The request is retried up to 'this.max_retries',
        any failures are logged and ignored.

        Params:
            preimage = the pre-image information to send

    ***************************************************************************/

    public void sendPreimage (PreImageInfo preimage) @trusted nothrow
    {
        this.gossip_queue.insertBack(GossipEvent(preimage));
        this.gossip_timer.rearm(GossipDelay, Periodic.No);
    }

    /***************************************************************************

        Params:
            tx_hashes = A Set of Transaction hashes

        Returns:
            Transactions corresponding to the requested hashes or
            Transaction.init for hashes that can't be found in the pool

    ***************************************************************************/

    public Transaction[] getTransactions (Set!Hash tx_hashes) @trusted nothrow
    {
        return this.attemptRequest!(API.getTransactions, Throw.No)(tx_hashes);
    }

    /***************************************************************************

        Params:
            heights = Set of block heights

        Returns:
            Block headers for the requested block heights

    ***************************************************************************/

    public BlockHeader[] getBlockHeaders (Set!ulong heights) @trusted nothrow
    {
        return this.attemptRequest!(API.getBlockHeaders, Throw.No)(heights);
    }

    /***************************************************************************

        Get the array of pre-images starting from the `enrolled_height`.

        Params:
            start_height = the starting enrolled height to begin retrieval from

        Returns:
            the array of preimages of validators enrolling from `enrolled_height`
            to `end_height`

            If the request failed, returns an empty array

    ***************************************************************************/

    public PreImageInfo[] getPreimagesFrom (ulong start_height) nothrow
    {
        return this.attemptRequest!(API.getPreimagesFrom, Throw.No)(start_height);
    }

    /***************************************************************************

        Returns the preimages for the specified enroll keys.

        Params:
            enroll_keys = Set of enrollment keys. If the set of enroll_keys is
            null or empty, then all preimages known to the node are returned.

        Returns:
            The preimages for the specified enroll keys. If the requested node
            doesn't know the preimage for a specific enroll key, then it will
            not be included in the result.

        API:
            GET /preimages

    ***************************************************************************/

    public PreImageInfo[] getPreimages (Set!Hash enroll_keys = Set!Hash.init) @trusted nothrow
    {
        return this.attemptRequest!(API.getPreimages, Throw.No)(enroll_keys);
    }

    /***************************************************************************

        Attempt a request up to 'this.max_retries' attempts, and make the task
        wait this.retry_delay between each attempt.

        If all requests fail and 'ex' is not null, throw the exception.

        Params:
            endpoint = the API endpoint (e.g. `API.postTransaction`)
            DT = whether to throw an exception if the request failed after
                 all attempted retries
            log_level = the logging level to use for logging failed requests
            Args = deduced
            args = the arguments to the API endpoint

        Returns:
            the return value of of the API call, which may be void

    ***************************************************************************/

    protected auto attemptRequest (alias endpoint, Throw DT,
        LogLevel log_level = LogLevel.Trace, Args...)
        (auto ref Args args, string file = __FILE__, uint line = __LINE__)
    {
        import std.traits;
        enum name = __traits(identifier, endpoint);
        alias T = ReturnType!(__traits(getMember, API, name));

        T onError ()
        {
            static if (DT == Throw.Yes)
            {
                this.exception.file = file;
                this.exception.line = line;
                throw this.exception;
            }
            else static if (!is(T == void))
                return T.init;
        }

    RETRY: foreach (idx; 1 .. this.max_retries + 1)
        {
            // Clients without connections should not wait and instead error out
            if (!this.connections.length)
                return onError();

            foreach (index, conn; this.connections)
            {
                if (this.banman.isBanned(conn.address))
                {
                    this.connections.remove(index);
                    log.warn("Removing banned address {} while performing {}, addresses left: {}",
                             conn.address, name, this.addresses);
                    continue RETRY;
                }

                try
                {
                    log.dbg("Client.attemptRequest '{}' to {}: {}/{}", name, conn.address, idx, this.max_retries);
                    scope (success) this.log.format(log_level, "Client.attemptRequest '{}' to {}: {}/{} SUCCESS",
                        name, conn.address, idx, this.max_retries);
                    return __traits(getMember, conn.api, name)(args);
                }
                catch (Exception ex)
                {
                    try
                    {
                        this.log.format(log_level, "Client.attemptRequest '{}' to {}: {}/{} FAILED ({})",
                            name, conn.address, idx, this.max_retries, ex.message);
                    }
                    catch (Exception ex)
                    {
                        // nothing we can do
                    }
                }
            }
            if (idx < this.max_retries) // wait after each failure except last
            {
                log.dbg("Client.attemptRequest '{}' to addresses {} attempt {}/{} FAILED - wait {} before retry",
                    name, this.connections.map!(c => c.address), idx, this.max_retries, this.retry_delay);
                this.taskman.wait(this.retry_delay);
            }
        }
        log.warn("Client.attemptRequest '{}' to addresses {} FAILED after {} attempts",
            name, this.connections.map!(c => c.address), this.max_retries);

        // request considered failed after max retries reached
        foreach (const ref conn; this.connections)
            this.banman.onFailedRequest(conn.address);

        return onError();
    }

    /// Merge connections of incoming client to this
    public bool merge (in Address address, API api)
    {
        import std.range;

        if (this.tryMergeRPC(address, api))
            return true;

        if (address != Address.init || this.connections.length == 0)
        {
            this.connections ~= ConnectionInfo(address, api);
            return true;
        }
        return false;
    }

    /// Try to merge an incoming RPC connection to an existing one if possible
    public bool tryMergeRPC (in Address address, API api)
    {
        import std.typecons;
        import agora.network.RPC;

        alias ValidatorClient = RPCClient!(agora.api.Validator.API);

        auto incoming_peer = cast(ValidatorClient) api;
        if (incoming_peer is null)
            return false;

        auto range = this.connections
            .map!(c => tuple!("address", "api")(c.address, cast(ValidatorClient) c.api))
            .filter!(conn => conn.api !is null);
        if (range.empty)
            return false;
        assert(range.front.address != Address.init);
        range.front.api.merge(incoming_peer);
        return true;
    }
}
