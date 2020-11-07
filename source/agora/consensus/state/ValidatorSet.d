/*******************************************************************************

    Contains supporting code for managing validators' information
    using SQLite as a backing store, including the enrolled height
    which means enrollment process is confirmed as part of consensus.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.state.ValidatorSet;

import agora.common.crypto.Key;
import agora.common.ManagedDatabase;
import agora.common.Serializer;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.PreImage;
import agora.consensus.state.UTXOSet;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Schnorr;
import agora.utils.Log;
version (unittest) import agora.utils.Test;

import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.typecons : Tuple;

mixin AddLogger!();

public enum EnrollmentStatus : int
{
    Expired = 0,
    Active = 1,
}

/// The information that can be queried for an enrollment
public struct EnrollmentState
{
    /// If the most recent enrollment is still active
    EnrollmentStatus status;

    /// The Height the enrollment was accepted at
    Height enrolled_height;

    /// Length of the Validation cycle
    uint cycle_length;

    /// The most recently revealed PreImage
    Hash last_image;

    /// Distance of the most recently revealed PreImage
    ushort distance;
}

/// Delegate type to query the history of Enrollments
public alias EnrollmentFinder = bool delegate (in Hash enroll_key, out EnrollmentState state) @trusted nothrow;

/// A Height and PublicKey pair to represent expiring Validators
public alias ExpiringValidator = Tuple!(Height, "enrolled_height",
    PublicKey, "pubkey");

/// Ditto
public class ValidatorSet
{
    /// SQLite db instance
    private ManagedDatabase db;

    /// Parameters for consensus-critical constants
    private immutable(ConsensusParams) params;

    /***************************************************************************

        Constructor

        Params:
            db = the managed database instance
            params = the consensus-critical constants

    ***************************************************************************/

    public this (ManagedDatabase db, immutable(ConsensusParams) params)
    {
        this.db = db;
        this.params = params;

        // create the table for validator set if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS validator_set " ~
            "(key TEXT, public_key TEXT, " ~
            "cycle_length INTEGER, enrolled_height INTEGER, " ~
            "distance INTEGER, preimage TEXT, nonce BLOB, active INTEGER, " ~
            "PRIMARY KEY (key, active))");
    }

    /***************************************************************************

        Add a enrollment data to the validators set

        Params:
            block_height = the current block height in the ledger
            finder = the delegate to find UTXOs with
            enroll = the enrollment data to add
            pubkey = the public key of the enrollment

        Returns:
            A string describing the error, or `null` on success

    ***************************************************************************/

    public string add (in Height block_height, scope UTXOFinder finder,
        in Enrollment enroll, PublicKey pubkey) @safe nothrow
    {
        import agora.consensus.validation.Enrollment : isInvalidReason;

        // check validaty of the enrollment data
        if (auto reason = isInvalidReason(enroll, finder,
                                    block_height, &this.findRecentEnrollment))
            return reason;

        // check if already exists
        if (this.hasEnrollment(enroll.utxo_key))
            return "This validator is already enrolled";

        // check if an enrollment of the same public key is already present
        if (this.hasPublicKey(pubkey))
            return "An validator with the same public key is already enrolled";

        try
        {
            () @trusted {
                const ZeroDistance = 0;  // initial distance
                this.unenroll(enroll.utxo_key);
                this.db.execute("INSERT INTO validator_set " ~
                    "(key, public_key, cycle_length, enrolled_height, " ~
                    "distance, preimage, nonce, active) " ~
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                    enroll.utxo_key.toString(),
                    pubkey.toString(),
                    enroll.cycle_length, block_height.value, ZeroDistance,
                    enroll.random_seed.toString(),
                    extractNonce(enroll.enroll_sig)[],
                    EnrollmentStatus.Active);
            }();
        }
        catch (Exception ex)
        {
            // This should never happen, hence why we log it as well
            log.error("Unexpected error while adding a validator: {} ({})",
                      ex, enroll);
            return "Internal error in `ValidatorSet.add`";
        }

        return null;
    }

    /***************************************************************************

        Returns:
            the number of active enrollments, or 0 if there was a database error

    ***************************************************************************/

    public size_t count () @trusted nothrow
    {
        try
        {
            return this.db.execute("SELECT count(*) FROM validator_set WHERE active = ?", EnrollmentStatus.Active).
                oneValue!size_t;
        }
        catch (Exception ex)
        {
            log.error("Error while calling ValidatorSet.count(): {}", ex);
            return 0;
        }
    }

    /***************************************************************************

        Remove all validators from the validator set

    ***************************************************************************/

    public void removeAll () @trusted nothrow
    {
        try
        {
            this.db.execute("DELETE FROM validator_set");
        }
        catch (Exception ex)
        {
            log.error("Error while calling ValidatorSet.removeAll(): {}", ex);
        }
    }

    /***************************************************************************

        Unenroll the enrollment with the given UTXO key from the validator set
        First we remove any previous expired record for this key and then we set
        the current active record to expired

        Params:
            utxo_key = the UTXO key of the enrollment data to unerno

    ***************************************************************************/

    public void unenroll (in Hash enroll_hash) @trusted nothrow
    {
        try
        {
            () @trusted {
                this.db.execute("DELETE from validator_set WHERE key = ? AND active = ?",
                    EnrollmentStatus.Expired, enroll_hash.toString());
                this.db.execute("UPDATE validator_set SET active = ? WHERE key = ?",
                    EnrollmentStatus.Expired, enroll_hash.toString());
            }();
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error: {}", ex.msg);
        }
    }

    /***************************************************************************

        In validatorSet DB, return the enrolled block height.

        Params:
            enroll_hash = key for an enrollment block height

        Returns:
            the enrolled block height, or `ulong.max` if no matching key exists

    ***************************************************************************/

    public Height getEnrolledHeight (in Hash enroll_hash) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT enrolled_height FROM validator_set" ~
                " WHERE key = ? AND active = ?", enroll_hash.toString(),
                EnrollmentStatus.Active);
            if (results.empty)
                return Height(ulong.max);

            return Height(results.oneValue!(size_t));
        }
        catch (Exception ex)
        {

            log.error("ManagedDatabase operation error: {}", ex.msg);
            return Height(ulong.max);
        }
    }

    /***************************************************************************

        Check if a enrollment data exists in the validator set.

        Params:
            enroll_hash = key for an enrollment data which is hash of frozen UTXO

        Returns:
            true if the validator set has the enrollment data

    ***************************************************************************/

    public bool hasEnrollment (in Hash enroll_hash) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
                "validator_set WHERE key = ? AND active = ?)",
                enroll_hash.toString(), EnrollmentStatus.Active);
            return results.front().peek!bool(0);
        }
        catch (Exception ex)
        {
            log.fatal("Exception occured on hasEnrollment: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_hash);
            assert(0);
        }
    }

    /***************************************************************************

        Check with public key if a enrollment data exists in the validator set

        Params:
            pubkey = the key by which the validator set searches enrollment

        Returns:
            true if the validator set has an enrollment for the public key

    ***************************************************************************/

    public bool hasPublicKey (in PublicKey pubkey) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
                "validator_set WHERE public_key = ? AND active = ?)", pubkey.toString(),
                EnrollmentStatus.Active);
            return results.front().peek!bool(0);
        }
        catch (Exception ex)
        {
            log.fatal("Exception occured on hasEnrollment: {}, " ~
                "PublicKey for enrollment: {}", ex.msg, pubkey);
            assert(0);
        }
    }

    /***************************************************************************

        Get all the current validators in ascending order of public key

        Params:
            pub_keys = will contain the public keys
            height = the block height for which we want the active validators

        Returns:
            Return true if there was no error in getting the public keys

    ***************************************************************************/

    public bool getActiveValidatorPublicKeys (ref PublicKey[] pub_keys, Height height)
        @trusted nothrow
    {
        try
        {
            pub_keys.length = 0;
            assumeSafeAppend(pub_keys);
            auto results = this.db.execute("SELECT public_key FROM validator_set
                WHERE enrolled_height < ? AND active = ? ORDER BY key ASC",
                    height.value, EnrollmentStatus.Active);
            foreach (row; results)
                pub_keys ~= PublicKey.fromString(row.peek!(char[])(0));
            return true;
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error: {}", ex.msg);
            return false;
        }
    }

    /***************************************************************************

        Get all the current validators in ascending order with the utxo_key

        Params:
            validators = will be filled with all the validators during
                their validation cycles

        Returns:
            Return true if there was no error in getting the UTXO keys

    ***************************************************************************/

    public bool getEnrolledUTXOs (out Hash[] utxo_keys) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT key " ~
                "FROM validator_set WHERE active = ? ORDER BY key ASC",
                EnrollmentStatus.Active);
            foreach (row; results)
                utxo_keys ~= Hash(row.peek!(char[])(0));
            return true;
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error: {}", ex.msg);
            return false;
        }
    }

    /***************************************************************************

        Clear up expired validators whose cycle for a validator ends

        The validator set clears up expired validators from the set based on
        the block height. Validators are deleted if their enrolled height is
        less than or equal to the value of the passed block height minus the
        validator cycle.

        Params:
            block_height = current block height

    ***************************************************************************/

    public void clearExpiredValidators (Height block_height) @safe nothrow
    {
        // the smallest enrolled height would be 0 (genesis block),
        // so the passed block height should be at minimum the
        // size of the validator cycle
        if (block_height < this.params.ValidatorCycle)
            return;

        try
        {
            () @trusted {
                if (block_height > this.params.ValidatorCycle)
                {
                    this.db.execute("DELETE from validator_set " ~
                    "WHERE (enrolled_height < ? AND active = ?) or (enrolled_height < ?)",
                    EnrollmentStatus.Expired, block_height - this.params.ValidatorCycle,
                    block_height - this.params.ValidatorCycle - 1);
                }
                this.db.execute("UPDATE validator_set SET active = ? WHERE enrolled_height <= ? AND active = ?",
                    EnrollmentStatus.Expired, block_height - this.params.ValidatorCycle, EnrollmentStatus.Active);
            }();
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error: {}", ex.msg);
        }
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

    public ulong getValidatorCount (Height block_height) @safe nothrow
    {
        try
        {
            const height = (block_height >= this.params.ValidatorCycle) ?
                block_height - this.params.ValidatorCycle + 1 : 0;
            return () @trusted {
                return this.db.execute(
                    "SELECT count(*) FROM validator_set WHERE " ~
                    "enrolled_height >= ? AND active = ?", height,
                    EnrollmentStatus.Active).oneValue!ulong;
            }();
        }
        catch (Exception ex)
        {
            log.error("Database operation error {}", ex);
        }

        return 0;
    }

    /***************************************************************************

        Check if a pre-image exists

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.
            distance = The minimum expected distance to the commitment

        Returns:
            true if the pre-image exists

    ***************************************************************************/

    public bool hasPreimage (in Hash enroll_key, ushort distance) @safe
        nothrow
    {
        try
        {
            return () @trusted {
                auto results = this.db.execute("SELECT EXISTS(SELECT 1 FROM " ~
                    "validator_set WHERE key = ? AND distance >= ? AND active = ?)",
                    enroll_key.toString(), distance, EnrollmentStatus.Active);
                return results.front.peek!bool(0);
            }();
        }
        catch (Exception ex)
        {
            log.error("Exception occured on hasPreimage: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_key);
            return false;
        }
    }

    /***************************************************************************

        Extract the `R` used in the signing of the associated enrollment
        We do not check the active flag as we may get block signatures afer
        the next cycle has started

        Params:
            key = The public key of the validator
            height = height of block being signed

        Returns:
            the `R` that was used in the signing of the Enrollment,
            or `Point.init` if one was not found

    ***************************************************************************/

    public Point getCommitmentNonce (in PublicKey key, in Height height) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT nonce FROM validator_set " ~
                "WHERE public_key = ? and enrolled_height < ? " ~
                "and enrolled_height >= ?", key.toString(), height.value,
                    height.value <= this.params.ValidatorCycle ? 0 : height.value - this.params.ValidatorCycle);

            if (!results.empty && results.oneValue!(ubyte[]).length != 0)
            {
                auto row = results.front;
                return Point(row.peek!(ubyte[])(0));
            }
        }
        catch (Exception ex)
        {
            log.error("Exception occured on getCommitmentNonce: {}, " ~
                "for public key: {}", ex.msg, key);
        }

        return Point.init;
    }

    /***************************************************************************

        Get validator's pre-image from the validator set

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.

        Returns:
            the PreImageInfo of the enrolled key if it exists,
            otherwise PreImageInfo.init

    ***************************************************************************/

    public PreImageInfo getPreimage (in Hash enroll_key) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT preimage, distance FROM " ~
                "validator_set WHERE key = ? AND active = ?", enroll_key.toString(),
                EnrollmentStatus.Active);

            if (!results.empty && results.oneValue!(byte[]).length != 0)
            {
                auto row = results.front;
                Hash preimage = Hash(row.peek!(char[])(0));
                ushort distance = row.peek!ushort(1);
                return PreImageInfo(enroll_key, preimage, distance);
            }
        }
        catch (Exception ex)
        {
            log.error("Exception occured on getPreimage: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_key);
        }

        return PreImageInfo.init;
    }

    /***************************************************************************

        Get validators' pre-image information

        Params:
            start_height = the starting enrolled height to begin retrieval from
            end_height = the end enrolled height to finish retrieval to

        Returns:
            preimages' information of the validators

    ***************************************************************************/

    public PreImageInfo[] getPreimages (Height start_height,
        Height end_height) @trusted nothrow
    {
        PreImageInfo[] preimages;

        try
        {
            auto results = this.db.execute("SELECT key, preimage, distance " ~
                "FROM validator_set WHERE enrolled_height >= ? AND " ~
                "enrolled_height <= ?",
                start_height, end_height);

            foreach (row; results)
            {
                Hash enroll_key = Hash(row.peek!(char[])(0));
                Hash preimage = Hash(row.peek!(char[])(1));
                ushort distance = row.peek!ushort(2);
                preimages ~= PreImageInfo(enroll_key, preimage, distance);
            }
        }
        catch (Exception ex)
        {
            log.error("Exception occured on getPreimages: {}, heights " ~
                "[{}..{}]", ex.msg, start_height, end_height);
        }

        return preimages;
    }

    /***************************************************************************

        Get validator's pre-image for the given block height from the
        validator set

        Params:
            enroll_key = The key for the enrollment in which the pre-image is
                contained.
            height = the desired preimage block height. If it's older than
                     the preimage's current block height, the preimage will
                     be hashed until the older preimage is retrieved.
                     Otherwise PreImageInfo.init is returned.

        Returns:
            the PreImageInfo of the enrolled key if it exists,
            otherwise PreImageInfo.init

    ***************************************************************************/

    public PreImageInfo getPreimageAt (in Hash enroll_key, in Height height)
        @trusted nothrow
    {
        try
        {
            auto results = this.db.execute(
                "SELECT preimage, enrolled_height, distance " ~
                "FROM validator_set WHERE key = ? AND enrolled_height <= ? " ~
                "AND enrolled_height + distance >= ? AND active = ?",
                enroll_key.toString(), height.value, height.value,
                EnrollmentStatus.Active);

            if (!results.empty && results.oneValue!(byte[]).length != 0)
            {
                auto row = results.front;
                Hash preimage = Hash(row.peek!(char[])(0));
                Height enrolled_height = Height(row.peek!ulong(1));
                ushort distance = row.peek!ushort(2);

                // go back to the desired preimage of a previous height
                while (enrolled_height + distance > height)
                {
                    preimage = hashFull(preimage);
                    distance--;
                }

                return PreImageInfo(enroll_key, preimage, distance);
            }
        }
        catch (Exception ex)
        {
            log.error("Exception occured in getPreimageAt: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_key);
        }

        return PreImageInfo.init;
    }

    /***************************************************************************

        Add a pre-image information to a validator data

        Params:
            preimage = the pre-image information to add

        Returns:
            true if the pre-image information has been added to the validator

    ***************************************************************************/

    public bool addPreimage (in PreImageInfo preimage) @trusted nothrow
    {
        import agora.consensus.validation.PreImage : isInvalidReason;

        const prev_preimage = this.getPreimage(preimage.enroll_key);

        if (prev_preimage == PreImageInfo.init)
        {
            log.info("Rejected pre-image: validator not enrolled for key: {}",
                preimage.hash);
            return false;
        }

        // Ignore same height pre-image because validators will gossip them
        if (prev_preimage.distance == preimage.distance)
            return false;

        if (auto reason = isInvalidReason(preimage, prev_preimage,
            this.params.ValidatorCycle))
        {
            log.info("Invalid pre-image data: {}. Pre-image: {}",
                reason, preimage);
            return false;
        }

        // update the preimage info
        try
        {
            () @trusted {
                this.db.execute("UPDATE validator_set SET preimage = ?, " ~
                    "distance = ? WHERE key = ? AND active = ?",
                    preimage.hash.toString(), preimage.distance,
                    preimage.enroll_key.toString(), EnrollmentStatus.Active);
            }();
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error on addPreimage: {}, Preimage: {}",
                ex.msg, preimage);
            return false;
        }

        return true;
    }

    /***************************************************************************

        Find the most recent Enrollment with the provided UTXO hash, regardless
        of it's active status but order by status descending so that active is
        returned first

        Params:
            enroll_key = The key for the enrollment
            state = struct to fill once an enrollment is found

        Returns:
            true if an enrollment with the key was ever accepted, false otherwise

    ***************************************************************************/

    bool findRecentEnrollment (in Hash enroll_key, out EnrollmentState state) @trusted nothrow
    {
        try
        {
            // No filter for `active` field, since we want to query the whole history
            // of enrollments
            auto results = this.db.execute("SELECT active, enrolled_height," ~
                "cycle_length, preimage, distance FROM " ~
                "validator_set WHERE key = ? ORDER BY active DESC", enroll_key.toString());

            if (!results.empty && results.oneValue!(byte[]).length != 0)
            {
                auto row = results.front;
                state.status = row.peek!(EnrollmentStatus)(0);
                state.enrolled_height = Height(row.peek!(size_t)(1));
                state.cycle_length = row.peek!(uint)(2);
                state.last_image = Hash(row.peek!(char[])(3));
                state.distance = row.peek!(ushort)(4);
                return true;
            }
        }
        catch (Exception ex)
        {
            log.error("Exception occured on findRecentEnrollment: {}, " ~
                "Key for enrollment: {}", ex.msg, enroll_key);
        }

        return false;
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

    public ExpiringValidator[] getExpiringValidators (Height height,
        ref ExpiringValidator[] ex_validators)
        @trusted nothrow
    {
        ex_validators.length = 0;
        assumeSafeAppend(ex_validators);

        try
        {
            auto results = this.db.execute("SELECT enrolled_height, public_key" ~
                " FROM validator_set WHERE enrolled_height + cycle_length = ?" ~
                " AND active =  ?", height.value, EnrollmentStatus.Active);

            foreach (row; results)
            {
                ex_validators ~= ExpiringValidator(Height(row.peek!(ulong)(0)),
                    PublicKey.fromString(row.peek!(char[])(1)));
            }
        }
        catch (Exception ex)
        {
            log.error("Exception occured on findExpiringValidators: {}, ",
                ex.msg);
            ex_validators.length = 0;
        }

        return ex_validators;
    }

    /***************************************************************************

        Query stakes of active Validators

        Params:
            peekUTXO = A delegate to query UTXOs
            utxos = Array to save the stakes

        Returns:
            Staked UTXOs of existing Validators

    ***************************************************************************/

    public UTXO[] getValidatorStakes (UTXOFinder peekUTXO, ref UTXO[] utxos,
        in uint[] missing_validators) @trusted nothrow
    {
        import std.algorithm;
        import std.range;
        utxos.length = 0;
        assumeSafeAppend(utxos);

        Hash[] keys;
        if (!this.getEnrolledUTXOs(keys) || keys.length == 0)
        {
            log.fatal("Could not retrieve enrollments / no enrollments found");
            assert(0);
        }

        keys.enumerate.each!((idx, key) {
            if (missing_validators.canFind(idx))
                return;
            UTXO utxo;
            assert(peekUTXO(key, utxo), "Missing enroll UTXO");
            utxos ~= utxo;
        });

        return utxos;
    }
}

