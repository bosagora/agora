/*******************************************************************************

    Stats corresponding to endpoint requests

    Copyright:
        Copyright (c) 2019-2021 BOSAGORA Foundation
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.EndpointReq;

import agora.stats.Stats;

///
public struct EndpointReqStatsLabel
{
    public string endpoint;
    public string protocol;
}

///
public struct EndpointReqStatsValue
{
    public ulong agora_endpoint_calls_total;
}

///
public alias EndpointRequestStats = Stats!(EndpointReqStatsValue, EndpointReqStatsLabel);
