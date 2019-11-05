# Build Agora from source
FROM alpine:edge AS Builder
ARG DUB_OPTIONS
RUN apk --no-cache add build-base git libsodium-dev openssl openssl-dev sqlite-dev zlib-dev
RUN apk --no-cache add -X http://dl-cdn.alpinelinux.org/alpine/edge/testing ldc ldc-static dtools-rdmd dub
ADD . /root/agora/
WORKDIR /root/agora/
RUN dub build --skip-registry=all --compiler=ldc2 ${DUB_OPTIONS}

# Runner
FROM alpine:edge
COPY --from=Builder /root/agora/build/agora /root/agora
RUN apk --no-cache add libexecinfo libgcc libsodium libstdc++ sqlite-libs
WORKDIR /root/
ENTRYPOINT [ "/root/agora" ]
