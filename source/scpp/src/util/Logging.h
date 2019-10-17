#pragma once

// Copyright 2014 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

#include <string>
#include <sstream>
#include <iostream>

#define TRACE 0
#define DEBUG 0
#define INFO  1
#define WARN  2
#define ERROR 3
#define FATAL 4
#define CLOG(LEVEL, MOD) stellar::DLogger(LEVEL, MOD)

// Logging function to D code
void writeDLog(const char* logger, int level, const char* msg);

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

struct DLogger
{
  private:
    std::string mLoggerName;
    int mLevel;
    std::ostringstream mOutStream;

  public:
    DLogger(int level, std::string const& loggerName);
    ~DLogger();

    template <class T>
    DLogger &operator<<(const T &value)
    {
        mOutStream << value;
        return *this;
    }
};
}
