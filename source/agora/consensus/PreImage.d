/*******************************************************************************

    Hold pre-image related utilities

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.PreImage;

import agora.common.crypto.ECC;
import agora.common.Hash;

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
        /// Default value, just print the two extreme values
        Bounds,
        /// Print all stored intermediate value and the last bound
        Stride,
        /// Print all values, performing intermediate hashing
        All,
    }

    /***************************************************************************

        Print the content of a cache

        By default, this functoin prints the bounds of the cache (the value at
        index 0, and the last value, as returned by `reset`).
        Changing the mode makes it print either the internal content, or the
        full range that is covered, in a newline-separated list.
        Those two later mode are intended for debugging. Additionally, no
        parameterless `toString` is provided for this reason.

        Params:
          sink = The sink to write the piecemeal string data to
          mode = The `PrintMode` to use for printing the content.
                 By default, only the bounds (0 and $) are printed.

    ***************************************************************************/

    public void toString (scope void delegate(scope const(char)[]) @safe sink,
                          PrintMode mode = PrintMode.Bounds) const
    {
        switch (mode)
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

        default:
            assert(0);
        }
    }

    nothrow:

    /// Store the actual preimages
    private Hash[] data;

    /// Interval between two preimages in `data`
    private const ulong interval;

    /// Default-initialized `PreImageCache` is not valid, make sure it can't
    /// be accidentally constructed (e.g. by embbeding it in another aggregate)
    @disable public this();

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
        For example, if one wish to represent a range of 1000 pre-images with
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
                   and one wish to stop initialization past a certain threshold.

    ***************************************************************************/

    public void reset (Hash seed, size_t length)
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

/// This struct hold all the cycle data together for better readability
public struct PreImageCycle
{
    /// Make sure we get initialized by disabling the default ctor
    @disable public this();
    /// Ditto
    public this (typeof(PreImageCycle.tupleof) args)
    {
        this.tupleof = args;
    }

    /// The number of cycles for a bulk of pre-images
    public static immutable uint NumberOfCycles = 100;

    /***************************************************************************

        The number of the current cycle

        This is the data used as a nonce in generating the cycle seed.
        Named `nonce` to avoid any ambiguity. It is incremented once every
        `EnrollPerCycle` period, currently 700 days.

    ***************************************************************************/

    public uint nonce;

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

        Populate the caches of pre-images

        This will first populate the caches (seeds and preimages) as necessary,
        then increase the `index` by one, or reset it to 0 and increase `nonce`
        if necessary.

        Note that the increment is done after the caches are populated,
        so `populate` needs to be called once this node has confirmed it
        is part of consensus. If the caches are only needed without the
        increment, the `consume` parameter must be set to `false`.

        Params:
          secret = The secret key of the node, used as part of the hash
                   to generate the cycle seeds
          consume = If true, calculate the cycle index. Otherwise, just
                   get the random seed which is the first pre-image

        Returns:
          The hash of the current enrollment round

    ***************************************************************************/

    public Hash populate (scope const ref Scalar secret, bool consume)
        @safe nothrow
    {
        // Populate the nonce cache if necessary
        if (this.index == 0)
        {
            const cycle_seed = hashMulti(
                secret, "consensus.preimages", this.nonce);
            this.seeds.reset(cycle_seed);
        }

        // Populate the current enrollment round cache
        // The index into `seeds` is the absolute index of the cycle,
        // not the number of round, hence why we use `byStrides`
        // The alternative would be:
        // [$ - (this.index + 1) * this.preimages.length]
        this.preimages.reset(this.seeds.byStride[$ - 1 - this.index]);

        // Increment index if there are rounds left in this cycle
        if (consume)
        {
            this.index += 1;
            if (this.index >= NumberOfCycles)
            {
                this.index = 0;
                this.nonce += 1;
            }
        }

        return this.preimages[$ - 1];
    }
}
