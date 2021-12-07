/*******************************************************************************

    Contains a task manager backed by vibe.d's event loop.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.VibeTask;

public import agora.common.Task;

static import vibe.core.core;

import std.stdio;
import core.time;

/// Exposes primitives to run tasks through Vibe.d
public final class VibeTaskManager : ITaskManager
{
    ///
    public override void runTask (void delegate() nothrow dg) nothrow
    {
        this.tasks_started++;
        vibe.core.core.runTask(dg);
    }

    ///
    public override void wait (Duration dur) nothrow
    {
        try
            vibe.core.core.sleep(dur);
        catch (Exception exc)
        {
            this.log.fatal("Call to wait({}) failed: {}", dur, exc);
            // TODO: Replace with a busy loop in non-debug mode ?
            assert(0);
        }
    }

    ///
    public override ITimer setTimer (Duration timeout, void delegate() dg,
        Periodic periodic = Periodic.No) nothrow
    {
        this.tasks_started++;
        assert(dg !is null, "Cannot call this delegate if null");
        return new VibedTimer(vibe.core.core.setTimer(timeout, dg, periodic));
    }

    ///
    public override ITimer createTimer (void delegate() nothrow @safe dg) nothrow
    {
        assert(dg !is null, "Cannot call this delegate if null");
        return new VibedTimer(vibe.core.core.createTimer(dg));
    }
}

/*******************************************************************************

    Vibe.d timer

*******************************************************************************/

private final class VibedTimer : ITimer
{
    private vibe.core.core.Timer timer;

    public this (vibe.core.core.Timer timer) @safe nothrow
    {
        this.timer = timer;
    }

    /// Ditto
    public override void stop () @safe nothrow
    {
        this.timer.stop();
    }

    /// Ditto
    public override void rearm (Duration timeout, bool periodic) nothrow
    {
        this.timer.rearm(timeout, periodic);
    }

    /// Ditto
    public override bool pending () @safe nothrow
    {
        return this.timer.pending();
    }
}
