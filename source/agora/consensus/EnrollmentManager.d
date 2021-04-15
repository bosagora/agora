/*******************************************************************************

    Manages this node's Enrollment, the `ValidatorSet`, and `EnrollmentPool`

    This class currently has 3 responsibilities:
    - It's a bridge to the `ValidatorSet`, where the list of currently active
      validators is stored;
    - It stores `Enrollment`s that are not yet part of the validator set;
    - Most importantly, if this node is a validator, it manages this node's
      enrollement data, including pre-images.

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
    of the private key, a constant string, and a nonce, starting from 0.
    Using this cycle seed, we generate a large amount of pre-images
    (currently enough for 100 enrollments). Then out of this range of
    [0 .. 100_800] pre-images, we reveal the last 1008 (`ValidatorCycle`),
    or in D terms `[$ - 1008 .. $]`.
    When the first enrollment runs out, we reveal the next last 1008,
    or in D terms `[$ - 2016 .. $ - 1008]`.
    When the cycle is expired, we re-generate a new cycle seed after
    increasing the nonce.
    By using this scheme, a node that would start from scratch with
    an already-enrolled key will be able to recover its nonce and
    cycle index by scanning the blockchain, and resume validating.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.EnrollmentManager;

import agora.common.ManagedDatabase;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.EnrollmentPool;
import agora.consensus.PreImage;
import agora.consensus.validation;
public import agora.consensus.state.ValidatorSet;
import agora.consensus.state.UTXOCache;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.utils.Log;
version (unittest) import agora.utils.Test;

import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.algorithm;
import std.file;
import std.path;
import std.string;

/*******************************************************************************

    Handle enrollment data and manage the validators set

*******************************************************************************/

public class EnrollmentManager
{
    /// The period for revealing a preimage
    /// It is an hour interval if a block is made in every 10 minutes
    public static immutable uint PreimageRevealPeriod = 6;

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

    /// Validator set managing validators' information such as Enrollment object
    /// enrolled height, and preimages.
    public ValidatorSet validator_set;  // FIXME: Made public to ease transition to raise this to ledger

    /// Enrollment pool managing enrollments waiting to be a validator
    private EnrollmentPool enroll_pool;

    /// Ditto
    private PreImageCycle cycle;

    /// Parameters for consensus-critical constants
    private immutable(ConsensusParams) params;

    /// In order to support collecting signatures *after* a block is
    /// externalized we must know the key index for the block header bitmask
    /// for the active validator set *for that block height*.
    /// Once a block is externalized the validator set might change
    /// - so we store for each block height (can be optimised later) the maps
    ///   for key_to_index and index_to_key

    /// used for setting the signature bitmask during signature collection
    private ulong[PublicKey][Height] key_to_index;

    /// used for validating the signature
    private PublicKey[ulong][Height] index_to_key;

    /***************************************************************************

        Constructor

        Params:
            stateDB = The state database, used by this and `ValidatorSet`
            cacheDB = The cache database, used by `EnrollmentPool`
            key_pair = the keypair of the owner node
            params = the consensus-critical constants

    ***************************************************************************/

    public this (ManagedDatabase stateDB, ManagedDatabase cacheDB,
                 KeyPair key_pair, immutable(ConsensusParams) params)
    {
        this.log = Logger(__MODULE__);
        assert(params !is null);
        this.params = params;
        this.key_pair = key_pair;
        this.cycle = PreImageCycle(key_pair.secret, params.ValidatorCycle);

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
        KeyPair key_pair, immutable(ConsensusParams) params)
    {
        this(new ManagedDatabase(":memory:"), new ManagedDatabase(":memory:"),
             key_pair, params);
    }


    /***************************************************************************

        Update the validator key index maps

        Params:
            height = the block height the validators will next sign

    ***************************************************************************/

    public void updateValidatorIndexMaps (in Height height) @safe
    {
        PublicKey[] keys;
        if (!this.getActiveValidatorPublicKeys(keys, height))
            assert(0, "Database failure on fetching Validator Public Keys");

        if (keys.length == 0)
            log.error("No Active validator public keys at height {}", height);

        log.trace("Update validator lookup maps at height {}: {}", height, keys);
        foreach (idx, key; keys)
        {
            this.key_to_index[height][key] = idx;
            this.index_to_key[height][idx] = key;
        }
    }

    /***************************************************************************

        Params:
            height = the height at which to look up the mapping for

        Returns:
            the count of validators at this enrollment height

    ***************************************************************************/

    public size_t getCountOfValidators (in Height height) const nothrow @safe
    {
        return height !in this.key_to_index ? 0
            : this.index_to_key[height].length;
    }

    /***************************************************************************

        Params:
            height = the height at which to look up the mapping for
            K = the Key for which to find the bitfield index to use

        Returns:
            the index of this key, or ulong.max if none was found

    ***************************************************************************/

