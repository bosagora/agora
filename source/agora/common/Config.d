/*******************************************************************************

    Utilities to fill a struct representing the configuration with the content
    of a YAML document.

    The main function of this module is `parseConfig`. Convenience functions
    `parseConfigString` and `parseConfigFile` are also available.

    The type parameter to those three functions must be a struct and is used
    to drive the processing of the YAML node. When an error is encountered,
    an `Exception` will be thrown, with a descriptive message.
    The rules by which the struct is filled are designed to be
    as intuitive as possible, and are described below.

    Optional_Fields:
      One of the major convenience offered by this utility is its handling
      of optional fields. A field is detected as optional if it has
      an initializer that is different from its type `init` value,
      for example `string field = "Something";` is an optional field,
      but `int count = 0;` is not.
      To mark a field as optional even with its default value,
      use the `Optional` UDA: `@Optional int count = 0;`.

    Converter:
      Because config structs may contain complex types such as
      a Phobos type, a user-defined `Amount`, or Vibe.d's `URL`,
      one may need to apply a converter to a struct's field.
      Converters are simply functions that take a `string` as argument
      and return a type that is implicitly convertible to the field type
      (usually just the field type).

    Composite_Types:
      Processing starts from a `struct` at the top level, and recurse into
      every fields individually. If a field is itself a struct,
      the filler will attempt the following, in order:
      - If the field has no value and is not optional, an Exception will
        be thrown with an error message detailing where the issue happened.
      - If the field has no value and is optional, the default value will
        be used.
      - If the field has a value, the filler will first check for a converter
        and use it if present.
      - If the type has a `static` method named `fromString` whose sole argument
        is a `string`, it will be used.
      - If the type has a constructor whose sole argument is a `string`,
        it will be used;
      - Finally, the filler will attempt to deserialize all struct members
        one by one and pass them to the default constructor, if there is any.
      - If none of the above succeeded, a `static assert` will trigger.

    Duration_parsing:
      If the config field is of type `core.time.Duration`, special parsing rules
      will apply. There are two possible forms in which a Duration field may
      be expressed. In the first form, the YAML node should be a mapping,
      and it will be checked for fields matching the supported units
      in `core.time`: `weeks`, `days`, `hours`, `minutes`, `seconds`, `msecs`,
      `usecs`, `hnsecs`, `nsecs`. Strict parsing option will be respected.
      The values of the fields will then be added together, so the following
      YAML usages are equivalent:
      ```
      sleepFor:
          hours: 8
          minutes: 30
      ```
      and:
      ```
      sleepFor:
          minutes: 510
      ```
      Provided that the definition of the field is:
      ```
      public Duration sleepFor;
      ```

      In the second form, the field should have a suffix composed of an
      underscore ('_'), followed by a unit name as defined in `core.time`.
      This can be either the field name directly, or a name override.
      The latter is recommended to avoid confusion when using the field in code.
      In this form, the YAML node is expected to be a scalar.
      So the previous example, using this form, would be expressed as:
      ```
      sleepFor_minutes: 510
      ```
      and the field definition should be one of those two:
      ```
      public @Name("sleepFor_minutes") Duration sleepFor; /// Prefer this
      public Duration sleepFor_minutes; /// This works too
      ```

      Those forms are mutually exclusive, so a field with a unit suffix
      will error out if a mapping is used. This prevents surprises and ensures
      that the error message, if any, is consistent accross user input.

      To disable or change this behavior, one may use a `Converter` instead.

    Strict_Parsing:
      When strict parsing is enabled, the config filler will also validate
      that the YAML nodes do not contains entry which are not present in the
      mapping (struct) being processed.
      This can be useful to catch typos or outdated configuration options.

    Post_Validation:
      Some configuration will require validation accross multiple sections.
      For example, two sections may be mutually exclusive as a whole,
      or may have fields which are mutually exclusive with another section's
      field(s). This kind of dependence is hard to account for declaratively,
      and does not affect parsing. For this reason, the preferred way to
      handle those cases is to define a `validate` member method on the
      top level config struct, which will be called once parsing is completed.
      If an error is detected, this method should throw an Exception.

    Enabled_or_disabled_field:
      While most complex logic validation should be handled post-parsing,
      some section may be optional by default, but if provided, will have
      required fields. To support this use case, if a field with the name
      `enabled` is present in a struct, the parser will first process it.
      If it is `false`, the parser will not attempt to process the struct
      further, and the other fields will have their default value.
      Likewise, if a field named `disabled` exists, the struct will not
      be processed if it is set to `true`.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Config;

public import agora.common.ConfigAttributes;

import dyaml.exception;
import dyaml.node;
import dyaml.loader;

import std.algorithm;
import std.conv;
import std.datetime;
import std.format;
import std.getopt;
import std.range;
import std.traits;

static import core.time;

/// Command-line arguments
public struct CLIArgs
{
    /// Path to the config file
    public string config_path = "config.yaml";

    /// Overrides for config options
    public string[][string] overrides;

    /// Helper to add items to `overrides`
    public void overridesHandler (string, string value)
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

    /***************************************************************************

        Parses the base command line arguments

        This can be composed with the program argument.
        For example, consider a program which wants to expose a `--version`
        switch, the definition could look like this:
        ```
        public struct ProgramCLIArgs
        {
            public CLIArgs base; // This struct

            public alias base this; // For convenience

            public bool version_; // Program-specific part
        }
        ```
        Then, an application-specific configuration routine would be:
        ```
        public GetoptResult parse (ref ProgramCLIArgs clargs, ref string[] args)
        {
            auto r = clargs.base.parse(args);
            if (r.helpWanted) return r;
            return getopt(
                args,
                "version", "Print the application version, &clargs.version_);
        }
        ```

        Params:
          args = The command line args to parse (parsed options will be removed)
          passThrough = Whether to enable `config.passThrough` and
                        `config.keepEndOfOptions`. `true` by default, to allow
                        composability. If your program doesn't have other
                        arguments, pass `false`.

        Returns:
          The result of calling `getopt`

    ***************************************************************************/

    public GetoptResult parse (ref string[] args, bool passThrough = true)
    {
        return getopt(
            args,
            // `caseInsensistive` is the default, but we need something
            // with the same type for the ternary
            passThrough ? config.keepEndOfOptions : config.caseInsensitive,
            // Also the default, same reasoning
            passThrough ? config.passThrough : config.noPassThrough,
            "config|c",
                "Path to the config file. Defaults to: " ~ this.config_path,
                &this.config_path,

            "override|O",
                "Override a config file value\n" ~
                "Example: -O foo.bar=true -o dns=1.1.1.1 -o dns=2.2.2.2\n" ~
                "Array values are additive, other items are set to the last override",
                &this.overridesHandler,
        );
    }
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

