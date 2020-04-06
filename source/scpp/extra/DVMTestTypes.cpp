/*******************************************************************************

    Contains classes to check the offset of virtual methods.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

#include "DVMTestTypes.h"

void export_classes ()
{
    auto pF1A = &TestA::vfunc1;
    auto pF1B = &TestB::vfunc1;
}
