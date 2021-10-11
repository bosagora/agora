/*******************************************************************************

    Define the configuration objects that are used through the node

    See `doc/config.example.yaml` for some documentation.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.node.Config;

import agora.common.Amount;
import agora.common.BanManager;
import agora.common.Ensure;
import agora.common.Types;
import agora.config.Attributes;
import agora.config.Config;
import agora.consensus.data.Params;
import agora.crypto.Key;
import agora.flash.Config;
import agora.utils.Log;

import std.algorithm.iteration : splitter;
import std.algorithm.searching : all;
import std.exception;
import std.getopt;
import std.traits : hasUnsharedAliasing;
import std.uni : isAlphaNum;

import core.time;

/// Path to the import file containing the version information
public immutable VersionFileName = "VERSION";

/// Agora-specific command line arguments
public struct AgoraCLIArgs
{
    /// Base command line arguments
    public CLIArgs base;

    ///
    public alias base this;

    /// If non-`null`, what address to bind the setup interface to
    public string initialize;

    /// check state of config file and exit early
    public bool config_check;

    /// Do not output anything
    public bool quiet;

    /// Print the version information
    public bool version_;
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

    /// Proxy to be used for outgoing Agora connections
    public @Optional ProxyConfig proxy;

    /// Ditto
    static private struct ProxyConfig { URL url; }

    /// Consensus parameters for the chain
    public ConsensusConfig consensus;

    /// The validator config
    public ValidatorConfig validator;

    /// Flash configuration
    public FlashConfig flash;

    /// The administrator interface config
    public AdminConfig admin;

    /// Name registry configuration
    public RegistryConfig registry;

    /// The list of IPs for use with network discovery
    public @Optional immutable string[] network;

    /// The list of DNS FQDN seeds for use with network discovery
    @Name("dns")
    public @Optional immutable string[] dns_seeds;

    /// Logging config
    @Key("name")
    public immutable(LoggerConfig)[] logging = [ {
        name: null,
        level: LogLevel.Info,
        propagate: true,
        console: true,
        additive: true,
    } ];

    /// Event handler config
    @Key("type")
    public @Optional immutable(EventHandlerConfig)[] event_handlers;

    /// Validate that the config is self-consistent
    public void validate () @safe const scope
    {
        if (this.validator.enabled)
            enforce(this.network.length ||
                    this.validator.registry_address != "disabled" ||
                    // Allow single-network validator (assume this is NODE6)
                    this.node.limit_test_validators == 1,
                    "Either the network section must not be empty, or 'validator.registry_address' must be set");
        else
            enforce(this.network.length, "Network section must not be empty");

        if (!this.node.testing && this.node.limit_test_validators)
            throw new Exception("Cannot use 'node.limit_test_validator' without 'node.testing' set to 'true'");
        if (this.node.limit_test_validators > 6)
            throw new Exception("Value of 'node.limit_test_validators' must be between 0 and 6, inclusive");

        if (this.consensus.quorum_threshold < 1 || this.consensus.quorum_threshold > 100)
            throw new Exception("consensus.quorum_threshold is a percentage and must be between 1 and 100, included");

        // Work around https://github.com/bosagora/config/issues/3
        this.node.validate();
        if (this.registry.enabled)
            this.registry.validate();
    }
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
        https = 1,
        tcp = 2,
    }

    /// Ditto
    public Type type;

     /// Bind address
    public string address;

    /// Bind port
    public ushort port;

    /// Default values when none is given in the config file
    private static immutable InterfaceConfig[Type.max] Default = [
        // Publicly enabled by default
        { type: Type.http, address: "0.0.0.0", port: 0xB0A, },
        { type: Type.tcp,  address: "0.0.0.0", port: 0xA0B, },
    ];
}

/// Node config
public struct NodeConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// If set, a commons budget address to use
    /// in place of the built-in commons budget address as defined by CoinNet
    public @Optional PublicKey commons_budget_address;

    /// If set to true will run in testing mode and use different
    /// genesis block (agora.consensus.data.genesis.Test)
    /// and TODO: addresses should be different prefix (e.g. TN... for TestNet)
    public bool testing;

    /// Should only be set if `test` is set, can be set to the number of desired
    /// enrollment in the test Genesis block (1 - 6)
    public @Optional ubyte limit_test_validators;

    /// The minimum number of listeners to connect to
    /// before discovery is considered complete
    public size_t min_listeners = 2;

    /// Maximum number of listeners to connect to
    public size_t max_listeners = 10;

    /// The local address where the stats server (currently Prometheus)
    /// is going to connect to, for example: http://0.0.0.0:8008
    /// It can also be set to 0 do disable listening
    public @Optional ushort stats_listening_port;

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
    /// but less than current time + block_time_offset_tolerance
    public Duration block_time_offset_tolerance = 60.seconds;

    // The percentage by which the double spend transaction's fee should be
    // increased in order to be added to the transaction pool
    public ubyte double_spent_threshold_pct = 20;

    /***************************************************************************

        Minimum fee percentage for transactions to be added to the pool

        When accepting incoming transactions, only accept transactions where the
        fee is at least `min_fee_pct` percent of the current transaction pool.
        This setting can be tuned to prevent DoS attack.

        Setting this to 0 sets the mempool to be unlimited in size.

        Example:
        The transaction pool has two transactions, `TxA` which is 1000 bytes and
        has a fee of 15_000_000 (fee rate: 15_000) and another one which is 200
        bytes and comes with a fee of 1_000_000 (fee rate: 5_000).
        Hence, the average fee rate of the transaction pool is 10_000 / byte.
        (Fees are currently not weighted).

        If this is set to 110, and a transaction of 100 bytes arrives,
        the transaction would need to have at least `(1.1 * (10_000 * 100))`,
        or 1_100_000 in fees, to make it to the pool.

        On the other hand, if this is set to 50, then the transaction will only
        need to come with 500_000 of fees (`0.5 * (10_000 * 100)`).

    ***************************************************************************/

    public ushort min_fee_pct = 80;

    /// The maximum number of transactions relayed in every batch.
    /// Value 0 means no limit.
    public @Optional uint relay_tx_max_num;

    /// Transaction relay batch is triggered in every `relay_tx_interval`.
    /// Value 0 means, the transaction will be relayed immediately.
    public @Optional Duration relay_tx_interval;

    /// The minimum amount of fee a transaction has to have to be relayed.
    /// The fee is adjusted by the transaction size:
    /// adjusted fee = fee / transaction size in bytes.
    public @Optional Amount relay_tx_min_fee;

    /// Transaction put into the relay queue will expire, and will be removed
    /// after `relay_tx_cache_exp`.
    public @Optional Duration relay_tx_cache_exp;

    /// The realm to which this node belongs (a domain name)
    public string realm = "coinnet.bosagora.io";

    /// Validate this struct
    public void validate () const scope @safe
    {
        static bool isDomainChar (dchar c) @safe pure nothrow @nogc
        {
            // Dot is handled by `splitter`
            return isAlphaNum(c) || c == '-';
        }

        ensure(this.realm.length > 0, "node.realm cannot be empty");

        auto rng = this.realm.splitter('.');
        assert(!rng.empty);
        ensure(rng.front.length > 0,
            "node.realm ('{}')starts with a dot ('.'), which is not allowed. Remove it.",
            this.realm);

        do {
            // It might be the empty label, in which case it needs to be last
            if (rng.front.length == 0)
            {
                rng.popFront();
                ensure(rng.empty,
                    "node.realm ('{}') contains an empty label, which is not " ~
                    "allowed. Remove the double dot.",
                    this.realm);
                break;
            }
            ensure(rng.front.length <= 63,
                "node.realm ('{}') contains a label ('{}') which is longer " ~
                "than 63 characters ({} characters), which is not allowed.",
                this.realm, rng.front, rng.front.length);

            ensure(rng.front.all!isDomainChar,
                   "node.realm: label '{}' contains non-alpha characters. " ~
                   "Only alphanumeric ('a' to 'z', 'A' to 'Z', '0' to '9') and dash ('-'_ are allowed.",
                   rng.front);

            ensure(rng.front[0] != '-',
                   "node.realm: label '{}' cannot start with a dash", rng.front);
            ensure(rng.front[$-1] != '-',
                   "node.realm: label '{}' cannot end with a dash", rng.front);

            rng.popFront();
        } while (!rng.empty);
    }
}