public T parseConfigFile (T) (in CLIArgs cmdln)
{
    Node root = Loader.fromFile(cmdln.config_path).load();
    return parseConfig!T(cmdln, root);
}

/// ditto
public T parseConfigString (T) (string data, string path)
{
    CLIArgs cmdln = { config_path: path };
    Node root = Loader.fromString(data).load();
    return parseConfig!T(cmdln, root);
}

/*******************************************************************************

    Process the content of the YAML document described by `node` into an
    instance of the struct `T`.

    See the module description for a complete overview of this function.

    Params:
      T = Type of the config struct to fill
      cmdln = Command line arguments
      node = The root node matching `T`
      strict = Whether to perform strict parsing
      initPath = Unused

    Returns:
      An instance of `T` filled with the content of `node`

    Throws:
      If the content of `node` cannot satisfy the requirements set by `T`,
      or if `node` contain extra fields and `strict` is `true`.

*******************************************************************************/

public T parseConfig (T) (
    in CLIArgs cmdln, Node node, bool strict = true, string initPath = null)
{
    static assert(is(T == struct), "`" ~ __FUNCTION__ ~
                  " should only be called with a `struct` type as argument, not: `" ~
                  fullyQualifiedName!T ~ "`");

    final switch (node.nodeID)
    {
    case NodeID.mapping:
            dbgWrite("Parsing config '%s', strict: %s, initPath: %s",
                     fullyQualifiedName!T, strict.paintBool(true),
                     initPath.length ? initPath : "(none)");
        auto result = node.parseMapping!T(initPath, T.init, const(Context)(cmdln, strict), null);
        static if (is(typeof(result.validate())))
        {
            dbgWrite("%s: Calling `%s` method",
                     T.stringof.paint(Cyan), "validate()".paint(Green));
            result.validate();
        }
        else
            dbgWrite("%s: No `%s` method found",
                     T.stringof.paint(Cyan), "validate()".paint(Yellow));
        return result;
    case NodeID.sequence:
        throw new Exception("Expected to get a mapping (object) at the top level, but got a sequence (array)");
    case NodeID.scalar:
        throw new Exception("Expected to get a mapping (object) at top level, but got a scalar (value)");
    case NodeID.invalid:
        throw new Exception(format("Node type is invalid: %s", node));
    }
}

/// Used to pass around configuration
private struct Context
{
    ///
    private CLIArgs cmdln;

    ///
    private bool strict;
}

/// Helper template for `staticMap` used for strict mode
private template FieldToName (A)
{
    alias Pred (string FieldName) = FieldRef!(A, FieldName).Name;
}

