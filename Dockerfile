# Build Agora from source
FROM alpine:edge AS Builder
ARG DUB_OPTIONS
RUN apk --no-cache add build-base dtools-rdmd dub git ldc libsodium-dev openssl openssl-dev sqlite-dev zlib-dev
ADD . /root/agora/
WORKDIR /root/agora/
RUN dub build --skip-registry=all --compiler=ldc2 ${DUB_OPTIONS}

# Runner
FROM alpine:edge
RUN apk --no-cache add ldc-runtime libexecinfo libgcc libsodium libstdc++ sqlite-libs
COPY --from=Builder /root/agora/build/agora /usr/local/bin/agora
WORKDIR /agora/
ENTRYPOINT [ "/usr/local/bin/agora" ]