/// Validator config
public struct ValidatorConfig
{
    /// Whether or not this node should try to act as a validator
    public bool enabled;

    /// The seed to use for the keypair of this node
    @Converter!KeyPair((value) => KeyPair.fromSeed(SecretKey.fromString(value.as!string)))
    public @Name("seed") immutable KeyPair key_pair;

    /// The seed of PreImageCycle which is not parsed from the configuraton file
    public @Optional Hash cycle_seed;

    /// The height of the seed of PreImageCycle which is not parsed from the configuraton file
    public @Optional Height cycle_seed_height;

    /***************************************************************************

        How far in the future (in unit of blocks) pre-images can be revealed

        For example, if a validator enrolled at block #100, expiring at
        block #200, has this value set to 10, it will gossip pre-image
        for height #152 as soon as block #142 is externalized.

        Increasing this value allow to be more tolerant to long outage, at the
        expense of encrypted Votera ballots being readable earlier, and a minor
        increase in predictability.

        By default, the value is set to 6, which, with CoinNet defaults,
        is equivalent to an hour.

    ***************************************************************************/

    public size_t max_preimage_reveal = 6;

    // Network addresses that will be registered with the public key
    public @Optional immutable string[] addresses_to_register;

    // Registry address
    public string registry_address;

    // If the enrollments will be renewed or not at the end of the cycle
    public bool recurring_enrollment = true;

