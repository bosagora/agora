/*******************************************************************************

    Define UDAs that can be applied to a configuration struct

    This module is stand alone (a leaf module) to allow importing the UDAs
    without importing the whole configuration parsing code.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.ConfigAttributes;

import core.time;
import std.conv : to;
import std.traits;

/*******************************************************************************

    An optional parameter with an initial value of `T.init`

    The config parser automatically recognize non-default initializer,
    so that the following:
    ```
    public struct Config
    {
        public string greeting = "Welcome home";
    }
    ```
    Will not error out if `greeting` is not defined in the config file.
    However, this relies on the initializer of the field (`greeting`) being
    different from the type initializer (`string.init` is `null`).
    In some cases, the default value is also the desired initializer, e.g.:
    ```
    public struct Config
    {
        /// Maximum number of connections. 0 means unlimited.
        public uint connections_limit = 0;
    }
    ```
    In this case, one can add `@Optional` to the field to inform the parser.

*******************************************************************************/

public struct Optional {}

/*******************************************************************************

    Inform the config filler that this sequence is to be read as a mapping

    On some occasions, one might want to read a mapping as an array.
    One reason to do so may be to provide a better experience to the user,
    e.g. having to type:
    ```
    interfaces:
      eth0:
        ip: "192.168.0.1"
        private: true
      wlan0:
        ip: "1.2.3.4"
    ```
    Instead of the slightly more verbose:
    ```
    interfaces:
      - name: eth0
        ip: "192.168.0.1"
        private: true
      - name: wlan0
        ip: "1.2.3.4"
    ```

    The former would require to be expressed as an associative arrays.
    However, one major drawback of associative arrays is that they can't have
    an initializer, which makes them cumbersome to use in the context of the
    config filler. To remediate this issue, one may use `@Key("name")`
    on a field (here, `interfaces`) so that the mapping is flattened
    to an array. If `name` is `null`, the key will be discarded.

*******************************************************************************/

public struct Key
{
    ///
    public string name;
}

/*******************************************************************************

    Look up the provided name in the YAML node, instead of the field name.

    By default, the config filler will look up the field name of a mapping in
    the YAML node. If this is not desired, an explicit `Name` attribute can
    be given. This is especially useful for names which are keyword.

    ```
    public struct Config
    {
        public @Name("delete") bool remove;
    }
    ```

*******************************************************************************/

public struct Name
{
    ///
    public string name;
}

/*******************************************************************************

    Provides a means to convert a field from a `string` to a complex type

    When filling the config, it might be useful to store types which are
    not only simple `string` and integer, such as `Duration`, `URL`,
    `BigInt`, etc...

    To allow reading those values from the config file, a `Converter` needs
    to be used. The converter will tell the `ConfigFiller` how to convert from
    `string` to the desired type `T`.

    If the type is under the user's control, one can also add a constructor
    accepting a single string, or define the `fromString` method, both of which
    are tried if no `Converter` is found.

    For types not under the user's control, there might be different ways
    to parse the same type within the same struct. One common example is when
    using `core.time : Duration`.

    Below is an example of such an usage:
    ```
    public struct BanConfig
    {
        ///
        @Converter!Duration((string value) => value.to!ulong.hours)
        public Duration first_ban_hours = 12.hours;

        ///
        @Converter!Duration((string value) => value.to!ulong.days)
        public Duration second_ban_hours = 7.days;
    }
    ```

    Note that this modules provides a few common converters for convenience,
    such as `fromSeconds`.
    Additionally, to avoid repeating the field type, one may use the `converter`
    convenience function:
    ```
    public struct BanConfig
    {
        ///
        @converter((string value) => value.to!ulong.hours)
        public Duration first_ban_hours = 12.hours;

        ///
        @converter((string value) => value.to!ulong.days)
        public Duration second_ban_hours = 7.days;
    }
    ```

*******************************************************************************/

public struct Converter (T)
{
    ///
    public alias ConverterFunc = T function (string input);

    ///
    public ConverterFunc converter;
}

/// Ditto
public auto converter (FT) (FT func)
{
    static assert(isFunctionPointer!FT,
                  "Error: Argument to `converter` should be a function pointer, not: "
                  ~ FT.stringof);

    alias RType = ReturnType!FT;
    static assert(!is(RType == void),
                  "Error: Converter needs to be of the return type of the field, not `void`");
    return Converter!RType(func);
}

/*******************************************************************************

    A converter for `Duration` fields expressed in seconds

*******************************************************************************/

public immutable fromSeconds = Converter!Duration((string arg) => arg.to!ulong.seconds);

/*******************************************************************************

    A converter for `Duration` fields expressed in milliseconds (`msecs`)

*******************************************************************************/

public immutable fromMsecs = Converter!Duration((string arg) => arg.to!ulong.msecs);
