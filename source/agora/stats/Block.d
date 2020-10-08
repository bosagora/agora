/*******************************************************************************

    Stats corresponding to blocks

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Block;

import agora.stats.Stats;

///
public struct BlockStatsLabel
{
}

///
public struct BlockStatsValue
{
    public ulong agora_block_externalized_total;
    public ulong agora_block_enrollments_gauge;
    public ulong agora_block_txs_total;
    public ulong agora_block_txs_amount_total;
}

///
public alias BlockStats = Stats!(BlockStatsValue, BlockStatsLabel);
