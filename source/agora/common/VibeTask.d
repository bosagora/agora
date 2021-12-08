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

    @safe nothrow:

    ///
    public override void wait (Duration dur)
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
    alias setTimer = typeof(super).setTimer;

    ///
    public override ITimer setTimer (Duration timeout, SafeTimerHandler dg,
        Periodic periodic = Periodic.No)
    {
        this.tasks_started++;
        assert(dg !is null, "Cannot call this delegate if null");
        return new VibedTimer(vibe.core.core.setTimer(timeout, dg, periodic));
    }

    ///
    alias createTimer = typeof(super).createTimer;

    ///
    public override ITimer createTimer (SafeTimerHandler dg)
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

    @safe nothrow:

    public this (vibe.core.core.Timer timer)
    {
        this.timer = timer;
    }

    /// Ditto
    public override void stop ()
    {
        this.timer.stop();
    }

    /// Ditto
    public override void rearm (Duration timeout, bool periodic)
    {
        this.timer.rearm(timeout, periodic);
    }

    /// Ditto
    public override bool pending ()
    {
        return this.timer.pending();
    }
}
