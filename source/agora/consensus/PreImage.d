/*******************************************************************************

    Hold pre-image related utilities

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.PreImage;

import agora.common.Types;
import agora.crypto.ECC;
import agora.crypto.Hash;
import agora.crypto.Key;

/*******************************************************************************

    Helper struct to manage a range of pre-images

    When dealing with pre-images, the only unrecoverable data is the seed.
    Everything else is, by definition, derived from the seed.
    As a result, we can compress the data as much as we want,
    to reduce memory usage. However, this comes at the cost of more computation.

    For example, if we have cycles of 10 pre-images, we can first compute the
    seed (H0), then reveal our initial commitment (H9). This will cost us
    9 hash operations. Then on the next reveal, in order to get H8, we need to
    perform 8 hash operations, then 7 for H7, etc...

    If we want to improve this, we can store intermediate results:
    when generating H9, we do perform 9 hash operations, but store H5.
    Hence, when generating H8 and H7, we only need to perform
    3 and 2 hash operations, respectively, and will never need to perform more
    than 4 operations (save the initial commitment).

    This structure is a mean to generalize this approach, with arbitrary count
    and arbitrary sample size (interval, or distance, between saved pre-images).

*******************************************************************************/

public struct PreImageCache
{
    @safe:

    /// Describe print modes for `toString`
    public enum PrintMode
    {
        /// Print the two extreme values
        Bounds,
        /// Print all stored intermediate value and the last bound
        Stride,
        /// Print all values, performing intermediate hashing
        All,
    }

    /***************************************************************************

        Print the content of a cache

        By default, this function prints the bounds of the cache (the value at
        index 0, and the last value, as returned by `reset`).
        Changing the mode makes it print either the internal content, or the
        full range that is covered, in a newline-separated list.
        Those two later mode are intended for debugging. The parameterless
        `toString` overload is not implemented for this reason.

        Params:
          sink = The sink to write the piecemeal string data to
          mode = The `PrintMode` to use for printing the content.
                 By default, only the bounds (0 and $) are printed.

    ***************************************************************************/

    public void toString (scope void delegate(scope const(char)[]) @safe sink,
                          PrintMode mode = PrintMode.Bounds) const @safe
    {
        final switch (mode)
        {
        case PrintMode.Bounds:
            this[0].toString(sink);
            sink(" - ");
            this[$ - 1].toString(sink);
            break;

        case PrintMode.Stride:
            foreach (index, const ref value; this.data)
            {
                if (index > 0) sink("\n");
                value.toString(sink);
            }
            break;

        case PrintMode.All:
            foreach (index; 0 .. this.length)
            {
                if (index > 0) sink("\n");
                this[index].toString(sink);
                if ((index % this.interval) == 0)
                    sink(" [STORED]");
            }
            break;
        }
    }

    nothrow:

    /// Store the actual preimages
    private Hash[] data;

    /// Interval between two preimages in `data`
    private const ulong interval;

    /// Default-initialized `PreImageCache` is not valid, make sure it can't
    /// be accidentally constructed (e.g. by embbeding it in another aggregate)
    @disable public this ();

    /// Construct an instance using already existing data
    public this (inout(Hash)[] data_, ulong sample_size) inout @nogc pure
    {
        assert(sample_size > 0, "The distance must be at least 1");

        this.data = data_;
        this.interval = sample_size;
    }

    /***************************************************************************

        Construct an instance and allocate memory

        This takes a `count` of pre-image and a sample size, or distance.
        For example, if one wishes to represent a range of 1000 pre-images with
        this cache, and perform no more than 5 hash operations each time,
        the `sample_size` should be `5` and the `count` should be `200`
        (1000 / 5).

        Params:
          count = Number of samples to store (number of entries in the array)
          sample_size = Distance between two pre-images. If the value 1 is
                        provided, the pre-images will be consecutives and
                        this struct will behave essentially like an array.

    ***************************************************************************/

    public this (ulong count, ulong sample_size) pure
    {
        assert(count > 1, "A count of less than 2 does not make sense");
        this(new Hash[](count), sample_size);
    }

    /***************************************************************************

        Populate this cache from the `seed`

        Params:
          seed = Initial value to derive preimage from. This will always be the
                 first value of the array.
          length = The number of entries to populate.
                   This can be used when large sample size are used,
                   and one wishes to stop initialization past a certain threshold.

    ***************************************************************************/