/// Parse a single mapping, recurse as needed
private T parseMapping (T)
    (Node node, string path, auto ref T defaultValue, in Context ctx, in Node[string] fieldDefaults)
{
    static assert(is(T == struct), "`parseMapping` called with wrong type (should be a `struct`)");
    assert(node.nodeID == NodeID.mapping, "Internal error: parseMapping shouldn't have been called");

    dbgWrite("%s: `parseMapping` called for '%s' (node entries: %s)",
             T.stringof.paint(Cyan), path.paint(Cyan),
             node.length.paintIf(!!node.length, Green, Red));

    if (ctx.strict)
    {
        /// First, check that all the sections found in the mapping are present in the type
        /// If not, the user might have made a typo.
        immutable string[] fieldNames = [ staticMap!(FieldToName!(T).Pred, FieldNameTuple!T) ];
        // The second message has '%s' which will not format to anything,
        // because `path` is empty. This allow us to call `ensure` with the same params.
        const fmt = path.length ? "Unexpected key '%s' in section '%s'. There are %s valid keys: %-(%s, %)" :
            "Unexpected key '%s' in document root%s. There are %s valid keys: %-(%s, %)";
        foreach (const ref Node key, const ref Node value; node)
            node.enforce(fieldNames.canFind(key.as!string),
                         fmt, key.as!string.paint(Red), path.paint(Green),
                         fieldNames.length.paint(Yellow), fieldNames.map!(f => f.paint(Green)));
    }

    const enabledState = node.isMappingEnabled!T(defaultValue);

    if (enabledState.field != EnabledState.Field.None)
        dbgWrite("%s: Mapping is enabled: %s", T.stringof.paint(Cyan), (!!enabledState).paintBool());

    auto convert (string FName) ()
    {
        alias FR = FieldRef!(T, FName);
        static if (FR.Name != FR.FieldName)
            dbgWrite("Field name `%s` will use YAML field `%s`",
                     FR.FieldName.paint(Yellow), FR.Name.paint(Green));
        // Using exact type here matters: we could get a qualified type
        // (e.g. `immutable(string)`) if the field is qualified,
        // which causes problems.
        FR.Type default_ = __traits(getMember, defaultValue, FR.FieldName);

        // If this struct is disabled, do not attempt to parse anything besides
        // the `enabled` / `disabled` field.
        if (!enabledState)
        {
            // Even this is too noisy
            version (none)
                dbgWrite("%s: %s field of disabled struct, default: %s",
                         path.paint(Cyan), "Ignoring".paint(Yellow), default_);

            static if (FName == "enabled")
                return false;
            else static if (FName == "disabled")
                return true;
            else
                return default_;
        }

        if (auto ptr = FName in fieldDefaults)
        {
            dbgWrite("Found %s (%s.%s) in `fieldDefaults",
                     FR.Name.paint(Cyan), path.paint(Cyan), FName.paint(Cyan));

            node.enforce(!ctx.strict || FName !in node, "'Key' field '%s' is specified twice", path.paint(Yellow));
            return (*ptr).parseField!(FR)(path.addPath(FName), default_, ctx)
                .dbgWriteRet("Using value '%s' from fieldDefaults for field '%s'",
                             FName.paint(Cyan));
        }

        if (auto ptr = FR.Name in node)
        {
            dbgWrite("%s: YAML field is %s in node%s",
                     FR.Name.paint(Cyan), "present".paint(Green),
                     (FR.Name == FR.FieldName ? "" : " (note that field name is overriden)").paint(Yellow));
            return (*ptr).parseField!(FR)(path.addPath(FR.Name), default_, ctx)
                .dbgWriteRet("Using value '%s' from YAML document for field '%s'",
                             FR.FieldName.paint(Cyan));
        }

        dbgWrite("%s: Field is %s from node%s",
                 FR.Name.paint(Cyan), "missing".paint(Red),
                 (FR.Name == FR.FieldName ? "" : " (note that field name is overriden)").paint(Yellow));

        // A field is considered optional if it has an initializer that is different
        // from its default value, or if it has the `Optional` UDA.
        // In that case, just return this value.
        static if (isOptional!FR)
            return FR.Default
                .dbgWriteRet("Using default value '%s' for optional field '%s'", FName.paint(Cyan));

        // The field is not present, but it could be because it is an optional section.
        // For example, the section could be defined as:
        // ```
        // struct RequestLimit { size_t reqs = 100; }
        // struct Config { RequestLimit limits; }
        // ```
        // In this case we need to recurse into `RequestLimit` to check if any
        // of its field is required.
        else static if (mightBeOptional!FR)
        {
            const npath = path.addPath(FName);
            string[string] aa;
            return Node(aa).parseMapping!(FR.Type)(npath, FR.Default, ctx, null);
        }
        else
        {
            const fmt = path.length ?
                "'%s' was not found in '%s', nor was it provided in command line arguments" :
                // The extra `%s` is used to allow passing the same arguments to `enforce`
                "'%s' was not found in document%s, nor was it provided in command line arguments";
            node.enforce(false, fmt, FR.Name, path);
            assert(0);
        }
    }

    debug (ConfigFillerDebug)
    {
        indent++;
        scope (exit) indent--;
    }
    // This might trigger things like "`this` is not accessible".
    // In this case, the user most likely needs to provide a converter.
    return T(staticMap!(convert, FieldNameTuple!T));
}

