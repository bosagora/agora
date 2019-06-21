/*******************************************************************************

    Contains the Cache.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Cache;

/// Use to cache messages.
struct Cache(T, U)
{   
private:
    U[T] base;

public:

    /// Obtains a value corresponding to the key
    ref U get(T t)
    {
        auto p = t in base;
        if (p is null)
        {
            throw new Exception("There is no such key in cache");
        } else {
            return base[t];
        }
    }

    /// Add keys and value.
    void put(T t, U u)
    {
        auto p = t in base;
        if (p is null)
        {
            base[t] = u;
        } else {
            *p = u;
        }
    }

    /// Return true if a value corresponding to the key exists
    bool exists(T t)
    {
        auto p = t in base;
        if (p is null)
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    /// Update keys and value
    void update(T t, U u)
    {
        auto p = t in base;
        if (p is null)
        {
        } else {
            *p = u;
        }
    }

    /// Remove key
    void erase(T t)
    {
        auto p = t in base;
        if (p is null)
        {

        } else {
            base.remove(t);
        }
    }
}

unittest
{
    import std.stdio;

    Cache!(string, int) cache;

    cache.put("node1", 1);
    cache.put("node2", 2);

    assert (cache.exists("node1"));
    assert (cache.exists("node2"));

    assert (!cache.exists("node3"));

    cache.erase("node2");

    assert (!cache.exists("node2"));
}
