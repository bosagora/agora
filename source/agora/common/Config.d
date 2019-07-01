/*******************************************************************************

    Define the configuration objects that are used through the application

    See `doc/config.example.yaml` for some documentation.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Config;

import agora.common.crypto.Key;
import agora.common.Set;

import dyaml.node;

import vibe.core.log;

import std.algorithm;
import std.conv;
import std.exception;
import std.format;
import std.getopt;
import std.range;
import std.traits;


/// Command-line arguments
public struct CommandLine
{
    /// Path to the config file
    public string config_path = "config.yaml";

    /// check state of config file and exit early
    public bool config_check;
}

/// Main config
public struct Config
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// The node config
    public NodeConfig node;

    /// The administrator interface config
    public AdminConfig admin;

    /// The list of IPs for use with network discovery
    public immutable string[] network;

    /// The list of DNS FQDN seeds for use with network discovery
    public immutable string[] dns_seeds;

    /// The quorum slice config
    public immutable QuorumConfig[] quorums;

    /// Logging config
    public LoggingConfig logging;
}

/// Node config
public struct NodeConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// Is this a validator node
    public bool is_validator;

    /// Maximum number of listeners to connect to
    public size_t max_listeners = 10;

    /// Bind address
    public string address;

    /// Bind port
    public ushort port;

    /// The seed to use for the keypair of this node
    public immutable KeyPair key_pair;

    /// Number of msecs to wait before retrying failed connections
    public long retry_delay = 3000;
}

/// Admin API config
public struct AdminConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// Is the control API enabled?
    public bool enabled;

    /// Bind address
    public string address;

    /// Bind port
    public ushort port;
}

/// Configuration for a peer we trust
public struct QuorumConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// Name of the config (for usability)
    public string name;

    /// Threshold of this quorum set
    public float threshold = 100.0;

    /// List of nodes in this quorum
    public immutable PublicKey[] nodes;

    /// List of any sub-quorums
    public immutable QuorumConfig[] quorums;
}

/// Configuration for logging
public struct LoggingConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// The logging level
    LogLevel log_level = LogLevel.none;
}

/// Parse the command-line arguments and return a GetoptResult
public GetoptResult parseCommandLine (ref CommandLine cmdline, string[] args)
{
    return getopt(
        args,
        "config|c",
            "Path to the config file. Defaults to: " ~ CommandLine.init.config_path,
            &cmdline.config_path,

        "config-check",
            "Check the state of the config and exit",
            &cmdline.config_check);
}

/// Thrown when parsing the config fails
class ConfigException : Exception
{
    ///
    @nogc @safe pure nothrow public this ( string msg, string file = __FILE__,
        size_t line = __LINE__ )
    {
        super(msg, file, line);
    }
}

/*******************************************************************************

    Parses the config file and returns a Config instance.

    Params:
        cmdlnd = command-line arguments (containing the path to the config)

    Throws:
        ConfigException if parsing the config file failed.

    Returns:
        Config instance

*******************************************************************************/

public Config parseConfigFile (CommandLine cmdln)
{
    try
    {
        return parseConfigFileImpl(cmdln);
    }
    catch (Exception ex)
    {
        throw new ConfigException(ex.msg, ex.file, ex.line);
    }
}

/// ditto
private Config parseConfigFileImpl (CommandLine cmdln)
{
    import std.conv;
    import dyaml;

    Node root = Loader.fromFile(cmdln.config_path).load();

    string[] parseSequence ( string section )
    {
        if (auto node = section in root)
            enforce(root[section].type == NodeType.sequence,
                format("`%s` section must be a sequence", section));
        else
            throw new Exception(
                format("The '%s' section is mandatory and must " ~
                    "specify at least one item", section));

        string[] result;
        foreach (string item; root[section])
            result ~= item;

        return result;
    }

    enforce("node" in root, "The 'node' section is required");
    enforce("quorum" in root, "The 'quorum' section is required");

    Config conf =
    {
        node : parseNodeConfig(root["node"]),
        network : assumeUnique(parseSequence("network")),
        dns_seeds : assumeUnique(parseSequence("dns")),
        quorums : assumeUnique(parseQuorumSection(root["quorum"]))
    };

    enforce(conf.network.length > 0, "Network section is empty");

    if (auto admin = "admin" in root)
    {
        conf.admin.enabled = (*admin)["enabled"].as!bool;
        conf.admin.address = (*admin)["address"].as!string;
        conf.admin.port    = (*admin)["port"].as!ushort;
    }

    conf.logging.log_level
        = root["logging"]["level"].as!string.to!LogLevel;

    enforce(conf.quorums.length != 0);
    logInfo("Quorum set: %s", conf.quorums);

    return conf;
}

/// Parse the node config section
private NodeConfig parseNodeConfig ( Node node )
{
    auto is_validator = node["is_validator"].as!bool;
    auto max_listeners = node["max_listeners"].as!size_t;
    auto address = node["address"].as!string;

    long retry_delay = 3000;
    if (auto delay = "retry_delay" in node)
        retry_delay = cast(long)(delay.as!float * 1000);

    auto port = node["port"].as!ushort;

    string node_seed = node["seed"].as!string;
    auto key_pair = KeyPair.fromSeed(Seed.fromString(node_seed));

    NodeConfig conf =
    {
        is_validator : is_validator,
        max_listeners : max_listeners,
        address : address,
        port : port,
        key_pair : key_pair,
        retry_delay : retry_delay,
    };

    return conf;
}

/// Parse the quorum config section
private QuorumConfig[] parseQuorumSection ( Node quorums_root )
{
    struct PreQuorum
    {
        string threshold;
        PublicKey[] nodes;
        string[] sub_quorums;  // they're looked up later
    }

    PreQuorum[string] pre_quorums;

    foreach (Node entry; quorums_root)
    {
        PreQuorum quorum;
        quorum.threshold = entry["threshold"].as!string;
        string name = entry["name"].as!string;

        foreach (string node; entry["nodes"])
        {
            if (node[0] == '$')  // entries beginning with '$' refer to quorums
                quorum.sub_quorums ~= node[1 .. $];
            else
                quorum.nodes ~= PublicKey.fromString(node);
        }

        pre_quorums[name] = quorum;
    }

    float parseThreshold ( string input )
    {
        // todo: add ability to specify 2/3 style fractions
        if (input.endsWith("%"))
            return input.stripRight('%').to!float;
        else
            return 100.0;
    }

    QuorumConfig toQuorum ( string temp_name, PreQuorum temp_quorum )
    {
        auto name = temp_name;
        auto threshold = parseThreshold(temp_quorum.threshold);
        auto nodes = temp_quorum.nodes;

        QuorumConfig[] quorums;
        foreach (string temp; temp_quorum.sub_quorums)
            quorums ~= toQuorum(temp, pre_quorums[temp]);

        QuorumConfig quorum =
        {
            name : name,
            threshold : threshold,
            nodes : assumeUnique(nodes),
            quorums : assumeUnique(quorums)
        };

        return quorum;
    }

    QuorumConfig[] quorums;
    foreach (string temp_name, PreQuorum temp_quorum; pre_quorums)
        quorums ~= toQuorum(temp_name, temp_quorum);

    return quorums;
}
