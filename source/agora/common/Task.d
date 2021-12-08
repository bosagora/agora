/*******************************************************************************

    Contains the base definition for the task manager

    The `TaskManager` base class provides certain primitives that are modeled
    after Vibe.d's primitives, such as `setTimer`, `sleep`, or `runTask`.
    Overriding classes can implement task routines to run tasks in their
    own event loop - mostly, to be used with LocalRest.

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
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

    /// Unsafe timer handler, these will be run in `trusted` and exceptions
    /// inside the handler will be logged
    protected alias UnsafeTimerHandler = void delegate();

    /// Recommended handler delegate for timers
    protected alias SafeTimerHandler = void delegate() nothrow @safe;

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

    public abstract void runTask (void delegate () nothrow dg) nothrow;

    @safe nothrow:

    /// Converts an unsafe timer handler to safe, `dg` will be executed in
    /// `trusted` and exceptions happening inside the handler will be logged
    private SafeTimerHandler toSafeHandler (UnsafeTimerHandler dg)
    {
        return (() @safe nothrow
        {
            () @trusted
            {
                try
                    dg();
                catch (Exception e)
                    this.log.error("Timer handler caused an exception: {}", e.msg);
            } ();
        });
    }

    /***************************************************************************

        Suspend the current task for the given duration

        Params:
            dur = the duration for which to suspend the task for

    ***************************************************************************/

    public void wait (Duration dur);

    /***************************************************************************

        Run an asynchronous task after a given time.

        The task will first run after the given `timeout`, and
        can either repeat or run only once (the default).

        Currently non `@safe` and non `nothrow` handlers are allowed but not
        recommended. It might be deprecated in the future.

        See_Also: https://vibed.org/api/vibe.core.core/setTimer

        Params:
            timeout = Determines the minimum amount of time that elapses before
                the timer fires.
            dg = This delegate will be called when the timer fires. It is recommended
                to provide a `@safe` and `nothrow` handler.
            periodic = Specifies if the timer fires repeatedly or only once.

        Returns:
            An `ITimer` interface with the ability to control the timer

    ***************************************************************************/

    public ITimer setTimer (Duration timeout, SafeTimerHandler dg,
        Periodic periodic = Periodic.No);

    /// Ditto
    public final ITimer setTimer (Duration timeout, UnsafeTimerHandler dg,
        Periodic periodic = Periodic.No)
    {
        return setTimer(timeout, toSafeHandler(dg), periodic);
    }

    /***************************************************************************

        Creates a new timer without arming it

        See_Also: https://vibed.org/api/vibe.core.core/createTimer

        Params:
            dg = This delegate will be called when the timer fires

        Returns:
            An `ITimer` interface with the ability to control the timer

    ***************************************************************************/

    public ITimer createTimer (SafeTimerHandler dg);

    /// Ditto
    public final ITimer createTimer (UnsafeTimerHandler dg)
    {
        return createTimer(toSafeHandler(dg));
    }

    /***************************************************************************

        Log out the request stats

    ***************************************************************************/

    public final void logStats ()
    {
        log.info("Tasks started: {}", this.tasks_started);
    }
}

/*******************************************************************************

    Defines an abstraction over the timer implementation

*******************************************************************************/

public interface ITimer
{
    @safe nothrow:

    /***************************************************************************

        Stop or cancel this timer

    ***************************************************************************/

    public void stop ();

    /***************************************************************************

        Rearm this timer

    ***************************************************************************/

    void rearm (Duration timeout, bool periodic);

    /***************************************************************************

        See_also: https://vibed.org/api/vibe.core.core/Timer.pending

        Returns:
            True if timer is armed and pending to fire

    ***************************************************************************/

    public bool pending ();
}
