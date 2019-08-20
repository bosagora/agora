# Build Agora from source
FROM alpine:3.10.1 AS Builder
RUN apk --no-cache add build-base git libsodium-dev openssl-dev sqlite-dev zlib-dev
COPY --from=bpfk/pkgbuilder:latest --chown=root:root /home/effortman/.abuild/*.rsa.pub /etc/apk/keys/
COPY --from=bpfk/ldc:latest /root/packages/ /root/packages/
COPY --from=bpfk/dub:latest /root/packages/ /root/packages/
RUN apk --no-cache add /root/packages/effortman/x86_64/ldc-1.16.0-r0.apk \
    /root/packages/effortman/x86_64/ldc-runtime-1.16.0-r0.apk \
    /root/packages/effortman/x86_64/ldc-static-1.16.0-r0.apk \
    /root/packages/effortman/x86_64/dub-1.16.0-r0.apk \
    /root/packages/effortman/x86_64/dtools-rdmd-2.087.1-r0.apk \
    && rm -rf /root/packages/
ADD . /root/agora/
WORKDIR /root/agora/
RUN dub build --compiler=ldc2 --override-config vibe-d:tls/openssl-1.1

# Runner
FROM alpine:3.10.1
COPY --from=Builder /root/agora/build/agora /root/agora
RUN apk --no-cache add libgcc libsodium libstdc++ sqlite-libs
ENTRYPOINT [ "/root/agora" ]
