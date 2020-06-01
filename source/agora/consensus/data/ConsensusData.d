/*******************************************************************************

    Defines the data used when reaching consensus.

    Copyright:
        Copyright (c) 2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.ConsensusData;

import agora.consensus.data.Enrollment;
import agora.consensus.data.Transaction;

/// Consensus data which is nominated & voted on
public struct ConsensusData
{
    /// The transaction set that is being nominated / voted on
    public Transaction[] tx_set;

    /// The enrollments that are being nominated / voted on
    public Enrollment[] enrolls;
}

/// ConsensusData type testSymmetry check
unittest
{
    import agora.common.Serializer;
    import agora.common.Types;
    import agora.consensus.data.genesis.Test;

    testSymmetry!ConsensusData();

    Hash key = Hash("0x000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f" ~
                    "1b60a8ce26f000000000019d6689c085ae165831e934ff763ae46a2" ~
                    "a6c172b3f1b60a8ce26f");
    Hash seed = Hash("0X4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E2CC77AB212" ~
                     "7B7AFDEDA33B4A5E1E4BAAB89F3A32518A88C31BC87F618F76673E" ~
                     "2CC77AB2127B7AFDEDA33B");
    Signature sig = Signature("0x000000000000000000016f605ea9638d7bff58d2c0c" ~
                              "c2467c18e38b36367be78000000000000000000016f60" ~
                              "5ea9638d7bff58d2c0cc2467c18e38b36367be78");
    const Enrollment record = {
        utxo_key: key,
        random_seed: seed,
        cycle_length: 1008,
        enroll_sig: sig,
    };

    const(ConsensusData) data =
    {
        tx_set:  GenesisBlock.txs,
        enrolls: [ record, record, ],
    };

    testSymmetry(data);
}