    public ulong getIndexOfValidator (in Height height, in PublicKey K) nothrow @safe
    {
        if (height !in this.key_to_index)
        {
            log.warn("No keys at this height {}", height);
            return ulong.max;
        }
        if (K !in this.key_to_index[height])
        {
            log.warn("Public key {} not found in keys at this height {}", K, height);
            return ulong.max;
        }
        return this.key_to_index[height][K];
    }

    /***************************************************************************

        Params:
            height = the height at which to look up the mapping for
            index = the index for which to find the associated Key

        Returns:
            the key belonging to this index,
            or `PublicKey.init` if none was found

    ***************************************************************************/

    public PublicKey getValidatorAtIndex (in Height height, in ulong index)
        const @safe nothrow
    {
        if (height !in this.index_to_key || index !in this.index_to_key[height])
            return PublicKey.init;
        else
            return this.index_to_key[height][index];
    }

    /***************************************************************************

        In validatorSet DB, return the enrolled block height.

        Params:
            enroll_hash = key for an enrollment block height

        Returns:
            the enrolled block height, or `ulong.max` if no matching key exists

    ***************************************************************************/

    public Height getEnrolledHeight (in Hash enroll_hash)
        @trusted nothrow
    {
        return this.validator_set.getEnrolledHeight(enroll_hash);
    }

    /***************************************************************************

        Add a enrollment data to the enrollment pool

        Params:
            enroll = the enrollment data to add
            pubkey = the public key of the enrollment
            height = current block height
            finder = the delegate to find UTXOs with

        Returns:
            true if the enrollment data has been added to the enrollment pool

    ***************************************************************************/

    public bool addEnrollment (in Enrollment enroll,
        in PublicKey pubkey, in Height height, scope UTXOFinder finder)
        @safe nothrow
    {
        const Height enrolled = this.getEnrolledHeight(enroll.utxo_key);

        // The first height at which the enrollment can be enrolled
        // is either the next block (if there is no prior enrollment)
        // or the height of the last enrollment + the validator cycle.
        // Bear in mind that "height of last enrollment + validator cycle"
        // is also the last block that the validator would be signing
        // if it wasn't re-enrolling.
        const Height available = enrolled == ulong.max ?
            height + 1:
            enrolled + this.params.ValidatorCycle;

        // There is a possibility that the validator is already enrolled,
        // using a different UTXO controlled by the same key pair.
        // This is only possible if we didn't already find an Enrollment,
        // as the Ledger would not accept this in the first place.
        if (enrolled == ulong.max && this.validator_set.hasPublicKey(pubkey))
        {
            log.warn("Rejected enrollment: an enrollment with the same " ~
                "key already exists, requested enrolment: {}, public key: {}",
                enroll, pubkey);
            return false;
        }

        return this.enroll_pool.add(enroll, Height(available), finder,
                                    &this.validator_set.findRecentEnrollment);
    }

    /***************************************************************************

        Get the unregistered enrollments that can be validator in the next
        block based on the current block height.

        Params:
            height = current block height
            peekUTXO = An `UTXOFinder` without replay-protection

        Returns:
            The unregistered enrollments data

    ***************************************************************************/