/*******************************************************************************

    Parse a field, trying to match up the compile-time expectation with
    the run time value of the Node (`nodeID`).

    Because a `struct` can be filled from either a mapping or a scalar,
    this function will first try the converter / fromString / string ctor
    methods before defaulting to fieldwise construction.

    Note that optional fields are checked before recursion happens,
    so this method does not do this check.

*******************************************************************************/

private FR.Type parseField (alias FR)
    (Node node, string path, auto ref FR.Type defaultValue, in Context ctx)
{
    if (node.nodeID == NodeID.invalid)
        throw new Exception(format("Node type is invalid: %s", node));

    // If we reached this, it means the field is set, so just recurse
    // to peel the type
    static if (is(FR.Type : SetInfo!FT, FT))
        return FR.Type(
            parseField!(FieldRef!(FR.Type, "value"))(node, path, defaultValue, ctx),
            true);

    else static if (hasConverter!(FR.Ref))
        return node.viaConverter!(FR);

    else static if (hasFromString!(FR.Type))
        return FR.Type.fromString(node.as!string);

    else static if (hasStringCtor!(FR.Type))
        return FR.Type(node.as!string);

    else static if (is(immutable(FR.Type) == immutable(core.time.Duration)))
        return parseDuration!(FR)(node, path, defaultValue, ctx);

    else static if (is(FR.Type == struct))
    {
        node.enforce(node.nodeID == NodeID.mapping,
               "Expected '%s' to be a mapping (object), not a %s",
               path, node.nodeTypeString());
        return node.parseMapping!(FR.Type)(path, defaultValue, ctx, null);
    }

    // Handle string early as they match the sequence rule too
    else static if (isSomeString!(FR.Type))
        // Use `string` type explicitly because `Variant` thinks
        // `immutable(char)[]` (aka `string`) and `immutable(char[])`
        // (aka `immutable(string)`) are not compatible.
        return node.parseScalar!(string)(path);
    // Enum too, as their base type might be an array (including strings)
    else static if (is(FR.Type == enum))
        return node.parseScalar!(FR.Type)(path);

    else static if (is(FR.Type : E[], E))
    {
        static if (hasUDA!(FR.Ref, Key))
        {
            node.enforce(node.nodeID == NodeID.mapping,
                   "Expected '%s' to be a mapping (object), not a %s",
                   path, node.nodeTypeString());

            static assert(getUDAs!(FR.Ref, Key).length == 1,
                          "`" ~ fullyQualifiedName!(FR.Ref) ~
                          "` field shouldn't have more than one `Key` attribute");
            static assert(is(E == struct),
                          "Field `" ~ fullyQualifiedName!(FR.Ref) ~
                          "` has a `Key` attribute, but is a sequence of `" ~
                          fullyQualifiedName!E ~ "`, not a sequence of `struct`");

            string key = getUDAs!(FR.Ref, Key)[0].name;
            return node.mapping().map!(
                (Node.Pair pair) {
                    node.enforce(pair.value.nodeID == NodeID.mapping,
                           "Field '%s' should be a sequence of mapping (array of objects), " ~
                           "but it is a sequence of %s",
                           path, pair.value.nodeTypeString());

                    return pair.value.parseMapping!E(
                        path.addPath(pair.key.as!string),
                        E.init, ctx, key.length ? [ key: pair.key ] : null);
                }).array();
        }
        else
        {
            node.enforce(node.nodeID == NodeID.sequence,
                   "Expected '%s' to be a sequence (array), not a %s",
                   path, node.nodeTypeString());
            return node.parseSequence!(FR.Type, E)(path, ctx);
        }
    }
    else
        return node.parseScalar!(FR.Type)(path);
}

/// Parse a node as a scalar
private T parseScalar (T) (Node node, string path)
{
    node.enforce(node.nodeID == NodeID.scalar,
           "Expected '%s' to be a scalar (value), not a %s",
           path, node.nodeTypeString());
    static if (is(T == enum))
        return node.as!string.to!(T);
    else
        return node.as!(T);
}

/*******************************************************************************

    Parse a `core.time : Duration` from the YAML

*******************************************************************************/

