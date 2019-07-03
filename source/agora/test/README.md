# Agora test folder

This folder contains network tests for Agora.
Network tests are the second layer of tests in our 3 layers test architecture,
the first one being unit tests, and the last one integration tests.
They are implemented in `unittest` blocks but are more involved than unit tests.

Network tests involve the `localrest` library, which simulates a network situation,
and a task manager. The core idea is that localrest spawns a thread per "remote node",
and allows a client, living in the main thread, to make requests to one or more
of those remote nodes. They then communicate with each other via message passing.
This approach is surprisingly efficient to model a node's behavior,
and also forces a design where the network code is decoupled from the business code.

When adding a test, a good starting point is to look at `agora.test.Base`,
a module that provides basic functionality to write tests.
Note that this approach requires careful design of the business code.
For example, when writing tasks, one has to use the `TaskManager`,
and not directly what Vibe.d provides.
Additionally, any IO-using classes must expose a way to override the IO behavior,
e.g. `NetworkManager` exposes `getClient` in order to get a client to an address.
In regular code this uses Vibe.d, while it uses LocalRest in test code.

For a more complete example, see `agora.test.Network`.
Other tests might use more complex functionalities, such as the ability to filter
some methods, or pause a node for some time. See `localrest` documentation for more.
