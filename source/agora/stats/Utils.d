/*******************************************************************************

    Utilities for stats support

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Utils;

public import ocean.util.prometheus.collector.Collector;
import ocean.util.prometheus.collector.CollectorRegistry;
import vibe.vibe;

import std.stdio;

/*******************************************************************************

    Utility method to generate a collector delegate for a particular `Stats`
    The generated function will have the signature of
    void <collector_name>(Collector collector)

    Params:
        statVar = variable of `Stats` type that we want to collect
        collector_name = name of the generated function

*******************************************************************************/

public mixin template DefineCollectorForStats (string statVar,
    string collector_name)
{
    import std.format;
    mixin(
    q{
        private void %2$s (Collector collector) @safe
        {
            foreach (stat; %1$s.getStats())
                if (%1$s.LabelTypeT.tupleof.length)
                    collector.collect(stat.value, stat.label);
                else
                    collector.collect(stat.value);
        }
    }.format(statVar, collector_name));
}

/// collection of Utility classes for stats collection
public class Utils
{
    /***************************************************************************

            Static function that returns a singleton instance
            of type `CollectorRegistry`

            Returns:
                a singleton instance of type `CollectorRegistry`
    ***************************************************************************/

    public static CollectorRegistry getCollectorRegistry ()
    {
        static CollectorRegistry collector_registry;
        if (collector_registry is null)
            collector_registry = new CollectorRegistry([]);
        return collector_registry;
    }
}
