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

import agora.common.BanManager;
import agora.common.crypto.Key;
import agora.common.Set;
import agora.utils.Log;

import dyaml.node;

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

    /// Overrides for config options
    public string[][string] overrides;

    /// Helper to add items to `overrides`
    private void overridesHandler (string, string value)
    {
        import std.string;
        const idx = value.indexOf('=');
        if (idx < 0) return;
        string k = value[0 .. idx], v = value[idx + 1 .. $];
        if (auto val = k in this.overrides)
            (*val) ~= v;
        else
            this.overrides[k] = [ v ];
    }
}

/// Main config
public struct Config
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// Ban manager config
    public BanManager.Config banman;

    /// The node config
    public NodeConfig node;

    /// The administrator interface config
    public AdminConfig admin;

    /// The list of IPs for use with network discovery
    public immutable string[] network;

    /// The list of DNS FQDN seeds for use with network discovery
    public immutable string[] dns_seeds;

    /// The quorum config
    public QuorumConfig quorum;

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

    /// The minimum number of listeners to connect to
    /// before discovery is considered complete
    public size_t min_listeners = 2;

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

    /// Maximum number of retries to issue before a request is considered failed
    public size_t max_retries = 5;

    /// Timeout of each request (in milliseconds)
    public long timeout = 500;

    /// Path to the data directory to store metadata and blockchain data
    public string data_dir;
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

    /// Threshold of this quorum set
    public size_t threshold = 1;

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
    LogLevel log_level = LogLevel.None;
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
            &cmdline.config_check,

        "override|O",
            "Override a config file value\n" ~
            "Example: ./agora -O node.validator=true -o dns=1.1.1.1 -o dns=2.2.2.2\n" ~
            "Array values are additive, other items are set to the last override",
            &cmdline.overridesHandler,
        );
}

/// Thrown when parsing the config fails
class ConfigException : Exception
{
    ///
    public this (string msg, string file = __FILE__, size_t line = __LINE__)
        @nogc @safe pure nothrow
    {
        super(msg, file, line);
    }
}

/*******************************************************************************

    Parses the config file and returns a `Config` instance.

    Params:
        cmdln = command-line arguments (containing the path to the config)

    Throws:
        `ConfigException` if parsing the config file failed.

    Returns:
        `Config` instance

*******************************************************************************/

public Config parseConfigFile (ref const CommandLine cmdln)
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
private Config parseConfigFileImpl (ref const CommandLine cmdln)
{
    import std.conv;
    import dyaml;

    Node root = Loader.fromFile(cmdln.config_path).load();

    const(string)[] parseSequence (string section, bool optional = false)
    {
        if (auto val = section in cmdln.overrides)
            return *val;

        if (auto node = section in root)
            enforce(root[section].type == NodeType.sequence,
                format("`%s` section must be a sequence", section));
        else if (optional)
            return null;
        else
            throw new Exception(
                format("The '%s' section is mandatory and must " ~
                    "specify at least one item", section));

        string[] result;
        foreach (string item; root[section])
            result ~= item;

        return result;
    }

    Config conf =
    {
        banman : parseBanManagerConfig("banman" in root, cmdln),
        node : parseNodeConfig("node" in root, cmdln),
        network : assumeUnique(parseSequence("network")),
        dns_seeds : assumeUnique(parseSequence("dns", true)),
        quorum : parseQuorumSection("quorum" in root, cmdln),
    };

    enforce(conf.network.length > 0, "Network section is empty");

    Node* admin = "admin" in root;
    conf.admin.enabled = opt!(bool,   "admin", "enabled")(cmdln, admin);
    conf.admin.address = opt!(string, "admin", "address")(cmdln, admin);
    conf.admin.port    = opt!(ushort, "admin", "port")(cmdln, admin);

    conf.logging.log_level = opt!(LogLevel, "logging", "level")(
        cmdln, "logging" in root, LogLevel.Error);

    return conf;
}

/// Parse the node config section
private NodeConfig parseNodeConfig (Node* node, const ref CommandLine cmdln)
{
    auto is_validator = get!(bool, "node", "is_validator")(cmdln, node);
    auto min_listeners = get!(size_t, "node", "min_listeners")(cmdln, node);
    auto max_listeners = get!(size_t, "node", "max_listeners")(cmdln, node);
    auto address = get!(string, "node", "address")(cmdln, node);

    long retry_delay = cast(long)(opt!(float, "node", "retry_delay")(cmdln, node, 3.0) * 1000);

    size_t max_retries = get!(size_t, "node", "max_retries")(cmdln, node);
    size_t timeout = get!(size_t, "node", "timeout")(cmdln, node);

    string data_dir = get!(string, "node", "data_dir")(cmdln, node);
    auto port = get!(ushort, "node", "port")(cmdln, node);

    string node_seed = get!(string, "node", "seed")(cmdln, node);
    auto key_pair = KeyPair.fromSeed(Seed.fromString(node_seed));

    NodeConfig conf =
    {
        is_validator : is_validator,
        min_listeners : min_listeners,
        max_listeners : max_listeners,
        address : address,
        port : port,
        key_pair : key_pair,
        retry_delay : retry_delay,
        max_retries : max_retries,
        timeout : timeout,
        data_dir : data_dir,
    };

    return conf;
}