    public void reset (in Hash seed, size_t length)
    {
        // Set the length, so that extra entries are not accessible through
        // `opIndex`
        assert(length > 0, "The length of the array should be at least 1");
        this.data.length = length;
        () @trusted { assumeSafeAppend(this.data); }();
        this.reset(seed);
    }

    /// Ditto
    public void reset (Hash seed) @nogc
    {
        this.data[0] = seed;
        foreach (ref entry; this.data[1 .. $])
        {
            foreach (idx; 0 .. this.interval)
                seed = hashFull(seed);
            entry = seed;
        }
    }

    /***************************************************************************

        Get the hash at index `idx` in the cycle

        Will perform at most `cycle_length % interval` computations.

    ***************************************************************************/

    public Hash opIndex (size_t index) const @nogc
    {
        immutable startIndex = (index / this.interval);
        // This will trigger out of bound if needed
        // We could possibly silently allow to index arbitrarily outside the
        // array by just taking the computational hit, since indexing past the
        // end means we are generating new pre-images, but it sounds like abuse
        Hash value = this.data[startIndex];
        foreach (_; (startIndex * this.interval) .. index)
            value = hashFull(value);
        return value;
    }

    /// Alias to the underlying data, useful when dealing with multiple levels
    public const(Hash)[] byStride () const pure @nogc { return this.data; }

    /// Returns: The number of preimages this cache can represent
    public size_t length () const pure nothrow @nogc @safe
    {
        return this.interval * this.data.length;
    }

    /// Ditto
    alias opDollar = length;
}

///
unittest
{
    Hash[32] data;
    data[0] = hashFull("Hello World");
    foreach (idx, ref entry; data[1 .. $])
        entry = hashFull(data[idx]);

    // First case and last two are degenerate
    immutable intervals = [1, 2, 4, 8, 16];
    foreach (interval; intervals)
    {
        auto cache = PreImageCache(data.length / interval, interval);
        cache.reset(data[0]);
        foreach (idx, const ref value; data)
            assert(value == cache[idx]);

        // Test `length` and `$` properties
        assert(cache[$-1] == data[$-1]);
        assert(cache[cache.length - 1] == data[$-1]);

        switch (interval)
        {
        case 32:
        case 16:
        case 8:
        case 4:
        case 2:
        case 1:
            assert(cache.data.length == (32 / interval));
            size_t data_idx;
            foreach (idx, const ref entry; cache.data)
            {
                assert(entry == data[data_idx]);
                data_idx += interval;
            }
            break;

        case 64:
            assert(cache.data.length == 1);
            assert(cache.data[0] == data[0]);
            break;

        default:
            assert(0);
        }
    }
}

/*******************************************************************************

    Combines two PreImageCache, allowing for faster lookup

    Nodes generate a large amount of pre-images on startup, then will seek to
    a certain position in their pre-image chain and use the values sequentially.
    In order to reduce the space usage of nodes, while ensuring they don't
    get random delays while seeking pre-images, this struct holds two caches.
    The `seeds` are sparse values spawing the whole pre-image chain, while the
    `preimages` are consecutive values for the current cycle.

*******************************************************************************/

public struct PreImageCycle
{
    @safe nothrow:

    /// Make sure we get initialized by disabling the default ctor
    @disable public this ();

    /// The total number of pre-images
    public static immutable ulong PreImageCount = 5_040_000;

    /***************************************************************************

        Construct an instance based on a secret

        The secret will be hashed in a predictable manner, and this will give
        the 'seed' hash, which will correspond to the last pre-image the node
        will be able to reveal (at height `cycles * cycle_length`).

        This overload is provided for convenience. To have more control over
        the pre-image, see the overload accepting a Hash.

        Params:
          secret = The secret to use to generate the pre-image
          cycle_length = The length of a cycle
          cycles = Number of cycles to generate (defaults to 100)
          initial_seek = The value to seek at after generating the seeds

    ***************************************************************************/

