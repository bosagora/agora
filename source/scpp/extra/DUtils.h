#pragma once

// Copyright Mathias Lang
// Not originally part of SCP but required for the D side to work

#include <set>
#include <unordered_map>
#include <vector>

#include "crypto/SecretKey.h"  // for operator() (hashing support)

// rudimentary support for walking through an std::set
// note: can't use proper callback type due to
// https://issues.dlang.org/show_bug.cgi?id=20223
template<typename T>
int cpp_set_foreach(void* setptr, void* ctx, void* func)
{
    auto wrapper = (int (*)(void* ctx, const T& value))func;

    for (auto const &elem : *(std::set<T>*)setptr)
    {
        int res = wrapper(ctx, elem);
        if (res != 0)
            return res;
    }

    return 0;
}

template<typename T>
bool cpp_set_empty(const void* setptr)
{
    return ((const std::set<T>*)setptr)->empty();
}

template<typename K, typename V>
void cpp_unordered_map_assign (void* map, const K& key, const V& value)
{
    auto m = (std::unordered_map<K, V>*)map;
    (*m)[key] = value;
}

template<typename K, typename V>
std::size_t cpp_unordered_map_length (const void* map)
{
    auto m = (const std::unordered_map<K, V>*)map;
    return m->size();
}

template<typename K, typename V>
void* cpp_unordered_map_create ()
{
    return new std::unordered_map<K, V>();
}

// @bug with substitution
// https://issues.dlang.org/show_bug.cgi?id=20679
// template<typename K, typename V>
// std::unordered_map<K, V> * cpp_unordered_map_create ()
// {
//     return new std::unordered_map<K, V>();
// }

template<typename T, typename VectorT>
void push_back(VectorT& this_, T& value)
{
    this_.push_back(value);
}

template<typename VectorT>
VectorT duplicate(const VectorT& this_)
{
    VectorT dup = VectorT(this_);
    return dup;
}
