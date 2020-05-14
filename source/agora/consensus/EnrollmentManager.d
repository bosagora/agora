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
import agora.consensus.data.UTXOSet;
import agora.consensus.EnrollmentPool;
import agora.consensus.Validation;
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

    /// The number of cycles for a bulk of pre-images
    private static immutable uint NumberOfCycles = 100;

    /// This struct hold all the cycle data together for better readability
    private static struct PreImageCycle
    {
        /// Make sure we get initialized by disabling the default ctor
        @disable public this();
        /// Ditto
        public this (typeof(PreImageCycle.tupleof) args)
        {
            this.tupleof = args;
        }

        /***********************************************************************

            The number of the current cycle

            This is the data used as a nonce in generating the cycle seed.
            Named `nonce` to avoid any ambiguity. It is incremented once every
            `EnrollPerCycle` period, currently 700 days.

        ***********************************************************************/

        private uint nonce;

        /***********************************************************************

            The index of the enrollment within the current cycle

            This number is incremented every time a new Enrollment is accepted
            by the consensus protocol, and reset when `nonce` is incremented.

        ***********************************************************************/

        private uint index;

        /***********************************************************************

            Seed for all enrollments for the current cycle

            This variable is changed every time `nonce` is changed,
            and contains all the roots used to generate the `preimages` value.

        ***********************************************************************/

        private PreImageCache seeds;

        /***********************************************************************

            Currently active list of pre-images

            This variable is changed every time `index` is changed, to reflect
            the current Enrollment's pre-images.

        ***********************************************************************/

        private PreImageCache preimages;

        /***********************************************************************

            Consume the current cycle

            This will first populate the caches (seeds and preimages)
            as necessary, then increase the `index` by one, or reset it to 0
            and increase `nonce` if necessary.
            Note that the increment is done after the caches are populated,
            so `consume` needs to be called once this node has confirmed it
            is part of consensus.

            Params:
              secret = The secret key of the node, used as part of the hash
                       to generate the cycle seeds

            Returns:
              The hash of the current enrollment round

        ***********************************************************************/

        private Hash consume (scope const ref Scalar secret) @safe nothrow
        {
            // Populate the nonce cache if necessary
            if (this.index == 0)
            {
                const cycle_seed = hashMulti(
                    secret, "consensus.preimages", this.nonce);
                this.seeds.reset(cycle_seed);
            }
            // Populare the current enrollment round cache
            const ret = this.preimages.reset(this.seeds[this.index]);

            // Increment index if there are rounds left in this cycle
            if (this.index < NumberOfCycles)
                this.index += 1;
            else
            {
                this.index = 0;
                this.nonce += 1;
            }

            return ret;
        }
    }

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
            /* seeds:  */ PreImageCache(NumberOfCycles, Enrollment.ValidatorCycle),
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
        auto results = this.db.execute("SELECT val FROM node_enroll_data " ~
            "WHERE key = ?", "enroll_key");

        if (!results.empty)
            this.enroll_key = results.oneValue!(ubyte[]).deserializeFull!(Hash);

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

    /***************************************************************************

        Add a enrollment data to the enrollment pool

        Params:
            enroll = the enrollment data to add
            finder = the delegate to find UTXOs with

        Returns:
            true if the enrollment data has been added to the enrollment pool

    ***************************************************************************/

    public bool add (const ref Enrollment enroll, scope UTXOFinder finder)
        @safe nothrow
    {
        return this.enroll_pool.add(enroll, finder);
    }

    /***************************************************************************

        Remove the enrollment data with the given key from the validator set

        Params:
            enroll_hash = key for an enrollment data to remove

    ***************************************************************************/

    public void remove (const ref Hash enroll_hash) @trusted
    {
        this.enroll_pool.remove(enroll_hash);
    }

    /***************************************************************************

        In validatorSet DB, return the enrolled block height.

        Params:
            enroll_hash = key for an enrollment block height

        Returns:
            the enrolled block height, or 0 if no matching key exists

    ***************************************************************************/

    public size_t getEnrolledHeight (const ref Hash enroll_hash) @trusted
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
            true if the update operation was successful, false otherwise

    ***************************************************************************/

    public bool addValidator (const ref Enrollment enroll,
        size_t block_height, scope UTXOFinder finder) @safe
    {
        this.enroll_pool.remove(enroll.utxo_key);

        if (!this.validator_set.add(block_height, finder, enroll))
            return false;

        // set next height for revealing a pre-image
        if (enroll.utxo_key == this.enroll_key)
            this.setNextRevealHeight(block_height);

        return true;
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
        try
        {
            serializeToBuffer(this.enroll_key, buffer);
        }
        catch (Exception ex)
        {
            this.logMessage("Serialization error of enroll_key", enroll, ex);
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
            this.logMessage("Database operation error", enroll, ex);
            return false;
        }

        // signature
        data.enroll_sig = sign(this.key_pair.v, this.key_pair.V, this.signature_noise.V,
            this.signature_noise.v, this.data);

        enroll = this.data;

        return true;
    }

    /***************************************************************************

        Check if a enrollment data exists in the enrollment pool.

        Params:
            enroll_hash = key for an enrollment data which is hash of frozen UTXO

        Returns:
            true if the enrollment pool has the enrollment data

    ***************************************************************************/

    private bool hasEnrollment (const ref Hash enroll_hash) @trusted
    {
        return this.enroll_pool.hasEnrollment(enroll_hash);
    }

    /***************************************************************************

        Get the enrollment data with the key, and store it to 'enroll' if found

        Params:
            enroll_hash = key for an enrollment data which is a hash of a frozen
                            UTXO
            enroll = will contain the enrollment data if found

        Returns:
            Return true if the enrollment data was found

    ***************************************************************************/

    public bool getEnrollment (const ref Hash enroll_hash,
        out Enrollment enroll) @trusted
    {
        return this.enroll_pool.getEnrollment(enroll_hash, enroll);
    }

    /***************************************************************************

        Get all the current validators

        Params:
            validators = will be filled with all the validators during
                their validation cycles

        Returns:
            Return true if there is no error in getting validators

    ***************************************************************************/

    public bool getValidators (out Enrollment[] validators) @safe nothrow
    {
        return this.validator_set.getValidators(validators);
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

        Get the unregistered enrollments in the block
        And this is arranged in ascending order with the utxo_key

        Params:
            enrolls = will contain the unregistered enrollments data if found

        Returns:
            The unregistered enrollments data

    ***************************************************************************/

    public Enrollment[] getUnregistered (ref Enrollment[] enrolls)
        @trusted
    {
        return this.enroll_pool.getEnrollments(enrolls);
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
        const start_height =
            this.validator_set.getEnrolledHeight(this.enroll_key) + 1;
        if (height < start_height)
            return false;
        immutable index = (height - start_height);
        if (index > Enrollment.ValidatorCycle - 1)
            return false;

        preimage.enroll_key = this.data.utxo_key;
        preimage.distance = index;
        preimage.hash = this.cycle.preimages[index];
        return true;
    }

    /***************************************************************************

        Check if a pre-image exists

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.
            height = The block height of the preimage to check existence

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool hasPreimage (const ref Hash enroll_key, ulong height) @safe
        nothrow
    {
        return this.validator_set.hasPreimage(enroll_key, height);
    }

    /***************************************************************************

        Get validator's pre-image from the validator set

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.
            result_image = will contain the PreImageInfo if exists

        Returns:
            true if getting pre-image is successfully processed

    ***************************************************************************/

    public bool getValidatorPreimage (const ref Hash enroll_key,
        out PreImageInfo result_image) @trusted nothrow
    {
        return this.validator_set.getPreimage(enroll_key, result_image);
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

        Logs message

        Params:
            msg = the log message to be logged
            enroll = the Enrollment object, the information of which will be logged
            ex = the Exception object, the message of which will be logged

    ***************************************************************************/

    private static void logMessage (string msg, const ref Enrollment enroll,
        const Exception ex = null) @safe nothrow
    {
        try
        {
            if (ex !is null)
            {
                log.error("{}, enrollment:{}, exception:{}", msg, enroll, ex);
            }
            else
            {
                log.info("{}, enrollment:{}", msg, enroll);
            }
        }
        catch (Exception ex)
        {}
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
    fail_enroll.enroll_sig = sign(fail_enroll_key_pair.v, fail_enroll_key_pair.V,
        signature_noise.V, signature_noise.v, fail_enroll);

    assert(man.createEnrollment(utxo_hash, 1, enroll));
    assert(!man.hasEnrollment(utxo_hash));
    assert(!man.add(fail_enroll, &storage.findUTXO));
    assert(man.add(enroll, &storage.findUTXO));
    assert(man.enroll_pool.count() == 1);
    assert(man.hasEnrollment(utxo_hash));
    assert(!man.add(enroll, &storage.findUTXO));

    // create and add the second Enrollment object
    auto utxo_hash2 = utxo_hashes[1];
    assert(man.createEnrollment(utxo_hash2, 1, enroll2));
    assert(man.add(enroll2, &storage.findUTXO));
    assert(man.enroll_pool.count() == 2);

    auto utxo_hash3 = utxo_hashes[2];
    Enrollment enroll3;
    assert(man.createEnrollment(utxo_hash3, 1, enroll3));
    assert(man.add(enroll3, &storage.findUTXO));
    assert(man.enroll_pool.count() == 3);

    Enrollment[] enrolls;
    man.getUnregistered(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // get a stored Enrollment object
    Enrollment stored_enroll;
    assert(man.getEnrollment(utxo_hash2, stored_enroll));
    assert(stored_enroll == enroll2);

    // remove an Enrollment object
    man.remove(utxo_hash2);
    assert(man.enroll_pool.count() == 2);

    // test for getEnrollment with removed enrollment
    assert(!man.getEnrollment(utxo_hash2, stored_enroll));

    // test for enrollment block height update
    assert(!man.getEnrolledHeight(utxo_hash));
    assert(man.addValidator(enroll, 9, &storage.findUTXO));
    assert(man.getEnrolledHeight(enroll.utxo_key) == 9);
    assert(!man.addValidator(enroll, 9, &storage.findUTXO));
    assert(man.getEnrolledHeight(enroll2.utxo_key) == 0);
    man.getUnregistered(enrolls);
    assert(enrolls.length == 1);
    // One Enrollment was moved to validator set
    assert(man.validator_set.count() == 1);
    assert(man.enroll_pool.count() == 1);

    man.remove(utxo_hash);
    man.remove(utxo_hash2);
    man.remove(utxo_hash3);
    assert(man.getUnregistered(enrolls).length == 0);

    Enrollment[] ordered_enrollments;
    ordered_enrollments ~= enroll;
    ordered_enrollments ~= enroll2;
    ordered_enrollments ~= enroll3;
    // Reverse ordering
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (ordered_enroll; ordered_enrollments)
        assert(man.add(ordered_enroll, &storage.findUTXO));
    man.getUnregistered(enrolls);
    assert(enrolls.length == 3);
    assert(enrolls.isStrictlyMonotonic!("a.utxo_key < b.utxo_key"));

    // clear up all validators
    man.clearExpiredValidators(1018);

    // get a pre-image at a certain height
    // A validation can start at the height of the enrolled height plus 1.
    // So, a pre-image can only be got from the start height.
    PreImageInfo preimage;
    assert(man.createEnrollment(utxo_hash, 1, enroll));
    assert(man.addValidator(enroll, 10, &storage.findUTXO));
    assert(!man.getPreimage(10, preimage));
    assert(man.getPreimage(11, preimage));
    assert(man.getPreimage(10 + Enrollment.ValidatorCycle, preimage));
    assert(!man.getPreimage(11 + Enrollment.ValidatorCycle, preimage));

    /// test for the functions about periodic revelation of a pre-image
    assert(man.needRevealPreimage(10));
    man.increaseNextRevealHeight();
    assert(man.needRevealPreimage(16));

    // If the height of the requested preimage exceeds the height of the end of
    // the validator cycle, the `getNextPreimage` must return `false`.
    man.next_reveal_height = 10 + Enrollment.ValidatorCycle;
    assert(!man.getNextPreimage(preimage));

    // test for getting validators
    Enrollment[] validators;

    // validator A with the `utxo_hash` and the enrolled height of 10.
    // validator B with the 'utxo_hash2' and the enrolled height of 11.
    // validator C with the 'utxo_hash3' and no enrolled height.
    assert(man.addValidator(enroll2, 11, &storage.findUTXO));
    man.clearExpiredValidators(11);
    assert(man.validatorCount() == 2);
    assert(man.getValidators(validators));
    assert(validators.length == 2);

    // set an enrolled height for validator C
    // set the block height to 1019, which means validator B is expired.
    // there is only one validator in the middle of 1020th block being made.
    assert(man.addValidator(enroll3, 1019, &storage.findUTXO));
    man.clearExpiredValidators(1019);
    assert(man.validatorCount() == 1);
    assert(man.getValidators(validators));
    assert(validators.length == 1);
    assert(validators[0].utxo_key == enroll3.utxo_key);
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
    assert(man.add(enroll, &storage.findUTXO));
    assert(man.hasEnrollment(utxo_hash));

    PreImageInfo result_image;
    assert(man.getValidatorPreimage(utxo_hash, result_image));
    assert(result_image == PreImageInfo.init);
    auto preimage = PreImageInfo(utxo_hash, man.cycle.preimages[100], 1100);
    assert(man.addValidator(enroll, 2, &storage.findUTXO));
    assert(man.addPreimage(preimage));
    assert(man.getValidatorPreimage(utxo_hash, result_image));
    assert(result_image.enroll_key == utxo_hash);
    assert(result_image.hash == man.cycle.preimages[100]);
    assert(result_image.distance == 1100);
}