private core.time.Duration parseDuration (alias FR)
    (Node node, string path, in core.time.Duration defaultValue, in Context ctx)
{
    // Try second form first as it convey the developer's intent explicitly
    static foreach (Suffix; DurationSuffixes)
    {
        static if (FR.Name.endsWith(Suffix))
        {
            // Since we don't have flow control at CT, we have to rely on `is()`
            // check to see if variables have been defined... Ugly but it works.
            // We would get "Warning: Statement is not reachable" otherwise.
            enum hasMatch = true;

            node.enforce(node.nodeID == NodeID.scalar,
                   "Field '%s' expects an integer value (scalar), not a %s",
                   path, node.nodeTypeString());
            return core.time.dur!(Suffix[1 .. $])(node.as!long);
        }
    }
    // First form, sum all possible fields
    static if (!is(typeof(hasMatch)))
    {
        node.enforce(node.nodeID == NodeID.mapping,
               "Field '%s' is a %s, but expected a mapping with at least one of: %-(%s, %)",
               path.paint(Cyan), node.nodeTypeString(), DurationSuffixes.map!(s => s[1 .. $].paint(Green)));
        auto result = node.parseMapping!DurationPseudoMapping(
            path, DurationPseudoMapping.init, ctx, null);
        bool hasOneSet;
    FOREACH: foreach (field; result.tupleof)
            if ((hasOneSet = field.set) == true)
                break FOREACH;

        if (!hasOneSet)
        {
            static if (isOptional!FR)
                return defaultValue;
            else
                node.enforce(false, "Field  '%s' expected one of its values to be set", path);
        }

        return result.opCast!Duration();
    }
}

/// Supported suffix names
private immutable DurationSuffixes = [
    "_weeks", "_days", "_hours", "_minutes", "_seconds",
    "_msecs", "_usecs", "_hnsecs", "_nsecs",
];

/// Allows us to reuse parseMapping and strict parsing
private struct DurationPseudoMapping
{
    public SetInfo!long weeks;
    public SetInfo!long days;
    public SetInfo!long hours;
    public SetInfo!long minutes;
    public SetInfo!long seconds;
    public SetInfo!long msecs;
    public SetInfo!long usecs;
    public SetInfo!long hnsecs;
    public SetInfo!long nsecs;

    ///  Allow conversion to a `Duration`
    public Duration opCast (T : Duration) () const scope @safe pure nothrow @nogc
    {
        return core.time.weeks(this.weeks) + core.time.days(this.days) +
            core.time.hours(this.hours) + core.time.minutes(this.minutes) +
            core.time.seconds(this.seconds) + core.time.msecs(this.msecs) +
            core.time.usecs(this.usecs) + core.time.hnsecs(this.hnsecs) +
            core.time.nsecs(this.nsecs);
    }
}

private T parseSequence (T : E[], E) (Node node, string path, in Context ctx)
{
    assert(node.nodeID == NodeID.sequence, "Internal error: parseSequence shouldn't have been called");
    // TODO: Fix path
    static if (is(E == struct))
        return node.sequence.map!(n => n.parseMapping!E(path, E.init, ctx, null)).array();
    else static if (isSomeString!E) // Avoid Variant bug
        return node.sequence.map!(n => cast(E) n.parseScalar!string(path)).array();
    else
        return node.sequence.map!(n => n.parseScalar!E(path)).array();
}

private auto parseDefaultMapping (alias SFR) (
    string path, string firstMissing, in Context ctx)
{
    static assert(is(SFR.Type == struct), "Internal error: `parseDefaultMapping` called with non-struct");

    string[string] emptyMapping;
    const enabledState = Node(emptyMapping).isMappingEnabled!(SFR.Type)(SFR.Default);

    auto convert (string FName) ()
    {
        alias FR = FieldRef!(SFR.Type, FName);
        const npath = path.addPath(FName);

        // See `isMappingEnabled`
        if (!enabledState)
        {
            static if (FName == "enabled")
                return false;
            else static if (FName == "disabled")
                return true;
            else
                return FR.Default;
        }

        // If it has converters, we should not recurse into it
        static if (isOptional!FR)
            return FR.Default;
        else static if (mightBeOptional!FR)
            return parseDefaultMapping!FR(npath, firstMissing, ctx);
        else
        {
            node.enforce(false, "Field '%s' is not optional (first undefined: %s)",
                   npath, firstMissing);
            return FR.Default;
        }
    }

    static if (hasFieldwiseCtor!(SFR.Type))
        return SFR.Type(staticMap!(convert, FieldNameTuple!(SFR.Type)));
    else
    {
        node.enforce(false, "Field '%s' is not optional (first undefined: %s)",
               path, firstMissing);
        return SFR.Type.init; // Just so that the compiler doesn't get confused
    }
}

