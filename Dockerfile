FROM teddysun/xray:latest AS xray-bin

# FIX: Replaced 'latest' with a valid tag format
FROM envoyproxy/envoy:v1.31-latest

ENV TZ=Asia/Shanghai
ENV PORT=8080

# Install supervisor, procps, and required tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends supervisor procps ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy Xray binary from builder stage
COPY --from=xray-bin /usr/bin/xray /usr/local/bin/

# Copy configuration files and scripts
COPY config.json /etc/xray.json
COPY envoy.yaml /etc/envoy/envoy.yaml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Apply execution and file permissions
RUN chmod +x /usr/local/bin/xray /usr/local/bin/entrypoint.sh && \
    chmod 644 /etc/xray.json /etc/envoy/envoy.yaml /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
