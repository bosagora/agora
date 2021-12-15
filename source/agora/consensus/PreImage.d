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
        Those two later modes are intended for debugging. The parameterless
        `toString` overload is not implemented for this reason.

        Params:
          sink = The sink to write the piecemeal string data to
          mode = The `PrintMode` to use for printing the content.
                 By default, only the bounds (0 and $) are printed.

    ***************************************************************************/

    public void toString (scope void delegate(in char[]) @safe sink,
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
                   This can be used when large sample sizes are used,
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
          preimage_count = The total number of pre-images
          initial_seek = The value to seek at after generating the seeds

    ***************************************************************************/

    public this (in Scalar secret, in uint cycle_length = 20,
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

    public this (in Hash from, in Height at, in uint cycle_length = 20,
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
        by the consensus protocol.

    ***************************************************************************/

    public uint index;

    /***************************************************************************

        Seed for all enrollments for the current cycle

        This variable is contains all the roots used to generate the
        `preimages` value.

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

        This will calculate the `index` according to the given
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

version (unittest)
{
    import agora.utils.WellKnownKeys;
    import std.stdio;
}

/// Each `PreImageCycle` for random keys can be created just with a cycle seed without generating
/// 5 million preimages. These pre-defined cycle seeds are used for that.
/// To get the cycle seeds for `PreImageCycle`s of some of well-known keys,
/// which are used for getting 10 * `validator cycle(20)` number of pre-images
version (unittest)
public void getCycleSeed (in KeyPair pair, in uint validator_cycle, out Hash seed,
    out Height seed_height)
{
    import agora.consensus.PreImage;
    import std.format;

    // If the validator_cycle is 1008, call special function for that
    if (validator_cycle == 1008)
        return getCycleSeed1008(pair, validator_cycle, seed, seed_height);

    // This `seed_height` + 1 is the common multiple of various validator cycles,
    // like 10, 20
    assert(validator_cycle == 10 || validator_cycle == 20);
    seed_height = Height(199);
    assert((seed_height + 1) % validator_cycle == 0,
        format!"This validator cycle (%s) is not supported."(validator_cycle));

    // All these values are the seeds for 10 * `validator cycle(20)` number of
    // pre-images, which are `Hash` values at the height of 199 (= 200 - 1) and
    // in fact the hash values hashed (PreImageCycle.PreImageCount - 200) times
    // from the values of `hashMulti(secret, "consensus.preimages", 0)` for each secret.
    if (pair == NODE2)
        seed = Hash(`0x1ae4bf7d4ace6f158357602bcca93c275be9ea42b189aa39e209479aa57f7e62cbe2a5ec8ead1297637937e6929d1ddd2d21e864bef02bff3fffafb2026f3db1`);
    else if (pair == NODE3)
        seed = Hash(`0xd1a46d0201452a5bac305966dba8f245cf23ae167d11cf21e196f953372719b193b2def6bc91f5428bb0b4091473e2f386ce6ee42d7f4845282dae9ac9d5ac5a`);
    else if (pair == NODE4)
        seed = Hash(`0xe28ec36906b56a853bd7eef2f28affde35296e5bd81d1f130095494a9bd4779b74b895e3d386135a2a72355f79db81f817d336f1ca0a8337f7f7571ea4eac468`);
    else if (pair == NODE5)
        seed = Hash(`0x5c55c17261648edc0764b2cd3bdb97f0fa4cc171f329837f90db2382784a0ef04da53e32462add25ad2c88f8b45ea546c0ab7bc6735e657cd45f7c6fd64c69d1`);
    else if (pair == NODE6)
        seed = Hash(`0x429cb1d508a5fe277e7a8b6bad671514581f0f024023e6eecebda03e86462ae330c59c1807d807e52ceefe6e2b556734c7a0dd2c32e632dc5e37a6cb48c3d49a`);
    else if (pair == NODE7)
        seed = Hash(`0xd7b512cab6ace6a563d50efedac3beea021410887e46eb338439f6fa8cae281c75eac7e1f9a164a0094e0f95a7b8b6d52f7bc3f959e685ec4f33e3100091bde5`);
    else if (pair == A)
        seed = Hash(`0x3a481cb1576d79002755239b8d4019587d7e5394ddd448f92d5dca74baf742f4899dd53daefda9136e9d3cc6887b3456ffcfc85cfc711e5cf8659998047771cb`);
    else if (pair == C)
        seed = Hash(`0x1a7ebfe71dd438ac96da520917680ff4278c3e4de031890cea2305de009dc750dfd3d9b714ef7b4cf983633a540ca4614ff1eae38d9d121604907f2dc2a7e885`);
    else if (pair == D)
        seed = Hash(`0x64d1b6e98019df73b59c3593e2ca1baea53aeeb3cac18748d3ab50473a64963c76c318913158349caf368730b027eb8c4596b743308a7e53a65e484016c8e2ca`);
    else if (pair == E)
        seed = Hash(`0x0bb70cf7d265661d006bc5bfd5bf70a66c5b32e54d05ee37bf023c4c0bf9b3bc76faf38d656c25e254aae7ea73aabba1902192575da80cfe10a24363d3e41118`);
    else if (pair == F)
        seed = Hash(`0xbb19e8bae8f03ce2aee0c15f83089c87dd208b44d17683ace877696a98680730c4cae9f762366a70dd00885cf0ff2eb228f285885ebda9e6dc11c0288158d8cf`);
    else if (pair == G)
        seed = Hash(`0x90f2a3d469831bad2d27f4698c463dad56c8d942b28859e38c2f4b1bc975605f0641f62aff2edf23326b67ad3b34c47bc43f96167485d4db2529d5e84fc7e994`);
    else if (pair == H)
        seed = Hash(`0xa84c60d88e1c075d8d70c77426c4724ac8bd38f83030fb16a3db71890396548572031907fbf7adba1034a7f9b7b4f2ae11155010cf677ed81cc32728f6ec7a06`);
    else if (pair == J)
        seed = Hash(`0xe39ae981988560d89e85f340c087fea46f1d9eefe73400f2a85edd3d3adee2bc5a3efd6e6ce9de04d73a3fe2554a1b1035450b7be9eaade24bbb789585aa0015`);
    else if (pair == K)
        seed = Hash(`0x72d84ce0dfc74f856909a3f49dffdb8b68c39212f1229fddec3fb071c3bff84983645f8caab335189a710502c1020ec4b855f70f8b1493718848aa9dcc761fa7`);
    else
    {
        auto cycle = PreImageCycle(pair.secret, 20, PreImageCycle.PreImageCount, Height(0));
        seed = cycle[seed_height];
        writeln(format!"There's no seed for %s. The Hash of (Hash(`%s`) should be added."
                (pair.address, seed));
    }
}

version (unittest)
private void getCycleSeed1008 (in KeyPair pair, in uint validator_cycle, out Hash seed,
    out Height seed_height)
{
    import agora.consensus.PreImage;
    import std.format;

    assert(validator_cycle == 1008);
    seed_height = Height(2015); // which is 2 * 1008 - 1
    assert((seed_height + 1) % validator_cycle == 0,
        format!"This validator cycle (%s) is not supported."(validator_cycle));

    // All these values are the seeds for 2 * `validator cycle(1008)` number of
    // pre-images, which are `Hash` values at the height of 2015 (= 2016 - 1) and
    // in fact the hash values hashed (PreImageCycle.PreImageCount - 2016) times
    // from the values of `hashMulti(secret, "consensus.preimages", 0)` for each secret.
    if (pair == NODE2)
        seed = Hash(`0x953ea564d1f8c9ea2147e8be7a982a9e13731b2e21a6c389744a7dcd69dc23d21684f388dc7719274c922fc93de69d8912fd528f1d831f5e61609b9243eccb83`);
    else if (pair == NODE3)
        seed = Hash(`0x3f9a695a810120ce158c0d135f5a08eb0f7abb114a4cf1e9a6d35acb9f24202921ec3db3081d2bc343006bcee249bb609f6197ec07792df9dec65a4c66419c34`);
    else if (pair == NODE4)
        seed = Hash(`0x739174927d577f7600a497a410526174810745d466a9eb667bff47e34f63f101272cb5c97a8c2a7baa8553b99af838b00c0908d93c8670a616cabd7bae8eb639`);
    else if (pair == NODE5)
        seed = Hash(`0xb37a9677e30ade4907abcb5dd21221f8378012ab40ecc90f1b8fad435fa4ef246fb4d11489402b2b60262bdd3c8a52df4853d140ba96a726446f9ed5508914ec`);
    else if (pair == NODE6)
        seed = Hash(`0x59f1291846188a8b344e43460bf2baeda269be3e0529e1f54cf64408796c86b1e93eb45d65769485f37d20af93fe019a312f09e8b99ef714ca067b3f3dd23b79`);
    else if (pair == NODE7)
        seed = Hash(`0x2c9baab303ff0f2c574f0134db19e4340bd8191c16a34c9d7da0d907b2db496def4d7191ecfa360e8da196ee926d4eeb88d96f997a24646e6d4bc53e7fd4fdc1`);
    else if (pair == A)
        seed = Hash(`0xc9e2284968f9f4305806e46d6e106648d7c5f396a46bb34fb3e6a364733413a984e8e4d243c17eb445dcaf13583781c02ad03ea9ac3f18ab8ba7e8525a1da3da`);
    else if (pair == C)
        seed = Hash(`0x9d97c67b7e9aedfb27bdb176704c25fd1d540ea857a3c1574169b4df7b16e929670e73c1f7e5085e3ecba8b635bec13ae1b573173d6504c196490af8a77a3ad4`);
    else if (pair == D)
        seed = Hash(`0xd7550ad9b654fb9f6911609d6167ab8b5ba814ef7c046e78b49624f54bec7949e185c3db76df77af15f2eea95d03717188d4ed1d290744f8fb88aae727bad90f`);
    else if (pair == E)
        seed = Hash(`0xb2cf21c06192535af972debdb4f966e8d5cb552d2d663472bea2cbf6bf04a14413db0ff88fbc171c110fe5a8d38ed8da97a9a55df35fa51273fdb3b28f343314`);
    else if (pair == F)
        seed = Hash(`0xdbd4a527c35d6de88605b70760cf9cd91fa2cf4bd7286d460f0f7227545d4cf3096305c91512e0978c32ae75510a415bba1afcf94d77ea12cd6ce4b5bd39de92`);
    else if (pair == G)
        seed = Hash(`0xe23194a7e7452c5204b5aebd37a48ba67f32b2b5dfb63fd4c963b6c1fe798d59a5d8f818672105e5688ff0d9b71d89f28e07c2fd19c7efaeb79b3d242aea96d7`);
    else if (pair == H)
        seed = Hash(`0x970c773f30876d148d5beac30d5b35dd35145f4cc6b0922e6538338fc01e0b3116422d38bce483006e5ef0a211a5da2954edf155e4475812565f20d1450c746c`);
    else if (pair == J)
        seed = Hash(`0x9fe29ab7f933da33c4727eb67dbe5d3859c34d425538c8f2e6bd1d9fb5d35bef404787799dfb316a0b943bd6235a7cccf1f9d386b0636996c9079eaa803d65bd`);
    else if (pair == K)
        seed = Hash(`0x9a4fa1aa78c7b7aee273002b5d33c96fdc12cd9f7fbb881024d5589569854e95b456f23211331aa5b4d5ba8420fca926c8936d32df662996c5f85c88dd1b6115`);
    else
    {
        auto cycle = PreImageCycle(pair.secret, 1008, PreImageCycle.PreImageCount, Height(0));
        seed = cycle[seed_height];
        writeln(format!"There's no seed for %s. The Hash of (Hash(`%s`) should be added."
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

    getCycleSeed(NODE5, 1008, seed, seed_height);
    assert(seed != Hash.init);
    assert(seed_height != Height(0));
    assertThrown!Exception(getCycleSeed(L, 1008, seed, seed_height));
}