    /// How often we should check the name registry for our own address
    public Duration name_registration_interval = 2.minutes;

    /// How often should the periodic preimage reveal timer trigger (in seconds)
    public Duration preimage_reveal_interval = 10.seconds;

    /// How often the nomination timer should trigger, in seconds
    public Duration nomination_interval = 5.seconds;

    /// How often the validator should try to catchup for the preimages for the
    /// next block
    public Duration preimage_catchup_interval = 2.seconds;
}

/// Admin API config
public struct AdminConfig
{
    static assert(!hasUnsharedAliasing!(typeof(this)),
        "Type must be shareable accross threads");

    /// Is the control API enabled?
    public bool enabled;

    /// Whether to use tls for admin
    public bool tls = true;

    /// Bind address
    public string address = "127.0.0.1";

    /// Bind port
    public ushort port = 0xB0B;

    /// Username
    public string username;

    /// Password
    public string pwd;
}

/// Type of event which can be forwarded to an API server
public enum HandlerType
{
    ///
    BlockExternalized,
    ///
    BlockHeaderUpdated,
    ///
    PreimageReceived,
    ///
    TransactionReceived,
}

/// Configuration for URLs to push a data when an event occurs
public struct EventHandlerConfig
{
    ///
    public HandlerType type;

    /// URLs to push data to
    public immutable string[] addresses;
}

/// Parse the command-line arguments and return a GetoptResult
public GetoptResult parseCommandLine (ref AgoraCLIArgs cmdline, string[] args)
{
    auto intermediate = cmdline.base.parse(args);
    if (intermediate.helpWanted)
        return intermediate;

    return getopt(
        args,
        "initialize",
            "The address at which to offer a web-based configuration interface",
            &cmdline.initialize,

        "config-check",
            "Check the state of the config and exit",
            &cmdline.config_check,

        "quiet|q",
            "Do not output anything (currently only affects `--config-check`)",
            &cmdline.quiet,

        "version",
            "Print Agora's version and build informations, then exit",
            &cmdline.version_,
        );
}

/// Configuration for the name registry
public struct RegistryConfig
{
    /// If this node should also act as a registry
    public bool enabled;

    /***************************************************************************

        The address to bind to - All interfaces by default

        You might want to set this to your public IP address so it doesn't bind
        to the local interface, which might be already used by systemd-resolvd.

    ***************************************************************************/

    public string address = "0.0.0.0";

    /// The port to bind to - Default to the standard DNS port (53)
    public ushort port = 53;

    /// The 'validators' zone
    public immutable(ZoneConfig) validators;

    /// The 'flash' zone
    public immutable(ZoneConfig) flash;

