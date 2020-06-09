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
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.EnrollmentManager;

import agora.common.crypto.ECC;
import agora.common.crypto.Key;
import agora.common.crypto.Schnorr;
import agora.common.Hash;
import agora.common.Serializer;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.PreImageInfo;
import agora.consensus.data.UTXOSetValue;
import agora.consensus.UTXOSet;
import agora.consensus.EnrollmentPool;
import agora.consensus.PreImage;
import agora.consensus.validation;
import agora.consensus.ValidatorSet;
import agora.utils.Log;

import d2sqlite3.database;
import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.algorithm;
import std.file;
import std.path;
import std.string;

mixin AddLogger!();

/*******************************************************************************

    Handle enrollment data and manage the validators set

*******************************************************************************/

public class EnrollmentManager
{
    /// SQLite db instance
    private Database db;

    /// Node's key pair
    private Pair key_pair;

    /// Key used for enrollment which is actually an UTXO hash
    private Hash enroll_key;

    /// Random key for enrollment
    private Pair signature_noise;

    /// Enrollment data object
    private Enrollment data;

    /// Next height for pre-image revelation
    private ulong next_reveal_height;

    /// The period for revealing a preimage
    /// It is an hour interval if a block is made in every 10 minutes
    public static immutable uint PreimageRevealPeriod = 6;

    /// Validator set managing validators' information such as Enrollment object
    /// enrolled height, and preimages.
    private ValidatorSet validator_set;

    /// Enrollment pool managing enrollments waiting to be a validator
    private EnrollmentPool enroll_pool;

    /// Ditto
    private PreImageCycle cycle;

    /***************************************************************************

        Constructor

        Params:
            db_path = path to the database file, or in-memory storage if
                        :memory: was passed
            key_pair = the keypair of the owner node

    ***************************************************************************/

    public this (string db_path, KeyPair key_pair)
    {
        this.cycle = PreImageCycle(
            /* nounce: */ 0,
            /* index:  */ 0,
            /* seeds:  */ PreImageCache(PreImageCycle.NumberOfCycles, Enrollment.ValidatorCycle),
            // Since those pre-images might be accessed often,
            // use an interval of 1 (no interval)
            /* preimages: */ PreImageCache(Enrollment.ValidatorCycle, 1)
        );

        this.validator_set = new ValidatorSet(db_path);
        this.enroll_pool = new EnrollmentPool(db_path);

        this.db = Database(db_path);

        // create the table for enrollment data for a node itself
        this.db.execute("CREATE TABLE IF NOT EXISTS node_enroll_data " ~
            "(key CHAR(128) PRIMARY KEY, val BLOB NOT NULL)");

        // create Pair object from KeyPair object
        this.key_pair.v = secretKeyToCurveScalar(key_pair.secret);
        this.key_pair.V = this.key_pair.v.toPoint();

        // load enroll_key
        this.enroll_key = this.getEnrollmentKey();

        // load next height for preimage revelation
        this.next_reveal_height = this.getNextRevealHeight();
    }

    /***************************************************************************

        Shut down the database

        Note: this method must be called explicitly, and not inside of
        a destructor.

    ***************************************************************************/

    public void shutdown ()
    {
        this.db.close();
        this.validator_set.shutdown();
        this.enroll_pool.shutdown();
    }

    /// Provide direct access to the `EnrollmentPool`
    public inout(EnrollmentPool) pool () inout @safe pure nothrow @nogc
    {
        return this.enroll_pool;
    }

    /***************************************************************************

        In validatorSet DB, return the enrolled block height.

        Params:
            enroll_hash = key for an enrollment block height

        Returns:
            the enrolled block height, or `ulong.max` if no matching key exists

    ***************************************************************************/

    public ulong getEnrolledHeight (const ref Hash enroll_hash) @trusted
    {
        return this.validator_set.getEnrolledHeight(enroll_hash);
    }

    /***************************************************************************

        Add a validator to the validator set or update the enrolled height.

        Params:
            enroll = Enrollment structure to add to the validator set
            block_height = enrolled blockheight
            finder = the delegate to find UTXOs with

        Returns:
            A string describing the error, or `null` on success

    ***************************************************************************/

    public string addValidator (const ref Enrollment enroll,
        size_t block_height, scope UTXOFinder finder) @safe
    {
        this.enroll_pool.remove(enroll.utxo_key);

        if (auto r = this.validator_set.add(block_height, finder, enroll))
            return r;

        // set next height for revealing a pre-image
        if (enroll.utxo_key == this.enroll_key)
            this.setNextRevealHeight(block_height);

        return null;
    }

