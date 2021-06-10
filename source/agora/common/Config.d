/*******************************************************************************

    Define the configuration objects that are used through the application

    See `doc/config.example.yaml` for some documentation.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Config;

import agora.common.Amount;
import agora.common.BanManager;
import agora.common.Set;
import agora.common.Types;
import agora.consensus.data.Params;
import agora.crypto.Key;
import agora.flash.Config;
import agora.utils.Log;

import scpd.types.Stellar_SCP;
import scpd.types.Utils;

import dyaml.node;
import dyaml.loader;

import std.algorithm;
import std.conv;
import std.datetime;
import std.exception;
import std.format;
import std.getopt;
import std.range;
import std.traits;

import core.time;

/// Path to the import file containing the version information
public immutable VersionFileName = "VERSION";

/// Command-line arguments
public struct CommandLine
{
    /// Path to the config file
    public string config_path = "config.yaml";

    /// If non-`null`, what address to bind the setup interface to
    public string initialize;

    /// check state of config file and exit early
    public bool config_check;

    /// Do not output anything
    public bool quiet;

    /// Print the version information
    public bool version_;

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

    /// Configuration for interfaces the node expose (only http for now)
    public immutable InterfaceConfig[] interfaces = InterfaceConfig.Default;

    /// Consensus parameters for the chain
    public ConsensusConfig consensus;

    /// The validator config
    public ValidatorConfig validator;

    /// Flash configuration
    public FlashConfig flash;

    /// The administrator interface config
    public AdminConfig admin;

    /// The list of IPs for use with network discovery
    public immutable string[] network;

    /// The list of DNS FQDN seeds for use with network discovery
    public immutable string[] dns_seeds;

    /// Logging config
    public immutable(LoggerConfig)[] logging;

    /// Event handler config
    public EventHandlerConfig event_handlers;
}

/// Used to specify endpoint-specific configuration
public struct InterfaceConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// Type of interface one is able to register
    public enum Type
    {
        // FIXME: https://github.com/sociomantic-tsunami/ocean/issues/846
        // /// Cannonical name is in upper case
        // HTTP = 0,
        /// Convenience alias for parsing
        http = 0,
    }

    /// Ditto
    public Type type;

     /// Bind address
    public string address;

    /// Bind port
    public ushort port;

    /// Default values when none is given in the config file
    private static immutable InterfaceConfig[/* Type.max */ 1] Default = [
        // Publicly enabled by default
        { type: Type.http, address: "0.0.0.0", port: 0xB0A, },
    ];
}

/// Node config
public struct NodeConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// If set, a commons budget address to use
    /// in place of the built-in commons budget address as defined by CoinNet
    public PublicKey commons_budget_address;

    /// If set to true will run in testing mode and use different
    /// genesis block (agora.consensus.data.genesis.Test)
    /// and TODO: addresses should be different prefix (e.g. TN... for TestNet)
    public bool testing;

    /// Should only be set if `test` is set, can be set to the number of desired
    /// enrollment in the test Genesis block (1 - 6)
    public ubyte limit_test_validators;

    /// How often a block should be created
    public uint block_interval_sec = 600;

    /// The minimum number of listeners to connect to
    /// before discovery is considered complete
    public size_t min_listeners = 2;

    /// Maximum number of listeners to connect to
    public size_t max_listeners = 10;

    /// The local address where the stats server (currently Prometheus)
    /// is going to connect to, for example: http://0.0.0.0:8008
    /// It can also be set to 0 do disable listening
    public ushort stats_listening_port;

    /// Time to wait between request retries
    public Duration retry_delay = 3.seconds;

    /// Maximum number of retries to issue before a request is considered failed
    public size_t max_retries = 50;

    /// Timeout for each request
    public Duration timeout = 5000.msecs;

    /// Path to the data directory to store metadata and blockchain data
    public string data_dir = ".cache";

    /// The duration between requests for doing periodic network discovery
    public Duration network_discovery_interval = 5.seconds;

    /// The duration between requests for retrieving the latest blocks
    /// from all other nodes
    public Duration block_catchup_interval = 20.seconds;

    /// The new block time offset has to be greater than the previous block time offset,
    /// but less than current time + block_time_offset_tolerance_secs
    public Duration block_time_offset_tolerance = 60.seconds;

    // The percentage by which the double spend transaction's fee should be
    // increased in order to be added to the transaction pool
    public ubyte double_spent_threshold_pct = 20;

    /// The maximum number of transactions relayed in every batch.
    /// Value 0 means no limit.
    public uint relay_tx_max_num;

    /// Transaction relay batch is triggered in every `relay_tx_interval`.
    /// Value 0 means, the transaction will be relayed immediately.
    public Duration relay_tx_interval;

    /// The minimum amount of fee a transaction has to have to be relayed.
    /// The fee is adjusted by the transaction size:
    /// adjusted fee = fee / transaction size in bytes.
    public Amount relay_tx_min_fee;

    /// Transaction put into the relay queue will expire, and will be removed
    /// after `relay_tx_cache_exp`.
    public Duration relay_tx_cache_exp;
}