    public this (in Scalar secret, in uint cycle_length,
        in ulong preimage_count = PreImageCount, in Height initial_seek = Height(0))
    {
        // Using this predictable scheme ensures that the pre-image can
        // be recovered in case of a crash or if another node takes over
        // (e.g. disk failure from a server leads to a backup server starting
        // with no state or way to recover it).
        const cycle_seed = hashMulti(secret, "consensus.preimages", 0);
        this(cycle_seed, preimage_count / cycle_length, cycle_length, initial_seek);
    }

    /***************************************************************************

        Construct an instance based on a pre-image at a given height

        Assumes that the hash `from` is the hash to be used at height `at`,
        and populate this `PreImageCycle` accordingly.

        Params:
          from = The seed used for the pre-images, which is the last value
                 the node can reveal
          at = The height matching `from`
          cycle_length = The length of a cycle
          initial_seek = The value to seek at after generating the seeds

    ***************************************************************************/

    public this (in Hash from, in Height at, in uint cycle_length,
                 in Height initial_seek = Height(0))
    {
        // Make sure that what we got falls on the boundary of a seed
        auto requested_length = at + 1;
        assert((requested_length % cycle_length) == 0,
               "Cannot create a `PreImageCycle` at this height");
        const cycles = requested_length / cycle_length;
        this(from, cycles, cycle_length, initial_seek);
    }

    /// Common implementation for public overloads
    private this (in Hash seed, in ulong cycles, in uint cycle_length,
                  in Height initial_seek)
    {
        this.cycles = cycles;
        this.seeds = PreImageCache(cycles, cycle_length);
        this.preimages = PreImageCache(cycle_length, 1);
        this.seeds.reset(seed);
        this.index = uint.max; // Invalid value to force reset
        this.seek(initial_seek);
    }

    /***************************************************************************

        Get a pre-image at the specified height.

        This routine might first need to seek to the given `height`,
        hence calls might have various latency depending if the image is
        cached or not.

        Params:
          height = Requested height

        Returns:
            Pre-image at `height`

    ***************************************************************************/

    public Hash opIndex (in Height height) @nogc
    {
        this.seek(height);
        auto offset = height % this.preimages.length();
        return this.preimages[$ - offset - 1];
    }

    /// The number of cycles for a bulk of pre-images
    public ulong cycles;

    /***************************************************************************

        The index of the enrollment within the current cycle

        This number is incremented every time a new Enrollment is accepted
        by the consensus protocol, and reset when `nonce` is incremented.

    ***************************************************************************/

    public uint index;

    /***************************************************************************

        Seed for all enrollments for the current cycle

        This variable is changed every time `nonce` is changed,
        and contains all the roots used to generate the `preimages` value.

    ***************************************************************************/

    public PreImageCache seeds;

    /***************************************************************************

        Currently active list of pre-images

        This variable is changed every time `index` is changed, to reflect
        the current Enrollment's pre-images.

    ***************************************************************************/

    public PreImageCache preimages;

    /***************************************************************************

        Seek to the `PreImage`s at height `height`

        This will calculate the `index` and `nonce` according to the given
        height and populate the `seed` and `preimages` if neccesary.

        This will be particularly usefull since the PreImages will now be
        consumed not by new enrollments but creation of new blocks.

        Params:
          secret = The secret key of the node, used as part of the hash
                   to generate the cycle seeds
          height = Requested height

    ***************************************************************************/

    private void seek (in Height height) @nogc
    {
        uint seek_index = cast (uint) (height / this.preimages.length());
        seek_index %= this.cycles;

        if (seek_index != this.index)
        {
            this.index = seek_index;
            this.preimages.reset(this.seeds.byStride[$ - 1 - this.index]);
        }
    }
}

version (unittest)
{
    // Test all heights of multiple cycles
    private void testPreImageCycle (uint cycle_length, ulong number_of_cycles)
    {
        import std.algorithm;
        import std.format;
        import std.range;
        import std.stdio;

        auto secret = Scalar.random();
        ulong total_images = cycle_length * number_of_cycles;
        auto cycle = PreImageCycle(secret, cycle_length, total_images);
        scope(failure) writefln("\nBatch failed with cycle %s", cycle);
        Hash[] batch;
        iota(total_images).each!( i =>
            batch ~= i == 0 ?
                hashMulti(secret, "consensus.preimages", 0)
                : hashFull(batch[i - 1]));
        batch.enumerate.each!( (idx, image) =>
            assert(cycle[Height(total_images - idx - 1)] == image));
    }
}

