/*******************************************************************************

    Base stats class that helps define other stats classes

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Stats;

import agora.utils.Utility : snakeCaseToUpperCamelCase;

import std.array : join, split, byPair;
import std.typecons : Tuple, tuple;

/*******************************************************************************

    Base stats class that helps define other stats classes.class
    Usage is Stats!(ConcreateStatsValue, ConcreateStatsLabel) concreate_stats;

    Params:
        ValueType = fields of this struct will correspond to metric names
        LabelType = fields of this struct will correspond to label names

*******************************************************************************/

public struct Stats (ValueType, LabelType)
{
    ///
    public alias ValueType ValueTypeT;

    ///
    public alias LabelType LabelTypeT;

    ///
    public struct StatValueLabel
    {
        ///
        const ValueType value;
        ///
        const LabelType label;
    }

    /// Contains the stats
    private ValueType[string] stats_maps;

    /// Separator used by Prometheus
    private static immutable SEPARATOR = "|SEPARATORSYM|";

    /***************************************************************************

        Increases the metric's value by some amount and attach some labels to it

        Params:
            metricName = name of the metric we want to change
            LabelTs... = types of the labels
            amount = metric will be increased by this amount
            labels_packed = labels that will be attached to the metric

    ***************************************************************************/

    public void increaseMetricBy (string metricName, LabelTs...)(ulong amount,
        LabelTs labels_packed) pure nothrow @safe
    {
        static assert(labels_packed.length == LabelType.tupleof.length);

        string[] labels = [labels_packed];
        auto key = labels.join(SEPARATOR);

        if (auto metrics = key in this.stats_maps)
            __traits(getMember, *metrics, metricName) += amount;
        else
        {
            this.stats_maps[key] = ValueType.init;
            __traits(getMember, this.stats_maps[key], metricName) = amount;
        }
    }

    /***************************************************************************

        Sets the metric's value to some amount and attach some labels to it

        Params:
            metricName = name of the metric we want to change
            LabelTs... = types of the labels
            amount = metric will be increased by this amount
            labels_packed = labels that will be attached to the metric

    ***************************************************************************/

    public void setMetricTo (string metricName, LabelTs...)(ulong amount,
        LabelTs labels_packed)
    {
        static assert(labels_packed.length == LabelType.tupleof.length);

        string[] labels = [labels_packed];
        auto key = labels.join(SEPARATOR);

        __traits(getMember, this.stats_maps.require(key, ValueType.init),
            metricName) = amount;
    }

    /***************************************************************************

        Function that prepares and returns the metrics with the corresponding
        labels

        Returns:
            an array of pairs of metrics and label names

    ***************************************************************************/

    public StatValueLabel[] getStats () const pure nothrow @safe
    {
        StatValueLabel[] res;
        foreach (pair; stats_maps.byPair)
        {
            LabelType label;
            immutable field_value = pair.key.split(SEPARATOR);
            foreach (i, ref field; label.tupleof)
                field = field_value[i];
            res ~= StatValueLabel(pair.value, label);
        }
        return res;
    }
}

/// Convenience struct for easier stats definition
public struct NoLabel {}

version (unittest)
{
    import agora.stats.Utils;

    import ocean.util.prometheus.collector.CollectorRegistry;
    import ocean.util.prometheus.collector.Collector;

    public struct TestStatsWithLabelT
    {
        public string test_metric_label;
    }

    public struct TestStatsValueT
    {
        public ulong test_metric_value;
    }

    Stats!(TestStatsValueT, TestStatsWithLabelT) test_stats_with_label;
    Stats!(TestStatsValueT, NoLabel) test_stats_without_label;

    mixin DefineCollectorForStats!("test_stats_with_label", "collectTestStatWithLabel");
    mixin DefineCollectorForStats!("test_stats_without_label", "collectTestStatWithoutLabel");
}

unittest
{
    import std.functional : toDelegate;

    // stats with one label
    CollectorRegistry collector_registry_with_label = new CollectorRegistry([]);
    collector_registry_with_label.addCollector(toDelegate(&collectTestStatWithLabel));
    test_stats_with_label.setMetricTo!"test_metric_value"(41, "interesting_label1");
    test_stats_with_label.increaseMetricBy!"test_metric_value"(1, "interesting_label1");
    test_stats_with_label.setMetricTo!"test_metric_value"(5, "interesting_label2");
    test_stats_with_label.increaseMetricBy!"test_metric_value"(2, "interesting_label2");
    assert(collector_registry_with_label.collect() ==
        "test_metric_value {test_metric_label=\"interesting_label1\"} 42\n" ~
        "test_metric_value {test_metric_label=\"interesting_label2\"} 7\n");

    // stats without label
    CollectorRegistry collector_registry_without_label = new CollectorRegistry([]);
    collector_registry_without_label.addCollector(toDelegate(&collectTestStatWithoutLabel));
    test_stats_without_label.setMetricTo!"test_metric_value"(41);
    test_stats_without_label.increaseMetricBy!"test_metric_value"(1);
    assert(collector_registry_without_label.collect() == "test_metric_value 42\n");
}
