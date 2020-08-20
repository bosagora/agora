/*******************************************************************************

    Contains a task manager backed by vibe.d's event loop.

    Overriding classes can implement task routines to run
    tasks in their own event loop - for example to be used
    with LocalRest to simulate a network and avoid any I/O.

    Copyright:
        Copyright (c) 2019 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Task;

import agora.utils.Log;

import core.time;

mixin AddLogger!();

/// Whether the timer periodic type
public enum Periodic : bool
{
    No,
    Yes
}

/// Exposes primitives to run tasks through Vibe.d
public class TaskManager
{
    /***************************************************************************

        Run an asynchronous task in vibe.d's event loop

        Params:
            dg = the delegate the task should run

    ***************************************************************************/

    public void runTask (void delegate() dg) nothrow
    {
        static import vibe.core.core;
        vibe.core.core.runTask(dg);
    }

    /***************************************************************************

        Suspend the current task for the given duration

        Params:
            dur = the duration for which to suspend the task for

    ***************************************************************************/

    public void wait (Duration dur) nothrow
    {
        static import vibe.core.core;
        try
            vibe.core.core.sleep(dur);
        catch (Exception exc)
        {
            log.fatal("Call to wait({}) failed: {}", dur, exc);
            // TODO: Replace with a busy loop in non-debug mode ?
            assert(0);
        }
    }

    /***************************************************************************

        Run an asynchronous task after a given time.

        The task will first run after the given `timeout`, and
        can either repeat or run only once (the default).
        See_Also: https://vibed.org/api/vibe.core.core/setTimer

        Params:
            timeout = Determines the minimum amount of time that elapses before
                the timer fires.
            dg = This delegate will be called when the timer fires.
            periodic = Specifies if the timer fires repeatedly or only once.

        Returns:
            An `ITimer` interface with the ability to control the timer

    ***************************************************************************/

    public ITimer setTimer (Duration timeout, void delegate() dg,
        Periodic periodic = Periodic.No) nothrow
    {
        assert(dg !is null, "Cannot call this delegate if null");
        static import vibe.core.core;
        return new VibedTimer(vibe.core.core.setTimer(timeout, dg, periodic));
    }
}

/*******************************************************************************

    Defines an abstraction over the timer implementation

*******************************************************************************/

public interface ITimer
{
    /***************************************************************************

        Stop or cancel this timer

    ***************************************************************************/

    public void stop () @safe nothrow;
}

/*******************************************************************************

    Vibe.d timer

*******************************************************************************/

private final class VibedTimer : ITimer
{
    static import Vibe = vibe.core.core;

    private Vibe.Timer timer;

    public this (Vibe.Timer timer) @safe nothrow
    {
        this.timer = timer;
    }

    /// Ditto
    public override void stop () @safe nothrow
    {
        this.timer.stop();
    }
}
