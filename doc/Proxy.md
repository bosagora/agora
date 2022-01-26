## Agora behind a reverse proxy (Incoming connections)

Agora communicates with other nodes through its configured `interfaces` which can be
either HTTP or RPC (TCP) based. Some configurations might require putting an Agora
node behind a reverse proxy. However, an Agora node depends on a ban manager to
temporarily disable communications with bad-behaving nodes. Those nodes are
banned through their public addresses. An Agora node cannot know public address
of a peer when it is behind a reverse proxy with a default configuration.

Agora supports [Proxy Protocol V1](http://www.haproxy.org/download/1.8/doc/proxy-protocol.txt)
for RPC interfaces. Proxy Protocol allows an Agora node to know public address
of the peer even it is behind a reverse proxy.

Only RPC interfaces and Proxy Protocol (V1) is supported. Preferred reverse proxy
implementation must support proxy for TCP streams and Proxy Protocol (V1).
Protocol mismatch or misconfigurations will result in Agora node to fail with
error message informing about the reason.

### Enabling Proxy Protocol on Agora

Add `proxy_proto: true` field for the TCP interface that will be proxied. See the
`config.example.yaml` for an example.
HTTP interfaces (`Forwarded` headers) are not supported yet.

### Enabling Proxy Protocol on a Reverse Proxy

Configuration may differ between reverse proxy implementations, provided example
is for Nginx.

Add a `stream` configuration:

```
stream {
    server {
        listen <ip>:<port>;
        proxy_pass 127.0.0.1:<agora_tcp_port>;
        proxy_protocol on;
    }
}
```

For more information, see the [Nginx documentation.](https://docs.nginx.com/nginx/admin-guide/load-balancer/using-proxy-protocol/)