///
unittest
{
    const cycle_length = 2;
    const number_of_cycles = 10;
    testPreImageCycle(cycle_length, number_of_cycles);
}

///
unittest
{
    const cycle_length = 3;
    const number_of_cycles = 12;
    testPreImageCycle(cycle_length, number_of_cycles);
}

/// This is a cycle seed commonly used for testing.
version (unittest)
{
    static immutable CommonCycleSeed = Hash(`0xb7f3802d774665c6ccb4d24f3e6128542185f847e6da4e9c5a0254cfeb885d2536a89be8b882f0917f3ed43dae4760bb3a85b4c5a9e1871872a794fcf5e5236d`);
}

/// Each `PreImageCycle` for ramdon keys can be created just with a cycle seed without generating
/// 5 million preimages. These pre-defined cycle seeds are used for that.
version (unittest)
{
    static immutable Hash[] NodeCycleSeeds = [
        Hash(`0x3a481cb1576d79002755239b8d4019587d7e5394ddd448f92d5dca74baf742f4899dd53daefda9136e9d3cc6887b3456ffcfc85cfc711e5cf8659998047771cb`),
        Hash(`0x1a7ebfe71dd438ac96da520917680ff4278c3e4de031890cea2305de009dc750dfd3d9b714ef7b4cf983633a540ca4614ff1eae38d9d121604907f2dc2a7e885`),
        Hash(`0x64d1b6e98019df73b59c3593e2ca1baea53aeeb3cac18748d3ab50473a64963c76c318913158349caf368730b027eb8c4596b743308a7e53a65e484016c8e2ca`),
        Hash(`0x0bb70cf7d265661d006bc5bfd5bf70a66c5b32e54d05ee37bf023c4c0bf9b3bc76faf38d656c25e254aae7ea73aabba1902192575da80cfe10a24363d3e41118`),
        Hash(`0xbb19e8bae8f03ce2aee0c15f83089c87dd208b44d17683ace877696a98680730c4cae9f762366a70dd00885cf0ff2eb228f285885ebda9e6dc11c0288158d8cf`),
        Hash(`0x90f2a3d469831bad2d27f4698c463dad56c8d942b28859e38c2f4b1bc975605f0641f62aff2edf23326b67ad3b34c47bc43f96167485d4db2529d5e84fc7e994`),
        Hash(`0xa84c60d88e1c075d8d70c77426c4724ac8bd38f83030fb16a3db71890396548572031907fbf7adba1034a7f9b7b4f2ae11155010cf677ed81cc32728f6ec7a06`),
        Hash(`0xe39ae981988560d89e85f340c087fea46f1d9eefe73400f2a85edd3d3adee2bc5a3efd6e6ce9de04d73a3fe2554a1b1035450b7be9eaade24bbb789585aa0015`),
    ];
}

