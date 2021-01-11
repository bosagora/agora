# Build Agora from source
FROM bpfk/agora-builder:latest AS Builder
ARG DUB_OPTIONS
ARG AGORA_VERSION="HEAD"
ADD . /root/agora/
WORKDIR /root/agora/
RUN apk --no-cache add llvm-libunwind-dev
RUN AGORA_VERSION=${AGORA_VERSION} dub build --skip-registry=all --compiler=ldc2 ${DUB_OPTIONS}

# Runner
FROM alpine:3.12.0
RUN apk --no-cache add ldc-runtime libexecinfo llvm-libunwind libgcc libsodium libstdc++ sqlite-libs
COPY --from=Builder /root/agora/build/agora /usr/local/bin/agora
WORKDIR /agora/
ENTRYPOINT [ "/usr/local/bin/agora" ]
