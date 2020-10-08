/*******************************************************************************

    Stats corresponding to Blocks

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.stats.Tx;

import agora.stats.Stats;

///
public struct TxStatsLabel
{
}

///
public struct TxStatsValue
{
    public ulong agora_transactions_received_total;
    public ulong agora_transactions_accepted_total;
    public ulong agora_transactions_rejected_total;
    public ulong agora_transactions_poolsize_gauge;
    public ulong agora_transactions_amount_gauge;
}

///
public alias TxStats = Stats!(TxStatsValue, TxStatsLabel);
