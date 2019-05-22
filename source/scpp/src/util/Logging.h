#pragma once

// Copyright 2014 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

#include <string>
#include <sstream>
#include <iostream>

#define TRACE "trace"
#define DEBUG "debug"
#define INFO "info"
#define ERROR "error"
#define FATAL "fatal"
#define CLOG(LEVEL, MOD) std::cout << "[" << LEVEL << ", " << MOD << "] "

namespace stellar
{
class Logging
{
  public:
    static void init();
    static void setFmt(std::string const& peerID, bool timestamps = true);
    static void setLoggingToFile(std::string const& filename);
    static bool logDebug(std::string const& partition) { return true; }
    static bool logTrace(std::string const& partition) { return true; }
    static void rotate();
};
}
