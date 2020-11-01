# Consensus package

The consensus package is aimed to be usable as a library by client code.
It contains the definitions of the data types that are exchanged and stored,
as well as the state a full node must keep.

This classification derives from framing the problem as [state machine replication](https://en.wikipedia.org/wiki/State_machine_replication).

Following the state machine's definition, we associate the following components:
- **States**: `ValidatorSet` & `UTXOSet` represent the node's view of the network;
- **Inputs**: The content of the blocks (`Block`, `Enrollment`, `Transaction`);
- **Outputs**: In our system, output is equal to state, so there's no distinction;
- **Transition function**: Most of the mutation methods in `state` (e.g. applying transactions to `UTXOSet`) and the content of the `validation` package;
- **Output function**: Like outputs, we don't have a separate representation for this;
- **Start**: This is simply the genesis block.

Our **Inputs** also includes some specific items, such as `agora.consensus.data.Params`,
which should be constant for the lifetime of the machine, but is used to tweak behavior in tests.