    /***************************************************************************

        Make an enrollment data for enrollment process

        Params:
            frozen_utxo_hash = the hash of a frozen UTXO used to identify a validator
                        and to generate a siging key
            height = the starting index for generating pre-images
            enroll = will contain the Enrollment if created

        Returns:
            true if the enrollment manager succeeded in creating the Enrollment

    ***************************************************************************/

    public bool createEnrollment (Hash frozen_utxo_hash, ulong height,
        out Enrollment enroll) @trusted nothrow
    {
        static ubyte[] buffer;

        // K, frozen UTXO hash
        this.data.utxo_key = frozen_utxo_hash;
        this.enroll_key = frozen_utxo_hash;

        // N, cycle length
        this.data.cycle_length = Enrollment.ValidatorCycle;

        // X, final seed data and preimages of hashes
        //
        // TODO: Move this consume call to `addValidator` and instead
        // make this calculate the future pre-image without changing
        // the state
        this.data.random_seed = this.cycle.consume(this.key_pair.v);

        // R, signature noise
        this.signature_noise = this.createSignatureNoise(height);

        // save enroll_key
        if (!this.setEnrollmentKey(enroll))
            return false;

        // signature
        data.enroll_sig = sign(this.key_pair, this.signature_noise, this.data);

        enroll = this.data;

        return true;
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

        Get the number of active validators.

        Client code can use this between clearExpiredValidators() calls to
        determine if the number of validators has changed, and act accordingly.

        Returns:
            the number of active validators

    ***************************************************************************/

    public size_t validatorCount () @safe
    {
        return this.validator_set.count();
    }

    /***************************************************************************

        Clear up expired validators whose cycle for a validator ends

        The enrollment manager clears up expired validators from the set based
        on the block height.

        Params:
            block_height = current block height

    ***************************************************************************/

    public void clearExpiredValidators (ulong block_height) @safe nothrow
    {
        this.validator_set.clearExpiredValidators(block_height);
    }

    /***************************************************************************

        Get a pre-image for revelation

        Params:
            preimage = will contain the PreImageInfo if exists

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool getNextPreimage (out PreImageInfo preimage) @safe
    {
        auto height = this.next_reveal_height + PreimageRevealPeriod * 2;
        return getPreimage(height, preimage);
    }

    /***************************************************************************

        Get a pre-image at a certain height

        Params:
            height = the number of the height at which the pre-image exists
            preimage = will contain the PreImageInfo if exists

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool getPreimage (ulong height, out PreImageInfo preimage) @safe
    {
        const enrolled_height =
            this.validator_set.getEnrolledHeight(this.enroll_key);
        // FIXME: This function should only be called if we're enrolled
        assert(enrolled_height != ulong.max);
        const start_height = enrolled_height + 1;
        if (height < start_height)
            return false;
        immutable index = (height - start_height);
        if (index > Enrollment.ValidatorCycle - 1)
            return false;

        preimage.enroll_key = this.data.utxo_key;
        assert(index <= ushort.max);
        preimage.distance = cast(ushort)index;  // max: Enrollment.ValidatorCycle - 1
        preimage.hash = this.cycle.preimages[$ - index - 1];
        return true;
    }

    /***************************************************************************

        Check if a pre-image exists

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.
            distance = The distance of the preimage

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool hasPreimage (const ref Hash enroll_key, ushort distance) @safe
        nothrow
    {
        return this.validator_set.hasPreimage(enroll_key, distance);
    }

    /***************************************************************************

        Get validator's pre-image from the validator set.

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.

        Returns:
            the PreImageInfo of the enrolled key if it exists,
            otherwise PreImageInfo.init

    ***************************************************************************/

    public PreImageInfo getValidatorPreimage (const ref Hash enroll_key)
        @trusted nothrow
    {
        return this.validator_set.getPreimage(enroll_key);
    }

    /***************************************************************************

        Add a pre-image information to a validator data

        Params:
            preimage = the pre-image information to add

        Returns:
            true if the pre-image information has been added to the validator

    ***************************************************************************/

    public bool addPreimage (const ref PreImageInfo preimage) @safe nothrow
    {
        return this.validator_set.addPreimage(preimage);
    }

    /***************************************************************************

        Check if revealing a pre-image is needed at a certain height

        Params:
            height = block height to check

        Returns:
            true if revealing a pre-image is needed

    ***************************************************************************/

    public bool needRevealPreimage (ulong height) @safe nothrow
    {
        return height >= this.next_reveal_height;
    }

    /***************************************************************************

        Increase the next reveal height by the revelation period

    ***************************************************************************/

    public void increaseNextRevealHeight () @safe nothrow
    {
        ulong next_height = this.getNextRevealHeight();
        if (this.next_reveal_height < ulong.max)
            this.setNextRevealHeight(next_height + PreimageRevealPeriod);
    }

    /***************************************************************************

        Restore validators' information from block

        Params:
            last_height = the latest block height
            block = the block to update the validator set with
            finder = the delegate to find UTXOs with

    ***************************************************************************/

    public void restoreValidators (ulong last_height, const ref Block block,
        scope UTXOFinder finder) @safe nothrow
    {
        this.validator_set.restoreValidators(last_height, block, finder);
    }

    /***************************************************************************

        Get the public key of node that is used for a enrollment

        Returns:
            Public key of a node

    ***************************************************************************/

    public PublicKey getEnrollmentPublicKey () @safe nothrow
    {
        return PublicKey(this.key_pair.V[]);
    }

    /***************************************************************************

        Get the key for the enrollment data for this node

        Returns:
            the key for the enrollment data

    ***************************************************************************/

    private Hash getEnrollmentKey () @safe nothrow
    {
        Hash en_key;

        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT val FROM node_enroll_data " ~
                    "WHERE key = ?", "enroll_key");

                if (!results.empty)
                    en_key = results.oneValue!(ubyte[]).deserializeFull!(Hash);
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error: {}", ex);
        }

