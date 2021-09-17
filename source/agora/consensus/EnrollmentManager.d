/*******************************************************************************

    Manages this node's Enrollment, the `ValidatorSet`, and `EnrollmentPool`

    This class currently has 3 responsibilities:
    - It's a bridge to the `ValidatorSet`, where the list of currently active
      validators is stored;
    - It stores `Enrollment`s that are not yet part of the validator set;
    - Most importantly, if this node is a validator, it manages this node's
      `Enrollment` data, including pre-images.

    The consensus protocol requires each validator to commit to a hash and
    to reveal a pre-image for the next `ValidatorCycle` blocks (currently 1008).
    That newly-revealed hash is used as a basis for various operations,
    such as deriving the new signature noise (in order to make signature
    aggregation possible) and both as a source of randomness for the node
    itself (e.g. for the quorum balancing) and as part of the network
    randomness function, when aggregated with other node's pre-images.
    As a result, revealing the pre-image in time is absolutely critical and
    not doing so will lead to penalties.

    In order to ensure that we will never lose the ability to reveal
    pre-images, this implementation uses a reproducible scheme:
    on the first run, we generate a "cycle seed" which is derived from a hash
    of the private key, a constant string, and a constant value (0).
    Using this cycle seed, we generate a large amount of pre-images
    (currently 5_040_000). Then out of this range of
    [0 .. 5_040_000] pre-images, we reveal the last 1008 (`ValidatorCycle`),
    or in D terms `[$ - 1008 .. $]`.
    When the first enrollment runs out, we reveal the next last 1008,
    or in D terms `[$ - 2016 .. $ - 1008]`.
    When the cycle is expired, we re-generate a new cycle seed.
    By using this scheme, a node that would start from scratch with
    an already-enrolled key will be able to recover its
    cycle index by scanning the blockchain, and resume validating.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.EnrollmentManager;

import agora.common.ManagedDatabase;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.pool.Enrollment;
import agora.consensus.PreImage;
import agora.consensus.validation;
public import agora.consensus.state.ValidatorSet;
import agora.consensus.state.UTXOCache;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
// TODO: Remove (consensus shouldn't import `node`)
import agora.node.Config : ValidatorConfig;
import agora.utils.Log;
version (unittest) import agora.utils.Test;

import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.algorithm;
import std.range;
import std.file;
import std.path;
import std.string;

/*******************************************************************************

    Handle enrollment data and manage the validators set

*******************************************************************************/

public class EnrollmentManager
{
    /// Logger instance
    private Logger log;

    /// SQLite db instance
    private ManagedDatabase db;

    /// Node's key pair
    private KeyPair key_pair;

    /// Key used for enrollment which is actually an UTXO hash
    private Hash enroll_key;

    /// The final hash of the preimages at the beginning of the enrollment cycle
    private Hash commitment;

    /// How far away in the future a pre-image should be revealed.
    /// This is expressed in numbers of block
    private size_t max_preimage_reveal;

    /// Validator set managing validators' information such as Enrollment object
    /// enrolled height, and preimages.
    public ValidatorSet validator_set;  // FIXME: Made public to ease transition to raise this to ledger

    /// Enrollment pool managing enrollments waiting to be a validator
    public EnrollmentPool enroll_pool;

    /// Ditto
    private PreImageCycle cycle;

    /// Parameters for consensus-critical constants
    private immutable(ConsensusParams) params;

    /// Current height
    private Height current_height;

    /// Indices of Frozen UTXOs which are sorted by hashes of UTXOs
    private uint[Hash] utxo_key_to_idx;

    /// Enrollments of Frozen UTXOs by index
    private Enrollment[uint] utxo_idx_to_enroll;

    /***************************************************************************

        Constructor

        Params:
            stateDB = The state database, used by this and `ValidatorSet`
            cacheDB = The cache database, used by `EnrollmentPool`
            config = A valid `ValidatorConfig` instance
            params = the consensus-critical constants

    ***************************************************************************/

    public this (ManagedDatabase stateDB, ManagedDatabase cacheDB,
        ValidatorConfig config, immutable(ConsensusParams) params)
    {
        assert(params !is null);
        // TODO: Currently EnrollmentManager is instantiated by FullNode
        version (none) assert(config.key_pair !is KeyPair.init);

        this.log = Logger(__MODULE__);
        this.params = params;
        this.key_pair = config.key_pair;
        this.max_preimage_reveal = config.max_preimage_reveal;

        if (config.key_pair !is KeyPair.init)
        {
            // Initialize the cycle_seed from the config, prevents excessive
            // hashing in unittests
            if (config.cycle_seed !is Hash.init)
            {
                this.cycle = PreImageCycle(
                    config.cycle_seed, config.cycle_seed_height,
                    params.ValidatorCycle);
            }
            else
                this.cycle = PreImageCycle(key_pair.secret, params.ValidatorCycle);
        }
        else
            this.cycle = PreImageCycle.init;

        this.db = stateDB;
        this.validator_set = new ValidatorSet(stateDB, params);
        this.enroll_pool = new EnrollmentPool(cacheDB);


        // create the table for enrollment data for a node itself
        this.db.execute("CREATE TABLE IF NOT EXISTS node_enroll_data " ~
            "(key TEXT PRIMARY KEY, val TEXT NOT NULL)");

        // load enrollment key
        this.enroll_key = this.getEnrollmentKey();
    }

