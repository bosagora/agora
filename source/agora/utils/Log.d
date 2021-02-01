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
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.utils.Log;

import ocean.text.convert.Formatter;
import ocean.transition;
import ocean.util.log.AppendConsole;
import ocean.util.log.Appender;
import ocean.util.log.Event;
import Ocean = ocean.util.log.Logger;

import std.algorithm : min;
import std.format;
import std.stdio;
import std.range : Cycle, cycle, isOutputRange, take, takeExactly, put;

/// nothrow wrapper around Ocean's Logger
public struct Logger
{
    private Ocean.Logger logger;

    /// ctor
    public this (string moduleName)
    {
        import core.memory;
        this.logger = Ocean.Log.lookup(moduleName);
        this.logger.buffer(new char[](16384));
    }

    public void opDispatch (string call, Args...) (Args args)
    {
        try
        {
            import core.memory : GC;
            if (GC.inFinalizer())
            {
                writeln("allowing logging from the destructor on a GC thread would risk running into segfaults, please see issue #1128");
                return;
            }
            else if (logger is null)
            {
                assert(0,"\nplease make sure you are declaring the \nmixin AddLogger!(); statement on top, followed by:\nstatic this{}; followed by:\nstatic ~this{};");
                return;
            }
            mixin("this.logger." ~ call ~ "(args);");
        }
        catch (Exception ex)
        {
            assert(0, ex.msg);
        }
    }

    // Supports `log = Log.lookup("yo")`,
    // where `log` is of `typeof(this)` type
    public ref Logger opAssign (Ocean.Logger newLogger)
        @safe pure nothrow @nogc return
    {
        this.logger = newLogger;
        return this;
    }

    // Support `Logger log = Log.lookup("yo")` (initialization)
    public this (Ocean.Logger initRef)
        @safe pure nothrow @nogc
    {
        this.logger = initRef;
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
public alias LogLevel = Ocean.Level;

/// Ditto
public alias Log = Ocean.Log;

/// Initialize the logger
static this ()
{
    version (unittest)
        auto appender = CircularAppender!()();
    else
        auto appender = new AppendConsole();

    appender.layout(new AgoraLayout());
    Log.root.add(appender);
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
    public override istring name ()
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
            formattedWrite(this.cyclic, "\n");
            this.used_length++;
        }

        this.layout.format(event,
            (cstring content)
            {
                formattedWrite(this.cyclic, content);
                this.used_length = min(this.buffer.length,
                    this.used_length + content.length);
            });
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
            sformat(dg, "{}", event);
        }
    }

    scope get_log_output = (string log_msg){
        import ocean.util.log.ILogger;

        immutable buffer_size = 7;
        char[buffer_size + 1] result_buff;
        LogEvent event;
        scope appender = new CircularAppender!(buffer_size);
        event.set(ILogger.Context.init, ILogger.Level.init, log_msg, "");
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
}

/// A layout with colored LogLevel
public class AgoraLayout : Appender.Layout
{
    import ocean.time.WallClock;

    /// Format the message
    public override void format (LogEvent event, scope FormatterSink dg)
    {
        // convert time to field values
        const tm = event.time;
        const dt = WallClock.toDate(tm);

        // format date according to ISO-8601 (lightweight formatter)
        sformat(dg, "{u4}-{u2}-{u2} {u2}:{u2}:{u2},{u2} {} [{}] - {}",
            dt.date.year, dt.date.month, dt.date.day,
            dt.time.hours, dt.time.minutes, dt.time.seconds, dt.time.millis,
            coloredName(event.level), event.name, event);
    }

    /// Returns: A colorized version of a LogLevel
    protected static string coloredName (LogLevel lvl)
    {
        switch (lvl)
        {
            // Cyan
        case LogLevel.Trace:
            return "\u001b[36mTrace\u001b[0m";
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
            // so use red and make them noticeable
        case LogLevel.None:
            return "\u001b[31mNone\u001b[0m";
        default:
            return "\u001b[31mUnknown\u001b[0m";
        }
    }
}

/***************************************************************************

    Logging function which is only called from C++ code

    It's for C++ code to use agora's logger instead of C++ stdout

    Params:
        logger = the logger name
        level = the logging level
        msg = the log message

***************************************************************************/

private extern(C++) void writeDLog (const(char)* logger, int level,
    const(char)* msg)
{
    if (level >= LogLevel.min && level <= LogLevel.max)
    {
        import std.string;

        auto log = Log.lookup(fromStringz(logger));
        assert(log !is null);
        log.format(cast(LogLevel) level, fromStringz(msg));
    }
}
