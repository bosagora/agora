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
import agora.common.Types;
import agora.utils.Log;

import scpd.types.Stellar_SCP;
import scpd.types.Utils;

import dyaml.node;
import dyaml.loader;

import std.algorithm;
import std.conv;
import std.exception;
import std.format;
import std.getopt;
import std.range;
import std.traits;

import core.stdc.time;
import core.time;

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

    /// Logging config
    public LoggingConfig logging;

    /// Event handler config
    public EventHandlerConfig event_handlers;
}

/// Node config
public struct NodeConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// If set, a hexdump serialized representation of the genesis block to use
    /// in place of the built-in genesis block as defined by CoinNet
    public string genesis_block;

    /// Is this a validator node
    public bool is_validator;

    /// The minimum number of listeners to connect to
    /// before discovery is considered complete
    public size_t min_listeners = 2;

    /// Maximum number of listeners to connect to
    public size_t max_listeners = 10;

    /// Bind address
    public string address = "0.0.0.0";

    /// Bind port
    public ushort port = 0xB0A;

    /// The seed to use for the keypair of this node
    public immutable KeyPair key_pair;

    /// Time to wait between request retries
    public Duration retry_delay = 3.seconds;

    /// Maximum number of retries to issue before a request is considered failed
    public size_t max_retries = 5;

    /// Timeout for each request
    public Duration timeout = 500.msecs;

    /// Path to the data directory to store metadata and blockchain data
    public string data_dir = "/var/lib/agora/";

    /// The cycle length for a validator
    public uint validator_cycle = 1008;
}

/// Admin API config
public struct AdminConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// Is the control API enabled?
    public bool enabled;

    /// Bind address
    public string address = "127.0.0.1";

    /// Bind port
    public ushort port = 0xB0B;
}

/// Configuration for logging
public struct LoggingConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// The logging level
    LogLevel log_level = LogLevel.Error;
}

/// Configuration for URLs to push a data when an event occurs
public struct EventHandlerConfig
{
    /// URLs to push a data when a block is externalized
    public immutable string[] block_externalized_handler_addresses;

    /// URLs to push a data when a pre-image is updated
    public immutable string[] preimage_updated_handler_addresses;
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

/*******************************************************************************

    Parses the config file or string and returns a `Config` instance.

    Params:
        cmdln = command-line arguments (containing the path to the config)

    Throws:
        `Exception` if parsing the config file failed.

    Returns:
        `Config` instance

*******************************************************************************/

public Config parseConfigFile (ref const CommandLine cmdln)
{
    Node root = Loader.fromFile(cmdln.config_path).load();
    return parseConfigImpl(cmdln, root);
}

/// ditto
public Config parseConfigString (string data, string path)
{
    CommandLine cmdln = { config_path: path };
    Node root = Loader.fromString(data).load();
    return parseConfigImpl(cmdln, root);
}

///
unittest
{
    assertThrown!Exception(parseConfigString("", "/dev/null"));
    // Missing 'network' section
    {
        immutable conf_str = `
node:
  validator: false
`;
        assertThrown!Exception(parseConfigString(conf_str, "/dev/null"));
    }

    {
        immutable conf_str = `
network:
  - http://192.168.0.42:2826
`;
        auto conf = parseConfigString(conf_str, "/dev/null");
        assert(conf.network == [ `http://192.168.0.42:2826` ]);
    }
}

/// ditto
private Config parseConfigImpl (ref const CommandLine cmdln, Node root)
{
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
        logging: parseLoggingSection("logging" in root, cmdln),
        event_handlers: parserEventHandlers("event_handlers" in root, cmdln),
    };

    enforce(conf.network.length > 0, "Network section is empty");

    Node* admin = "admin" in root;
    conf.admin.enabled = opt!(bool,   "admin", "enabled")(cmdln, admin);
    if (conf.admin.enabled)
    {
        conf.admin.address = get!(string, "admin", "address")(cmdln, admin);
        conf.admin.port    = get!(ushort, "admin", "port")(cmdln, admin);
    }
    return conf;
}