    /// Validate the semantic of the user-provided configuration
    public void validate () const scope @safe
    {
        ensure(this.address.length > 0, "registry is enabled but no `address` is provided");
        ensure(this.port > 0, "registry.port: 0 is not a valid value");

        static void validateZone (string name, in ZoneConfig zone)
        {
            // If we're not authoritative, there's no configuration to validate
            if (!zone.authoritative)
                return;

            ensure(zone.email.length > 0,
                   "registry.{}: Authoritative zones require an email to be provided", name);

            // Now validate the durations are consistent with one another
            ensure(zone.refresh <= zone.expire,
                   "registry.{}.refresh ({}) should be lower than field 'expire' ({})",
                   name, zone.refresh, zone.expire);
            // The other ones could actually be set to very low values to
            // avoid clients caching data, so don't validate them besides
            // checking they fit in an `int`.
            const intMaxSecs = int.max.seconds;
            const uintMaxSecs = uint.max.seconds;
            ensure(zone.refresh <= intMaxSecs,
                   "registry.{}.refresh ({}) should be at most {}",
                   name, zone.refresh, intMaxSecs);
            ensure(zone.retry <= intMaxSecs,
                   "registry.{}.retry ({}) should be at most {}",
                   name, zone.retry, intMaxSecs);
            ensure(zone.expire <= intMaxSecs,
                   "registry.{}.expire ({}) should be at most {}",
                   name, zone.expire, intMaxSecs);
            ensure(zone.minimum <= uintMaxSecs,
                   "registry.{}.minimum ({}) should be at most {}",
                   name, zone.minimum, uintMaxSecs);
        }

        validateZone("validators", this.validators);
        validateZone("flash", this.flash);
    }
}

/// Configuration for a DNS zone
/// All `Duration` values are precise to the second
public struct ZoneConfig
{
    /// Whether this registry is authoritative for the zone or not
    public bool authoritative;

    /// Email address of the person responsible for the zone
    public SetInfo!string email;

    /// How often secondary servers should refresh this zone
    /// Default to 9 minutes, slightly lower than the block interval
    public Duration refresh = 9.minutes;

    /// How much time should elapse before a request should be retried
    public Duration retry = 10.seconds;

    /***************************************************************************

        How much time should elapse before the zone is no longer authoritative

        This value should be higher than `refresh` so that a client attempt to
        refresh its zone data before completely discarding it.

        Default to 10 blocks, or 100 minutes.

    ***************************************************************************/

    public Duration expire = 100.minutes;

    /***************************************************************************

        The minimum value to TTL for any record in the zone

        The TTL define the amount of time (expressed in second in the record)
        that a record is valid for. With a minimum of 2 minutes, the clients
        will cache DNS queries for at least 2 minutes before querying us again.

        This value needs to be lower than the block interval.

    ***************************************************************************/

    public Duration minimum = 2.minutes;
}

//
unittest
{
    assertThrown!Exception(parseConfigString!Config("", "/dev/null"));

    // Missing 'network' section for a non validator node
    {
        immutable conf_str = `
validator:
  enabled: false
`;
        assertThrown!Exception(parseConfigString!Config(conf_str, "/dev/null"));
    }

    // Missing 'network' section for a validator node with name registry
    {
        immutable conf_str = `
validator:
  enabled: true
  registry_address: http://127.0.0.1:3003
  seed:    SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI
  recurring_enrollment: true
  preimage_reveal_interval:
    seconds: 10
`;
        parseConfigString!Config(conf_str, "/dev/null");
    }

        // Missing 'network' section for a validator node without name registry
    {
        immutable conf_str = `
validator:
  enabled: true
  registry_address: disabled
  seed:    SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI
  recurring_enrollment: true
  preimage_reveal_interval:
    seconds: 10
`;
        assertThrown!Exception(parseConfigString!Config(conf_str, "/dev/null"));
    }

    {
        immutable conf_str = `
network:
  - http://192.168.0.42:2826
`;
        auto conf = parseConfigString!Config(conf_str, "/dev/null");
        assert(conf.network == [ `http://192.168.0.42:2826` ]);
    }
}

///
unittest
{
    immutable conf_example = `
node:
  data_dir: .cache
  commons_budget_address: boa1xrzwvvw6l6d9k84ansqgs9yrtsetpv44wfn8zm9a7lehuej3ssskxth867s
network:
 - "something"
`;
    auto config = parseConfigString!Config(conf_example, "/dev/null");
    assert(config.node.min_listeners == 2);
    assert(config.node.max_listeners == 10);
    assert(config.node.data_dir == ".cache");
    assert(config.node.commons_budget_address.toString() == "boa1xrzwvvw6l6d9k84ansqgs9yrtsetpv44wfn8zm9a7lehuej3ssskxth867s");
}

