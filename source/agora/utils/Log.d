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
import ocean.util.log.Logger;

import std.algorithm : min;
import std.format;
import std.stdio;
import std.range : Cycle, cycle, take;

/// Insert a logger in the current scope, named log
public template AddLogger (string moduleName = __MODULE__)
{
    import Ocean = ocean.util.log.Logger;
    import agora.common.Types;

    /// nothrow wrapper around Ocean's Logger
    public static struct Logger
    {
        private Ocean.Logger logger;

        // workaround: weird CT bug in NetworkManager.d call:
        // log.info("Discovery reached. {} peers connected.", this.peers.length);
        // source/agora/network/NetworkManager.d(149,12): Error: no property info for type Logger
        public void info (Args...) (Args args) @safe nothrow
        {
            try
            {
                this.logger.info(args);
            }
            catch (Exception ex)
            {
                assert(0, ex.msg);
            }
        }

        public void opDispatch (string call, Args...) (Args args) @safe nothrow
        {
            try
            {
                mixin("this.logger." ~ call ~ "(args);");
            }
            catch (Exception ex)
            {
                assert(0, ex.msg);
            }
        }
    }

    private Logger log;
    static this ()
    {
        import core.memory;
        log = Logger(Ocean.Log.lookup(moduleName));
        GC.addRoot(cast(void*)log.logger);
    }

    static ~this()
    {
        import core.memory;
        GC.removeRoot(cast(void*)log.logger);
    }
}

/// Convenience alias
public alias LogLevel = Level;

/// Initialize the logger
static this ()
{
    version (unittest)
        auto appender = CircularAppender();
    else
        auto appender = new AppendConsole();

    appender.layout(new AgoraLayout());
    Log.root.add(appender);
}

/// Circular appender which appends to an internal buffer
public class CircularAppender : Appender
{
    /// Mask
    private Mask mask_;

    /// Used length of the buffer, only grows, up to buffer.length
    private size_t used_length;

    /// Backing store for the cyclic buffer
    private char[2 ^^ 16] buffer;

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
        static CircularAppender appender;
        if (appender is null)
            appender = new CircularAppender();

        return appender;
    }

    /// Print the contents of the appender to the console
    public void printConsole ()
    {
        // edge-case: if the buffer isn't filled yet,
        // write from buffer index 0, not the cycle's current index
        if (this.used_length <= this.buffer.length)
            writeln(this.buffer[0 .. this.used_length]);
        else
            writeln(this.cyclic.take(this.used_length));
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

/// A layout with colored LogLevel
public class AgoraLayout : Appender.Layout
{
    /// Format the message
    public override void format (LogEvent event, scope FormatterSink dg)
    {
        import ocean.time.WallClock;

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

private extern (C++) void writeDLog (const char* logger, int level, const char* msg)
{
    if (level >= Level.min && level <= Level.max)
    {
        import std.string;

        auto log = Log.lookup(fromStringz(logger));
        assert(log !is null);
        log.format(cast(Level) level, fromStringz(msg));
    }
}
