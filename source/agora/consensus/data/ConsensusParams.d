/*******************************************************************************

    The set for consensus-critical constants

    This defines the class for the consensus-critical constants. Only one
    object should exist for a single node. The `class` is `immutable`, hence
    the constants need to be set at the start of the process. The
    consensus-critical constants are the protocol-level constants, so they
    shouldn't be modified outside of test environments.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.ConsensusParams;

/// Ditto
public immutable class ConsensusParams
{
    /// The cycle length for a validator
    public uint ValidatorCycle;

    /***************************************************************************

        Constructor

        Params:
            validator_cycle = cycle length for a validator

    ***************************************************************************/

    public this (uint validator_cycle = 1008)
    {
        this.ValidatorCycle = validator_cycle;
    }
}
