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
import ocean.util.log.AppendConsole;
import ocean.util.log.Appender;
import ocean.util.log.Event;
import ocean.util.log.Logger;

/// Insert a logger in the current scope, named log
public template AddLogger (string moduleName = __MODULE__)
{
    import ocean.util.log.Logger;
    private Logger log;
    static this ()
    {
        import core.memory;
        log = Log.lookup(moduleName);
        GC.addRoot(cast(void*)log);
    }

    static ~this()
    {
        import core.memory;
        GC.removeRoot(cast(void*)log);
    }
}

/// Convenience alias
public alias LogLevel = Level;

/// Whether logging is enabled (by default disabled in unittests)
version (unittest)
    __gshared bool EnableLogging = false;
else
    __gshared bool EnableLogging = true;

/// Initialize the logger
static this ()
{
    if (EnableLogging)
    {
        auto appender = new AppendConsole();
        appender.layout(new AgoraLayout());
        Log.root.add(appender);
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
