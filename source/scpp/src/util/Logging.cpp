// Copyright 2014 Stellar Development Foundation and contributors. Licensed
// under the Apache License, Version 2.0. See the COPYING file at the root
// of this distribution or at http://www.apache.org/licenses/LICENSE-2.0

#include <cstdarg>
#include <iostream>
#include <vector>
#include "Logging.h"

using namespace std;

namespace stellar
{
DLogger::DLogger(int level, std::string const& loggerName)
{
    mLevel = level;
    mLoggerName = std::string(loggerName);
}

DLogger::~DLogger()
{
    writeDLog(mLoggerName.c_str(), mLevel, mOutStream.str().c_str());
}
}