        return en_key;
    }

    /***************************************************************************

        Set the key for the enrollment data for this node

        Params:
            enroll = the enrollment data for this node

        Returns:
            true if setting the data succeeds

    ***************************************************************************/

    private bool setEnrollmentKey (ref Enrollment enroll) @safe nothrow
    {
        static ubyte[] buffer;
        try
        {
            serializeToBuffer(enroll.utxo_key, buffer);
        }
        catch (Exception ex)
        {
            log.error("Serialization error: {} ({})", ex, enroll);
            return false;
        }

        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
                    "node_enroll_data WHERE key = ?)", "enroll_key");
                if (results.oneValue!(bool))
                    this.db.execute("UPDATE node_enroll_data SET val = ? " ~
                        "WHERE key = ?", buffer, "enroll_key");
                else
                    this.db.execute("INSERT INTO node_enroll_data (key, val)" ~
                        " VALUES (?, ?)", "enroll_key", buffer);
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error: {} ({})", ex, enroll);
            return false;
        }

        return true;
    }

    /***************************************************************************

        Get the next block height to reveal a pre-image

        Returns:
            the next block height to reveal a pre-image. if any problem in
            getting the value, it returns the MAX ulong value.

    ***************************************************************************/

    private ulong getNextRevealHeight () @safe nothrow
    {
        ulong next_height = ulong.max;
        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT val FROM node_enroll_data " ~
                    "WHERE key = ?", "next_reveal_height");
                if (!results.empty)
                    next_height = results.oneValue!(size_t);
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error {}", ex);
        }
        return next_height;
    }

    /***************************************************************************

        Set the next block height to reveal a pre-image

        Params:
            height = the next block height to reveal a pre-image

    ***************************************************************************/

    private void setNextRevealHeight (ulong height) @safe nothrow
    {
        try
        {
            () @trusted {
                auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
                    "node_enroll_data WHERE key = ?)", "next_reveal_height");
                if (results.oneValue!(bool))
                    this.db.execute("UPDATE node_enroll_data SET val = ? " ~
                        "WHERE key = ?", height, "next_reveal_height");
                else
                    this.db.execute("INSERT INTO node_enroll_data (key, val)" ~
                        " VALUES (?, ?)", "next_reveal_height", height);

                this.next_reveal_height = height;
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error {}", ex);
        }
    }

    /***************************************************************************

        Create signature noise for enrollment data.

        It creates a signature noise for enrollment data by hashing the private
        key, the constant value which states the "purpose", and non-constant
        value like a block height. This makes the enrollment data for a
        validator recoverable in any abnormal situation.

        Params:
            height = the height used for a salt value

        Returns:
            the signature noise created using the private key

    ***************************************************************************/

    private Pair createSignatureNoise (ulong height) nothrow @safe @nogc
    {
        Pair key_pair;
        key_pair.v = Scalar(hashMulti(this.key_pair.v,
            "consensus.signature.noise", height));
        key_pair.V = key_pair.v.toPoint();
        return key_pair;
    }

    /***************************************************************************

        Gets the number of active validators at the block height.

        `block_height` is the height of the newly created block.
        If the active validators are less than the specified value,
        new blocks cannot be created.

        Params:
            block_height = the height of proposed block

        Returns:
            Returns the number of active validators when the block height is
            `block_height`.
            Returns 0 in case of error.

    ***************************************************************************/

    public ulong getValidatorCount (ulong block_height) @safe nothrow
    {
        return this.validator_set.getValidatorCount(block_height);
    }
}

