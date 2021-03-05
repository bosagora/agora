# The following environment variables will be available in integration tests
# See `ci/system_integration_test.d` to see how this is used.

# When running in Github's CI, Tracy fails to initialize with this message:
# https://github.com/wolfpld/tracy/blob/57d636f2432048d6b209568afb3b8ec90d0aafae/client/TracyProfiler.cpp#L241
# This is specific to the environment exposed by the VM and might not trigger on your machine.
TRACY_NO_INVARIANT_CHECK=1