/// Convenience short-hand template to get a field identifier
private enum FId (alias Field) = __traits(identifier, Field);

/// Evaluates to `true` if this field is to be considered optional
/// (does not need to be present in the YAML document)
private enum isOptional (alias FR) = hasUDA!(FR.Ref, Optional) ||
    is(immutable(FR.Type) == immutable(bool)) ||
    is(FR.Type : SetInfo!FT, FT) ||
    (FR.Default != FR.Type.init);

/// Evaluates to `true` if we should recurse into the struct via `parseDefaultMapping`
private enum mightBeOptional (alias FR) = is(FR.Type == struct) &&
    !hasConverter!(FR.Ref) && !hasFromString!(FR.Type) && !hasStringCtor!(FR.Type);

/// Convenience template to check for the presence of converter(s)
private enum hasConverter (alias Field) = hasUDA!(Field, Converter);

/// Provided a field reference `FR` which is known to have at least one converter,
/// perform basic checks and return the value after applying the converter.
private auto viaConverter (alias FR) (Node node)
{
    enum Converters = getUDAs!(FR.Ref, Converter);
    static assert (Converters.length,
                   "Internal error: `viaConverter` called on field `" ~
                   FId!(FR.Ref) ~ "` with no converter");

    static assert(Converters.length == 1,
                  "Field `" ~ FId!(FR.Ref) ~ "` cannot have more than one `Converter`");
    return Converters[0].converter(node);
}

/*******************************************************************************

    A reference to a field in a `struct`

    The compiler sometimes rejects passing fields by `alias`, or complains about
    missing `this` (meaning it tries to evaluate the value). Sometimes, it also
    discards the UDAs.

    To prevent this from happening, we always pass around a `FieldRef`,
    which wraps the parent struct type (`T`) and the name of the field (`name`).

    To avoid any issue, eponymous usage is also avoided, hence the reference
    needs to be accessed using `Ref`. A convenience `Type` alias is provided,
    as well as `Default`.

*******************************************************************************/

private template FieldRef (alias T, string name)
{
    // Import needed as `Name` is defined in this template but we also need
    // to use that identifier in `getUDAs`.
    import agora.common.ConfigAttributes : CAName = Name;

    /// The reference to the field
    public alias Ref = __traits(getMember, T, name);

    /// Type of the field
    public alias Type = typeof(Ref);

    /// The name of the field in the struct itself
    public alias FieldName = name;

    /// The name used in the configuration field (taking `@Name` into account)
    static if (hasUDA!(Ref, CAName))
    {
        static assert (getUDAs!(Ref, CAName).length == 1,
                       "Field `" ~ fullyQualifiedName!(Ref) ~
                       "` cannot have more than one `Name` attribute");

        public immutable Name = getUDAs!(Ref, CAName)[0].name;
    }
    else
        public immutable Name = FieldName;

    /// Default value of the field (may or may not be `Type.init`)
    public enum Default = __traits(getMember, T.init, name);
}

/// Returns whether or not the field has a `enabled` / `disabled` field,
/// and its value. If it does not, returns `true`.
private EnabledState isMappingEnabled (M) (Node node, auto ref M default_)
{
    static if ([FieldNameTuple!M].canFind("enabled"))
    {
        if (auto ptr = "enabled" in node)
            return EnabledState(EnabledState.Field.Enabled, (*ptr).as!bool);
        return EnabledState(EnabledState.Field.Enabled, __traits(getMember, default_, "enabled"));
    }
    else static if ([FieldNameTuple!M].canFind("disabled"))
    {
        if (auto ptr = "disabled" in node)
            return EnabledState(EnabledState.Field.Disabled, (*ptr).as!bool);
        return EnabledState(EnabledState.Field.Disabled, __traits(getMember, default_, "disabled"));
    }
    else
        return EnabledState(EnabledState.Field.None);
}

/// Retun value of `isMappingEnabled`
private struct EnabledState
{
    /// Used to determine which field controls a mapping enabled state
    private enum Field
    {
        /// No such field, the mapping is considered enabled
        None,
        /// The field is named 'enabled'
        Enabled,
        /// The field is named 'disabled'
        Disabled,
    }

    /// Check if the mapping is considered enabled
    public bool opCast () const scope @safe pure @nogc nothrow
    {
        return this.field == Field.None ||
            (this.field == Field.Enabled && this.fieldValue) ||
            (this.field == Field.Disabled && !this.fieldValue);
    }

    /// Type of field found
    private Field field;

    /// Value of the field, interpretation depends on `field`
    private bool fieldValue;
}