    /// Unittest-only constructor
    version (unittest) private this (
        KeyPair key_pair, immutable(ConsensusParams) params,
        PreImageCycle cycle = PreImageCycle.init)
    {
        ValidatorConfig config = ValidatorConfig(
            true, key_pair, CommonCycleSeed, Height(params.ValidatorCycle * 2 - 1));
        this(new ManagedDatabase(":memory:"), new ManagedDatabase(":memory:"),
             config, params);
    }

    /***************************************************************************

        Add a enrollment data to the enrollment pool

        Params:
            enroll = the enrollment data to add
            pubkey = the public key of the enrollment
            height = block height for enrollment
            finder = the delegate to find UTXOs with

        Returns:
            true if the enrollment data has been added to the enrollment pool

    ***************************************************************************/

    public bool addEnrollment (in Enrollment enroll,
        in PublicKey pubkey, in Height height, scope UTXOFinder finder)
        @safe nothrow
    {
        const Height enrolled = this.validator_set.getEnrolledHeight(height, enroll.utxo_key);

        // The first height at which the enrollment can be enrolled
        // is either the next block (if there is no prior enrollment)
        // or the height of the last enrollment + the validator cycle.
        // Bear in mind that "height of last enrollment + validator cycle"
        // is also the last block that the validator would be signing
        // if it wasn't re-enrolling. The height now may be after the end of the
        // cycle so we will use it in that case.
        const Height available = enrolled == ulong.max ?
            height : max(height, enrolled + this.params.ValidatorCycle);

        // There is a possibility that the validator is already enrolled,
        // using a different UTXO controlled by the same key pair.
        // This is only possible if we didn't already find an Enrollment,
        // as the Ledger would not accept this in the first place.
        if (enrolled == ulong.max && this.validator_set.hasPublicKey(height, pubkey))
        {
            log.warn("Rejected enrollment: an enrollment with the same " ~
                "key already exists, requested enrolment: {}, public key: {}",
                enroll, pubkey);
            return false;
        }

        auto result = this.enroll_pool.add(enroll, Height(available), finder,
                                    &this.validator_set.findRecentEnrollment);

        // Update the map of index to UTXO if the UTXO is already frozen
        if (result && this.current_height + 1 == Height(available) &&
            enroll.utxo_key in this.utxo_key_to_idx)
            this.utxo_idx_to_enroll[this.utxo_key_to_idx[enroll.utxo_key]] = enroll;

        return result;
    }

    /***************************************************************************

        Get the unregistered enrollments that can be validator in the next
        block based on the current block height.

        Params:
            height = block height intended for the enrollments
            peekUTXO = An `UTXOFinder` without replay-protection

        Returns:
            The unregistered enrollments data

    ***************************************************************************/

    public Enrollment[] getEnrollments (in Height height, scope UTXOFinder peekUTXO)
        @trusted nothrow
    {
        this.enroll_pool.removeExpired(height);
        Enrollment[] enrolls;
        auto pool_enrolls = this.enroll_pool.getEnrollments(height);
        foreach (enroll; pool_enrolls)
        {
            UTXO utxo;
            if (peekUTXO(enroll.utxo_key, utxo) &&
                this.isInvalidCandidateReason(enroll, utxo.output.address,
                                    height, peekUTXO) is null)
                enrolls ~= enroll;
        }
        return enrolls;
    }

    /***************************************************************************

        Add a validator to the validator set or update the enrolled height.

        This also gets and stores the information about this node's enrollment
        information which could be lost in abnormal situations.

        Params:
            enroll = Enrollment structure to add to the validator set
            pubkey = the public key of the enrollment
            height = enrolled blockheight
            finder = the delegate to find UTXOs with
            self_utxos = the UTXOs belonging to this node

        Returns:
            A string describing the error, or `null` on success

    ***************************************************************************/

    public string addValidator (in Enrollment enroll, in PublicKey pubkey,
        in Height height, scope UTXOFinder finder,
        in UTXO[Hash] self_utxos) @safe nothrow
    {
        this.enroll_pool.remove(enroll.utxo_key);

        if (auto r = this.validator_set.add(height, finder, enroll, pubkey))
            return r;

        if (enroll.utxo_key in self_utxos)
        {
            this.setEnrollmentKey(enroll.utxo_key);
            this.setCommitment(enroll.commitment);
        }

        return null;
    }

    /***************************************************************************

        Build an `Enrollment` using `makeEnrollment`, stores and returns it

        Params:
            utxo = The hash of the frozen UTXO used as a stake.
                   It must be owned by the private key this validator controls
                   (`key_pair` argument to constructor).
            height = The height that the created Enrollment can be available

        Returns:
            The `Enrollment` created by `makeEnrollment`

    ***************************************************************************/

    public Enrollment createEnrollment (in Hash utxo, in Height height)
        @safe nothrow
    {
        // X, final seed data and preimages of hashes
        const seed = this.cycle[height];
        const enroll = makeEnrollment(
            utxo, this.key_pair, seed,
            this.cycle.index);

        return enroll;
    }

    /***************************************************************************

        Build enrollment data for an arbitrary utxo + key combination

        This static function builds a valid, real-world 'enrollment' for any
        private key + utxo combination.  It can be used to generate realistic
        test data or specialized usage, e.g. by tools.

        To avoid code duplication and overhead, this function has two overload:
        the one accepting an offset will generate a new `PreImageCache`,
        which is quite expensive, and retrieve the hash to use based on the
        offset (defaults to `0`), and then forwards to the second overload
        that accepts a `Hash` and thus does not incur the cost of re-generating
        the pre-images.

        Params:
            utxo = `Hash` of a frozen UTXO value that can be used for enrollment
            key  = `KeyPair` that controls the `utxo`
            seed = commitment to use
            offset = The number of times this private key has enrolled before.
                     If `seed` is provided, this parameter is non-optional.

        Returns:
            An `Enrollment` referencing `utxo` signed with `key`

    ***************************************************************************/