/// Parse the node config section
private NodeConfig parseNodeConfig (Node* node, const ref CommandLine cmdln)
{
    auto is_validator = get!(bool, "node", "is_validator")(cmdln, node);
    auto min_listeners = get!(size_t, "node", "min_listeners")(cmdln, node);
    auto max_listeners = get!(size_t, "node", "max_listeners")(cmdln, node);
    auto address = get!(string, "node", "address")(cmdln, node);
    auto genesis_block = opt!(string, "node", "genesis_block")(cmdln, node);

    Duration retry_delay = get!(Duration, "node", "retry_delay",
                                str => str.to!ulong.msecs)(cmdln, node);

    size_t max_retries = get!(size_t, "node", "max_retries")(cmdln, node);
    Duration timeout = get!(Duration, "node", "timeout", str => str.to!ulong.msecs)
        (cmdln, node);

    string data_dir = get!(string, "node", "data_dir")(cmdln, node);
    auto port = get!(ushort, "node", "port")(cmdln, node);
    auto validator_cycle = get!(uint, "node", "validator_cycle")(cmdln, node);

    NodeConfig makeConf (KeyPair key_pair)
    {
        NodeConfig r = {
            is_validator : is_validator,
            min_listeners : min_listeners,
            max_listeners : max_listeners,
            genesis_block : genesis_block,
            address : address,
            port : port,
            key_pair : key_pair,
            retry_delay : retry_delay,
            max_retries : max_retries,
            timeout : timeout,
            data_dir : data_dir,
            validator_cycle : validator_cycle,
        };
        return r;
    }

    if (is_validator)
    {
        string node_seed = get!(string, "node", "seed")(cmdln, node);
        return makeConf(KeyPair.fromSeed(Seed.fromString(node_seed)));
    }
    return makeConf(KeyPair.init);
}

///
unittest
{
    import dyaml.loader;

    CommandLine cmdln;

    {
        immutable conf_example = `
node:
  address: 0.0.0.0
  port: 2926
  data_dir: .cache
`;
        auto node = Loader.fromString(conf_example).load();
        auto config = parseNodeConfig("node" in node, cmdln);
        assert(config.min_listeners == 2);
        assert(config.max_listeners == 10);
        assert(config.is_validator == false);
        assert(config.data_dir == ".cache");
    }
    {
    immutable conf_example = `
node:
  is_validator: true
`;
        auto node = Loader.fromString(conf_example).load();
        assertThrown!Exception(parseNodeConfig("node" in node, cmdln));
    }
}

/// Parse the banman config section
private BanManager.Config parseBanManagerConfig (Node* node, const ref CommandLine cmdln)
{
    BanManager.Config conf;
    conf.max_failed_requests = get!(size_t, "banman", "max_failed_requests")(cmdln, node);
    conf.ban_duration = cast(time_t)get!(size_t, "banman", "ban_duration")(cmdln, node);
    return conf;
}

/*******************************************************************************

    Parse the `logging` config section

    Params:
        ptr = pointer to the Yaml node containing the loggers configuration
        c = the parsed command line arguments, for override

    Returns:
        the parsed config section

*******************************************************************************/

private LoggingConfig parseLoggingSection (Node* ptr, const ref CommandLine c)
{
    LoggingConfig ret;
    ret.log_level = opt!(LogLevel, "logging", "level")(c, ptr, LogLevel.Error);
    return ret;
}

