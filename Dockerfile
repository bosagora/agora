# Build Agora from source
FROM alpine:3.10.1 AS Builder
ARG DUB_OPTIONS
RUN apk --no-cache add binutils-gold build-base git libsodium-dev openssl openssl-dev sqlite-dev zlib-dev
COPY --from=bpfk/pkgbuilder:v3.10.1 --chown=root:root /home/effortman/.abuild/*.rsa.pub /etc/apk/keys/
COPY --from=bpfk/ldc:v1.18.0 /root/packages/ /root/packages/
COPY --from=bpfk/dub:v1.18.0 /root/packages/ /root/packages/
RUN apk --no-cache add /root/packages/effortman/x86_64/ldc-1.18.0-r0.apk \
    /root/packages/effortman/x86_64/ldc-runtime-1.18.0-r0.apk \
    /root/packages/effortman/x86_64/ldc-static-1.18.0-r0.apk \
    /root/packages/effortman/x86_64/dub-1.18.0_beta1-r0.apk \
    /root/packages/effortman/x86_64/dtools-rdmd-2.087.1-r0.apk \
    && rm -rf /root/packages/
ADD . /root/agora/
WORKDIR /root/agora/
RUN dub build --skip-registry=all --compiler=ldc2 ${DUB_OPTIONS}

# Runner
FROM alpine:3.10.1
COPY --from=Builder /root/agora/build/agora /root/agora
RUN apk --no-cache add libexecinfo libgcc libsodium libstdc++ sqlite-libs
WORKDIR /root/
ENTRYPOINT [ "/root/agora" ]
