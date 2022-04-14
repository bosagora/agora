# Build Agora from source
FROM bosagora/agora-builder:latest AS Builder
ARG DUB_OPTIONS
ARG AGORA_STANDALONE
ARG AGORA_VERSION="HEAD"
ADD . /root/agora/
WORKDIR /root/agora/talos/
RUN if [ -z ${AGORA_STANDALONE+x} ]; then npm ci && npm run build; else mkdir -p build; fi
WORKDIR /
RUN wget https://github.com/wasmerio/wasmer/releases/download/2.1.1/wasmer-linux-musl-amd64.tar.gz
RUN tar -zxvf wasmer-linux-musl-amd64.tar.gz
RUN wasmer -V
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
FROM alpine:3.15
WORKDIR /
RUN wget https://github.com/wasmerio/wasmer/releases/download/2.1.1/wasmer-linux-musl-amd64.tar.gz
RUN tar -zxvf wasmer-linux-musl-amd64.tar.gz
RUN wasmer -V
# The following makes debugging Agora much easier on server
# Since it's a tiny configuration file read by GDB at init, it won't affect release build
COPY devel/dotgdbinit /root/.gdbinit
COPY --from=Builder /root/packages/ /root/packages/
RUN apk --no-cache add --allow-untrusted -X /root/packages/build/ ldc-runtime=1.28.1-r0 \
    && rm -rf /root/packages/
RUN apk --no-cache add llvm-libunwind libgcc libsodium libstdc++ sqlite-libs
COPY --from=Builder /root/agora/talos/build/ /usr/share/agora/talos/
COPY --from=Builder /root/agora/build/agora /usr/local/bin/agora
COPY --from=Builder /root/agora/build/agora-client /usr/local/bin/agora-client
COPY --from=Builder /root/agora/build/agora-config-dumper /usr/local/bin/agora-config-dumper
WORKDIR /agora/
ENTRYPOINT [ "/usr/local/bin/agora" ]