/// Validator config
public struct ValidatorConfig
{
    /// Whether or not this node should try to act as a validator
    public bool enabled;

    /// The seed to use for the keypair of this node
    public immutable KeyPair key_pair;

    // Network addresses that will be registered with the public key (Validator only)
    public immutable string[] addresses_to_register;

    // Registry address
    public string registry_address;

    // If the enrollments will be renewed or not at the end of the cycle
    public bool recurring_enrollment = true;

    /// How often should the periodic preimage reveal timer trigger (in seconds)
    public Duration preimage_reveal_interval = 10.seconds;

    /// How often the nomination timer should trigger, in seconds
    public Duration nomination_interval = 5.seconds;
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

/// Configuration for URLs to push a data when an event occurs
public struct EventHandlerConfig
{
    /// URLs to push a data when a block is externalized
    public immutable string[] block_externalized_handler_addresses;

    /// URLs to push a data when a pre-image is updated
    public immutable string[] preimage_updated_handler_addresses;

    /// URLs to push a data when a transaction is received
    public immutable string[] transaction_received_handler_addresses;
}

/// Parse the command-line arguments and return a GetoptResult
public GetoptResult parseCommandLine (ref CommandLine cmdline, string[] args)
{
    return getopt(
        args,
        "initialize",
            "The address at which to offer a web-based configuration interface",
            &cmdline.initialize,

        "config|c",
            "Path to the config file. Defaults to: " ~ CommandLine.init.config_path,
            &cmdline.config_path,

        "config-check",
            "Check the state of the config and exit",
            &cmdline.config_check,

        "quiet|q",
           "Do not output anything (currently only affects `--config-check`)",
            &cmdline.quiet,

        "override|O",
            "Override a config file value\n" ~
            "Example: ./agora -O node.validator=true -o dns=1.1.1.1 -o dns=2.2.2.2\n" ~
            "Array values are additive, other items are set to the last override",
            &cmdline.overridesHandler,

        "version",
            "Print Agora's version and build informations, then exit",
            &cmdline.version_,
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

public Config parseConfigFile (in CommandLine cmdln)
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

    // Missing 'network' section for a non validator node
    {
        immutable conf_str = `
validator:
  enabled: false
`;
        assertThrown!Exception(parseConfigString(conf_str, "/dev/null"));
    }

    // Missing 'network' section for a validator node with name registry
    {
        immutable conf_str = `
validator:
  enabled: true
  registry_address: http://127.0.0.1:3003
  seed:    SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI
  recurring_enrollment: true
  preimage_reveal_interval: 10
`;
        parseConfigString(conf_str, "/dev/null");
    }

        // Missing 'network' section for a validator node without name registry
    {
        immutable conf_str = `
validator:
  enabled: true
  registry_address: disabled
  seed:    SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI
  recurring_enrollment: true
  preimage_reveal_interval: 10
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

///
private const(string)[] parseSequence (string section, in CommandLine cmdln,
        Node root, bool optional = false)
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

/// ditto
private Config parseConfigImpl (in CommandLine cmdln, Node root)
{
    immutable(InterfaceConfig)[] interfaces;

    // TODO: Make parseSequence return any type, not just string[]
    if (Node* interfacesNode = "interfaces" in root)
    {
        foreach (ref Node l; *interfacesNode)
        {
            auto type = get!(InterfaceConfig.Type, "interfaces", "type")(cmdln, &l);
            // All nodes have a default address
            auto address = opt!(string, "interfaces", "address")(
                cmdln, &l, InterfaceConfig.Default[type].address);
            // ... but some are disabled by default
            ushort port = () {
                const defaultPort = InterfaceConfig.Default[type].port;
                if (defaultPort == 0)
                    return get!(ushort, "interfaces", "port")(cmdln, &l);
                return opt!(ushort, "interfaces", "port")(cmdln, &l, defaultPort);
            }();

            interfaces ~= InterfaceConfig(type, address, port);
        }

        if (!interfaces.length)
            throw new Exception("The 'interfaces' section must be empty or have valid values");
    }
    else
        interfaces = InterfaceConfig.Default;

    auto validator = parseValidatorConfig("validator" in root, cmdln);
    auto node = parseNodeConfig("node" in root, cmdln);

    Config conf =
    {
        banman : parseBanManagerConfig("banman" in root, cmdln),
        node : node,
        interfaces: interfaces,
        consensus: parseConsensusConfig("consensus" in root, cmdln),
        validator : validator,
        flash : parseFlashConfig("flash" in root, cmdln, node, validator),
        network : assumeUnique(parseSequence("network", cmdln, root, true)),
        dns_seeds : assumeUnique(parseSequence("dns", cmdln, root, true)),
        logging: parseLoggingSection("logging" in root, cmdln),
        event_handlers: parserEventHandlers("event_handlers" in root, cmdln),
    };

    if (conf.validator.enabled)
        enforce(conf.network.length ||
                conf.validator.registry_address != "disabled" ||
                // Allow single-network validator (assume this is NODE6)
                conf.node.limit_test_validators == 1,
            "Either the network section must not be empty, or 'validator.registry_address' must be set");
    else
        enforce(conf.network.length, "Network section must not be empty");

    Node* admin = "admin" in root;
    conf.admin.enabled = get!(bool, "admin", "enabled")(cmdln, admin);
    if (conf.admin.enabled)
    {
        conf.admin.address = get!(string, "admin", "address")(cmdln, admin);
        conf.admin.port    = get!(ushort, "admin", "port")(cmdln, admin);
    }
    return conf;
}

/// Parse the node config section
private NodeConfig parseNodeConfig (Node* node, in CommandLine cmdln)
{
    auto min_listeners = get!(size_t, "node", "min_listeners")(cmdln, node);
    auto max_listeners = get!(size_t, "node", "max_listeners")(cmdln, node);
    auto commons_budget = opt!(string, "node", "commons_budget_address")(cmdln, node);

    auto commons_budget_address = (commons_budget.length > 0)
        ? PublicKey.fromString(commons_budget)
        : PublicKey.init;

    auto testing = opt!(bool, "node", "testing")(cmdln, node);
    auto limit_test_validators = opt!(ubyte, "node", "limit_test_validators")(cmdln, node);
    if (!testing && limit_test_validators)
        throw new Exception("Cannot use 'node.limit_test_validator' without 'node.testing' set to 'true'");
    if (limit_test_validators > 6)
        throw new Exception("Value of 'node.limit_test_validators' must be between 0 and 6, inclusive");

    uint block_interval_sec = get!(uint, "node", "block_interval_sec")(cmdln, node);

    Duration retry_delay = get!(Duration, "node", "retry_delay",
                                str => str.to!ulong.msecs)(cmdln, node);

    size_t max_retries = get!(size_t, "node", "max_retries")(cmdln, node);
    Duration timeout = get!(Duration, "node", "timeout", str => str.to!ulong.msecs)
        (cmdln, node);

    string data_dir = get!(string, "node", "data_dir")(cmdln, node);
    const stats_listening_port = opt!(ushort, "node", "stats_listening_port")(cmdln, node);
    const block_time_offset_tolerance_secs = opt!(uint, "node", "block_time_offset_tolerance_secs")(cmdln, node);
    const network_discovery_interval = opt!(uint, "node", "network_discovery_interval_secs")(cmdln, node);
    const block_catchup_interval = opt!(uint, "node", "block_catchup_interval_secs")(cmdln, node);
    const double_spent_threshold_pct = opt!(ubyte, "node", "double_spent_threshold_pct")(cmdln, node);
    const relay_tx_max_num = opt!(ushort, "node", "relay_tx_max_num")(cmdln, node, 100);
    Duration relay_tx_interval = opt!(ulong, "node", "relay_tx_interval_secs")(cmdln, node, 15).seconds;
    const relay_tx_min_fee = Amount(opt!(ulong, "node", "relay_tx_min_fee")(cmdln, node, 0));
    Duration relay_tx_cache_exp = opt!(ulong, "node", "relay_tx_cache_exp_secs")(cmdln, node, 1200).seconds;

    NodeConfig result = {
            min_listeners : min_listeners,
            max_listeners : max_listeners,
            commons_budget_address : commons_budget_address,
            testing : testing,
            limit_test_validators: limit_test_validators,
            block_interval_sec : block_interval_sec,
            retry_delay : retry_delay,
            max_retries : max_retries,
            timeout : timeout,
            data_dir : data_dir,
            stats_listening_port : stats_listening_port,
            block_time_offset_tolerance : block_time_offset_tolerance_secs.seconds,
            network_discovery_interval : network_discovery_interval.seconds,
            block_catchup_interval : block_catchup_interval.seconds,
            double_spent_threshold_pct : double_spent_threshold_pct,
            relay_tx_max_num : relay_tx_max_num,
            relay_tx_interval : relay_tx_interval,
            relay_tx_min_fee : relay_tx_min_fee,
            relay_tx_cache_exp : relay_tx_cache_exp,
    };
    return result;
}

///
unittest
{
    import dyaml.loader;

    CommandLine cmdln;

    {
        immutable conf_example = `
node:
  interfaces:
    - type: http
      address: 0.0.0.0
      port: 2926
  data_dir: .cache
  commons_budget_address: boa1xrzwvvw6l6d9k84ansqgs9yrtsetpv44wfn8zm9a7lehuej3ssskxth867s
`;
        auto node = Loader.fromString(conf_example).load();
        auto config = parseNodeConfig("node" in node, cmdln);
        assert(config.min_listeners == 2);
        assert(config.max_listeners == 10);
        assert(config.data_dir == ".cache");
        assert(config.commons_budget_address.toString() == "boa1xrzwvvw6l6d9k84ansqgs9yrtsetpv44wfn8zm9a7lehuej3ssskxth867s");
    }
}

/// Parse Consensus parameters
private ConsensusConfig parseConsensusConfig (Node* node, in CommandLine cmdln)
{
    const validator_cycle = get!(uint, "consensus", "validator_cycle")(cmdln, node);
    const genesis_ts = get!(ulong, "consensus", "genesis_timestamp")(cmdln, node);
    const max_quorum_nodes = get!(uint, "consensus", "max_quorum_nodes")(cmdln, node);
    const quorum_threshold = get!(uint, "consensus", "quorum_threshold")(cmdln, node);
    const quorum_shuffle_interval = get!(uint, "consensus", "quorum_shuffle_interval")(cmdln, node);
    const tx_payload_max_size = get!(uint, "consensus", "tx_payload_max_size")(cmdln, node);
    const tx_payload_fee_factor = get!(uint, "consensus", "tx_payload_fee_factor")(cmdln, node);
    const validator_tx_fee_cut = get!(ubyte, "consensus", "validator_tx_fee_cut")(cmdln, node);
    const payout_period = get!(uint, "consensus", "payout_period")(cmdln, node);

    if (quorum_threshold < 1 || quorum_threshold > 100)
        throw new Exception("consensus.quorum_threshold is a percentage and must be between 1 and 100, included");

    ConsensusConfig result = {
        validator_cycle: validator_cycle,
        genesis_timestamp: genesis_ts,
        max_quorum_nodes: max_quorum_nodes,
        quorum_threshold: quorum_threshold,
        quorum_shuffle_interval: quorum_shuffle_interval,
        tx_payload_max_size: tx_payload_max_size,
        tx_payload_fee_factor: tx_payload_fee_factor,
        validator_tx_fee_cut: validator_tx_fee_cut,
        payout_period: payout_period,
    };

    return result;
}

///
unittest
{
    import dyaml.loader;

    CommandLine cmdln;

    immutable conf_example = `
consensus:
    validator_cycle:           42
    max_quorum_nodes:         420
    quorum_threshold:          96
    quorum_shuffle_interval:  210
    tx_payload_max_size:     2048
    tx_payload_fee_factor:   2100
    validator_tx_fee_cut:      69
    payout_period:           9999
    genesis_timestamp:     424242
`;

    auto node = Loader.fromString(conf_example).load();
    auto config = parseConsensusConfig("consensus" in node, cmdln);
    assert(config.validator_cycle == 42);
    assert(config.max_quorum_nodes == 420);
    assert(config.quorum_threshold == 96);
    assert(config.quorum_shuffle_interval == 210);
    assert(config.tx_payload_max_size == 2048);
    assert(config.tx_payload_fee_factor == 2100);
    assert(config.validator_tx_fee_cut == 69);
    assert(config.payout_period == 9999);
    assert(config.genesis_timestamp == 424242);
}

/// Parse the validator config section
private ValidatorConfig parseValidatorConfig (Node* node, in CommandLine cmdln)
{
    const enabled = get!(bool, "validator", "enabled")(cmdln, node);
    if (!enabled)
        return ValidatorConfig(false);

    auto registry_address = get!(string, "validator", "registry_address")(cmdln, node);
    const recurring_enrollment = get!(bool, "validator", "recurring_enrollment")(cmdln, node);
    const preimage_reveal_interval = get!(Duration, "validator", "preimage_reveal_interval",
        str => str.to!ulong.seconds)(cmdln, node);
    const nomination_interval = get!(Duration, "validator", "nomination_interval",
        str => str.to!ulong.seconds)(cmdln, node);

    ValidatorConfig result = {
        enabled: true,
        key_pair:
            KeyPair.fromSeed(SecretKey.fromString(get!(string, "validator", "seed")(cmdln, node))),
        registry_address: registry_address,
        addresses_to_register : assumeUnique(parseSequence("addresses_to_register", cmdln, *node, true)),
        recurring_enrollment : recurring_enrollment,
        preimage_reveal_interval : preimage_reveal_interval,
        nomination_interval : nomination_interval,
    };
    return result;
}

/// Parse the flash config section
private FlashConfig parseFlashConfig (Node* node, in CommandLine cmdln,
    in NodeConfig node_config, in ValidatorConfig validator_config)
{
    const enabled = get!(bool, "flash", "enabled")(cmdln, node);
    if (!enabled)
        return FlashConfig(false);

    const timeout = get!(Duration, "flash", "timeout", str => str.to!ulong.msecs)
        (cmdln, node);

    const listener_address = get!(string, "flash", "listener_address")(cmdln, node);
    const min_funding = opt!(ulong, "flash", "min_funding")(cmdln, node);
    const max_funding = opt!(ulong, "flash", "max_funding")(cmdln, node);
    const min_settle_time = opt!(uint, "flash", "min_settle_time")(cmdln, node);
    const max_settle_time = opt!(uint, "flash", "max_settle_time")(cmdln, node);
    const max_retry_time = get!(Duration, "flash", "max_retry_time", str => str.to!ulong.msecs)
        (cmdln, node);
    const max_retry_delay = get!(Duration, "flash", "max_retry_delay", str => str.to!ulong.msecs)
        (cmdln, node);
    enforce(max_retry_time > max_retry_delay, "`max_retry_time` must be greater than `max_retry_delay`");
    const retry_multiplier = opt!(uint, "flash", "retry_multiplier")(cmdln, node);
    const registry_address = get!(string, "flash", "registry_address")(cmdln, node);

    const control_address = get!(string, "flash", "control_address")(cmdln, node);
    const control_port    = get!(ushort, "flash", "control_port")(cmdln, node);

    FlashConfig result = {
        enabled: true,
        timeout: timeout,
        listener_address: listener_address,
        control_address: control_address,
        control_port: control_port,
        min_funding: min_funding.coins,
        max_funding: max_funding.coins,
        min_settle_time: min_settle_time,
        max_settle_time: max_settle_time,
        max_retry_time : max_retry_time,
        max_retry_delay : max_retry_delay,
        retry_multiplier : retry_multiplier,
        registry_address : registry_address,
        addresses_to_register : assumeUnique(parseSequence("addresses_to_register", cmdln, *node, true)),
    };
    return result;
}

unittest
{
    import dyaml.loader;

    CommandLine cmdln;

    {
        immutable conf_example = `
validator:
  enabled: true
  seed: SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI
  registry_address: http://127.0.0.1:3003
  recurring_enrollment : false
  preimage_reveal_interval: 99
`;
        auto node = Loader.fromString(conf_example).load();
        auto config = parseValidatorConfig("validator" in node, cmdln);
        assert(config.enabled);
        assert(config.preimage_reveal_interval == 99.seconds);
        assert(config.key_pair == KeyPair.fromSeed(
            SecretKey.fromString("SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI")));
        assert(!config.recurring_enrollment);
    }
    {
    immutable conf_example = `
validator:
  enabled: true
`;
        auto node = Loader.fromString(conf_example).load();
        assertThrown!Exception(parseValidatorConfig("validator" in node, cmdln));
    }
}

/// Parse the banman config section
private BanManager.Config parseBanManagerConfig (Node* node, in CommandLine cmdln)
{
    BanManager.Config conf;
    conf.max_failed_requests = get!(size_t, "banman", "max_failed_requests")(cmdln, node);
    conf.ban_duration = get!(Duration, "banman", "ban_duration",
                             str => str.to!ulong.seconds)(cmdln, node);
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

private immutable(LoggerConfig)[] parseLoggingSection (Node* ptr, in CommandLine)
{
    // By default, configure the root logger to be verbose enough for users
    // to see what's happening
    static immutable LoggerConfig[] DefaultConfig = [ {
        name: null,
        level: LogLevel.Info,
        propagate: true,
        console: true,
        additive: true,
    } ];

    if (ptr is null)
        return DefaultConfig;

    immutable(LoggerConfig)[] result;
    foreach (string name_, Node value; *ptr)
    {
        LoggerConfig c = { name: name_ != "root" ? name_ : null };
        if (auto p = "level" in value)
            c.level = (*p).as!string.to!LogLevel;
        if (auto p = "propagate" in value)
            c.propagate = (*p).as!bool;
        if (auto p = "console" in value)
            c.console = (*p).as!bool;
        if (auto p = "additive" in value)
            c.additive = (*p).as!bool;
        if (auto p = "file" in value)
            c.file = (*p).as!string;
        if (auto p = "buffer_size" in value)
            c.buffer_size = (*p).as!size_t;

        result ~= c;
    }

    return result.length ? result : DefaultConfig;
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
  root:
    level: Trace
  agora.network:
    level: Error
`;
        auto node = Loader.fromString(conf_example).load();
        auto config = parseLoggingSection("logging" in node, cmdln);
        assert(config[0].name.length == 0);
        assert(config[0].level == LogLevel.Trace);
        assert(config[1].name == "agora.network");
        assert(config[1].level == LogLevel.Error);
    }

    {
        CommandLine cmdln;
        immutable conf_example = `
noLoggingSectionHere:
  foo: bar
`;
        auto node = Loader.fromString(conf_example).load();
        auto config = parseLoggingSection("logging" in node, cmdln);
        assert(config.length == 1);
        assert(config[0].name.length == 0);
        assert(config[0].level == LogLevel.Info);
        assert(config[0].console == true);
    }
}

/// Optionally get a value
private T opt (T, string section, string name) (
    in CommandLine cmdln, Node* node, lazy T def = T.init)
{
    try
        return get!(T, section, name)(cmdln, node);
    catch (Exception e)
        return def;
}

/// Helper function to get a config parameter
private T get (T, string section, string name) (in CommandLine cmdln, Node* node)
{
    return get!(T, section, name, (string val) => val.to!T)(cmdln, node);
}

/// Helper function to get a config parameter with a conversion routine
private T get (T, string section, string name, alias conv)
    (in CommandLine cmdl, Node* node)
{
    static immutable QualifiedName = (section ~ "." ~ name);
    static immutable Names = [ section, name ];

    if (auto val = QualifiedName in cmdl.overrides)
        return conv((*val)[$ - 1]);

    if (node)
        if (auto val = name in *node)
            return conv((*val).as!string);

    // If the user sets a default value, just return it
    static if (is(typeof(initValue!(Config.init, Names)) : T)
               && hasCustomInit!(Config.init, Names))
        return initValue!(Config.init, Names);
    // Additionally, `bool` is special cased, as a `bool` that is mandatory
    // does not make sense: it defaults to either `true` or `false`
    else static if (is(T == bool))
        return false;
    else
        throw new Exception(format(
            "'%s' was not found in config's '%s' section, nor was '%s' in command line arguments",
            name, section, QualifiedName));
}

/// Helper template to check if a struct's field has a non-default init
private template hasCustomInit (alias instance, const string[] FieldNames)
{
    private alias T = typeof(initValue!(instance, FieldNames));
    enum bool hasCustomInit = initValue!(instance, FieldNames) != T.init;
}

/// Helper template to get the initial value of a field
private template initValue (alias instance, const string[] FieldNames)
{
    static if (FieldNames.length == 1)
        static immutable initValue = __traits(getMember, instance, FieldNames[0]);
    else
        static immutable initValue =  initValue!(__traits(getMember, instance, FieldNames[0]), FieldNames[1 .. $]);
}

unittest
{
    static assert(initValue!(Config.init, ["consensus", "max_quorum_nodes"]) == 7);
    static assert(hasCustomInit!(Config.init, [ "consensus", "max_quorum_nodes"]));

    static assert(initValue!(Config.init, ["validator", "enabled"]) == false);
    static assert(!hasCustomInit!(Config.init, ["validator", "enabled"]));

    static assert(initValue!(Config.init.validator, ["preimage_reveal_interval"]) == 10.seconds);
    static assert(hasCustomInit!(Config.init.validator, ["preimage_reveal_interval"]));
}

/// Helper function to get a config parameter with a converter
private auto get (string section, string name, Converter) (
    in CommandLine cmdl, Node* node, scope Converter converter)
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

public SCPQuorumSet toSCPQuorumSet (in QuorumConfig quorum_conf) @safe nothrow
{
    import std.conv;
    import scpd.types.Stellar_types : uint256, NodeID;

    SCPQuorumSet quorum;
    quorum.threshold = quorum_conf.threshold;

    foreach (ref const node; quorum_conf.nodes)
    {
        auto pub_key = NodeID(uint256(node.data[][0 .. uint256.sizeof]));
        quorum.validators.push_back(pub_key);
    }

    foreach (ref const sub_quorum; quorum_conf.quorums)
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

public QuorumConfig toQuorumConfig (const ref SCPQuorumSet scp_quorum)
    @safe nothrow
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
        threshold : scp_quorum.threshold,
        nodes : nodes,
        quorums : quorums,
    };

    return quorum;
}

///
unittest
{
    auto quorum = QuorumConfig(2,
        [PublicKey.fromString("boa1xp9rtxssrry6zqc4yt40h5h3al6enaywnvxfsp0ng8jt0ywyecsszs3fs7r"),
         PublicKey.fromString("boa1xpc2ugmlve2ttuq6sjl4fznrggf2l5hksk2h2nsakexn690zxg4gss4p0w2")],
        [QuorumConfig(2,
            [PublicKey.fromString("boa1xp9rtxssrry6zqc4yt40h5h3al6enaywnvxfsp0ng8jt0ywyecsszs3fs7r"),
             PublicKey.fromString("boa1xpc2ugmlve2ttuq6sjl4fznrggf2l5hksk2h2nsakexn690zxg4gss4p0w2")],
            [QuorumConfig(2,
                [PublicKey.fromString("boa1xp9rtxssrry6zqc4yt40h5h3al6enaywnvxfsp0ng8jt0ywyecsszs3fs7r"),
                 PublicKey.fromString("boa1xpc2ugmlve2ttuq6sjl4fznrggf2l5hksk2h2nsakexn690zxg4gss4p0w2"),
                 PublicKey.fromString("boa1xpc2ugmlve2ttuq6sjl4fznrggf2l5hksk2h2nsakexn690zxg4gss4p0w2")])])]);

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

private EventHandlerConfig parserEventHandlers (Node* node, in CommandLine c)
{
    if (node is null)
        return EventHandlerConfig.init;

    EventHandlerConfig handlers =
    {
        block_externalized_handler_addresses:
            assumeUnique(parseSequence("block_externalized", c, *node, true)),
        preimage_updated_handler_addresses:
            assumeUnique(parseSequence("preimage_received", c, *node, true)),
        transaction_received_handler_addresses:
            assumeUnique(parseSequence("transaction_received", c, *node, true)),
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
        assert(conf.transaction_received_handler_addresses.length == 0);
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
  transaction_received:
    - http://127.0.0.1:3836
`;
        auto node = Loader.fromString(conf_example).load();
        auto conf = parserEventHandlers("event_handlers" in node, cmdln);
        assert(conf.block_externalized_handler_addresses == [ `http://127.0.0.1:3836` ]);
        assert(conf.preimage_updated_handler_addresses == [ `http://127.0.0.1:3836` ]);
        assert(conf.transaction_received_handler_addresses == [ `http://127.0.0.1:3836` ]);
    }
}
