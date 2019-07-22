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

import core.time;

/// Ditto
public class TaskManager
{
    /***************************************************************************

        Run an asynchronous task in vibe.d's event loop

        Params:
            dg = the delegate the task should run

    ***************************************************************************/

    public void runTask (void delegate() dg)
    {
        static import vibe.core.core;
        vibe.core.core.runTask(dg);
    }

    /***************************************************************************

        Suspend the current task for the given duration

        Params:
            dur = the duration for which to suspend the task for

    ***************************************************************************/

    public void wait (Duration dur)
    {
        static import vibe.core.core;
        vibe.core.core.sleep(dur);
    }
}