    public Enrollment[] getEnrollments (in Height height, scope UTXOFinder peekUTXO)
        @trusted nothrow
    {
        Enrollment[] enrolls;
        auto pool_enrolls = this.enroll_pool.getEnrollments(height + 1);
        foreach (enroll; pool_enrolls)
        {
            UTXO utxo;
            if (peekUTXO(enroll.utxo_key, utxo) &&
                this.isInvalidCandidateReason(enroll, utxo.output.address,
                                    height + 1, peekUTXO) is null)
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
            this.params.ValidatorCycle, this.cycle.index);

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
            cycle_length = The cycle length to use (see `ConsensusParams`)
            offset = The number of times this private key has enrolled before.
                     If `seed` is provided, this parameter is non-optional.

        Returns:
            An `Enrollment` refencing `utxo` signed with `key`

    ***************************************************************************/

    public static Enrollment makeEnrollment (
        in Hash utxo, in KeyPair key, in Hash seed, uint cycle_length, ulong offset)
        @safe nothrow @nogc
    {
        Enrollment result = {
            utxo_key: utxo,
            cycle_length: cycle_length,
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
        in Hash utxo, in KeyPair key, uint cycle_length, uint offset = 0)
        @trusted nothrow
    {
        // Generate the commitment to use
        auto cache = PreImageCache(PreImageCycle.NumberOfCycles, cycle_length);
        assert(offset < cache.length);
        cache.reset(hashMulti(key.secret, "consensus.preimages", offset));

        return makeEnrollment(utxo, key, cache[$ - offset - 1], cycle_length, offset);
    }

    /***************************************************************************

        Retrieves the R from the (R, s) of the signature in the commitment
        for the associated public key

        Params:
            key = the public key to look up
            height = height of block the R will be used to check the signature

        Returns:
            The `R` used in the signature of the Enrollment,
            or `Point.init` if one is not found

    ***************************************************************************/

    public Point getCommitmentNonce (in PublicKey key, in Height height)
        @trusted nothrow
    {
        return this.validator_set.getCommitmentNonce(key, height);
    }

    /***************************************************************************

        Get the r that was used to sign the enrollment of this validator node

        Params:
            height = height of block that r will sign
        Returns:
            The initial `r` used when signing the Enrollment

    ***************************************************************************/

    public Scalar getCommitmentNonceScalar (in Height height) const @safe nothrow
    {
        ulong index = ulong((height - 1) / this.cycle.preimages.length());
        return Scalar(hashMulti(this.key_pair.secret, "consensus.signature.noise", index));
    }

    /***************************************************************************

        Get all the enrolled validator's UTXO keys.

        Params:
            utxo_keys = will contain the set of UTXO keys

        Returns:
            Return true if there was no error in getting the UTXO keys

    ***************************************************************************/

    public bool getEnrolledUTXOs (out Hash[] keys) @safe nothrow
    {
        return this.validator_set.getEnrolledUTXOs(keys);
    }

    /***************************************************************************

        Get all the enrolled validator's public keys.

        Params:
            keys = will contain the set of public keys
            height = the height of proposed block

        Returns:
            Return true if there was no error in getting the public keys

    ***************************************************************************/

    public bool getActiveValidatorPublicKeys (ref PublicKey[] keys, in Height height)
        @safe nothrow
    {
        return this.validator_set.getActiveValidatorPublicKeys(keys, height);
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
        const Height enrolled = this.validator_set.getEnrolledHeight(enroll.utxo_key);

        if (enrolled == ulong.max)
        {
            // Make sure there's no other enrollment with the same keypair
            if (this.validator_set.hasPublicKey(pubkey))
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

        Clear up expired validators whose cycle for a validator ends

        The enrollment manager clears up expired validators from the set based
        on the block height. It also clears up the enrollment of this node.

        Params:
            height = current block height

    ***************************************************************************/

    public void clearExpiredValidators (in Height height) @safe nothrow
    {
        // clear up the enrollment of a node if the validator cycle of the node
        // ends at the `height`
        const enrolled = this.validator_set.getEnrolledHeight(this.enroll_key);
        if (height >= enrolled + params.ValidatorCycle)
            this.resetNodeEnrollment();

        this.validator_set.clearExpiredValidators(height);
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
        const enrolled = this.validator_set.getEnrolledHeight(this.enroll_key);
        if (enrolled == ulong.max)
            return false;

        assert(height >= enrolled);
        const next_reveal = min(height + PreimageRevealPeriod,
                                enrolled + (this.params.ValidatorCycle - 1));

        if (next_reveal <= height)
            return false;

        preimage.utxo = this.enroll_key;
        preimage.distance = cast(ushort)(next_reveal - enrolled);
        preimage.hash = this.cycle[next_reveal];
        return true;
    }

    /***************************************************************************

        Generate the random seed reduced from the preimages for the provided
        block height.

        Params:
            keys = the keys to look up (must be sorted)
            height = the desired block height to look up the images for

        Returns:
            the random seed

    ***************************************************************************/

    public Hash getRandomSeed (in Hash[] keys, in Height height) @safe nothrow
    in
    {
        assert(keys.length != 0);
        assert(keys.isStrictlyMonotonic!((a, b) => a < b));
    }
    do
    {
        Hash rand_seed;
        foreach (const ref key; keys)
        {
            const preimage = this.validator_set.getPreimageAt(key, height);
            // We could have a misbehaving validator that does not reveal
            // its preimages in real world. In order to deal with the validator,
            // We implement the slashing protocol.
            if (preimage == PreImageInfo.init)
            {
                log.info("No preimage at height {} for validator key {}", height.value, key);
                continue;
            }
            rand_seed = hashMulti(rand_seed, preimage);
        }

        return rand_seed;
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
            end_height = the end enrolled height to finish retrieval to

        Returns:
            preimages' information of the validators

    ***************************************************************************/

    public PreImageInfo[] getValidatorPreimages (
        in Height start_height, in Height end_height) @safe nothrow
    {
        return this.validator_set.getPreimages(start_height,
            end_height);
    }

    /***************************************************************************

        Add a pre-image information to a validator data

        Params:
            preimage = the pre-image information to add

        Returns:
            true if the pre-image information has been added to the validator

    ***************************************************************************/

    public bool addPreimage (in PreImageInfo preimage) @safe nothrow
    {
        return this.validator_set.addPreimage(preimage);
    }

    /***************************************************************************

        Add pre-images for enrolled validators

        Params:
            preimages = the pre-images to add

        Returns:
            true if preimages was added successfully

    ***************************************************************************/

    public bool addPreimages (in PreImageInfo[] preimages) @safe nothrow
    {
        foreach (image; preimages)
        {
            auto stored_image =
                this.validator_set.getPreimage(image.utxo);
            if (stored_image == PreImageInfo.init ||
                stored_image.distance >= image.distance)
                continue;

            if (!this.validator_set.addPreimage(image))
                return false;
        }

        return true;
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

    /***************************************************************************

        Get the index of this node's enrollment in the sorted enrolled UTXOs

        Returns:
            the index of the enrollment, or ulong.max if this node is not
            enrolled as a validator.

    ***************************************************************************/

    public ulong getIndexOfEnrollment () @safe nothrow
    {
        if (this.enroll_key == Hash.init)
            return ulong.max;

        Hash[] utxo_keys;
        if (!this.validator_set.getEnrolledUTXOs(utxo_keys))
            assert(0);

        foreach (idx, key; utxo_keys)
            if (key == this.enroll_key)
                return idx;

        log.fatal("Index of the node's enrollment not found. Enrollment: {}",
            this.enroll_key);
        assert(0);
    }

    /// Returns: true if this validator is currently enrolled
    public bool isEnrolled (scope UTXOFinder finder) nothrow @safe
    {
        return this.getEnrolledUTXO(finder) != Hash.init;
    }

    /// Returns: The UTXO hash that this Validator is enrolled with or Hash.init if not enrolled
    public Hash getEnrolledUTXO (scope UTXOFinder finder) nothrow @safe
    {
        Hash[] utxo_keys;
        assert(this.validator_set.getEnrolledUTXOs(utxo_keys));

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

        Gets the number of active validators at the next block height.

        `height` is the height of the next block to be created. The count is of
        how many validators will be active in the following block should the
        block at `height` be externalized.
        If the active validators are less than the specified value,
        new blocks cannot be created.

        Params:
            height = the height of proposed block

        Returns:
            Returns the number of active validators when the block height is
            `height`.
            Returns 0 in case of error.

     ***************************************************************************/

    public ulong countActiveIfExternalized (in Height height) @safe nothrow
    {
        return this.validator_set.countActive(height + 1);
    }

    /***************************************************************************

        See `ValidatorSet.countActive`

    ***************************************************************************/

    public ulong countActive (in Height height) @safe nothrow
    {
        return this.validator_set.countActive(height);
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

        Remove all validators from the validator set

    ***************************************************************************/

    public void removeAllValidators () @trusted
    {
        this.validator_set.removeAll();
    }

    /***************************************************************************

        Returns: A delegate to query past Enrollments

    ***************************************************************************/

    public EnrollmentFinder getEnrollmentFinder () @trusted nothrow
    {
        return &this.validator_set.findRecentEnrollment;
    }

    /***************************************************************************

        Unenroll the validator from the validator set

        Params:
            enroll_hash = key for the validator to unenroll

    ***************************************************************************/

    public void unenrollValidator (in Hash enroll_hash) @trusted
    {
        this.validator_set.unenroll(enroll_hash);
    }

    /***************************************************************************

        Query Validators that have just finished their cycle

        Params:
            height = requested height
            ex_validators = Array to save the ExpiringValidators

        Returns:
            `PublicKey`s and enrollment heights of `Validator`s whose enrollment
            cycle have just ended

    ***************************************************************************/

    public ExpiringValidator[] getExpiringValidators (in Height height,
        ref ExpiringValidator[] ex_validators)
        @trusted nothrow
    {
        return this.validator_set.getExpiringValidators(height, ex_validators);
    }

    /***************************************************************************

        Query stakes of active Validators

        Params:
            peekUTXO = A delegate to query UTXOs
            utxos = Array to save the stakes

        Returns:
            Staked UTXOs of existing Validators

    ***************************************************************************/

    public UTXO[] getValidatorStakes (scope UTXOFinder peekUTXO, ref UTXO[] utxos,
        in uint[] missing_validators) @trusted nothrow
    {
        return this.validator_set.getValidatorStakes(peekUTXO, utxos,
            missing_validators);
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
            .sign(TxType.Freeze))
        .each!((tx) {
            utxo_set.put(tx);
            utxo_hashes ~= UTXO.getHash(tx.hashFull(), 0);
        });

    auto utxos = utxo_set.storage;

    // create an EnrollmentManager object
    auto params = new immutable(ConsensusParams)();
    auto man = new EnrollmentManager(key_pair, params);

    // check the return value of `getEnrollmentPublicKey`
    assert(key_pair.address == man.getEnrollmentPublicKey());

    // create and add the first Enrollment object
    auto utxo_hash = utxo_hashes[0];

    // The UTXO belongs to key_pair but we sign with genesis key pair
    Enrollment fail_enroll =
        EnrollmentManager.makeEnrollment(utxo_hash, gen_key_pair, 1008);
    assert(!man.addEnrollment(fail_enroll, gen_key_pair.address, Height(1),
            utxo_set.getUTXOFinder()));

    Enrollment[] ordered_enrollments;
    foreach (idx, kp; pairs[0 .. 3])
    {
        auto enroll = EnrollmentManager.makeEnrollment(
            utxo_hashes[idx], kp, params.ValidatorCycle, 0);

        assert(man.addEnrollment(enroll, kp.address, Height(1), &utxo_set.peekUTXO));
        assert(man.enroll_pool.count() == idx + 1);
        ordered_enrollments ~= enroll;
    }

    Enrollment[] enrolls = man.getEnrollments(Height(1), &utxo_set.peekUTXO);
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
    assert(man.getEnrolledHeight(utxo_hash) == ulong.max);
    assert(man.addValidator(ordered_enrollments[0], pairs[0].address, Height(9),
            &utxo_set.peekUTXO, utxos) is null);
    assert(man.getEnrolledHeight(ordered_enrollments[0].utxo_key) == 9);
    assert(man.addValidator(ordered_enrollments[0], pairs[0].address, Height(9),
            utxo_set.getUTXOFinder(), utxos) !is null);
    assert(man.getEnrolledHeight(ordered_enrollments[1].utxo_key) == ulong.max);
    enrolls = man.getEnrollments(Height(9), &utxo_set.peekUTXO);
    assert(enrolls.length == 1);
    // One Enrollment was moved to validator set
    assert(man.countActiveIfExternalized(Height(9)) == 1);
    assert(man.enroll_pool.count() == 1);

    man.enroll_pool.remove(utxo_hashes[0]);
    man.enroll_pool.remove(utxo_hashes[1]);
    man.enroll_pool.remove(utxo_hashes[2]);
    assert(man.getEnrollments(Height(9), &utxo_set.peekUTXO).length == 0);

    // clear up all validators
    man.validator_set.removeAll();

    // Reverse ordering
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (idx, ordered_enroll; ordered_enrollments)
        assert(man.addEnrollment(ordered_enroll, pairs[idx].address, Height(10),
            &utxo_set.peekUTXO));
    enrolls = man.getEnrollments(Height(man.params.ValidatorCycle + 8), &utxo_set.peekUTXO);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // A validation is enrolled at the height of 10.
    PreImageInfo preimage;
    assert(man.addValidator(ordered_enrollments[0], WK.Keys[0].address, Height(10),
            &utxo_set.peekUTXO, utxos) is null);
    assert(man.getNextPreimage(preimage, Height(10)));
    assert(preimage.hash ==
        man.cycle.preimages[$ - 1 - man.PreimageRevealPeriod - Height(10).value]);

    // test for getting validators' UTXO keys
    Hash[] keys;

    // validator A with the `utxo_hash` and the enrolled height of 10.
    // validator B with the 'utxo_hash2' and the enrolled height of 11.
    // validator C with the 'utxo_hash3' and no enrolled height.
    assert(man.addValidator(ordered_enrollments[1], WK.Keys[1].address, Height(11),
            &utxo_set.peekUTXO, utxos) is null);
    man.clearExpiredValidators(Height(11));
    assert(man.countActiveIfExternalized(Height(11)) == 2);
    assert(man.getEnrolledUTXOs(keys));
    assert(keys.length == 2);

    // set an enrolled height for validator C
    // set the block height to 1019, which means validator B is expired.
    // there is only one validator in the middle of 1020th block being made.
    assert(man.addValidator(ordered_enrollments[2], WK.Keys[2].address, Height(1019),
            &utxo_set.peekUTXO, utxos) is null);
    man.clearExpiredValidators(Height(1019));
    assert(man.countActiveIfExternalized(Height(1019)) == 1);
    assert(man.getEnrolledUTXOs(keys));
    assert(keys.length == 1);
    assert(keys[0] == ordered_enrollments[2].utxo_key);
}

/// Test `PreImageCycle` consistency between seeds and preimages
unittest
{
    auto params = new immutable(ConsensusParams)();

    auto secret = Scalar.random();

    // Note: This was copied from `EnrollmentManager` constructor and should
    // be kept in sync with it
    auto cycle = PreImageCycle(secret, params.ValidatorCycle);

    Scalar fake_secret; // Used whenever `secret` *shouldn't* be used
    foreach (uint cycleGroupCount; 0 .. 10)
    {
        foreach (outerIndex; 1 .. PreImageCycle.NumberOfCycles + 1)
        {
            // Sanity check #1
            assert(cycleGroupCount == cycle.nonce);
            assert(outerIndex - 1  == cycle.index);
            // Only provide `secret` on the first iteration
            const commitment =
                cycle.populate(outerIndex == 1 ? secret : fake_secret, true);
            const lastInCycle = outerIndex == PreImageCycle.NumberOfCycles;
            // Sanity check #2
            assert(cycleGroupCount + lastInCycle == cycle.nonce);
            if (lastInCycle)
                assert(0                         == cycle.index);
            else
                assert(outerIndex == cycle.index);
            // The commitment (last+1 in the cache, first to be revealed)
            // is the final pre-image revealed by the previous enrollment
            // (preimages[0])
            immutable SeedIndex = cycle.seeds.length
                - outerIndex * params.ValidatorCycle;
            assert(cycle.seeds.byStride[$ - outerIndex] == cycle.preimages[0]);
        }
    }

    // This check is quite expensive: 45s when it was written,
    // which doubled the total runtime of a `dub test` cycle.
    // It is versioned out now, but can be enabled for paranoid testing
    version (none)
    {
        // Reset the cycle and test that *all* values in `seeds` are represented
        // in `preimages`
        cycle.nonce = 0;
        cycle.index = 0;
        foreach (size_t cycleCount; 0 .. 5)
        {
            size_t seedIndex = cycle.seeds.length - 1;
            while (true)
            {
                const Index = seedIndex % Enrollment.ValidatorCycle;
                if (Index == (Enrollment.ValidatorCycle - 1))
                    cycle.populate(seedIndex == cycle.seeds.length ? secret :fake_secret);
                assert(cycle.seeds[seedIndex] == cycle.preimages[Index]);
                if (seedIndex == 0) break;
                seedIndex--;
            }
        }
    }
}

/// tests for `EnrollmentManager.countActiveIfExternalized
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
            .sign(TxType.Freeze))
        .each!((tx) {
            utxo_set.put(tx);
            utxo_hashes ~= UTXO.getHash(tx.hashFull(), 0);
        });
    auto utxos = utxo_set.storage;

    // create an EnrollmentManager object
    auto params = new immutable(ConsensusParams)();
    auto man = new EnrollmentManager(key_pair, params);

    Enrollment[] enrollments;
    foreach (idx, kp; pairs[0 .. 3])
    {
        enrollments ~= EnrollmentManager.makeEnrollment(
            utxo_hashes[idx], kp, params.ValidatorCycle, 0);
    }

    Height height = Height(2);

    // create and add the first Enrollment object
    assert(man.addEnrollment(enrollments[0], WK.Keys[0].address, height,
            utxo_set.getUTXOFinder()));
    assert(man.countActiveIfExternalized(height) == 0);  // not active yet

    man.clearExpiredValidators(height);
    assert(man.addValidator(enrollments[0], WK.Keys[0].address, height, &utxo_set.peekUTXO,
            utxos) is null);
    assert(man.countActiveIfExternalized(height) == 1);  // updated

    height = 3;

    // create and add the second Enrollment object
    assert(man.addEnrollment(enrollments[1], WK.Keys[1].address, height,
            utxo_set.getUTXOFinder()));
    assert(man.countActiveIfExternalized(height) == 1);  // not active yet

    man.clearExpiredValidators(height);
    assert(man.addValidator(enrollments[1], WK.Keys[1].address, height, &utxo_set.peekUTXO,
            utxos) is null);
    assert(man.countActiveIfExternalized(height) == 2);  // updated

    height = 4;

    // create and add the third Enrollment object
    assert(man.addEnrollment(enrollments[2], WK.Keys[2].address, height,
            utxo_set.getUTXOFinder()));
    assert(man.countActiveIfExternalized(height) == 2);  // not active yet

    man.clearExpiredValidators(height);
    assert(man.addValidator(enrollments[2], WK.Keys[2].address, height, &utxo_set.peekUTXO,
            utxos) is null);
    assert(man.countActiveIfExternalized(height) == 3);  // updated

    height = 5;    // valid block height : 0 <= H < 1008
    man.clearExpiredValidators(height);
    assert(man.countActiveIfExternalized(height) == 3);  // not cleared yet

    height = 1009; // valid block height : 2 <= H < 1010
    man.clearExpiredValidators(height);
    assert(man.countActiveIfExternalized(height) == 3);

    height = 1010; // valid block height : 3 <= H < 1011
    man.clearExpiredValidators(height);
    assert(man.countActiveIfExternalized(height) == 2);

    height = 1011; // valid block height : 4 <= H < 1012
    man.clearExpiredValidators(height);
    assert(man.countActiveIfExternalized(height) == 1);

    height = 1012; // valid block height : 5 <= H < 1013
    man.clearExpiredValidators(height);
    assert(man.countActiveIfExternalized(height) == 0);
}

// https://github.com/bosagora/agora/pull/1010#issuecomment-654149650
unittest
{
    // Irrelevant for this test, the seed is only derived from the private key
    // and the offset (which is 0 in both cases)
    Hash utxo;
    auto e1 = EnrollmentManager.makeEnrollment(utxo, WK.Keys.A, 10, 0);
    auto e2 = EnrollmentManager.makeEnrollment(utxo, WK.Keys.B, 10, 0);
    assert(e1.commitment != e2.commitment);
}

/// Test for the height when the enrollment will be available
unittest
{
    import agora.consensus.data.Transaction;

    scope utxo_set = new TestUTXOSet;
    KeyPair key_pair = KeyPair.random();
    genesisSpendable().map!(txb => txb.refund(key_pair.address).sign(TxType.Freeze))
        .each!(tx => utxo_set.put(tx));
    auto utxos = utxo_set.storage;

    // create an EnrollmentManager
    const validator_cycle = 20;
    scope man = new EnrollmentManager(key_pair,
        new immutable(ConsensusParams)(validator_cycle));

    // create and add the first enrollment
    Enrollment[] enrolls;
    auto enroll = man.createEnrollment(utxo_set.keys[0], Height(10));
    assert(man.addEnrollment(enroll, key_pair.address, Height(9),
            utxo_set.getUTXOFinder()));

    // if the current height is smaller than the available height,
    // we can get no enrollment
    enrolls = man.getEnrollments(Height(8), &utxo_set.peekUTXO);
    assert(enrolls.length == 0);

    // if the current height is greater than or equal to the available height,
    // we can get enrollments
    enrolls = man.getEnrollments(Height(9), &utxo_set.peekUTXO);
    assert(enrolls.length == 1);

    // make the enrollment a validator
    man.addValidator(enroll, key_pair.address, Height(10), &utxo_set.peekUTXO, utxos);
    enrolls = man.getEnrollments(Height(11), &utxo_set.peekUTXO);
    assert(enrolls.length == 0);

    // add the enrollment that is already a validator, and check if
    // the enrollment can be nominated at the height before the cycle end
    enroll = man.createEnrollment(utxo_set.keys[0], Height(10 + validator_cycle));
    assert(man.addEnrollment(enroll, key_pair.address, Height(11), &utxo_set.peekUTXO));
    enrolls = man.getEnrollments(Height(validator_cycle + 8), &utxo_set.peekUTXO);
    assert(enrolls.length == 0);
    enrolls = man.getEnrollments(Height(validator_cycle + 9), &utxo_set.peekUTXO);
    assert(enrolls.length == 1);

    // make the enrollment a validator again
    man.clearExpiredValidators(Height(validator_cycle + 11));
    assert(man.addValidator(enroll, key_pair.address, Height(validator_cycle + 11),
        &utxo_set.peekUTXO, utxos));

    // add the enrollment that has the available height smaller than
    // the enrolled height of the validator, it will fail because of the commitment
    // constraint
    assert(!man.addEnrollment(enroll, key_pair.address, Height(validator_cycle + 10),
        &utxo_set.peekUTXO));
    enrolls = man.getEnrollments(Height(validator_cycle + 11), &utxo_set.peekUTXO);
    assert(enrolls.length == 0);
}

// test getRandomSeed()
unittest
{
    import agora.consensus.data.Transaction;
    import std.conv;
    import std.range;
    import std.stdio;

    scope storage = new TestUTXOSet;
    Hash[] utxos;

    // genesisSpendable returns 8 outputs
    auto pairs = iota(8).map!(idx => WK.Keys[idx]).array;

    genesisSpendable()
        .enumerate
        .map!(tup => tup.value
            .refund(pairs[tup.index].address)
            .sign(TxType.Freeze))
        .each!((tx) {
            storage.put(tx);
            utxos ~= UTXO.getHash(tx.hashFull(), 0);
        });

    auto params = new immutable(ConsensusParams);
    scope man = new EnrollmentManager(KeyPair.random(), params);

    foreach (idx, kp; pairs)
    {
        const enroll = EnrollmentManager.makeEnrollment(
            utxos[idx], kp, params.ValidatorCycle, 0);
        assert(man.addValidator(enroll, kp.address, Height(1), storage.getUTXOFinder(),
            storage.storage) is null);

        auto cache = PreImageCache(PreImageCycle.NumberOfCycles, params.ValidatorCycle);
        cache.reset(hashMulti(kp.secret, "consensus.preimages", 0));

        PreImageInfo preimage = { utxo : utxos[idx],
            distance : cast(ushort)params.ValidatorCycle,
            hash : cache[$ - params.ValidatorCycle - 1] };

        assert(man.addPreimage(preimage));
    }

    utxos.sort();  // must be sorted by enrollment key
    assert(man.getRandomSeed(utxos, Height(1)) ==
        Hash(`0x348f4f51330674863fe6960715b693b0dd4a0865de9b70fc6527d368b7afcaa2c757b27d5d258135c48b68ea051babfbacad3fc1c4a5988ca88bc93d01c86579`),
        man.getRandomSeed(utxos, Height(1)).to!string);

    assert(man.getRandomSeed(utxos, Height(504)) ==
        Hash(`0xeae662a765560186a3e08d4dc965743917d06bac5fbd71c1483f891446fac972557a192e0a3e337c575c579702c7d75f896d4b454dab8112feb093e201e2cd1f`),
        man.getRandomSeed(utxos, Height(504)).to!string);

    assert(man.getRandomSeed(utxos, Height(1008)) ==
        Hash(`0xdbedac4b2a93a4a213ecc89e1d6aadad666ca36668621dc62f7fccc15d86c3481b8aed8d4b56c2a18ed800239e30aa2612283454378cc6e64d9baba0b91b2fc3`),
        man.getRandomSeed(utxos, Height(1008)).to!string);
}

// Tests for get/set a enrollment key
unittest
{
    import agora.consensus.data.Transaction;

    auto utxo_set = new TestUTXOSet;
    genesisSpendable()
        .map!(txb => txb.refund(WK.Keys.A.address).sign(TxType.Freeze))
        .each!(tx => utxo_set.put(tx));
    auto man = new EnrollmentManager(WK.Keys.A,
        new immutable(ConsensusParams)(10));

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

    genesisSpendable().map!(txb => txb.refund(key_pair.address).sign(TxType.Freeze))
        .each!(tx => utxo_set.put(tx));
    Hash[] utxo_hashes = utxo_set.keys;

    // create an EnrollmentManager object
    auto man = new EnrollmentManager(key_pair,
        new immutable(ConsensusParams)());

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
    import std.algorithm;

    scope utxo_set = new TestUTXOSet;
    KeyPair key_pair = KeyPair.random();

    genesisSpendable().map!(txb => txb.refund(key_pair.address).sign(TxType.Freeze))
        .each!(tx => utxo_set.put(tx));
    Hash[] utxo_hashes = utxo_set.keys;

    auto params = new immutable(ConsensusParams)();
    // create an EnrollmentManager object
    auto man = new EnrollmentManager(key_pair, params);
    auto findEnrollment = man.getEnrollmentFinder();

    auto genesis_enroll = man.createEnrollment(utxo_hashes[0], Height(0));
    assert(man.addEnrollment(genesis_enroll, key_pair.address, Height(0),
                                                        &utxo_set.peekUTXO));
    EnrollmentState state;
    assert(!findEnrollment(genesis_enroll.utxo_key, state));
    assert(man.addValidator(genesis_enroll, key_pair.address, Height(0),
                                &utxo_set.peekUTXO, utxo_set.storage) is null);
    assert(man.countActiveIfExternalized(Height(0)) == 1);
    assert(findEnrollment(genesis_enroll.utxo_key, state));
    assert(state.status == EnrollmentStatus.Active);
    assert(state.enrolled_height == Height(0));
    assert(state.cycle_length == params.ValidatorCycle);
    assert(state.preimage.hash == genesis_enroll.commitment);
    assert(state.preimage.distance == 0);

    PreImageInfo preimage;
    assert(man.getNextPreimage(preimage, Height(params.ValidatorCycle / 2)));
    assert(man.addPreimage(preimage));
    assert(findEnrollment(genesis_enroll.utxo_key, state));
    assert(state.preimage.hash == preimage.hash);
    assert(state.preimage.distance == preimage.distance);

    // First 2 iterations should fail because commitment is wrong
    foreach (offset; [-1, +1, 0])
    {
        auto enroll = man.createEnrollment(utxo_hashes[0],
                                        Height(params.ValidatorCycle + offset));
        assert((offset == 0) == man.addEnrollment(enroll, key_pair.address,
                                                Height(0), &utxo_set.peekUTXO));
    }

    Enrollment[] enrolls;
    // Enrollment should only be valid for one block height
    foreach (offset; [-2, 0, -1])
    {
        enrolls = man.getEnrollments(Height(params.ValidatorCycle + offset), &utxo_set.peekUTXO);
        assert(enrolls.length == (offset == -1 ? 1 : 0));
    }

    man.clearExpiredValidators(Height(params.ValidatorCycle));
    assert(findEnrollment(genesis_enroll.utxo_key, state));
    assert(state.status == EnrollmentStatus.Expired);
    assert(state.enrolled_height == Height(0));
    assert(state.cycle_length == params.ValidatorCycle);
    assert(state.preimage.hash == preimage.hash);
    assert(state.preimage.distance == preimage.distance);

    assert(man.countActiveIfExternalized(Height(params.ValidatorCycle)) == 0);
    assert(man.addValidator(enrolls[0], key_pair.address,
            Height(params.ValidatorCycle), &utxo_set.peekUTXO,
                                                utxo_set.storage) is null);
    assert(man.countActiveIfExternalized(Height(params.ValidatorCycle)) == 1);
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
            .refund(WK.Keys[tup.index].address).sign(TxType.Freeze))
        .each!((tx) {
            utxo_set.put(tx);
            utxos ~= UTXO.getHash(tx.hashFull(), 0);
        });

    auto man = new EnrollmentManager(WK.Keys.A,
        new immutable(ConsensusParams)(20));
    auto e1 = EnrollmentManager.makeEnrollment(
        utxos[0], WK.Keys.A, man.params.ValidatorCycle, 0);
    auto e2 = EnrollmentManager.makeEnrollment(
        utxos[1], WK.Keys.B, man.params.ValidatorCycle, 0);

    assert(man.addEnrollment(e1, WK.Keys.A.address, Height(1), &utxo_set.peekUTXO));
    assert(man.addEnrollment(e2, WK.Keys.B.address, Height(1), &utxo_set.peekUTXO));

    assert(man.addValidator(e1, WK.Keys.A.address, Height(2), &utxo_set.peekUTXO,
        utxo_set.storage) is null);
    assert(man.addValidator(e2, WK.Keys.B.address, Height(2), &utxo_set.peekUTXO,
        utxo_set.storage) is null);

    assert(man.countActiveIfExternalized(Height(2)) == 2);
    man.unenrollValidator(utxos[0]);
    assert(man.countActiveIfExternalized(Height(2)) == 1);
}
