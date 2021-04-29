/*******************************************************************************

    Contains supporting code for managing validators' information
    using SQLite as a backing store, including the enrolled height
    which means enrollment process is confirmed as part of consensus.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.state.ValidatorSet;

import agora.common.ManagedDatabase;
import agora.common.Types;
import agora.consensus.data.Block;
import agora.consensus.data.Enrollment;
import agora.consensus.data.Params;
import agora.consensus.data.PreImageInfo;
import agora.consensus.PreImage;
import agora.consensus.state.UTXOCache;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;
import agora.crypto.Schnorr;
import agora.serialization.Serializer;
import agora.utils.Log;
version (unittest) import agora.utils.Test;

import d2sqlite3.library;
import d2sqlite3.results;
import d2sqlite3.sqlite3;

import std.typecons : Tuple;

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
    PreImageInfo preimage;
}

/// Delegate type to query the history of Enrollments
public alias EnrollmentFinder = bool delegate (in Hash enroll_key, out EnrollmentState state) @trusted nothrow;

/// A Height and PublicKey pair to represent expiring Validators
public alias ExpiringValidator = Tuple!(Height, "enrolled_height",
    PublicKey, "pubkey");

/// Ditto
public class ValidatorSet
{
    /// Logger instance
    protected Logger log;

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
        this.log = Logger(__MODULE__);

        // create the table for validator set if it doesn't exist yet
        this.db.execute("CREATE TABLE IF NOT EXISTS validator " ~
            "(key TEXT, public_key TEXT, " ~
            "cycle_length INTEGER, enrolled_height INTEGER, " ~
            "distance INTEGER, preimage TEXT, nonce TEXT, active INTEGER, " ~
            "PRIMARY KEY (key, active))");
    }

    /***************************************************************************

        Add a enrollment data to the validators set

        Params:
            height = the current block height in the ledger
            finder = the delegate to find UTXOs with
            enroll = the enrollment data to add
            pubkey = the public key of the enrollment

        Returns:
            A string describing the error, or `null` on success

    ***************************************************************************/

    public string add (Height height, scope UTXOFinder finder,
        const ref Enrollment enroll, PublicKey pubkey) @safe nothrow
    {
        import agora.consensus.validation.Enrollment : isInvalidReason;

        // check validaty of the enrollment data
        if (auto reason = isInvalidReason(enroll, finder,
                                    height, &this.findRecentEnrollment))
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
                this.db.execute("INSERT INTO validator " ~
                    "(key, public_key, cycle_length, enrolled_height, " ~
                    "distance, preimage, nonce, active) " ~
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
                    enroll.utxo_key,
                    pubkey,
                    enroll.cycle_length, height.value, ZeroDistance,
                    enroll.commitment,
                    enroll.enroll_sig.R,
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

        Remove all validators from the validator set

    ***************************************************************************/

    public void removeAll () @trusted nothrow
    {
        try
        {
            this.db.execute("DELETE FROM validator");
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
                this.db.execute("DELETE from validator WHERE key = ? AND active = ?",
                    EnrollmentStatus.Expired, enroll_hash);
                this.db.execute("UPDATE validator SET active = ? WHERE key = ?",
                    EnrollmentStatus.Expired, enroll_hash);
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
            auto results = this.db.execute("SELECT enrolled_height FROM validator" ~
                " WHERE key = ? AND active = ?", enroll_hash, EnrollmentStatus.Active);
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
                "validator WHERE key = ? AND active = ?)",
                enroll_hash, EnrollmentStatus.Active);
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
                "validator WHERE public_key = ? AND active = ?)", pubkey,
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

        Get all the current validators in ascending order of the utxo key

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
            auto results = this.db.execute("SELECT public_key FROM validator
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

        Get all the current validators in ascending order with the utxo key

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
                "FROM validator WHERE active = ? ORDER BY key ASC",
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
            height = current block height

    ***************************************************************************/

    public void clearExpiredValidators (Height height) @safe nothrow
    {
        // the smallest enrolled height would be 0 (genesis block),
        // so the passed block height should be at minimum the
        // size of the validator cycle
        if (height < this.params.ValidatorCycle)
            return;

        try
        {
            () @trusted {
                if (height > this.params.ValidatorCycle)
                {
                    this.db.execute("DELETE from validator " ~
                    "WHERE (enrolled_height < ? AND active = ?) or (enrolled_height < ?)",
                    EnrollmentStatus.Expired, height - this.params.ValidatorCycle,
                    height - this.params.ValidatorCycle - 1);
                }
                this.db.execute("UPDATE validator SET active = ? WHERE enrolled_height <= ? AND active = ?",
                    EnrollmentStatus.Expired, height - this.params.ValidatorCycle, EnrollmentStatus.Active);
            }();
        }
        catch (Exception ex)
        {
            log.error("ManagedDatabase operation error: {}", ex.msg);
        }
    }

    /***************************************************************************

        Gets the number of active validators at a given block height.

        This function finds validators that should be active at a given height,
        provided they do not get slashed in between. Active validators are those
        that can sign a block.

        This can be used to look up arbitrary height in the future, as long as
        the height is not over `ValidatorCycle` distance from the known state
        of the ValidatorSet (in such case, 0 will always be returned).

        Params:
            height = height at which to count the validators

        Returns:
            Returns the number of active validators when the block height is
            `block_height`, or 0 in case of error.

    ***************************************************************************/

    public ulong countActive (in Height height) @safe nothrow
    {
        try
        {
            // E.g. for initial validators, enrolled at height 0,
            // they will validate blocks [1 .. 20] if the cycle is 20.
            const from_height = (height >= this.params.ValidatorCycle) ?
                (height - this.params.ValidatorCycle) : 0;
            return () @trusted {
                return this.db.execute(
                    "SELECT count(*) FROM validator WHERE " ~
                    "enrolled_height >= ? AND active = ?", from_height,
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

    public Point getCommitmentNonce (const ref PublicKey key, in Height height) @trusted nothrow
    {
        try
        {
            auto results = this.db.execute("SELECT nonce FROM validator " ~
                "WHERE public_key = ? and enrolled_height < ? " ~
                "and enrolled_height >= ?", key, height.value,
                    height.value <= this.params.ValidatorCycle ? 0 : height.value - this.params.ValidatorCycle);

            if (!results.empty && results.oneValue!(string).length != 0)
            {
                auto row = results.front;
                return Point(row.peek!(string)(0));
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
                "validator WHERE key = ? AND active = ?", enroll_key,
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
                "FROM validator WHERE enrolled_height >= ? AND " ~
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
                "FROM validator WHERE key = ? " ~
                "AND enrolled_height + distance >= ? ORDER BY enrolled_height + distance",
                enroll_key, height.value);

            if (!results.empty && results.oneValue!(byte[]).length != 0)
            {
                auto row = results.front;
                Hash preimage = Hash(row.peek!(char[])(0));
                Height enrolled_height = Height(row.peek!ulong(1));
                ushort distance = row.peek!ushort(2);

                auto pi = PreImageInfo(enroll_key, preimage, distance);
                auto times = enrolled_height + distance - height;
                return (times > pi.distance) ? PreImageInfo.init : pi.adjust(times);
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

    public bool addPreimage (const ref PreImageInfo preimage) @trusted nothrow
    {
        import agora.consensus.validation.PreImage : isInvalidReason;

        const prev_preimage = this.getPreimage(preimage.utxo);

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
                this.db.execute("UPDATE validator SET preimage = ?, " ~
                    "distance = ? WHERE key = ? AND active = ?",
                    preimage.hash, preimage.distance, preimage.utxo,
                    EnrollmentStatus.Active);
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
                "validator WHERE key = ? ORDER BY active DESC", enroll_key);

            if (!results.empty && results.oneValue!(byte[]).length != 0)
            {
                auto row = results.front;
                state.status = row.peek!(EnrollmentStatus)(0);
                state.enrolled_height = Height(row.peek!(size_t)(1));
                state.cycle_length = row.peek!(uint)(2);
                state.preimage.utxo = enroll_key;
                state.preimage.hash = Hash(row.peek!(char[])(3));
                state.preimage.distance = row.peek!(ushort)(4);
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
                " FROM validator WHERE enrolled_height + cycle_length = ?" ~
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
        const ref uint[] missing_validators) @trusted nothrow
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

    /***************************************************************************

        Returns:
            The lowest height an `Enrollment` had to appear at for it to be
            a validator at `height`

    ***************************************************************************/

    public Height minEnrollmentHeight (in Height height) const scope @safe
        pure nothrow @nogc
    {
        return Height(height <= this.params.ValidatorCycle ? 0
            : height - this.params.ValidatorCycle);
    }
}

/// test for functions of ValidatorSet
unittest
{
    import agora.consensus.data.Transaction;
    import agora.consensus.EnrollmentManager;
    import std.algorithm;
    import std.range;

    const FirstEnrollHeight = Height(1);
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
    auto enroll = EnrollmentManager.makeEnrollment(utxos[0], WK.Keys[0], FirstEnrollHeight, set.params.ValidatorCycle);
    assert(set.add(FirstEnrollHeight, &storage.peekUTXO, enroll, WK.Keys[0].address) is null);
    assert(set.countActive(FirstEnrollHeight) == 1);
    ExpiringValidator[] ex_validators;
    assert(set.getExpiringValidators(
        FirstEnrollHeight + set.params.ValidatorCycle, ex_validators).length == 1);
    assert(set.hasEnrollment(utxos[0]));
    assert(set.add(FirstEnrollHeight, &storage.peekUTXO, enroll, WK.Keys[0].address) !is null);

    auto enroll2 = EnrollmentManager.makeEnrollment(utxos[1], WK.Keys[1], FirstEnrollHeight, set.params.ValidatorCycle);
    assert(set.add(FirstEnrollHeight, &storage.peekUTXO, enroll2, WK.Keys[1].address) is null);
    assert(set.countActive(FirstEnrollHeight) == 2);
    assert(set.getExpiringValidators(
        FirstEnrollHeight + set.params.ValidatorCycle, ex_validators).length == 2);
    // Too early
    assert(set.getExpiringValidators(
        FirstEnrollHeight + (set.params.ValidatorCycle - 1), ex_validators).length == 0);
    // Already expired
    assert(set.getExpiringValidators(
        FirstEnrollHeight + (set.params.ValidatorCycle + 1), ex_validators).length == 0);

    const SecondEnrollHeight = Height(9);
    auto enroll3 = EnrollmentManager.makeEnrollment(utxos[2], WK.Keys[2], SecondEnrollHeight, set.params.ValidatorCycle);
    assert(set.add(SecondEnrollHeight, &storage.peekUTXO, enroll3, WK.Keys[2].address) is null);
    assert(set.countActive(SecondEnrollHeight) == 3);
    assert(set.getExpiringValidators(
        SecondEnrollHeight + set.params.ValidatorCycle, ex_validators).length == 1);

    // check if enrolled heights are not set
    Hash[] keys;
    set.getEnrolledUTXOs(keys);
    assert(keys.length == 3);
    assert(keys.isStrictlyMonotonic!("a < b"));

    // remove ValidatorSet
    set.unenroll(utxos[1]);
    assert(set.countActive(SecondEnrollHeight) == 2);
    assert(set.hasEnrollment(utxos[0]));
    set.unenroll(utxos[0]);
    assert(!set.hasEnrollment(utxos[0]));
    set.removeAll();
    assert(set.countActive(SecondEnrollHeight + 1) == 0);

    Enrollment[] ordered_enrollments;
    ordered_enrollments ~= enroll;
    ordered_enrollments ~= enroll2;
    ordered_enrollments ~= enroll3;
    /// PreImageCache for the first enrollment
    auto cache = PreImageCycle(WK.Keys[0].secret, set.params.ValidatorCycle);

    // Reverse ordering
    ordered_enrollments.sort!("a.utxo_key > b.utxo_key");
    foreach (i, ordered_enroll; ordered_enrollments)
        assert(set.add(FirstEnrollHeight, storage.getUTXOFinder(), ordered_enroll, WK.Keys[i].address) is null);
    set.getEnrolledUTXOs(keys);
    assert(keys.length == 3);
    assert(keys.isStrictlyMonotonic!("a < b"));

    // test for adding and getting preimage
    assert(set.getPreimage(utxos[0])
        == PreImageInfo(enroll.utxo_key, enroll.commitment, 0));
    auto preimage_11 = PreImageInfo(utxos[0], cache[SecondEnrollHeight + 2], cast(ushort)(SecondEnrollHeight + 1));
    assert(set.addPreimage(preimage_11));
    assert(set.getPreimage(utxos[0]) == preimage_11);
    assert(set.getPreimageAt(utxos[0], Height(FirstEnrollHeight - 1))  // N/A: enrolled at height 1!
        == PreImageInfo.init);
    assert(set.getPreimageAt(utxos[0], SecondEnrollHeight + 3)  // N/A: not revealed yet!
        == PreImageInfo.init);
    assert(set.getPreimageAt(utxos[0], FirstEnrollHeight)
        == PreImageInfo(enroll.utxo_key, enroll.commitment, 0));
    assert(set.getPreimageAt(utxos[0], SecondEnrollHeight + 2) == preimage_11);
    assert(set.getPreimageAt(utxos[0], SecondEnrollHeight + 1) ==
        PreImageInfo(utxos[0], hashFull(preimage_11.hash),
            cast(ushort)(preimage_11.distance - 1)));

    // test for clear up expired validators
    enroll = EnrollmentManager.makeEnrollment(utxos[3], WK.Keys[3], SecondEnrollHeight, set.params.ValidatorCycle);
    assert(set.add(SecondEnrollHeight, &storage.peekUTXO, enroll, WK.Keys[3].address) is null);
    set.clearExpiredValidators(SecondEnrollHeight + (set.params.ValidatorCycle - 1));
    keys.length = 0;
    assert(set.getEnrolledUTXOs(keys));
    assert(keys.length == 1);
    assert(keys[0] == utxos[3]);

    // add enrollment at the genesis block:
    // validates blocks [1 .. ValidatorCycle] inclusively
    assert(set.params.ValidatorCycle > 10);
    set.removeAll();  // clear all

    assert(set.countActive(SecondEnrollHeight + 1) == 0);
    enroll = EnrollmentManager.makeEnrollment(utxos[0], WK.Keys[0], FirstEnrollHeight, set.params.ValidatorCycle);
    assert(set.add(FirstEnrollHeight, &storage.peekUTXO, enroll, WK.Keys[0].address) is null);

    // not cleared yet at the last block where validators are active
    set.clearExpiredValidators(Height(set.params.ValidatorCycle));
    keys.length = 0;

    assert(set.countActive(Height(set.params.ValidatorCycle)) == 1);
    assert(set.getEnrolledUTXOs(keys));
    assert(keys.length == 1);
    assert(keys[0] == utxos[0]);

    // cleared after a new cycle was started
    set.clearExpiredValidators(Height(set.params.ValidatorCycle + 1));
    assert(set.countActive(Height(set.params.ValidatorCycle + 1)) == 0);
    assert(set.getEnrolledUTXOs(keys));
    assert(keys.length == 0);
    set.removeAll();  // clear all
}