unittest
{
    static struct Config1
    {
        int integer2 = 42;
        @(42) string str2;
    }

    static struct Config2
    {
        Config1 c1dup = { 42, "Hello World" };
        string message = "Something";
    }

    static struct Config3
    {
        Config1 c1;
        int integer;
        string str;
        Config2 c2 = { c1dup: { integer2: 69 } };
    }

    static assert(is(FieldRef!(Config3, "c2").Type == Config2));
    static assert(FieldRef!(Config3, "c2").Default != Config2.init);
    static assert(FieldRef!(Config2, "message").Default == Config2.init.message);
    alias NFR1 = FieldRef!(Config3, "c2");
    alias NFR2 = FieldRef!(NFR1.Ref, "c1dup");
    alias NFR3 = FieldRef!(NFR2.Ref, "integer2");
    alias NFR4 = FieldRef!(NFR2.Ref, "str2");
    static assert(hasUDA!(NFR4.Ref, int));
}

/// Evaluates to `true` if `T` is a `struct` with a default ctor
private enum hasFieldwiseCtor (T) = (is(T == struct) && is(typeof(() => T(T.init.tupleof))));

/// Evaluates to `true` if `T` has a static method that accepts a `string` and returns a `T`
private enum hasFromString (T) = is(typeof(T.fromString(string.init)) : T);

/// Evaluates to `true` if `T` is a `struct` which accepts a single string as argument
private enum hasStringCtor (T) = (is(T == struct) && is(typeof(T.__ctor)) &&
                                  Parameters!(T.__ctor).length == 1 &&
                                  is(typeof(() => T(string.init))));

unittest
{
    static struct Simple
    {
        int value;
        string otherValue;
    }

    static assert( hasFieldwiseCtor!Simple);
    static assert(!hasStringCtor!Simple);

    static struct PubKey
    {
        ubyte[] data;

        this (string hex) @safe pure nothrow @nogc{}
    }

    static assert(!hasFieldwiseCtor!PubKey);
    static assert( hasStringCtor!PubKey);

    static assert(!hasFieldwiseCtor!string);
    static assert(!hasFieldwiseCtor!int);
    static assert(!hasStringCtor!string);
    static assert(!hasStringCtor!int);
}

/// Convenience function to extend a YAML path
private string addPath (string opath, string newPart)
{
    return opath.length ? format("%s.%s", opath, newPart) : newPart;
}

/// Helper mixin for exception types
private mixin template ExceptionCtor ()
{
    public this (string msg, Mark position,
                 string file = __FILE__, size_t line = __LINE__)
        @safe pure nothrow @nogc
    {
        super(msg, position, file, line);
    }
}

/// Exception type thrown by the config parser
public class ConfigException : Exception
{
    /// Position at which the error happened
    public Mark yamlPosition;

    /// Constructor
    public this (string msg, Mark position,
                 string file = __FILE__, size_t line = __LINE__)
        @safe pure nothrow @nogc
    {
        super(msg, file, line);
        this.yamlPosition = position;
    }

    /***************************************************************************

        Overrides `Throwable.toString` sink overload

        It is quite likely that errors from this module may be printed directly
        to the end user, who might not have technical knowledge.

        This format the error in a nicer format (with colors if possible),
        and will additionally provide a stack-trace if the `ConfigFillerDebug`
        `debug` version was provided.

        Params:
          sink = The sink to send the piece-meal string to

    ***************************************************************************/

    public override void toString (scope void delegate(in char[]) sink) const scope
    {
        import core.internal.string : unsignedToTempString;

        char[20] buffer = void;

        sink(Yellow);
        sink(this.yamlPosition.name);
        sink(Reset);

        sink("(");
        sink(Cyan);
        sink(unsignedToTempString(this.yamlPosition.line, buffer));
        sink(Reset);
        sink(":");
        sink(Cyan);
        sink(unsignedToTempString(this.yamlPosition.column, buffer));
        sink(Reset);
        sink("): ");

        sink(this.msg);

        debug (ConfigFillerDebug)
        {
            sink("\n\tError originated from: ");
            sink(this.file);
            sink("(");
            sink(unsignedToTempString(line, buffer));
            sink(")");

            if (!this.info)
                return;

            try
            {
                sink("\n----------------");
                foreach (t; info)
                {
                    sink("\n"); sink(t);
                }
            }
            // ignore more errors
            catch (Throwable) {}
        }
    }
}

/// A convenience wrapper around `enforce` to throw a formatted exception
private void enforce (E = ConfigException, Args...) (Node node, bool cond,
                                string fmt, lazy Args args,
                                string file = __FILE__, size_t line = __LINE__)
{
    if (!cond)
        throw new E(format(fmt, args), node.startMark(), file, line);
}

/*******************************************************************************

    Debugging utility for config filler

    Since this module does a lot of meta-programming, some things can easily
    go wrong. For example, a condition being false might happen because it is
    genuinely false or because the condition is buggy.

    To make figuring out if a config is properly parsed or not, a little utility
    (config-dumper) exists, which will provide a verbose output of what the
    config filler does. To do this, `config-dumper` is compiled with
    the below `debug` version.

*******************************************************************************/

