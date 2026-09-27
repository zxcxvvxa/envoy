FROM teddysun/xray:latest AS xray-bin

FROM envoyproxy/envoy:v1.31.10

ENV TZ=Asia/Shanghai
ENV PORT=8080

# Install supervisor, procps (provides sysctl command), and required utilities
RUN apt-get update && \
    apt-get install -y --no-install-recommends supervisor procps && \
    rm -rf /var/lib/apt/lists/*

# Copy Xray binary from multi-stage builder
COPY --from=xray-bin /usr/bin/xray /usr/local/bin/

# Copy configuration files and entrypoint script
COPY config.json /etc/xray.json
COPY envoy.yaml /etc/envoy/envoy.yaml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Set executable permissions
RUN chmod +x /usr/local/bin/xray /usr/local/bin/entrypoint.sh && \
    chmod 644 /etc/xray.json /etc/envoy/envoy.yaml /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

# Run entrypoint.sh first, which then executes supervisord
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
