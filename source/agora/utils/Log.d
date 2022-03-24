/*******************************************************************************

    Utilities to deal with logging

    ---
    module agora.foo.bar;

    import agora.utils.Log;

    mixin AddLogger!();

    void myFunctionThatLogs (int arg = 42)
    {
        log.info("[{}:{}] My argument is: {}", __FILE__, __LINE__, arg);
    }
    ---

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Log;

import configy.Attributes;

import dtext.format.Formatter;
import dtext.log.AppendConsole;
import dtext.log.Appender;
import dtext.log.Event;
import Dtext = dtext.log.Logger;

import std.algorithm : min;
import std.stdio;
import std.exception : assumeWontThrow;
import std.range : Cycle, cycle, isOutputRange, take, takeExactly, put;

/// nothrow wrapper around dtext's Logger
public struct Logger
{
    private Dtext.Logger logger;

    /// ctor
    public this (string moduleName)
    {
        import core.memory;
        this.logger = Dtext.Log.lookup(moduleName);
        this.logger.buffer(new char[](16_384));
    }

    /// See `dtext.log.Logger : Logger.dbg`
    public void dbg (Args...) (in char[] fmt, Args args)
    {
        // For debug logging let's assume we do not throw
        assumeWontThrow(this.format(LogLevel.Debug, fmt, args));
    }

    /// See `dtext.log.Logger : Logger.trace`
    public void trace (Args...) (in char[] fmt, Args args)
    {
        this.format(LogLevel.Trace, fmt, args);
    }

    /// See `dtext.log.Logger : Logger.verbose`
    public void verbose (Args...) (in char[] fmt, Args args)
    {
        this.format(LogLevel.Verbose, fmt, args);
    }

    /// See `dtext.log.Logger : Logger.info`
    public void info (Args...) (in char[] fmt, Args args)
    {
        this.format(LogLevel.Info, fmt, args);
    }

    /// See `dtext.log.Logger : Logger.warn`
    public void warn (Args...) (in char[] fmt, Args args)
    {
        this.format(LogLevel.Warn, fmt, args);
    }

    /// See `dtext.log.Logger : Logger.error`
    public void error (Args...) (in char[] fmt, Args args)
    {
        this.format(LogLevel.Error, fmt, args);
    }

    /// See `dtext.log.Logger : Logger.fatal`
    public void fatal (Args...) (in char[] fmt, Args args)
    {
        this.format(LogLevel.Fatal, fmt, args);
    }

    /// See `dtext.log.Logger : Logger.format`
    public void format (Args...) (LogLevel level, in char[] fmt, Args args)
    {
        import core.memory : GC;
        try
        {
            if (GC.inFinalizer())
            {
                writeln("allowing logging from the destructor on a GC thread would risk running into segfaults, please see issue #1128");
                return;
            }
            else if (this.logger is null)
            {
                assert(0,"\nplease make sure you are declaring the \nmixin AddLogger!(); statement on top, followed by:\nstatic this{}; followed by:\nstatic ~this{};");
            }
            this.logger.format(level, fmt, args);
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }

    // Supports `log = Log.lookup("yo")`,
    // where `log` is of `typeof(this)` type
    public ref Logger opAssign (Dtext.Logger newLogger)
        @safe pure nothrow @nogc return
    {
        this.logger = newLogger;
        return this;
    }

    // Support `Logger log = Log.lookup("yo")` (initialization)
    public this (Dtext.Logger initRef)
        @safe pure nothrow @nogc
    {
        this.logger = initRef;
    }

    /***************************************************************************

        Enable console or file logging for this logger

        Those routines are useful for quick debugging. As the underlying logger
        is not accessible, the only way to enable an appender is to call
        `configureLogger`, however this can be unnecessarily complicated.

        Note that those methods are additive only: Calling `enableConsole` twice
        will have unintended consequences (messages being written twice).

        Hence, for production / advanced scenario, prefer `configureLogger`.

    ***************************************************************************/

    public void enableConsole (bool additive = false)
    {
        this.logger.additive = additive;
        auto appender = new AppendConsole();
        appender.layout(new AgoraLayout());
        this.logger.add(appender);
    }

    /// Ditto
    public void enableFile (string path, bool additive = false)
    {
        this.logger.additive = additive;
        auto appender = new PhobosFileAppender(path);
        appender.layout(new AgoraLayout());
        this.logger.add(appender);
    }
}

