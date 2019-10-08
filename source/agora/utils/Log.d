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

version (unittest) {}
else
{
    /// Initialize the logger
    static this ()
    {
        Log.defaultConfig();
    }
}