/// tests for member functions of EnrollmentManager
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Transaction;
    import agora.consensus.Genesis;
    import std.algorithm;
    import std.format;
    import std.conv;

    scope storage = new TestUTXOSet;

    auto gen_key_pair = getGenesisKeyPair();
    KeyPair key_pair = KeyPair.random();

    foreach (idx; 0 .. 8)
    {
        auto input = Input(hashFull(GenesisTransaction), idx.to!uint);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [Output(Amount.MinFreezeAmount, key_pair.address)]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        storage.put(tx);
    }

    // create an EnrollmentManager object
    auto man = new EnrollmentManager(":memory:", key_pair);
    scope (exit) man.shutdown();
    Hash[] utxo_hashes = storage.keys;

    // check the return value of `getEnrollmentPublicKey`
    assert(key_pair.address == man.getEnrollmentPublicKey());

    // create and add the first Enrollment object
    auto utxo_hash = utxo_hashes[0];
    Enrollment enroll;
    Enrollment enroll2;
    Enrollment fail_enroll;

    Pair signature_noise = man.createSignatureNoise(1);
    Pair fail_enroll_key_pair;
    fail_enroll_key_pair.v = secretKeyToCurveScalar(gen_key_pair.secret);
    fail_enroll_key_pair.V = fail_enroll_key_pair.v.toPoint();

    fail_enroll.utxo_key = utxo_hash;
    fail_enroll.random_seed = hashFull(Scalar.random());
    fail_enroll.cycle_length = 1008;
    fail_enroll.enroll_sig = sign(fail_enroll_key_pair, signature_noise, fail_enroll);

    assert(man.createEnrollment(utxo_hash, 1, enroll));
    assert(!man.pool.add(fail_enroll, &storage.findUTXO));
    assert(man.pool.add(enroll, &storage.findUTXO));
    assert(man.pool.count() == 1);
    assert(!man.pool.add(enroll, &storage.findUTXO));

    // create and add the second Enrollment object
    auto utxo_hash2 = utxo_hashes[1];
    assert(man.createEnrollment(utxo_hash2, 1, enroll2));
    assert(man.pool.add(enroll2, &storage.findUTXO));
    assert(man.pool.count() == 2);

    auto utxo_hash3 = utxo_hashes[2];
    Enrollment enroll3;
    assert(man.createEnrollment(utxo_hash3, 1, enroll3));
    assert(man.pool.add(enroll3, &storage.findUTXO));
    assert(man.pool.count() == 3);

    Enrollment[] enrolls;
    man.pool.getEnrollments(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // get a stored Enrollment object
    Enrollment stored_enroll;
    assert(man.pool.getEnrollment(utxo_hash2, stored_enroll));
    assert(stored_enroll == enroll2);

    // remove an Enrollment object
    man.pool.remove(utxo_hash2);
    assert(man.enroll_pool.count() == 2);

    // test for getEnrollment with removed enrollment
    assert(!man.pool.getEnrollment(utxo_hash2, stored_enroll));

    // test for enrollment block height update
    assert(man.getEnrolledHeight(utxo_hash) == ulong.max);
    assert(man.addValidator(enroll, 9, &storage.findUTXO) is null);
    assert(man.getEnrolledHeight(enroll.utxo_key) == 9);
    assert(man.addValidator(enroll, 9, &storage.findUTXO) !is null);
    assert(man.getEnrolledHeight(enroll2.utxo_key) == ulong.max);
    man.pool.getEnrollments(enrolls);
    assert(enrolls.length == 1);
    // One Enrollment was moved to validator set
    assert(man.validator_set.count() == 1);
    assert(man.pool.count() == 1);

    man.pool.remove(utxo_hash);
    man.pool.remove(utxo_hash2);
    man.pool.remove(utxo_hash3);
    assert(man.pool.getEnrollments(enrolls).length == 0);

    Enrollment[] ordered_enrollments;
    ordered_enrollments ~= enroll;
    ordered_enrollments ~= enroll2;
    ordered_enrollments ~= enroll3;
    // Reverse ordering
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (ordered_enroll; ordered_enrollments)
        assert(man.pool.add(ordered_enroll, &storage.findUTXO));
    man.pool.getEnrollments(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // clear up all validators
    man.clearExpiredValidators(1018);

    // get a pre-image at a certain height
    // A validation can start at the height of the enrolled height plus 1.
    // So, a pre-image can only be got from the start height.
    PreImageInfo preimage;
    assert(man.createEnrollment(utxo_hash, 1, enroll));
    assert(man.addValidator(enroll, 10, &storage.findUTXO) is null);
    assert(!man.getPreimage(10, preimage));
    assert(man.getPreimage(11, preimage));
    assert(preimage.hash == man.cycle.preimages[$ - 1]);
    assert(man.getPreimage(10 + Enrollment.ValidatorCycle, preimage));
    assert(preimage.hash == man.cycle.preimages[0]);
    assert(!man.getPreimage(11 + Enrollment.ValidatorCycle, preimage));

    /// test for the functions about periodic revelation of a pre-image
    assert(man.needRevealPreimage(10));
    man.increaseNextRevealHeight();
    assert(man.needRevealPreimage(16));

    // If the height of the requested preimage exceeds the height of the end of
    // the validator cycle, the `getNextPreimage` must return `false`.
    man.next_reveal_height = 10 + Enrollment.ValidatorCycle;
    assert(!man.getNextPreimage(preimage));

    // test for getting validators' UTXO keys
    Hash[] keys;

    // validator A with the `utxo_hash` and the enrolled height of 10.
    // validator B with the 'utxo_hash2' and the enrolled height of 11.
    // validator C with the 'utxo_hash3' and no enrolled height.
    assert(man.addValidator(enroll2, 11, &storage.findUTXO) is null);
    man.clearExpiredValidators(11);
    assert(man.validatorCount() == 2);
    assert(man.getEnrolledUTXOs(keys));
    assert(keys.length == 2);

    // set an enrolled height for validator C
    // set the block height to 1019, which means validator B is expired.
    // there is only one validator in the middle of 1020th block being made.
    assert(man.addValidator(enroll3, 1019, &storage.findUTXO) is null);
    man.clearExpiredValidators(1019);
    assert(man.validatorCount() == 1);
    assert(man.getEnrolledUTXOs(keys));
    assert(keys.length == 1);
    assert(keys[0] == enroll3.utxo_key);
}

/// tests for addPreimage and getValidatorPreimage
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Transaction;
    import agora.consensus.Genesis;
    import std.conv;

    scope storage = new TestUTXOSet;
    auto gen_key_pair = getGenesisKeyPair();
    KeyPair key_pair = KeyPair.random();

    foreach (idx; 0 .. 8)
    {
        auto input = Input(hashFull(GenesisTransaction), idx.to!uint);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [Output(Amount.MinFreezeAmount, key_pair.address)]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        storage.put(tx);
    }

    auto man = new EnrollmentManager(":memory:", key_pair);
    scope (exit) man.shutdown();
    Hash[] utxo_hashes = storage.keys;

    auto utxo_hash = utxo_hashes[0];
    Enrollment enroll;
    assert(man.createEnrollment(utxo_hash, 1, enroll));
    assert(man.pool.add(enroll, &storage.findUTXO));

    assert(Enrollment.ValidatorCycle - 101 == 907); // Sanity check
    assert(man.getValidatorPreimage(utxo_hash) == PreImageInfo.init);
    auto preimage = PreImageInfo(utxo_hash, man.cycle.preimages[100], 907);
    assert(man.addValidator(enroll, 2, &storage.findUTXO) is null);
    assert(man.addPreimage(preimage));
    assert(man.getValidatorPreimage(utxo_hash) == preimage);
}

