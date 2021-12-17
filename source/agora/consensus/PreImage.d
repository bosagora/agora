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
    if (pair == Genesis)
        seed = Hash(`0xc5a2d1cccbd541dbc94193c71f92df64ee946270926dbc42c16a21ae80ff67c83da20637eb6e769dc044d6d7fe15b97abed9f56ef3e81e6f09b7c149af275b60`);
    else if (pair == NODE2)
        seed = Hash(`0xf33d75944960b07065f0d29ccb7403f1f0c6d9e01fe32ee4a3f16c01d9a34657bee9e02af2c51a6f00afc33802445fc3d2056f4e0051d55ac07078b4a8b3024e`);
    else if (pair == NODE3)
        seed = Hash(`0x8f5239f23dc1a59dbe714b3476f229afa07d5c00b180dc0bd88947e7852a81cae39bf6f68aa181eafcba726168da98407da03c96ae93225b3914ea5311311214`);
    else if (pair == NODE4)
        seed = Hash(`0xb88bb7e5cf0c2ffc33978cbe1c41ce5f5d12cce2b96c67e908e4d03044d782b46606048b24071041e0dafaf015623628e136e66693681686bd30b33c75222b24`);
    else if (pair == NODE5)
        seed = Hash(`0x1c0cb8113eeaede322e5429cd210ba9f0834021cb595c2c4b9ff4b14022c28ca81a1550447d6cca57f7b37c9f37f4ab7a6455367d7112ece892ed55bb1943f21`);
    else if (pair == NODE6)
        seed = Hash(`0x6917a265e852182cf7a309378905ccc23a9f05967c1acec3854a9a54ebc59e75a3beea61443d04de90866595b8c710e89734f2d5bfa1a215461380eeb5db6c4a`);
    else if (pair == NODE7)
        seed = Hash(`0xa656589184be1055d12e60821ccf933023665db1903892b5814c6bbcc0e3bcd47067b6c4a6a2241c1f8e174bf417dc11edf03715ab9c50c7923500cf987fc717`);
    else if (pair == A)
        seed = Hash(`0xf552fa1caf80d22b3d5b6307b83ccd664065d099c5f830fab6886c0808815f724abc032ee31c2efa2d382077f56f38b6b841027a5392a9f47137176e1cf383d3`);
    else if (pair == C)
        seed = Hash(`0xfa126384ce0da0fc135fa7670fbe9686c7263daaa6cded62cf33d88c94c690d6f6d339aa7fa4da0aecae836d4882de2f951a3f7d247f9c0aa289022997498abf`);
    else if (pair == D)
        seed = Hash(`0x988430c307a2699a82a3c9f49f719b113d5c669458b9dbc12d51416ae4e4fd62ccad3bc7350a10c2f8bd77e462ea6400d2e6b65a8c35b684dbdd1cb03e7e494d`);
    else if (pair == E)
        seed = Hash(`0x9b65e3277352ed506736179bd3b49dd2577e5279fffbd0dc208d2e70e2534b1e66f74bb76c386056b9db5c8a6f543413ca807b7a0265f34cfebb0ee5950c8745`);
    else if (pair == F)
        seed = Hash(`0x4a3e76d46eface58683e647a456e5812de51db4dfbeab261a90418c9b43bf306c36c12b9b6c0f2e541a859ddf2f8d1f7621391ece992d5947ccbe3a86d411326`);
    else if (pair == G)
        seed = Hash(`0x18f65d7f34ce57b5a92f5647e6c5190d28e5fb28ef9edd9dec4762f8c7e3efbd01fbe062bbce0640fba4f90d918af93da27a409ef76dc6787741f3a34159dfb6`);
    else if (pair == H)
        seed = Hash(`0xec5f4d0538b5f60b4fe1dac8bad6fe5d9527531165fa3ea139d36c61b89eb37bd896a613d878d0f4140a59fae6b1e7ad95381a17bb54089943a39acf4c3b998e`);
    else if (pair == J)
        seed = Hash(`0x3256f762cee8e5345361d3db3d500ce7fb1c9591a0f051a264e383f764dc8c41033ce5f094917f58311c8597a450784c92bdfae947ca9c39a4ce62373a8631b4`);
    else if (pair == K)
        seed = Hash(`0xf32b9715a5ba6c8c26ac9dd92179c9e549cdbbe18066c02db7dc6fff62e83b8c3ac4052265b1320af39b93f3a70e2f9b5f860c39d1f2b27a7e66d3554628bcec`);
    // Coinnet validators
    else if (pair.address.toString == "boa1xzd6zuhueq5nyd0m4c4qm66az5dyq8r29hrynd3phezh50gf5c7u54eqtdh")
        seed = Hash(`0xa497313661b23a84fc039c91ebc773e7fb1538b6f51215ccb2e0ae2244b20ceb4c440ec267a38b94d80aaab72f1b172d8b880aa7b681ddc6776fdf531979fb2c`);
    else if (pair.address.toString == "boa1xzdmznw099p8e2h54pe8ed7599c99qez0f2m756ecmtamqtlq0vm73jg5mj")
        seed = Hash(`0xff648362a15f333a034bbb54d2cd3421432e12b58fed495ca71e61b7b2f2d45bb3b6c1b4b1640d4e20208788ff41e0efd1e493f0f5677f8d995e51de1cae99e8`);
    else if (pair.address.toString == "boa1xzduznmm7kp7gg20azr8k9c9pzdwapx6culll96s8dqah5kj5cjsj0le8rk")
        seed = Hash(`0xf55f73de5de178d252bf5357e9b88ae2d498d5ab8e395f5b4f7ac535d23812a7320c9bf6632d6a47ded075d6f549cdaa23efaf6f92a82bab58c85bd230fe163c`);
    else if (pair.address.toString == "boa1xzdaz4hx35kmp7zfd854yf98hx6ksdv3ps363dunvfl6l39m4v63qmyccsm")
        seed = Hash(`0x6a58710b8e0ceb1d46ef91d65674a7689c27ab6297eb76f66265d77618bb2d92f4b05573f42f92f222802c0beb4b4935167b4a502b4b7b433fa2c47d724cabb6`);
    else if (pair.address.toString == "boa1xzd7zmk7rnun06psp9d0r0p0lj2m6zfz63w55pguzlem7nkv274e6hn2hg3")
        seed = Hash(`0x53171235a501342219eabbd3cf021ae220e89af8a0a10341ccbf89740233f1549c05f48ccbc4461b8c433f43f8b4ef8c47f4015d1a4a44113c164d3141689d34`);
    else if (pair.address.toString == "boa1xzdlzl5znnssm3dlslqgrayrl4frdmh0s7dyqwgvkdqaqkf5994aw53cn58")
        seed = Hash(`0x4600086afc04e5650070e7288749d24d57e1f395f954f450e1e7dd30405e419499e59935742f8e7213dab598b8ec69a195e8ac80a196b5c10698c28c7fb688a8`);
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
    if (pair == Genesis)
        seed = Hash(`0xd0cd58f439dfa3cf14303cfbfc64d931d6ed5eb92e118aed1cdd80a6d8459db5746daacea2e3b6cca1ee8916674ac4c73adeb9a703f2063bce7e532fbc5e6bd2`);
    else if (pair == NODE2)
        seed = Hash(`0x8a79521ecbafea8c567a51a5da7fadc55493c28d49ea923358be9e1f9d9d25d24815cad1138988d80d2ffb64e8a95629676b1848949c8fa33fb1c76d5ed99a79`);
    else if (pair == NODE3)
        seed = Hash(`0xeb1cfd198b705ff7ecfc6616c2af470fc143cd9f30b28cdc5c7959e3dd16993f2bc7fab14dffc01013c5e9f99bd695cbfba79d9f7a69fc947b2753c89703c3cd`);
    else if (pair == NODE4)
        seed = Hash(`0xf8e0ff19a2d15aeaf777dc075002c45921fed3773fa6faf3a1e2fd644f11c0bffffac3c4696538356002f661fd5ee1bfe0d82d072dff479c4a73030c1ff60c2a`);
    else if (pair == NODE5)
        seed = Hash(`0x81d76a9fb44d4da47903f09f29c8d6de63d0414d908c2422da26cc5f5c3b9eeea75877688ec018eca2e7221a7c2e00b51b50f55ad6016c1f23513e2d7f2e96ca`);
    else if (pair == NODE6)
        seed = Hash(`0xd822e98070c7038330f126ad2eab1581891688420414580dcfe686e7ada66370e0499a602927b3e7d1ff345db439035619120cb4875a11de17a57635c9b6b536`);
    else if (pair == NODE7)
        seed = Hash(`0x39bd3d0a6ef55e0bc54e1fbcfc0d33508613a9272c6b79c68fd3f08edfe1328e1deee3e81b7e0f10a53e0f1f39b36d93047c86c4e3e507bece76a034628dd056`);
    else if (pair == A)
        seed = Hash(`0xed6b4f9d229d1fa691dd7776b220770a7be4627e38ee8b2181f3418d8b0dd7492fbf432d76807be80bacf3c02e9e30e4c5f654562a14783306e0c63d75959cfe`);
    else if (pair == C)
        seed = Hash(`0xb96e04de6ac67789506bfaf0785faba1e09c878e21c5cf80f417f441395b30c0ff0e9913115e5fa767358b60b2ea3f3f887f2f0108bf0f9fae57ae03ff1b74a0`);
    else if (pair == D)
        seed = Hash(`0x9267a9b3840a3576b94d87aea74cf60d73f74db0f16a571e466539bf36bfb60a443a96c97903d017dd9a0e0bb5f0a9d06272f514d7d61a19e33fd5de2c81b1ff`);
    else if (pair == E)
        seed = Hash(`0x91ee22da3a9654a705fff1e8ba42166418b7b8452cc12aec8facaf108fd95f37c192f93013d4c3ff70ff0c620d1036d13f48d624e3b7eb4b34152725689f8d90`);
    else if (pair == F)
        seed = Hash(`0xe5bb9c74171f0924b12a14fdca9336c849c5ded618ae56fc9484cb265b6edcc536f495516504ae0ad1f1e213f400bccf7a487294677edb496d224e5b3f60fe21`);
    else if (pair == G)
        seed = Hash(`0xef14cfd2be0ddde17778779fdcba873be0fabfec72b61640c609886a140b2feb16f11cd6c5c3632a763df6de17b8818104259ac48afb67a4b424f130fdc1e91b`);
    else if (pair == H)
        seed = Hash(`0xfa7dfdfc0fb7bc10d9cc28b66042a189bd2f9efadc24eb3bb7324fa679d54dcb47d52e8ba14ae0f224e6ec5c78b982327242678423bf4a60ff227f5583a3c268`);
    else if (pair == J)
        seed = Hash(`0xb058e527f47cdc15bb1c531c188c32f690bb2790086170ab8e057fb0dfcb1250c705e12ccc5761aefaec73a40540aa30519ae24bd0ae9e4fe87e8888f7a2281f`);
    else if (pair == K)
        seed = Hash(`0xb2b707e091ec6a708896ec6421a517f6a5b8f3df4dc76103dbc620d4a5e669ac4500c23bb46d0a4adbc415a36c12d3111748840912f4b19d1b576b37238cd646`);
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

    getCycleSeed(NODE5, 1008, seed, seed_height);
    assert(seed != Hash.init);
    assert(seed_height != Height(0));
}

version(none)
unittest
{
    KeyPair[] kps = [Genesis, NODE2, NODE3, NODE4, NODE5, NODE6, NODE7, A, C, D, E, F, G, H, J, K];

    Hash seed;
    Height seed_height;

    foreach(vc; [20, 1008])
    foreach(kp; kps)
    {
        try getCycleSeed(kp, vc, seed, seed_height);
        catch (Exception e) {}
        writefln("%s %d seed = Hash(`%s`);", kp.address, vc, seed);
    }
}
