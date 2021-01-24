# Build Agora from source
FROM bpfk/agora-builder:latest AS Builder
ARG DUB_OPTIONS
ARG AGORA_VERSION="HEAD"
ADD . /root/agora/
WORKDIR /root/agora/
RUN apk --no-cache add linux-headers
RUN AGORA_VERSION=${AGORA_VERSION} dub build --skip-registry=all --compiler=ldc2 ${DUB_OPTIONS}

# Runner
# Uses edge as we need the same `ldc-runtime` as the LDC that compiled Agora,
# and `bpfk/agora-builder:latest` uses edge.
FROM alpine:edge
RUN apk --no-cache add ldc-runtime llvm-libunwind libgcc libsodium libstdc++ sqlite-libs
COPY --from=Builder /root/agora/build/agora /usr/local/bin/agora
WORKDIR /agora/
ENTRYPOINT [ "/usr/local/bin/agora" ]