/// Insert a logger in the current scope, named log
public template AddLogger (string moduleName = __MODULE__)
{
    private Logger* log;
    static this ()
    {
        log = new Logger(moduleName);
    }
}

/// Convenience alias
public alias LogLevel = Dtext.Level;

/// Ditto
public alias Log = Dtext.Log;

version (unittest)
{
    // As we spawn one node per thread (except for the main thread),
    // we need to configure each thread's logger, a task normally
    // handled by `agora.node.main` / `agora.node.Runner`.
    static this ()
    {
        auto appender = CircularAppender!()();
        appender.layout(new AgoraLayout());
        Log.root.add(appender);
    }

    // Since threads may be reused, we also need to clear the buffer
    static ~this ()
    {
        auto appender = CircularAppender!()();
        appender.clear();
    }
}

/// Define options to configure a Logger
/// Loosely inspired from `ocean.utils.log.Config`
public struct LoggerConfig
{
    /// Name of the logger to configure
    public string name;

    /// Level to set the logger to (messages at a lower level won't be printed)
    public LogLevel level = LogLevel.Info;

    /// Whether to propagate that level to the children
    /// Default to `true` as this is the expected behavior for most users
    public bool propagate = true;

    /// Whether to use console output or not
    public bool console;

    /// Whether to use file output and if, which file path
    public @Optional string file;

    /// Whether this logger should be additive or not
    public bool additive;

    /// Buffer size of the buffer output
    public size_t buffer_size = 16_384;
}

/***************************************************************************

    Configure a Logger based on the provided `settings`

    Params:
        settings = Configuration to apply
        clear    = Whether the to clear the logger or reconfigure only

***************************************************************************/

public void configureLogger (in LoggerConfig settings, bool clear)
{
	auto log = (settings.name && settings.name != "root") ?
        Log.lookup(settings.name) : Log.root;

    if (clear)
        log.clear();

    if (settings.buffer_size)
        log.buffer(new char[](settings.buffer_size));

	// if console/file/syslog is specifically set, don't inherit other
    // appenders (unless we have been specifically asked to be additive)
	log.additive = settings.additive ||
        !(settings.console || settings.file.length);

    if (settings.console)
    {
        auto appender = new AppendConsole();
        appender.layout(new AgoraLayout());
        log.add(appender);
    }

    if (settings.file.length)
    {
        auto appender = new PhobosFileAppender(settings.file);
        appender.layout(new AgoraLayout());
        log.add(appender);
    }

    log.level(settings.level, settings.propagate);
}

/// Circular appender which appends to an internal buffer
public class CircularAppender (size_t BufferSize = 2^^20) : Appender
{
    /// Mask
    private Mask mask_;

    /// Used length of the buffer, only grows, up to buffer.length
    private size_t used_length;

    /// Backing store for the cyclic buffer
    private char[BufferSize] buffer;

    /// Cyclic Output range over buffer
    private Cycle!(typeof(buffer)) cyclic;

    /// Ctor
    private this ()
    {
        this.mask_ = register(name);
        this.cyclic = cycle(this.buffer);
    }

    public static CircularAppender opCall ()
    {
        static CircularAppender!BufferSize appender;
        if (appender is null)
            appender = new CircularAppender!BufferSize();

        return appender;
    }

    /// Print the contents of the appender to the console
    public void print (R) (R output)
        if (isOutputRange!(R, char))
    {
        // edge-case: if the buffer isn't filled yet,
        // write from buffer index 0, not the cycle's current index
        if (this.used_length < this.buffer.length)
            output.put(this.buffer[0 .. this.used_length]);
        else
            // Create a new range to work around `const` issue:
            // https://issues.dlang.org/show_bug.cgi?id=20888
            output.put(this.cyclic[0 .. $].takeExactly(this.buffer.length));
        output.put("\n");
    }

    /// Returns: the name of this class
    public override string name ()
    {
        return this.classinfo.name;
    }

    /// Return the fingerprint for this class
    public final override Mask mask ()
    {
        return this.mask_;
    }

    /// Append an event to the buffer
    public final override void append (LogEvent event)
    {
        // add a newline only before a subsequent event is logged
        // (avoids trailing empty lines with only a newline)
        if (this.used_length > 0)
        {
            this.cyclic.put("\n");
            this.used_length++;
        }

        this.layout.format(event,
            (in char[] content)
            {
                this.cyclic.put(content);
                this.used_length = min(this.buffer.length,
                    this.used_length + content.length);
            });
    }