debug (ConfigFillerDebug)
{
    /// A thin wrapper around `stderr.writefln` with indentation
    private void dbgWrite (Args...) (string fmt, Args args)
    {
        import std.stdio;
        stderr.write(IndentChars[0 .. indent >= IndentChars.length ? $ : indent]);
        stderr.writefln(fmt, args);
    }

    /// Log a value that is to be returned
    /// The value will be the first argument and painted yellow
    private T dbgWriteRet (T, Args...) (auto ref T return_, string fmt, Args args)
    {
        dbgWrite(fmt, return_.paint(Yellow), args);
        return return_;
    }

    /// The current indentation
    private size_t indent;

    /// Helper for indentation (who needs more than 16 levels of indent?)
    private immutable IndentChars = "\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t";
}
else
{
    /// No-op
    private void dbgWrite (Args...) (string fmt, lazy Args args) {}

    /// Ditto
    private T dbgWriteRet (T, Args...) (auto ref T return_, string fmt, lazy Args args)
    {
        return return_;
    }
}

/// Thin wrapper to simplify colorization
private struct Colored (T)
{
    /// Color used
    private string color;

    /// Value to print
    private T value;

    /// Hook for `formattedWrite`
    public void toString (scope void delegate (scope const char[]) @safe sink)
    {
        formattedWrite(sink, "%s%s%s", this.color, this.value, Reset);
    }
}

/// Ditto
private Colored!T paint (T) (T arg, string color)
{
    return Colored!T(color, arg);
}

/// Paint `arg` in color `ifTrue` if `cond` evaluates to `true`, use color `ifFalse` otherwise
private Colored!T paintIf (T) (T arg, bool cond, string ifTrue, string ifFalse)
{
    return Colored!T(cond ? ifTrue : ifFalse, arg);
}

/// Paint a boolean in green if `true`, red otherwise, unless `reverse` is set to `true`,
/// in which case the colors are swapped
private Colored!bool paintBool (bool value, bool reverse = false)
{
    return value.paintIf(reverse ^ value, Green, Red);
}

/// Reset the foreground color used
private immutable Reset = "\u001b[0m";
/// Set the foreground color to red, used for `false`, missing, errors, etc...
private immutable Red = "\u001b[31m";
/// Set the foreground color to red, used for warnings and other things
/// that should draw attention but do not pose an immediate issue
private immutable Yellow = "\u001b[33m";
/// Set the foreground color to green, used for `true`, present, etc...
private immutable Green = "\u001b[32m";
/// Set the foreground color to green, used field names / path
private immutable Cyan = "\u001b[36m";

/// Basic usage tests
unittest
{
    static struct Address
    {
        string address;
        string city;
        bool accessible;
    }

    static struct Nested
    {
        Address address;
    }

    static struct Config
    {
        bool enabled = true;

        string name = "Jessie";
        int age = 42;
        double ratio = 24.42;

        Address address = { address: "Yeoksam-dong", city: "Seoul", accessible: true };

        Nested nested = { address: { address: "Gangnam-gu", city: "Also Seoul", accessible: false } };
    }

    auto c1 = parseConfigString!Config("enabled: false", "/dev/null");
    assert(c1.name == "Jessie");
    assert(c1.age == 42);
    assert(c1.ratio == 24.42);

    assert(c1.address.address == "Yeoksam-dong");
    assert(c1.address.city == "Seoul");
    assert(c1.address.accessible);

    assert(c1.nested.address.address == "Gangnam-gu");
    assert(c1.nested.address.city == "Also Seoul");
    assert(!c1.nested.address.accessible);
}

// Tests for SetInfo
unittest
{
    static struct Address
    {
        string address;
        string city;
        bool accessible;
    }

    static struct Config
    {
        SetInfo!int value;
        SetInfo!int answer = 42;
        SetInfo!string name = "Lorene";

        SetInfo!Address address;
    }

    auto c1 = parseConfigString!Config("value: 24", "/dev/null");
    assert(c1.value == 24);
    assert(c1.value.set);

    assert(!c1.answer.set);
    assert(c1.answer == 42);

    assert(!c1.name.set);
    assert(c1.name == "Lorene");

    assert(!c1.address.set);

    auto c2 = parseConfigString!Config(`
name: Lorene
address:
  address: Somewhere
  city:    Over the rainbow
`, "/dev/null");

    assert(!c2.value.set);
    assert(c2.name == "Lorene");
    assert(c2.name.set);
    assert(c2.address.set);
    assert(c2.address.address == "Somewhere");
    assert(c2.address.city == "Over the rainbow");
}