    public static Enrollment makeEnrollment (
        in Hash utxo, in KeyPair key, in Hash seed, ulong offset = 0)
        @safe nothrow @nogc
    {
        Enrollment result = {
            utxo_key: utxo,
            commitment: seed,
        };

        // Generate signature noise
        const Pair noise = Pair.fromScalar(Scalar(hashMulti(key.secret, "consensus.signature.noise", offset)));

        // We're done, sign & return
        result.enroll_sig = Pair(key.secret, key.address).sign(noise, result);
        return result;
    }

    /// Ditto
    version (unittest) public static Enrollment makeEnrollment (
        in Hash utxo, in KeyPair key, in Height height)
        @trusted nothrow
    {
        // Generate the random seed to use
        auto cycle = PreImageCycle(key.secret);
        return makeEnrollment(utxo, key, cycle[height]);
    }

    /// Ditto
    version (unittest) public static Enrollment makeEnrollment (
        in Hash utxo, in KeyPair key, in Height height,
        in Hash cycle_seed, in Height seed_pos)
        @trusted nothrow
    {
        // Generate the random seed to use
        auto cycle = PreImageCycle(cycle_seed, seed_pos);
        return makeEnrollment(utxo, key, cycle[height]);
    }

    /***************************************************************************

        Get all the enrolled validator's UTXO keys.

        Params:
            utxo_keys = will contain the set of UTXO keys

        Returns:
            Return true if there was no error in getting the UTXO keys

    ***************************************************************************/

    public bool getEnrolledUTXOs (in Height height, out Hash[] keys) @safe nothrow
    {
        return this.validator_set.getEnrolledUTXOs(height, keys);
    }

    /***************************************************************************

        Check if an enrollment is a valid candidate for the proposed height

        This method is very similar to `addEnrollment`. This one deals with
        `ConsensusData` while `addEnrollment` is called when receiving an
        `Enrollment` from a client.

        Params:
            enroll = The enrollment of the target to be checked
            pubkey = public key of the enrollment
            height = the height of proposed block
            findUTXO = delegate to find the referenced unspent UTXOs with

        Returns:
            `null` if the enrollment can be a validator at the proposed height,
            otherwise a string explaining the reason it is invalid.

    ***************************************************************************/

    public string isInvalidCandidateReason (in Enrollment enroll,
        in PublicKey pubkey, in Height height, scope UTXOFinder findUTXO)
        @safe nothrow
    {
        const Height enrolled = this.validator_set.getEnrolledHeight(height, enroll.utxo_key);

        if (enrolled == ulong.max)
        {
            // Make sure there's no other enrollment with the same keypair
            if (this.validator_set.hasPublicKey(height + 1, pubkey))
                return "Enrollment: The same public key is already present";
        }
        else if (height < (enrolled + this.params.ValidatorCycle))
            return "Enrollment: Re-enrolling a validator too early";

        if (auto fail_reason = enroll.isInvalidReason(findUTXO, height,
                                &this.validator_set.findRecentEnrollment))
            return fail_reason;

        return null;
    }

    /***************************************************************************

        Get a pre-image for revelation

        Params:
            preimage = will contain the PreImageInfo if exists
            height = current block height

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool getNextPreimage (out PreImageInfo preimage, in Height height)
        @safe
    {
        const enrolled = this.validator_set.getEnrolledHeight(height, this.enroll_key);
        if (enrolled == ulong.max)
            return false;

        assert(height >= enrolled);
        const next_reveal = min(height + this.max_preimage_reveal,
                                enrolled + this.params.ValidatorCycle);

        if (next_reveal <= height)
            return false;

        preimage.utxo = this.enroll_key;
        preimage.height = Height(next_reveal);
        preimage.hash = this.cycle[next_reveal];
        return true;
    }

    /***************************************************************************

        Get validator's pre-image from the validator set.

        Params:
            utxo = The frozen UTXO used for enrollment.

        Returns:
            the PreImageInfo of the enrolled key if it exists,
            otherwise PreImageInfo.init

    ***************************************************************************/

    public PreImageInfo getValidatorPreimage (in Hash utxo)
        @safe nothrow
    {
        return this.validator_set.getPreimage(utxo);
    }

    /***************************************************************************

        Get validators' pre-image information

        Params:
            start_height = the starting enrolled height to begin retrieval from

        Returns:
            preimages' information of the validators

    ***************************************************************************/

    public PreImageInfo[] getValidatorPreimages (in Height start_height) @safe nothrow
    {
        return this.validator_set.getPreimages(start_height);
    }

    /***************************************************************************

        Get the pre-image hash for this validator

        Params:
            height = the block height of pre-image to be returned

        Returns:
            The preimage hash if found otherwise Hash.init

    ***************************************************************************/

    public Hash getOurPreimage (in Height height) @safe nothrow
    {
        return this.cycle[height];
    }

    /***************************************************************************

        Get the public key of node that is used for a enrollment

        Returns:
            Public key of a node

    ***************************************************************************/

    public PublicKey getEnrollmentPublicKey () @safe nothrow
    {
        return this.key_pair.address;
    }

    /// Returns: true if this validator is currently enrolled
    public bool isEnrolled (in Height height, scope UTXOFinder finder) nothrow @safe
    {
        this.enroll_key = this.getEnrolledUTXO(height, finder);
        return this.enroll_key != Hash.init;
    }