    ///
    public void clear ()
    {
        this.used_length = 0;
        this.cyclic = cycle(this.buffer);
    }
}

///
unittest
{
    static class MockLayout : Appender.Layout
    {
        /// Format the message
        public override void format (LogEvent event, scope FormatterSink dg)
        {
            sformat(dg, "{}", event.msg);
        }
    }

    scope get_log_output = (string log_msg){
        import dtext.log.ILogger;

        immutable buffer_size = 7;
        char[buffer_size + 1] result_buff;
        scope appender = new CircularAppender!(buffer_size);
        LogEvent event = {
            msg: log_msg,
        };
        appender.layout(new MockLayout());
        appender.append(event);
        appender.print(result_buff[]);
        return result_buff[0 .. min(log_msg.length, buffer_size)].dup;
    };

    // case 1
    // the internal buffer size is greater than the length of the messages
    // that we are trying to log
    assert(get_log_output("01234") == "01234");

    // case 2
    // the internal buffer size is equal to the length of the messages
    // that we are trying to log(there is a terminating newline)
    assert(get_log_output("012345") == "012345");

    // case 3
    // the internal buffer size is smaller than the length of the messages
    // that we are trying to log
    assert(get_log_output("0123456789") == "3456789");

    // Make sure we don't trip on stray format specifiers
    assert(get_log_output("Thou shalt ignore random %s in the string") == " string");

    // log a map over a range
    import std.algorithm;
    import std.range;
    assert(get_log_output(format("{}", iota(2).map!(i => i + 1))) == "[1, 2]");
}

/// A file appender that uses Phobos
public class PhobosFileAppender : Appender
{
    /// Mask
    private Mask mask_;

    ///
    private File file;

    ///
    public this (string path)
    {
        import std.file, std.path;
        path.dirName.mkdirRecurse();
        this.file = File(path, "a");
    }

    /// Returns: the name of this class
    public override string name ()
    {
        return this.classinfo.name;
    }

    /// Return the fingerprint for this class
    public final override Mask mask ()
    {
        return this.mask_;
    }

    /// Append an event to the buffer
    public final override void append (LogEvent event)
    {
        // We need the `file.flush()` to happen after the lockingTextWriter
        // is destroyed (unlocking the file).
        scope (exit) this.file.flush();
        scope writer = this.file.lockingTextWriter();
        this.layout.format(event,
            (in char[] content)
            {
                writer.put(content);
            });
        version (Windows) writer.put("\r\n");
        else              writer.put("\n");
    }
}

/// A layout with colored LogLevel
public class AgoraLayout : Appender.Layout
{
    /// Format the message
    public override void format (LogEvent event, scope FormatterSink dg)
    {
        // convert time to field values
        const tm = event.time;

        // `SysTime.month` returns an `enum`, we need an integer
        const uint month = tm.month;

        // format date according to ISO-8601 (lightweight formatter)
        sformat(dg, "{u4}-{u2}-{u2} {u2}:{u2}:{u2},{u2} {} [{}] - {}",
            tm.year, month, tm.day,
            tm.hour, tm.minute, tm.second, tm.fracSecs.total!"msecs",
            coloredName(event.level), event.name, event.msg);
    }

    /// Returns: A colorized version of a LogLevel
    protected static string coloredName (LogLevel lvl)
    {
        switch (lvl)
        {
            // White on Cyan
        case LogLevel.Debug:
            return "\u001b[46mDebug\u001b[0m";
            // Cyan
        case LogLevel.Trace:
            return "\u001b[36mTrace\u001b[0m";
            // Blue
        case LogLevel.Verbose:
            return "\u001b[34mVerbose\u001b[0m";
            // Green
        case LogLevel.Info:
            return "\u001b[32mInfo\u001b[0m";
            // Yellow
        case LogLevel.Warn:
            return "\u001b[33mWarn\u001b[0m";
            // Magenta
        case LogLevel.Error:
            return "\u001b[35mError\u001b[0m";
            // Red
        case LogLevel.Fatal:
            return "\u001b[31mFatal\u001b[0m";

            // The following two should never be printed,
            // so use white on red and make them noticeable
        case LogLevel.None:
            return "\u001b[41mNone\u001b[0m";
        default:
            return "\u001b[41mUnknown\u001b[0m";
        }
    }
}