/// To get the cycle seeds for `PreImageCycle`s of some of well-known keys,
/// which are used for getting 5040 number of pre-images
version (unittest)
public void getCycleSeed (in KeyPair pair, in uint validator_cycle, out Hash seed,
    out Height seed_height)
{
    import agora.consensus.PreImage;
    import agora.utils.WellKnownKeys;
    import std.format;

    // This `seed_height` + 1 is the common multiple of various validator cycles,
    // like 10, 20, 1008
    seed_height = Height(5039);
    assert((seed_height + 1) % validator_cycle == 0,
        format!"This validator cycle (%s) is not supported."(validator_cycle));

    // All these values are the seeds for 5040 number pre-images, which are `Hash` values at
    // the height of 5039(= 5040 - 1) and in fact the hash values hashed
    // (PreImageCycle.PreImageCount - 5040) times from the values of
    // `hashMulti(secret, "consensus.preimages", 0)` for each secret.
    if (pair == NODE7)
        seed = Hash(`0xea0db105d9d18258fefa31a4bae2f8238199d9389d42aa29b2f26312e6d73b460d511a6d637f2c5a174441edb3176acbb8d18d6c7a0d790ef934111d36ff065f`);
    else if (pair == NODE2)
        seed = Hash(`0x83c41cc48d14bcc825dc69501f7d31a22d551fc8eac4e2d72a79e0cb7b027ec739db7e997c3e322e819d9073e5f71ebdca7ce6829471785b1d101522bf7f9946`);
    else if (pair == NODE3)
        seed = Hash(`0x84fd47fd68bc12d6a7c7e076fb261682db02b63c6d14c00753fae5894c26a42be1cb98b5a5e2a8c45f7037cfc3257aacba94b66e281a78407264ac57cd83a321`);
    else if (pair == NODE6)
        seed = Hash(`0x3c82790786faaeafab5c82c8cae4b459b445cd6698bf9ae372f24ed9994418a00d305598ef54fad8aaf9a732c148085372fb19bc8a6093c48b4e052fa8dcb579`);
    else if (pair == NODE5)
        seed = Hash(`0x2c9306c0262a50fc1ccaa7f3248f28ad6d6ecd0b195ca229d085cd3f3866fa7f618f8d5d9d3fc41d91cf6b6010a75a941c19d54548f1a8c78c070d48b0a94b50`);
    else if (pair == NODE4)
        seed = Hash(`0xcf650f6f81949783a789c8a117eb505f50cfe16bcefe6581bb9bba81ae26e540aade33855be49280f2e5287281e9d90525127eedae568d7b1773a374d5730fc7`);
    else if (pair == A)
        seed = Hash(`0xd19817b4270c891fb7f095d972de462389727306fb0af679bd1db336f16e096342e999124606da7951749491842d602b9fe64a38582aca3d730382d0be571b0a`);
    else if (pair == C)
        seed = Hash(`0x22d80a87812c42caf42f45ce0a8afe216066420abb465d4a679eb46ebadbac413a267482c42c3c6089763d417525aa6b5454a598f77d562270e855285c6369dd`);
    else if (pair == D)
        seed = Hash(`0x8f67adb05d8caffbe8e2bc5f852715bed171dcdedce3f1105f8cccb4ad4f2e200de407aebda6ec5882a47ca6911d734f5cbdcb947e6f4f766c599c9f76f333ce`);
    else if (pair == E)
        seed = Hash(`0x857365c0ba6215097e2b8c45195f4b17a4d69b3555f5eebca42ffa34254670c7edfbbc44b37491fc918e0ba0017afff453f679726e8832b15c4b24cc6fd413e8`);
    else if (pair == F)
        seed = Hash(`0xfba44700d3f22c19dd00e3b00853cb3b0e1805d91ddfbbe1820da69d36c7e40c471ed216dde85564ac2d226232dccbf0baca56fad0764904f181795972770936`);
    else if (pair == G)
        seed = Hash(`0xd244e2d05a4520799ba0d927e949087ef125524f1ba1b75d8d3b7e06983496a546b50ef5f2bac1b6db8f81dcadd30b87e67e67e46a42c863a4938c4485fafeeb`);
    else if (pair == H)
        seed = Hash(`0x0e2a80082b26abab2b5c1d6e7e6c15789d68c551c318d614ec4bb96e92bcec484ea13e50ff614e33f64c9fa2ff1783ebeb4d480cde7b3285a2475fc19e974532`);
    else if (pair == J)
        seed = Hash(`0x2f3273381c16e00509adbd4fb1871a1aa640b6c908ba5837775b02c9cec4e410f8057d0f7f2f742cbae73da9f3086d68cdb4daab54a0665651fcc57f74c6ec29`);
    else if (pair == K)
        seed = Hash(`0xc2929018e4cda8ce470d8f6a57052abe05ae4e095cd7f63b2654c7c457d3c085f110a1e8048646bef51cc3ef03442ce3452f267bfd92538b0dbfab0b479560f0`);
    else
    {
        auto cycle = PreImageCycle(pair.secret, 20, PreImageCycle.PreImageCount, Height(0));
        seed = cycle[seed_height];
        throw new Exception(format!"There's no seed for %s. The Hash of (Hash(`%s`) should be added."
                (pair.address, seed));
    }
}

/// Test for the `getCycleSeed` function
unittest
{
    import agora.utils.WellKnownKeys;
    import std.exception;

    Hash seed;
    Height seed_height;
    getCycleSeed(NODE5, 20, seed, seed_height);
    assert(seed != Hash.init);
    assert(seed_height != Height(0));
    assertThrown!Exception(getCycleSeed(L, 20, seed, seed_height));
}