    /// Returns: The UTXO hash that this Validator is enrolled with or Hash.init if not enrolled
    public Hash getEnrolledUTXO (in Height height, scope UTXOFinder finder) nothrow @safe
    {
        Hash[] utxo_keys;
        assert(this.validator_set.getEnrolledUTXOs(height, utxo_keys));

        const PublicKey key = this.getEnrollmentPublicKey();
        foreach (utxo_key; utxo_keys)
        {
            UTXO value;
            if (!finder(utxo_key, value))
                assert(0, "UTXO for validator not found!");  // should never happen

            if (value.output.address == key)
                return utxo_key;
        }

        return Hash.init;
    }

    /***************************************************************************

        Get the commitment for the enrollment for this node

        If this node is not enrolled yet, the result will be empty. And if
        the database operation fails, this displays a log message and also
        returns `Hash.init`. Database errors mean that this node is not in
        a normal situation overall.

        Returns:
            the commitment hash

    ***************************************************************************/

    public Hash getCommitment () @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT val FROM node_enroll_data " ~
                "WHERE key = ?", "commitment");

            if (!results.empty)
                return Hash(results.oneValue!(string));
        }
        catch (Exception ex)
        {
            log.warn("ManagedDatabase operation error: {}", ex.msg);
        }

        return Hash.init;
    }

    /***************************************************************************

        Set the commitment for the enrollment for this node

        If saving a commitment fails, this displays a log messages and just
        returns. The `enroll_key` stores the value anyway and it can be restored
        from the catch-up process later. If the database or serialization
        operation fails, it means that node is not in normal situation overall.

        Params:
            commitment = the commitment hash

    ***************************************************************************/

    private void setCommitment (in Hash commitment) @trusted nothrow
    {
        this.commitment = commitment;

        try
        {
            this.db.execute("REPLACE into node_enroll_data " ~
                "(key, val) VALUES (?, ?)", "commitment", commitment);
        }
        catch (Exception ex)
        {
            log.warn("ManagedDatabase operation error {}", ex.msg);
        }
    }

    /***************************************************************************

        Get the key for the enrollment for this node

        If this node is not enrolled yet, the result will be empty. And if
        the database operation fails, this displays a log message and also
        returns `Hash.init`. Database errors mean that this node is not in
        a normal situation overall.

        Returns:
            the key for the enrollment

    ***************************************************************************/

    public Hash getEnrollmentKey () @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT val FROM node_enroll_data " ~
                "WHERE key = ?", "utxo");

            if (!results.empty)
                return Hash(results.oneValue!(string));
        }
        catch (Exception ex)
        {
            log.warn("ManagedDatabase operation error: {}", ex.msg);
        }

        return Hash.init;
    }

    /***************************************************************************

        Set the UTXO for the enrollment for this node

        If saving to the database fails, this displays a log messages and just
        returns. The `enroll_key` stores the value anyway and it can be restored
        from the catch-up process later. If the database or serialization
        operation fails, it means that node is not in normal situation overall.

        Params:
            utxo = the key for the enrollment

    ***************************************************************************/

    private void setEnrollmentKey (in Hash utxo) @trusted nothrow
    {
        this.enroll_key = utxo;

        try
        {
            this.db.execute("REPLACE into node_enroll_data " ~
                "(key, val) VALUES (?, ?)", "utxo", enroll_key);
        }
        catch (Exception ex)
        {
            log.warn("ManagedDatabase operation error {}", ex.msg);
        }
    }

    /***************************************************************************

        Reset all the information about an enrollment of this node

    ***************************************************************************/

    private void resetNodeEnrollment () @safe nothrow
    {
        this.enroll_key = Hash.init;
    }

    /***************************************************************************

        Get the enrollment with the key

        Params:
            enroll_hash = key for the enrollment which has the frozen UTXO

        Returns:
            Return an `Enrollment` if the enrollment is found, otherwise
                `Enrollment.init`

    ***************************************************************************/

    public Enrollment getEnrollment (in Hash enroll_hash) @trusted
    {
        return this.enroll_pool.getEnrollment(enroll_hash);
    }

    /***************************************************************************

        Returns: A delegate to query past Enrollments

    ***************************************************************************/

    public EnrollmentFinder getEnrollmentFinder () @trusted nothrow
    {
        return &this.validator_set.findRecentEnrollment;
    }

    /***************************************************************************

        Undate the map of frozen UTXOs

        Params:
            height = the current block height
            utxos =  the frozen UTXOs from the utxo set

    ***************************************************************************/

    public void updateFrozenUTXO (in Height height, in UTXO[Hash] utxos)
        @trusted nothrow
    {
        uint idx = 0;
        this.current_height = height;
        this.utxo_key_to_idx.clear();
        this.utxo_idx_to_enroll.clear();

        utxos.keys.sort.each!((key) {
            this.utxo_key_to_idx[key] = idx;
            this.utxo_idx_to_enroll[idx] = this.enroll_pool.getEnrollment(key, height);
            idx++;
        });
    }

    /***************************************************************************

        Get the indices of enrollments of the node and future ones

        Params:
            height = the height intended for the enrollments
            enroll_set = the indices of enrollments of the node

    ***************************************************************************/

    public void getEnrollmentIndices (Height height, ref Set!uint enroll_set)
        @safe nothrow
    {
        try
        {
            foreach (idx, value; this.utxo_idx_to_enroll)
            {
                if (value != Enrollment.init)
                    enroll_set.put(idx);
            }
        }
        catch (Exception ex)
        {
            log.warn("Caught Exception while calling getEnrolmentIndices {}", ex);
        }
    }

    /***************************************************************************

        Get all the enrollments excluding the unwanted enrollments

        Params:
            height = the height intended for the enrollments
            exclude_enrolls = the indices of unwanted enrollments

        Returns:
            The enrollments excluding the unwanted and `future` ones

    ***************************************************************************/

    public Enrollment[] getExclusiveEnrollments (in Height height,
        Set!uint exclude_enrolls) @safe nothrow
    {
        Enrollment[] enrolls;
        Set!uint enroll_set;
        getEnrollmentIndices(height, enroll_set);

        exclude_enrolls.each!(idx => enroll_set.remove(idx));
        foreach (idx; enroll_set)
            enrolls ~= utxo_idx_to_enroll[idx];

        return enrolls;
    }
}