/// Parse the banman config section
private BanManager.Config parseBanManagerConfig (Node* node, const ref CommandLine cmdln)
{
    BanManager.Config conf;
    conf.max_failed_requests = get!(size_t, "banman", "max_failed_requests")(cmdln, node);
    conf.ban_duration = get!(size_t, "banman", "ban_duration")(cmdln, node);
    return conf;
}

/*******************************************************************************

    Parse the quorum config section

    Params:
        node_ptr = pointer to the Yaml node containing the quorum configuration
        cmdln = the parsed command line arguments, for override
        level = the nesting level of the quorum. The maximum nesting is 3.

    Returns:
        the parsed quorum config section

*******************************************************************************/

private QuorumConfig parseQuorumSection (Node* node_ptr,
    const ref CommandLine cmdln, size_t level = 1)
{
    import std.algorithm;
    import std.exception;
    enforce(level <= 3, "Cannot have more than 2 levels of sub-quorums.");

    PublicKey[] nodes;
    if (auto nodeKeyArray = "quorum.nodes" in cmdln.overrides)
        foreach (string nodeKeyStr; *nodeKeyArray)
            nodes ~= PublicKey.fromString(nodeKeyStr);
    else if (node_ptr is null)
        throw new Exception("Section 'quorum.nodes' is mandatory but not present");
    else
        foreach (string nodeKeyStr; (*node_ptr)["nodes"])
            nodes ~= PublicKey.fromString(nodeKeyStr);

    QuorumConfig[] sub_quorums;
    // Node: Providing sub_quorums via command line is currently not supported
    if (node_ptr)
        if (auto subs = "sub_quorums" in *node_ptr)
        {
            foreach (ref Node sub; *subs)
                sub_quorums ~= parseQuorumSection(&sub, cmdln, level + 1);
        }

    const thresholdRaw = cmdln.get!(string, "quorum", "threshold")(node_ptr);
    const threshold = getThreshold(thresholdRaw.stripRight('%').to!float,
        nodes.length + sub_quorums.length);

    return QuorumConfig(threshold, nodes.assumeUnique, sub_quorums.assumeUnique);
}

///
unittest
{
    import dyaml.loader;
    CommandLine cmdln;

    immutable conf_example = `
    quorum:
        # threshold as a percentage
        threshold: 66%
        # the list of nodes
        nodes:
          - GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN
          - GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5
        sub_quorums:
          - threshold: 66%
            nodes:
              - GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN
              - GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5
            sub_quorums:
              - threshold: 66%
                nodes:
                  - GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN
                  - GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5
                  - GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5`;

    auto node = Loader.fromString(conf_example).load();
    auto quorum = parseQuorumSection("quorum" in node, cmdln);

    auto expected = QuorumConfig(2,
        [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
         PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")],
        [QuorumConfig(2,
            [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
             PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")],
            [QuorumConfig(2,
                [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
                 PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5"),
                 PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")])])]);

    assert(quorum == expected);

    immutable bad_nesting = `
        threshold: 66%
        nodes:
          - GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN
        sub_quorums:
          - threshold: 66%
            nodes:
              - GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5
            sub_quorums:
              - threshold: 66%
                nodes:
                  - GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5
                sub_quorums:
                  - threshold: 66%
                    nodes:
                      - GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5`;

    node = Loader.fromString(bad_nesting).load();
    assertThrown(parseQuorumSection("quorum" in node, cmdln));
}

/*******************************************************************************

    Return the threshold in an N of M form, rounding up (same as Stellar)

    Params:
        percentage = the threshold in percentage
        count = the M in N of M

    Returns:
        The N of M based on the percentage

*******************************************************************************/

private uint getThreshold ( float percentage, size_t count )
{
    return cast(uint)(((count * percentage - 1) / 100) + 1);
}

///
unittest
{
    assert(getThreshold(10.0, 10) == 1);
    assert(getThreshold(50.0, 10) == 5);
    assert(getThreshold(100.0, 10) == 10);
    assert(getThreshold(33.3, 10) == 4);  // round up
    assert(getThreshold(100.0, 1) == 1);
    assert(getThreshold(1, 1) == 1);  // round up
}

/// Optionally get a value
private T opt (T, string section, string name) (
    const ref CommandLine cmdln, Node* node, lazy T def = T.init)
{
    try
        return get!(T, section, name)(cmdln, node);
    catch (Exception e)
        return def;
}

/// Helper function to get a config parameter
private T get (T, string section, string name) (const ref CommandLine cmdl, Node* node)
{
    import std.conv;

    static immutable QualifiedName = (section ~ "." ~ name);

    if (auto val = QualifiedName in cmdl.overrides)
        return (*val)[$ - 1].to!T;

    if (node)
        if (auto val = name in *node)
            return (*val).as!string.to!T;

    throw new Exception(format(
        "'%s' was not found in config's '%s' section, nor was '%s' in command line arguments",
        name, section, QualifiedName));
}