///
unittest
{
    import dyaml.loader;

    {
        CommandLine cmdln;
        immutable conf_example = `
foo:
  bar: Useless
logging:
  level: Trace
`;
        auto node = Loader.fromString(conf_example).load();
        auto config = parseLoggingSection("logging" in node, cmdln);
        assert(config.log_level == LogLevel.Trace);

        cmdln.overrides["logging.level"] = [ "None" ];
        auto config2 = parseLoggingSection("logging" in node, cmdln);
        assert(config2.log_level == LogLevel.None);
    }

    {
        CommandLine cmdln;
        immutable conf_example = `
logging:
  foo: bar
`;
        auto node = Loader.fromString(conf_example).load();
        auto config = parseLoggingSection("logging" in node, cmdln);
        assert(config.log_level == LogLevel.Error);

        cmdln.overrides["logging.level"] = [ "Trace" ];
        auto config2 = parseLoggingSection("logging" in node, cmdln);
        assert(config2.log_level == LogLevel.Trace);
    }
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
private T get (T, string section, string name) (
    const ref CommandLine cmdln, Node* node)
{
    return get!(T, section, name, (string val) => val.to!T)(cmdln, node);
}

/// Helper function to get a config parameter with a conversion routine
private T get (T, string section, string name, alias conv)
    (const ref CommandLine cmdl, Node* node)
{
    static immutable QualifiedName = (section ~ "." ~ name);

    if (auto val = QualifiedName in cmdl.overrides)
        return conv((*val)[$ - 1]);

    if (node)
        if (auto val = name in *node)
            return conv((*val).as!string);

    // If the user sets a default value, just return it
    static if (is(typeof(mixin(`Config.` ~ QualifiedName)) : T)
               && mixin(`Config.init.` ~ QualifiedName) != T.init)
        return mixin(`Config.init.` ~ QualifiedName);
    // Additionally, `bool` is special cased, as a `bool` that is mandatory
    // does not make sense: it defaults to either `true` or `false`
    else static if (is(T == bool))
        return false;
    else
        throw new Exception(format(
            "'%s' was not found in config's '%s' section, nor was '%s' in command line arguments",
            name, section, QualifiedName));
}

/// Helper function to get a config parameter with a converter
private auto get (string section, string name, Converter) (
    const ref CommandLine cmdl, Node* node, scope Converter converter)
{
    return converter(get!(ParameterType!convert, section, name)(cmdl, node));
}

/*******************************************************************************

    Convert a QuorumConfig to the SCPQorum which the SCP protocol understands

    Params:
        quorum_conf = the quorum config

    Returns:
        `SCPQuorumSet` instance

*******************************************************************************/

public SCPQuorumSet toSCPQuorumSet ( in QuorumConfig quorum_conf ) @safe
{
    import std.conv;
    import scpd.types.Stellar_types : uint256, NodeID;

    SCPQuorumSet quorum;
    quorum.threshold = quorum_conf.threshold.to!uint;

    foreach (node; quorum_conf.nodes)
    {
        auto pub_key = NodeID(uint256(node));
        quorum.validators.push_back(pub_key);
    }

    foreach (sub_quorum; quorum_conf.quorums)
    {
        auto scp_quorum = toSCPQuorumSet(sub_quorum);
        quorum.innerSets.push_back(scp_quorum);
    }

    return quorum;
}

/*******************************************************************************

    Convert an SCPQorum to a QuorumConfig

    Params:
        scp_quorum = the quorum config

    Returns:
        `SCPQuorumSet` instance

*******************************************************************************/

public QuorumConfig toQuorumConfig (const ref SCPQuorumSet scp_quorum) @safe
{
    import std.conv;
    import scpd.types.Stellar_types : Hash, NodeID;

    PublicKey[] nodes;

    foreach (node; scp_quorum.validators.constIterator)
        nodes ~= PublicKey(node[]);

    QuorumConfig[] quorums;
    foreach (ref sub_quorum; scp_quorum.innerSets.constIterator)
        quorums ~= toQuorumConfig(sub_quorum);

    QuorumConfig quorum =
    {
        threshold : scp_quorum.threshold.to!uint,
        nodes : nodes,
        quorums : quorums,
    };

    return quorum;
}

///
unittest
{
    auto quorum = QuorumConfig(2,
        [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
         PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")],
        [QuorumConfig(2,
            [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
             PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")],
            [QuorumConfig(2,
                [PublicKey.fromString("GBFDLGQQDDE2CAYVELVPXUXR572ZT5EOTMGJQBPTIHSLPEOEZYQQCEWN"),
                 PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5"),
                 PublicKey.fromString("GBYK4I37MZKLL4A2QS7VJCTDIIJK7UXWQWKXKTQ5WZGT2FPCGIVIQCY5")])])]);

    auto scp_quorum = toSCPQuorumSet(quorum);
    assert(scp_quorum.toQuorumConfig() == quorum);
}

/*******************************************************************************

    Parse the `event_handlers` config section

    Params:
        ptr = pointer to the Yaml node containing the event_handlers configuration
        c = the parsed command line arguments, for override

    Returns:
        the parsed event handlers

*******************************************************************************/

private EventHandlerConfig parserEventHandlers (Node* node, const ref CommandLine c)
{
    if (node is null)
        return EventHandlerConfig.init;

    const(string)[] parseSequence (Node node, string section)
    {
        if (auto val = section in c.overrides)
            return *val;

        auto elem = section in node;
        if (elem is null)
            return null;

        enforce(elem.type == NodeType.sequence,
            format("`%s` section must be a sequence", section));

        string[] result;
        foreach (string item; *elem)
            result ~= item;

        return result;
    }

    EventHandlerConfig handlers =
    {
        block_externalized_handler_addresses:
            assumeUnique(parseSequence(*node, "block_externalized")),
        preimage_updated_handler_addresses:
            assumeUnique(parseSequence(*node, "preimage_received"))
    };

    return handlers;
}

///
unittest
{
    // If the node does not exist
    {
        CommandLine cmdln;
        immutable conf_example = `
noexist_event_handlers:
`;
        auto node = Loader.fromString(conf_example).load();
        auto conf = parserEventHandlers("event_handlers" in node, cmdln);
        assert(conf.block_externalized_handler_addresses.length == 0);
        assert(conf.preimage_updated_handler_addresses.length == 0);
    }

    // If the nodes and values exist
    {
        CommandLine cmdln;
        immutable conf_example = `
event_handlers:
  block_externalized:
    - http://127.0.0.1:3836
  preimage_received:
    - http://127.0.0.1:3836
`;
        auto node = Loader.fromString(conf_example).load();
        auto conf = parserEventHandlers("event_handlers" in node, cmdln);
        assert(conf.block_externalized_handler_addresses == [ `http://127.0.0.1:3836` ]);
        assert(conf.preimage_updated_handler_addresses == [ `http://127.0.0.1:3836` ]);
    }
}