/// tests for member functions of EnrollmentManager
unittest
{
    import agora.consensus.data.Transaction;
    import std.algorithm;
    import std.range;

    scope utxo_set = new TestUTXOSet;
    Hash[] utxo_hashes;

    auto gen_key_pair = WK.Keys.Genesis;
    KeyPair key_pair = KeyPair.random();

    // genesisSpendable returns 8 outputs
    auto pairs = iota(8).map!(idx => WK.Keys[idx]).array;
    genesisSpendable()
        .enumerate
        .map!(tup => tup.value
            .refund(pairs[tup.index].address)
            .sign(OutputType.Freeze))
        .each!((tx) {
            utxo_set.put(tx);
            utxo_hashes ~= UTXO.getHash(tx.hashFull(), 0);
        });

    auto utxos = utxo_set.storage;

    // create an EnrollmentManager object
    auto params = new immutable(ConsensusParams)();
    auto man = new EnrollmentManager(key_pair, params);
    // Useful constant
    const EnrollAt1 = Height(1);

    // check the return value of `getEnrollmentPublicKey`
    assert(key_pair.address == man.getEnrollmentPublicKey());

    // create and add the first Enrollment object
    auto utxo_hash = utxo_hashes[0];

    // The UTXO belongs to key_pair but we sign with genesis key pair and check it fails
    Enrollment fail_enroll =
        EnrollmentManager.makeEnrollment(utxo_hash, gen_key_pair, EnrollAt1,
        CommonCycleSeed, Height(params.ValidatorCycle * 2 - 1));
    assert(!man.addEnrollment(fail_enroll, gen_key_pair.address, EnrollAt1,
            utxo_set.getUTXOFinder()));

    Enrollment[] enrolls_before = man.getEnrollments(EnrollAt1, &utxo_set.peekUTXO);
    assert(enrolls_before.length == 0);

    Enrollment[] ordered_enrollments;
    foreach (idx, kp; pairs[0 .. 3])
    {
        auto enroll = EnrollmentManager.makeEnrollment(utxo_hashes[idx], kp,
            EnrollAt1, NodeCycleSeeds[idx], Height(params.ValidatorCycle * 2 - 1));

        assert(man.addEnrollment(enroll, kp.address, EnrollAt1, &utxo_set.peekUTXO));
        assert(man.enroll_pool.count() == idx + 1);
        ordered_enrollments ~= enroll;
    }

    Enrollment[] enrolls = man.getEnrollments(EnrollAt1, &utxo_set.peekUTXO);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // get a stored Enrollment object
    Enrollment stored_enroll;
    assert((stored_enroll = man.getEnrollment(utxo_hashes[1])) !=
        Enrollment.init);
    assert(stored_enroll == ordered_enrollments[1]);

    // remove an Enrollment object
    man.enroll_pool.remove(utxo_hashes[1]);
    assert(man.enroll_pool.count() == 2);

    // test for getEnrollment with removed enrollment
    assert(man.getEnrollment(utxo_hashes[1]) == Enrollment.init);

    // test for enrollment block height update
    const EnrollAt9 = Height(9);
    assert(man.validator_set.countActive(EnrollAt9 + 1) == 0);
    assert(man.validator_set.getEnrolledHeight(EnrollAt9, utxo_hash) == ulong.max);
    // Add removed enrollment to the pool with the new height
    assert(man.addEnrollment(
            EnrollmentManager.makeEnrollment(utxo_hashes[1], pairs[1], EnrollAt9,
                CommonCycleSeed, Height(params.ValidatorCycle * 2 - 1)),
            pairs[1].address, EnrollAt9, &utxo_set.peekUTXO));
    // The expired enrollments in the pool from height 1 are cleared on this next call
    // to get enrollments at a higher height. We do have an enrollment at height 9
    assert(man.getEnrollments(EnrollAt9, &utxo_set.peekUTXO).length == 1);
    assert(man.addValidator(
               ordered_enrollments[1], pairs[0].address, EnrollAt9, &utxo_set.peekUTXO, utxos)
           is null);
    assert(man.validator_set.getEnrolledHeight(EnrollAt9 + 1, ordered_enrollments[1].utxo_key) == EnrollAt9);
    // One Enrollment was moved to validator set
    assert(man.validator_set.countActive(EnrollAt9 + 1) == 1);
    // Check last block of cycle is still active
    assert(man.validator_set.countActive(EnrollAt9 + params.ValidatorCycle) == 1);
    // Check block in next cycle is no longer active
    assert(man.validator_set.countActive(EnrollAt9 + params.ValidatorCycle + 1) == 0);
    // Pool should now be empty
    assert(man.enroll_pool.count() == 0);

    assert(man.getEnrollments(EnrollAt9, &utxo_set.peekUTXO).length == 0);

    // clear up all validators
    man.validator_set.removeAll();

    // Adding enrollments in reverse order of utxo order to show it still works
    const EnrollAt10 = Height(10);
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (idx, ordered_enroll; ordered_enrollments)
        assert(man.addEnrollment(ordered_enroll, pairs[idx].address, EnrollAt10,
            &utxo_set.peekUTXO));
    enrolls = man.getEnrollments(EnrollAt10, &utxo_set.peekUTXO);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // A validator is enrolled at the height of 10.
    PreImageInfo preimage;
    assert(man.addValidator(ordered_enrollments[0], WK.Keys[0].address, EnrollAt10,
            &utxo_set.peekUTXO, utxos) is null);
    assert(man.getNextPreimage(preimage, EnrollAt10));
    assert(preimage.height >= EnrollAt10);
    assert(preimage.hash == man.cycle[preimage.height]);

    // test for getting validators' UTXO keys
    Hash[] keys;

    // validator A with the `utxo_hash` and the enrolled height of 10.
    // validator B with the 'utxo_hash2' and the enrolled height of 11.
    // validator C with the 'utxo_hash3' and no enrolled height.
    assert(man.addValidator(ordered_enrollments[1], WK.Keys[1].address, Height(11),
            &utxo_set.peekUTXO, utxos) is null);
    assert(man.validator_set.countActive(Height(12)) == 2);
    assert(man.validator_set.getEnrolledUTXOs(Height(12), keys));
    assert(keys.length == 2);

    // set an enrolled height for validator C
    // set the block height to 1019, which means validator B is expired.
    // there is only one validator in the middle of 1020th block being made.
    assert(man.addValidator(
               ordered_enrollments[2], WK.Keys[2].address, Height(12), &utxo_set.peekUTXO, utxos)
           is null);
    assert(man.validator_set.countActive(Height(params.ValidatorCycle + 12)) == 1);
    assert(man.validator_set.getEnrolledUTXOs(Height(params.ValidatorCycle + 12), keys));
    assert(keys.length == 1);
    assert(keys[0] == ordered_enrollments[2].utxo_key);
}