/// Test `PreImageCycle` consistency between seeds and preimages
unittest
{
    // Note: This was copied from `EnrollmentManager` constructor and should
    // be kept in sync with it
    auto cycle = PreImageCycle(
        /* nounce: */ 0,
        /* index:  */ 0,
        /* seeds:  */ PreImageCache(PreImageCycle.NumberOfCycles, Enrollment.ValidatorCycle),
        /* preimages: */ PreImageCache(Enrollment.ValidatorCycle, 1)
    );

    auto secret = Scalar.random();
    Scalar fake_secret; // Used whenever `secret` *shouldn't* be used
    foreach (uint cycleGroupCount; 0 .. 10)
    {
        foreach (outerIndex; 1 .. PreImageCycle.NumberOfCycles + 1)
        {
            // Sanity check #1
            assert(cycleGroupCount == cycle.nonce);
            assert(outerIndex - 1  == cycle.index);
            // Only provide `secret` on the first iteration
            const commitment = cycle.consume(outerIndex == 1 ? secret : fake_secret);
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
                - outerIndex * Enrollment.ValidatorCycle;
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
                    cycle.consume(seedIndex == cycle.seeds.length ? secret :fake_secret);
                assert(cycle.seeds[seedIndex] == cycle.preimages[Index]);
                if (seedIndex == 0) break;
                seedIndex--;
            }
        }
    }
}

