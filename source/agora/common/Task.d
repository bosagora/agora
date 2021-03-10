/*******************************************************************************

    Contains the base definition for the task manager

    The `TaskManager` base class provides certain primitives that are modeled
    after Vibe.d's primitives, such as `setTimer`, `sleep`, or `runTask`.
    Overriding classes can implement task routines to run tasks in their
    own event loop - mostly, to be used with LocalRest.

    Copyright:
        Copyright (c) 2019-2021 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.common.Task;

import agora.utils.Log;

import core.time;

/// Whether the timer periodic type
public enum Periodic : bool
{
    No,
    Yes,
}

/// Exposes primitives to run tasks
public abstract class ITaskManager
{
    /// stats: total number of task started
    protected ulong tasks_started;

    /// Logger used by this class
    protected Logger log;

    ///
    public this () @trusted
    {
        this.log = Log.lookup(__MODULE__);
    }

    /***************************************************************************

        Run an asynchronous task in an event loop

        Params:
            dg = the delegate the task should run

    ***************************************************************************/

    public abstract void runTask (void delegate() dg) nothrow;

    /***************************************************************************

        Suspend the current task for the given duration

        Params:
            dur = the duration for which to suspend the task for

    ***************************************************************************/

    public void wait (Duration dur) nothrow;

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
        Periodic periodic = Periodic.No) nothrow;

    /***************************************************************************

        Log out the request stats

    ***************************************************************************/

    public final void logStats () @safe nothrow
    {
        log.info("Tasks started: {}", this.tasks_started);
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