/// tests for `ValidatorSet.countActive
unittest
{
    import agora.consensus.data.Transaction;
    import std.range;

    scope utxo_set = new TestUTXOSet;
    Hash[] utxo_hashes;

    KeyPair key_pair = KeyPair.random();

    // genesisSpendable returns 8 outputs
    auto pairs = iota(8).map!(idx => WK.Keys[idx]).array;
    genesisSpendable()
        .enumerate
        .map!(tup => tup.value
            .refund(pairs[tup.index].address)
            .sign(OutputType.Freeze))
        .each!((tx) {
            utxo_set.put(tx);
            utxo_hashes ~= UTXO.getHash(tx.hashFull(), 0);
        });
    auto utxos = utxo_set.storage;

    // create an EnrollmentManager object
    auto params = new immutable(ConsensusParams)(20);
    auto man = new EnrollmentManager(key_pair, params);

    Height height = Height(2);

    Enrollment[] enrollments;
    foreach (idx, kp; pairs[0 .. 3])
    {
        enrollments ~= EnrollmentManager.makeEnrollment(
            utxo_hashes[idx], kp, height,
            NodeCycleSeeds[idx], Height(params.ValidatorCycle * 2 - 1));
    }

    // create and add the first Enrollment object
    assert(man.addEnrollment(enrollments[0], WK.Keys[0].address, height,
            utxo_set.getUTXOFinder()));
    assert(man.validator_set.countActive(height + 1) == 0);  // not active yet

    assert(man.addValidator(enrollments[0], WK.Keys[0].address, height, &utxo_set.peekUTXO,
            utxos) is null);
    assert(man.validator_set.countActive(height + 1) == 1);  // updated

    height = 3;

    // create and add the second Enrollment object
    assert(man.addEnrollment(enrollments[1], WK.Keys[1].address, height,
            utxo_set.getUTXOFinder()));
    assert(man.validator_set.countActive(height + 1) == 1);  // not active yet

    assert(man.addValidator(enrollments[1], WK.Keys[1].address, height, &utxo_set.peekUTXO,
            utxos) is null);
    assert(man.validator_set.countActive(height + 1) == 2);  // updated

    height = 4;

    // create and add the third Enrollment object
    assert(man.addEnrollment(enrollments[2], WK.Keys[2].address, height,
            utxo_set.getUTXOFinder()));
    assert(man.validator_set.countActive(height + 1) == 2);  // not active yet

    assert(man.addValidator(enrollments[2], WK.Keys[2].address, height, &utxo_set.peekUTXO,
            utxos) is null);
    assert(man.validator_set.countActive(height + 1) == 3);  // updated

    height = 5;    // valid block height : 0 <= H < 20
    assert(man.validator_set.countActive(height + 1) == 3);  // not cleared yet

    height = Height(1 + params.ValidatorCycle); // valid block height : 2 <= H < 22
    assert(man.validator_set.countActive(height + 1) == 3);

    height = Height(2 + params.ValidatorCycle); // valid block height : 3 <= H < 23
    assert(man.validator_set.countActive(height + 1) == 2);

    height = Height(3 + params.ValidatorCycle); // valid block height : 4 <= H < 24
    assert(man.validator_set.countActive(height + 1) == 1);

    height = Height(4 + params.ValidatorCycle); // valid block height : 5 <= H < 25
    assert(man.validator_set.countActive(height + 1) == 0);
}