/// tests for `EnrollmentManager.getValidatorCount
unittest
{
    import agora.common.Amount;
    import agora.consensus.data.Transaction;
    import agora.consensus.Genesis;
    import std.format;
    import std.conv;

    scope storage = new TestUTXOSet;

    auto gen_key_pair = getGenesisKeyPair();
    KeyPair key_pair = KeyPair.random();

    foreach (idx; 0 .. 8)
    {
        auto input = Input(hashFull(GenesisTransaction), idx.to!uint);

        Transaction tx =
        {
            TxType.Freeze,
            [input],
            [Output(Amount.MinFreezeAmount, key_pair.address)]
        };

        auto signature = gen_key_pair.secret.sign(hashFull(tx)[]);
        tx.inputs[0].signature = signature;
        storage.put(tx);
    }

    // create an EnrollmentManager object
    auto man = new EnrollmentManager(":memory:", key_pair);
    scope (exit) man.shutdown();
    Hash[] utxo_hashes = storage.keys;

    Enrollment enrollment;
    ulong block_height = 2;

    // create and add the first Enrollment object
    auto utxo_hash1 = utxo_hashes[0];
    assert(man.createEnrollment(utxo_hash1, block_height, enrollment));
    assert(man.pool.add(enrollment, &storage.findUTXO));
    assert(man.getValidatorCount(block_height) + 1 == 1);

    man.clearExpiredValidators(block_height);
    assert(man.addValidator(enrollment, block_height, &storage.findUTXO) is null);

    block_height = 3;

    // create and add the second Enrollment object
    auto utxo_hash2 = utxo_hashes[1];
    assert(man.createEnrollment(utxo_hash2, block_height, enrollment));
    assert(man.pool.add(enrollment, &storage.findUTXO));
    assert(man.getValidatorCount(block_height) + 1 == 2);

    man.clearExpiredValidators(block_height);
    assert(man.addValidator(enrollment, block_height, &storage.findUTXO) is null);

    block_height = 4;

    // create and add the third Enrollment object
    auto utxo_hash3 = utxo_hashes[2];
    assert(man.createEnrollment(utxo_hash3, block_height, enrollment));
    assert(man.pool.add(enrollment, &storage.findUTXO));
    assert(man.getValidatorCount(block_height) + 1 == 3);

    man.clearExpiredValidators(block_height);
    assert(man.addValidator(enrollment, block_height, &storage.findUTXO) is null);

    block_height = 5;    // valid block height : 0 <= H < 1008
    man.clearExpiredValidators(block_height);
    assert(man.getValidatorCount(block_height) == 3);

    block_height = 1009; // valid block height : 2 <= H < 1010
    man.clearExpiredValidators(block_height);
    assert(man.getValidatorCount(block_height) == 3);

    block_height = 1010; // valid block height : 3 <= H < 1011
    man.clearExpiredValidators(block_height);
    assert(man.getValidatorCount(block_height) == 2);

    block_height = 1011; // valid block height : 4 <= H < 1012
    man.clearExpiredValidators(block_height);
    assert(man.getValidatorCount(block_height) == 1);

    block_height = 1012; // valid block height : 5 <= H < 1013
    man.clearExpiredValidators(block_height);
    assert(man.getValidatorCount(block_height) == 0);
}
