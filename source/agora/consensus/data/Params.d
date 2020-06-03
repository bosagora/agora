/*******************************************************************************

    Parameter set for consensus-critcal constants

    In order to set the consensus-critical constants in runtime and share them
    between every objects, we must provide only one parameter set. So we worked
    on this with the concept of the Singleton pattern in order to meet the
    requirements.

    The only `Params` object exists after being created with the `createParams`
    function that calls the constructor of the `Params` class.

    Copyright:
        Copyright (c) 2019-2020 BOS Platform Foundation Korea
        All rights reserved.

    License:
        MIT License. See LICENSE for details.

*******************************************************************************/

module agora.consensus.data.Params;

class Params
{
    /// Cache instantiation flag in thread-local bool
    /// Thread local
    private static bool instantiated_;

    /// Thread global
    private __gshared Params instance_;

    /// The cycle length for a validator
    /// freezing period / 2
    public immutable uint ValidatorCycle;

    /// The period for revealing a preimage
    /// It is an hour interval if a block is made in every 10 minutes
    public immutable uint PreimageRevealPeriod;

    /***************************************************************************

        Constructor

        Params:
            validator_cycle = cycle length for a validator
            preimage_reveal_period = period for revealing a preimage

    ***************************************************************************/

    private this (uint validator_cycle, uint preimage_reveal_period)
    {
        this.ValidatorCycle = validator_cycle;
        this.PreimageRevealPeriod = preimage_reveal_period;
    }

    /***************************************************************************

        Create a `Params` object with values for contansts.

        Params:
            validator_cycle = cycle length for a validator
            preimage_reveal_period = period for revealing a preimage

    ***************************************************************************/

    static void createParams (uint validator_cycle, uint preimage_reveal_period)
    {
        if (!instantiated_)
        {
            synchronized (Params.classinfo)
            {
                if (!instance_)
                {
                    instance_ = new Params(validator_cycle,
                        preimage_reveal_period);
                }
                instantiated_ = true;
            }
        }
    }

    /***************************************************************************

        Get the 'Params' instance.

        Returns:
            the only one `Param` instance.

    ***************************************************************************/

    static Params get ()
    {
        if (!instance_)
        {
            assert(0);
        }
        return instance_;
    }
}

unittest
{
    Params.createParams(1008, 6);
    assert(Params.get().ValidatorCycle == 1008);
    assert(Params.get().PreimageRevealPeriod == 6);
}