// https://github.com/bosagora/agora/pull/1010#issuecomment-654149650
unittest
{
    // Irrelevant for this test, the seed is only derived from the private key
    // and the offset (which is 0 in both cases)
    Hash utxo;
    const validator_cycle = 20;
    auto e1 = EnrollmentManager.makeEnrollment(utxo, WK.Keys.A, Height(1),
        NodeCycleSeeds[0], Height(validator_cycle * 2 - 1));
    auto e2 = EnrollmentManager.makeEnrollment(utxo, WK.Keys.C, Height(1),
        NodeCycleSeeds[1], Height(validator_cycle * 2 - 1));
    assert(e1.commitment != e2.commitment);
}

/// Test for the height when the enrollment will be available
unittest
{
    import agora.consensus.data.Transaction;
    import agora.consensus.state.UTXOSet;

    // create an EnrollmentManager
    const validator_cycle = 20;
    KeyPair key_pair = KeyPair.random();
    scope man = new EnrollmentManager(key_pair,
        new immutable(ConsensusParams)(validator_cycle));

    scope utxo_set = new UTXOSet(man.db);
    genesisSpendable().map!(txb => txb.refund(key_pair.address).sign(OutputType.Freeze))
        .each!(tx => utxo_set.updateUTXOCache(tx, Height(1), man.params.CommonsBudgetAddress));
    auto utxos = utxo_set.getUTXOs(key_pair.address);

    // create and add the first enrollment
    Enrollment[] enrolls;
    const firstEnrolledAt10 = Height(10);
    auto enroll = man.createEnrollment(utxos.keys[0], firstEnrolledAt10);
    assert(man.addEnrollment(enroll, key_pair.address, firstEnrolledAt10,
            utxo_set.getUTXOFinder()));

    // if the current height is smaller than the available height,
    // we can get no enrollment
    enrolls = man.getEnrollments(Height(firstEnrolledAt10 - 1), &utxo_set.peekUTXO);
    assert(enrolls.length == 0);

    // if the current height is equal to the available height we can get enrollments
    enrolls = man.getEnrollments(firstEnrolledAt10, &utxo_set.peekUTXO);
    assert(enrolls.length == 1);

    // if the current height is more than the available height we don't
    enrolls = man.getEnrollments(firstEnrolledAt10 + 1, &utxo_set.peekUTXO);
    assert(enrolls.length == 0);

    // make the enrollment a validator
    man.addValidator(enroll, key_pair.address, firstEnrolledAt10, &utxo_set.peekUTXO, utxos);
    enrolls = man.getEnrollments(firstEnrolledAt10, &utxo_set.peekUTXO);
    assert(enrolls.length == 0);

    // add the enrollment that is already a validator, and check if
    // the enrollment can be nominated at the height before the cycle end
    auto re_enroll = man.createEnrollment(utxos.keys[0], firstEnrolledAt10 + validator_cycle);
    assert(man.addEnrollment(re_enroll, key_pair.address, firstEnrolledAt10 + validator_cycle, &utxo_set.peekUTXO));

    // Can only enroll at exact height as the preimage is for that height
    assert(man.getEnrollments(Height(firstEnrolledAt10 + validator_cycle - 1), &utxo_set.peekUTXO).length == 0);
    enrolls = man.getEnrollments(firstEnrolledAt10 + validator_cycle, &utxo_set.peekUTXO);
    assert(enrolls.length == 1);
    // We do this test after as the expired will be remved from the pool
    assert(man.getEnrollments(firstEnrolledAt10 + validator_cycle + 1, &utxo_set.peekUTXO).length == 0);

    // make the enrollment a validator again
    assert(man.addValidator(enroll, key_pair.address, firstEnrolledAt10 + validator_cycle,
        &utxo_set.peekUTXO, utxos));
    // Enrollment now gone from the pool
    assert(man.getEnrollments(firstEnrolledAt10 + validator_cycle, &utxo_set.peekUTXO).length == 0);
}

// Tests for get/set a enrollment key
unittest
{
    import agora.consensus.data.Transaction;

    auto utxo_set = new TestUTXOSet;
    genesisSpendable()
        .map!(txb => txb.refund(WK.Keys.A.address).sign(OutputType.Freeze))
        .each!(tx => utxo_set.put(tx));

    auto params = new immutable(ConsensusParams)(10);
    auto man = new EnrollmentManager(WK.Keys.A, params);

    assert(utxo_set.length == 8);
    man.setEnrollmentKey(utxo_set.keys[3]);
    assert(man.getEnrollmentKey()[] == utxo_set.keys[3][]);
    assert(man.getEnrollmentKey()[] != utxo_set.keys[0][]);
}

/// tests for adding enrollments from the same public key
unittest
{
    import agora.consensus.data.Transaction;
    import std.algorithm;

    scope utxo_set = new TestUTXOSet;
    KeyPair key_pair = KeyPair.random();

    genesisSpendable().map!(txb => txb.refund(key_pair.address).sign(OutputType.Freeze))
        .each!(tx => utxo_set.put(tx));
    Hash[] utxo_hashes = utxo_set.keys;

    // create an EnrollmentManager object
    auto params = new immutable(ConsensusParams)(10);
    auto man = new EnrollmentManager(key_pair, params);

    // check the return value of `getEnrollmentPublicKey`
    assert(key_pair.address == man.getEnrollmentPublicKey());

    // first enrollment succeeds
    auto enroll = man.createEnrollment(utxo_hashes[0], Height(1));
    assert(man.addEnrollment(enroll, key_pair.address, Height(1),
            &utxo_set.peekUTXO));

    // adding first enrollment succeeds
    assert(man.addValidator(enroll, key_pair.address, Height(1),
            &utxo_set.peekUTXO, utxo_set.storage) is null);

    // second enrollment with the same public key fails
    auto enroll2 = man.createEnrollment(utxo_hashes[1], Height(1));
    assert(!man.addEnrollment(enroll2, key_pair.address, Height(1),
            &utxo_set.peekUTXO));

    // adding second enrollment with the same public key fails
    assert(man.addValidator(enroll2, key_pair.address, Height(1),
            &utxo_set.peekUTXO, utxo_set.storage) !is null);
}

