# Build Agora from source
FROM bosagora/agora-builder:latest AS Builder
ARG DUB_OPTIONS
ARG AGORA_VERSION="HEAD"
RUN apk --no-cache add linux-headers python3 npm
ADD . /root/agora/
WORKDIR /root/agora/talos/
RUN npm ci && npm run build
WORKDIR /root/agora/
RUN AGORA_VERSION=${AGORA_VERSION} dub build --skip-registry=all --compiler=ldc2 ${DUB_OPTIONS}
RUN dub build --skip-registry=all --compiler=ldc2 -c config-dumper

# Runner
# Uses edge as we need the same `ldc-runtime` as the LDC that compiled Agora,
# and `bosagora/agora-builder:latest` uses edge.
FROM alpine:edge
# The following makes debugging Agora much easier on server
# Since it's a tiny configuration file read by GDB at init, it won't affect release build
COPY devel/dotgdbinit /root/.gdbinit
COPY --from=Builder /root/packages/ /root/packages/
RUN apk --no-cache add --allow-untrusted -X /root/packages/build/ ldc-runtime=1.26.0-r0 \
    && rm -rf /root/packages/
RUN apk --no-cache add llvm-libunwind libgcc libsodium libstdc++ sqlite-libs
COPY --from=Builder /root/agora/talos/build/ /usr/share/agora/talos/
COPY --from=Builder /root/agora/build/agora /usr/local/bin/agora
COPY --from=Builder /root/agora/build/agora-config-dumper /usr/local/bin/agora-config-dumper
WORKDIR /agora/
ENTRYPOINT [ "/usr/local/bin/agora" ]
