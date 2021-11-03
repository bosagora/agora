# Build Agora from source
FROM bosagora/agora-builder:latest AS Builder
ARG DUB_OPTIONS
ARG AGORA_STANDALONE
ARG AGORA_VERSION="HEAD"
ADD . /root/agora/
WORKDIR /root/agora/talos/
RUN if [ -z ${AGORA_STANDALONE+x} ]; then npm ci && npm run build; else mkdir -p build; fi
WORKDIR /root/agora/
# Build Agora
RUN AGORA_VERSION=${AGORA_VERSION} dub build --skip-registry=all --compiler=ldc2 ${DUB_OPTIONS}
# Then build related utilities if not in standalone mode
# Otherwise, copy the placeholder script as Dockerfile don't support conditional copy
RUN if [ -z ${AGORA_STANDALONE+x} ]; then dub build --skip-registry=all --compiler=ldc2 -c client; \
    else cp -v scripts/cli_placeholder.sh build/agora-client; fi
RUN if [ -z ${AGORA_STANDALONE+x} ]; then dub build --skip-registry=all --compiler=ldc2 -c config-dumper; \
    else cp -v scripts/cli_placeholder.sh build/agora-config-dumper; fi

# Runner
# Uses edge as we need the same `ldc-runtime` as the LDC that compiled Agora,
# and `bosagora/agora-builder:latest` uses edge.
FROM alpine:edge
# The following makes debugging Agora much easier on server
# Since it's a tiny configuration file read by GDB at init, it won't affect release build
COPY devel/dotgdbinit /root/.gdbinit
RUN apk --no-cache add ldc-runtime llvm-libunwind libgcc libsodium libstdc++ sqlite-libs
COPY --from=Builder /root/agora/talos/build/ /usr/share/agora/talos/
COPY --from=Builder /root/agora/build/agora /usr/local/bin/agora
COPY --from=Builder /root/agora/build/agora-client /usr/local/bin/agora-client
COPY --from=Builder /root/agora/build/agora-config-dumper /usr/local/bin/agora-config-dumper
WORKDIR /agora/
ENTRYPOINT [ "/usr/local/bin/agora" ]