unittest
{
    import agora.consensus.data.Transaction;
    import agora.consensus.state.UTXOSet;
    import std.algorithm;

    // create an EnrollmentManager object
    KeyPair key_pair = KeyPair.random();
    auto params = new immutable(ConsensusParams)();
    auto man = new EnrollmentManager(key_pair, params);

    scope utxo_set = new UTXOSet(man.db);
    genesisSpendable().map!(txb => txb.refund(key_pair.address).sign(OutputType.Freeze))
        .each!(tx => utxo_set.updateUTXOCache(tx, Height(1), man.params.CommonsBudgetAddress));
    auto utxos = utxo_set.getUTXOs(key_pair.address);
    Hash[] utxo_hashes = utxos.keys;

    auto findEnrollment = man.getEnrollmentFinder();

    auto genesis_enroll = man.createEnrollment(utxo_hashes[0], Height(0));
    assert(man.addEnrollment(genesis_enroll, key_pair.address, Height(0),
                                                        &utxo_set.peekUTXO));
    EnrollmentState state;
    assert(!findEnrollment(genesis_enroll.utxo_key, state));
    assert(man.addValidator(genesis_enroll, key_pair.address, Height(0),
                                &utxo_set.peekUTXO, utxos) is null);
    assert(man.validator_set.countActive(Height(1)) == 1);
    assert(findEnrollment(genesis_enroll.utxo_key, state));
    assert(state.enrolled_height == Height(0));
    assert(state.preimage.hash == genesis_enroll.commitment);
    assert(state.preimage.height == 0);

    PreImageInfo preimage;
    assert(man.getNextPreimage(preimage, Height(params.ValidatorCycle / 2)));
    assert(man.validator_set.addPreimage(preimage));
    assert(findEnrollment(genesis_enroll.utxo_key, state));
    assert(state.preimage.hash == preimage.hash);
    assert(state.preimage.height == preimage.height);

    // First 2 iterations should fail because commitment is wrong
    foreach (offset; [-1, +1, 0])
    {
        auto enroll = man.createEnrollment(utxo_hashes[0],
            Height(params.ValidatorCycle + offset));
        assert((offset == 0) == man.addEnrollment(enroll, key_pair.address,
            Height(params.ValidatorCycle), &utxo_set.peekUTXO));
    }

    Enrollment[] enrolls;
    // Enrollment should only be valid for one block height
    foreach (offset; [-2, -1, 0])
    {
        enrolls = man.getEnrollments(Height(params.ValidatorCycle + offset), &utxo_set.peekUTXO);
        assert(enrolls.length == (offset == 0 ? 1 : 0));
    }

    assert(findEnrollment(genesis_enroll.utxo_key, state));
    assert(state.enrolled_height == Height(0));
    assert(state.preimage.hash == preimage.hash);
    assert(state.preimage.height == preimage.height);

    assert(man.validator_set.countActive(Height(params.ValidatorCycle + 1)) == 0);
    assert(man.addValidator(enrolls[0], key_pair.address,
            Height(params.ValidatorCycle), &utxo_set.peekUTXO,
                                                utxos) is null);
    assert(man.validator_set.countActive(Height(params.ValidatorCycle + 1)) == 1);
}

// Test for adding and removing validators
unittest
{
    import agora.consensus.data.Transaction;
    import std.array;
    import std.range;

    Hash[] utxos;
    auto utxo_set = new TestUTXOSet;
    genesisSpendable()
        .enumerate.map!(tup => tup.value
            .refund(WK.Keys[tup.index].address).sign(OutputType.Freeze))
        .each!((tx) {
            utxo_set.put(tx);
            utxos ~= UTXO.getHash(tx.hashFull(), 0);
        });

    auto params = new immutable(ConsensusParams)(20);
    auto man = new EnrollmentManager(WK.Keys.A, params);
    auto e1 = EnrollmentManager.makeEnrollment(
        utxos[0], WK.Keys.A, Height(1),
        NodeCycleSeeds[0], Height(params.ValidatorCycle * 2 - 1));
    auto e2 = EnrollmentManager.makeEnrollment(
        utxos[1], WK.Keys.C, Height(1),
        NodeCycleSeeds[1], Height(params.ValidatorCycle * 2 - 1),);

    assert(man.addEnrollment(e1, WK.Keys.A.address, Height(1), &utxo_set.peekUTXO));
    assert(man.addEnrollment(e2, WK.Keys.C.address, Height(1), &utxo_set.peekUTXO));

    assert(man.addValidator(e1, WK.Keys.A.address, Height(1), &utxo_set.peekUTXO,
        utxo_set.storage) is null);
    assert(man.addValidator(e2, WK.Keys.C.address, Height(1), &utxo_set.peekUTXO,
        utxo_set.storage) is null);

    assert(man.validator_set.countActive(Height(2)) == 2);
    man.validator_set.slashValidator(utxos[0], Height(2));
    assert(man.validator_set.countActive(Height(2)) == 1);
}