///
unittest
{
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
network:
 - "something"
`;

    auto config = parseConfigString!Config(conf_example, "/dev/null");
    assert(config.consensus.validator_cycle == 42);
    assert(config.consensus.max_quorum_nodes == 420);
    assert(config.consensus.quorum_threshold == 96);
    assert(config.consensus.quorum_shuffle_interval == 210);
    assert(config.consensus.tx_payload_max_size == 2048);
    assert(config.consensus.tx_payload_fee_factor == 2100);
    assert(config.consensus.validator_tx_fee_cut == 69);
    assert(config.consensus.payout_period == 9999);
    assert(config.consensus.genesis_timestamp == 424242);
}

unittest
{
    {
        immutable conf_example = `
validator:
  enabled: true
  seed: SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI
  registry_address: http://127.0.0.1:3003
  recurring_enrollment : false
  preimage_reveal_interval:
    seconds: 99
network:
 - "something"
`;
        auto config = parseConfigString!Config(conf_example, "/dev/null");
        assert(config.validator.enabled);
        assert(config.validator.preimage_reveal_interval == 99.seconds);
        assert(config.validator.key_pair == KeyPair.fromSeed(
            SecretKey.fromString("SDV3GLVZ6W7R7UFB2EMMY4BBFJWNCQB5FTCXUMD5ZCFTDEVZZ3RQ2BZI")));
        assert(!config.validator.recurring_enrollment);
    }
    {
    immutable conf_example = `
validator:
  enabled: true
network:
 - "something"
`;
    assertThrown!Exception(parseConfigString!Config(conf_example, "/dev/null"));
    }
}

///
unittest
{
    {
        immutable conf_example = `
logging:
  root:
    level: Trace
  agora.network:
    level: Error
network:
 - "something"
`;
        auto config = parseConfigString!Config(conf_example, "/dev/null");
        assert(config.logging[0].name == "root");
        assert(config.logging[0].level == LogLevel.Trace);
        assert(config.logging[1].name == "agora.network");
        assert(config.logging[1].level == LogLevel.Error);
    }

    {
        immutable conf_example = `
network:
 - "something"
`;
        auto config = parseConfigString!Config(conf_example, "/dev/null");
        assert(config.logging.length == 1);
        assert(config.logging[0].name.length == 0);
        assert(config.logging[0].level == LogLevel.Info);
        assert(config.logging[0].console == true);
    }
}

///
unittest
{
    import std.algorithm : count, filter;

    // If the node does not exist
    {
        immutable conf_example = `
network:
  - "something"
`;
        auto config = parseConfigString!Config(conf_example, "/dev/null");
        assert(config.event_handlers.length == 0);
    }

    // If the nodes and values exist
    {
        immutable conf_example = `
network:
  - "something"
event_handlers:
  BlockExternalized:
    addresses:
      - http://127.0.0.1:3836
  BlockHeaderUpdated:
    addresses:
      - http://127.0.0.2:3836
  PreimageReceived:
    addresses:
      - http://127.0.0.3:3836
  TransactionReceived:
    addresses:
      - http://127.0.0.4:3836
`;

        auto config = parseConfigString!Config(conf_example, "/dev/null");
        with (HandlerType)
        {
            assert(config.event_handlers.filter!(h => h.type == BlockExternalized).front.addresses == [ `http://127.0.0.1:3836` ]);
            assert(config.event_handlers.filter!(h => h.type == BlockHeaderUpdated).front.addresses == [ `http://127.0.0.2:3836` ]);
            assert(config.event_handlers.filter!(h => h.type == PreimageReceived).front.addresses == [ `http://127.0.0.3:3836` ]);
            assert(config.event_handlers.filter!(h => h.type == TransactionReceived).front.addresses == [ `http://127.0.0.4:3836` ]);
        }
    }

    // If the nodes and some values exist
    {
        immutable conf_example = `
network:
  - "something"
event_handlers:
  BlockExternalized:
    addresses:
      - http://127.0.0.1:3836
  TransactionReceived:
    addresses:
      - http://127.0.0.4:3836
      - http://127.0.0.5:3836
`;

        auto config = parseConfigString!Config(conf_example, "/dev/null");
        with (HandlerType)
        {
            assert(config.event_handlers.filter!(h => h.type == BlockExternalized)
                .front.addresses == [ `http://127.0.0.1:3836` ]);
            assert(config.event_handlers.filter!(h => h.type == TransactionReceived)
                .front.addresses == [ `http://127.0.0.4:3836`, `http://127.0.0.5:3836` ]);
            assert(config.event_handlers.length == 2);
            assert(config.event_handlers.count!(h => h.type == PreimageReceived) == 0);
            assert(config.event_handlers.count!(h => h.type == BlockHeaderUpdated) == 0);
        }
    }
}