///
unittest
{
    import std.datetime;
    import core.memory;
    import core.time;

    char[] result = new char[](2048);
    result.length = 0;
    assumeSafeAppend(result);

    scope dg = (in char[] v) { result ~= v; };
    scope layout = new AgoraLayout();
    LogEvent event = {
       msg: "Have you met Ted?",
       name: "Barney",
       time: SysTime.fromUnixTime(1525048962, UTC()) + 420.msecs,
       level: LogLevel.Warn,
       host: null,
    };

    const before = GC.stats();
    layout.format(event, dg);
    const after = GC.stats();
    assert(result == "2018-04-30 00:42:42,420 \u001b[33mWarn\u001b[0m [Barney] - Have you met Ted?");
    assert(before == after);
}

/***************************************************************************

    Logging function which is only called from C++ code

    It's for C++ code to use agora's logger instead of C++ stdout

    Params:
        logger = the logger name
        level = the logging level
        msg = the log message

***************************************************************************/

private extern(C++, "agora") void writeDLog (const(char)* logger, int level,
    const(char)* msg) nothrow
{
    try
    {
        if (level >= LogLevel.min && level <= LogLevel.max)
        {
            import std.string;

            auto log = Log.lookup(fromStringz(logger));
            assert(log !is null);
            log.format(cast(LogLevel) level, fromStringz(msg));
        }
    }
    catch (Exception exc)
    {
        printf("ERROR while logging: %.*s\n", cast(int) exc.msg.length, exc.msg.ptr);
        try
        {
            auto trace = exc.toString();
            printf("Full error: %.*s\n", cast(int) trace.length, trace.ptr);
        }
        catch (Exception e2)
        {
            // At this point there's not much we can do
            printf("ERROR: Couldn't print stack trace\n");
        }
        // Abort here, because we don't want to silently swallow Exceptions
        // The better thing to do might be to ignore it
        // e.g. if Exceptions *can* happen, but currently they're not supposed to.
        // Not catching Exceptions, however, would lead to a cryptic message:
        // "libc++: terminated from uncaught foreign exception"
        assert(0);
    }
}

/// Used by C++ code to check whether a log level is enabled
/// and avoid needlessly formatting messages
private extern(C++, "agora") int getLogLevel (const(char)* logger)
{
    import std.string;
    auto log = Log.lookup(fromStringz(logger));
    assert(log !is null);
    return log.level();
}

/*******************************************************************************

    Set Vibe.d log level according to the configuration's log level

    This is used to ensure we get the right amount of information from Vibe.d
    Since a log level is the "minimum accepted" level, some level values might
    not match. For example, if we want Vibe.d's "diagnostic" to be part of
    the output when we set the loglevel to info, then that's what we must pass
    to Vibe's `setLogLevel` (and since diagnostic < info, it will include the
    latter too).

    Params:
        level = The level at which we want to set the logger

    See_Also:
      https://vibed.org/api/vibe.core.log/LogLevel
      https://github.com/vibe-d/vibe-core/blob/a9dbc9b8953f98790f8f94cda89067e3bf99a2b6/source/vibe/core/log.d#L238-L255

*******************************************************************************/

public void setVibeLogLevel (LogLevel level) @safe
{
    import vibe.core.log : LogLevel, setLogLevel;

    final switch (level)
    {
    case Dtext.Level.Debug:
        setLogLevel(LogLevel.trace);
        break;
    case Dtext.Level.Trace:
        setLogLevel(LogLevel.debugV);
        break;
    // There is one extra level between debugV and diagnostic (debug_),
    // but we choose to just include it in verbose.
    case Dtext.Level.Verbose:
        setLogLevel(LogLevel.diagnostic);
        break;
    case Dtext.Level.Info:
        setLogLevel(LogLevel.info);
        break;
    case Dtext.Level.Warn:
        setLogLevel(LogLevel.warn);
        break;
    case Dtext.Level.Error:
        setLogLevel(LogLevel.error);
        break;
    case Dtext.Level.Fatal:
        setLogLevel(LogLevel.critical);
        break;
    case Dtext.Level.None:
        setLogLevel(LogLevel.none);
        break;
    }
}