version (unittest)
private Enrollment createEnrollment(in Hash utxo_key, in KeyPair key_pair,
    in Scalar random_seed_src, uint validator_cycle)
{
    import std.algorithm;

    Pair pair = Pair.fromScalar(secretKeyToCurveScalar(key_pair.secret));

    auto enroll = Enrollment();
    auto signature_noise = Pair.random();
    auto cache = PreImageCache(validator_cycle, 1);
    cache.reset(hashFull(random_seed_src));

    enroll.utxo_key = utxo_key;
    enroll.cycle_length = validator_cycle;
    enroll.random_seed = cache[$ - 1];
    enroll.enroll_sig = sign(pair.v, pair.V, signature_noise.V,
        signature_noise.v, enroll);
    return enroll;
}

/// test for functions of ValidatorSet
unittest
{
    import agora.consensus.data.Transaction;
    import std.algorithm;
    import std.range;

    scope storage = new TestUTXOSet;
    scope set = new ValidatorSet(new ManagedDatabase(":memory:"),
        new immutable(ConsensusParams)());

    Hash[] utxos;
    genesisSpendable().take(8).enumerate
        .map!(en => en.value.refund(WK.Keys[en.index].address).sign(TxType.Freeze))
        .each!((tx) {
            storage.put(tx);
            utxos ~= UTXO.getHash(tx.hashFull(), 0);
        });

    // add enrollments
    Scalar[Hash] seed_sources;
    seed_sources[utxos[0]] = Scalar.random();
    auto enroll = createEnrollment(utxos[0], WK.Keys[0], seed_sources[utxos[0]],
        set.params.ValidatorCycle);
    assert(set.add(Height(1), &storage.peekUTXO, enroll, WK.Keys[0].address) is null);
    assert(set.count() == 1);
    ExpiringValidator[] ex_validators;
    assert(set.getExpiringValidators(
        Height(1 + set.params.ValidatorCycle), ex_validators).length == 1);
    assert(set.hasEnrollment(utxos[0]));
    assert(set.add(Height(1), &storage.peekUTXO, enroll, WK.Keys[0].address) !is null);

    seed_sources[utxos[1]] = Scalar.random();
    auto enroll2 = createEnrollment(utxos[1], WK.Keys[1], seed_sources[utxos[1]],
        set.params.ValidatorCycle);
    assert(set.add(Height(1), &storage.peekUTXO, enroll2, WK.Keys[1].address) is null);
    assert(set.count() == 2);
    assert(set.getExpiringValidators(
        Height(1 + set.params.ValidatorCycle), ex_validators).length == 2);
    // Too early
    assert(set.getExpiringValidators(
        Height(1 + set.params.ValidatorCycle - 1), ex_validators).length == 0);
    // Already expired
    assert(set.getExpiringValidators(
        Height(1 + set.params.ValidatorCycle + 1), ex_validators).length == 0);

    seed_sources[utxos[2]] = Scalar.random();
    auto enroll3 = createEnrollment(utxos[2], WK.Keys[2], seed_sources[utxos[2]],
        set.params.ValidatorCycle);
    assert(set.add(Height(9), &storage.peekUTXO, enroll3, WK.Keys[2].address) is null);
    assert(set.count() == 3);
    assert(set.getExpiringValidators(
        Height(9 + set.params.ValidatorCycle), ex_validators).length == 1);

    // check if enrolled heights are not set
    Hash[] keys;
    set.getEnrolledUTXOs(keys);
    assert(keys.length == 3);
    assert(keys.isStrictlyMonotonic!("a < b"));

    // remove ValidatorSet
    set.unenroll(utxos[1]);
    assert(set.count() == 2);
    assert(set.hasEnrollment(utxos[0]));
    set.unenroll(utxos[0]);
    assert(!set.hasEnrollment(utxos[0]));
    set.removeAll();
    assert(set.count() == 0);

    Enrollment[] ordered_enrollments;
    ordered_enrollments ~= enroll;
    ordered_enrollments ~= enroll2;
    ordered_enrollments ~= enroll3;
    /// PreImageCache for the first enrollment
    PreImageCache cache = PreImageCache(set.params.ValidatorCycle, 1);
    cache.reset(hashFull(seed_sources[utxos[0]]));

    // Reverse ordering
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (i, ordered_enroll; ordered_enrollments)
        assert(set.add(Height(1), storage.getUTXOFinder(), ordered_enroll, WK.Keys[i].address) is null);
    set.getEnrolledUTXOs(keys);
    assert(keys.length == 3);
    assert(keys.isStrictlyMonotonic!("a < b"));

    // test for adding and getting preimage
    assert(!set.hasPreimage(utxos[0], 10));
    assert(set.getPreimage(utxos[0])
        == PreImageInfo(enroll.utxo_key, enroll.random_seed, 0));
    auto preimage = PreImageInfo(utxos[0], cache[$ - 11], 10);
    assert(set.addPreimage(preimage));
    assert(set.hasPreimage(utxos[0], 10));
    assert(set.getPreimage(utxos[0]) == preimage);
    assert(set.getPreimageAt(utxos[0], Height(0))  // N/A: enrolled at height 1!
        == PreImageInfo.init);
    assert(set.getPreimageAt(utxos[0], Height(12))  // N/A: not revealed yet!
        == PreImageInfo.init);
    assert(set.getPreimageAt(utxos[0], Height(1))
        == PreImageInfo(enroll.utxo_key, enroll.random_seed, 0));
    assert(set.getPreimageAt(utxos[0], Height(11)) == preimage);
    assert(set.getPreimageAt(utxos[0], Height(10)) ==
        PreImageInfo(preimage.enroll_key, hashFull(preimage.hash),
            cast(ushort)(preimage.distance - 1)));

    // test for clear up expired validators
    seed_sources[utxos[3]] = Scalar.random();
    enroll = createEnrollment(utxos[3], WK.Keys[3], seed_sources[utxos[3]],
        set.params.ValidatorCycle);
    assert(set.add(Height(9), &storage.peekUTXO, enroll, WK.Keys[3].address) is null);
    set.clearExpiredValidators(Height(1016));
    keys.length = 0;
    assert(set.getEnrolledUTXOs(keys));
    assert(keys.length == 1);
    assert(keys[0] == utxos[3]);

    // add enrollment at the genesis block:
    // validates blocks [1 .. 1008] inclusively
    set.removeAll();  // clear all
    assert(set.count == 0);
    seed_sources[utxos[0]] = Scalar.random();
    enroll = createEnrollment(utxos[0], WK.Keys[0], seed_sources[utxos[0]],
        set.params.ValidatorCycle);
    assert(set.add(Height(0), &storage.peekUTXO, enroll, WK.Keys[0].address) is null);

    // not cleared yet at height 1007
    set.clearExpiredValidators(Height(1007));
    keys.length = 0;
    assert(set.count == 1);
    assert(set.getEnrolledUTXOs(keys));
    assert(keys.length == 1);
    assert(keys[0] == utxos[0]);

    // cleared after block height 1008 was externalized
    set.clearExpiredValidators(Height(1008));
    assert(set.count == 0);
    assert(set.getEnrolledUTXOs(keys));
    assert(keys.length == 0);
    set.removeAll();  // clear all

    // now try with validator for [1 .. 1009]
    seed_sources[utxos[0]] = Scalar.random();
    enroll = createEnrollment(utxos[0], WK.Keys[0], seed_sources[utxos[0]],
        set.params.ValidatorCycle);
    assert(set.add(Height(1), &storage.peekUTXO, enroll, WK.Keys[0].address) is null);

    // not cleared yet at height 1008
    set.clearExpiredValidators(Height(1008));
    keys.length = 0;
    assert(set.count == 1);
    assert(set.getEnrolledUTXOs(keys));
    assert(keys.length == 1);
    assert(keys[0] == utxos[0]);

    // cleared after block height 1009 was externalized
    set.clearExpiredValidators(Height(1009));
    assert(set.count == 0);
    assert(set.getEnrolledUTXOs(keys));
    assert(keys.length == 0);
}
