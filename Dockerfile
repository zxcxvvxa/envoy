FROM teddysun/xray:latest AS xray-bin

FROM envoyproxy/envoy:v1.31-latest

ENV TZ=Asia/Shanghai

# Install supervisor, procps, python3, and required dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends supervisor procps ca-certificates python3 python3-pip && \
    rm -rf /var/lib/apt/lists/*

# Copy Xray binary from builder stage
COPY --from=xray-bin /usr/bin/xray /usr/local/bin/

# Copy configuration files, server scripts, and entrypoints
COPY config.json /etc/xray.json
COPY envoy.yaml /etc/envoy/envoy.yaml
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY sub_server.py /usr/local/bin/sub_server.py

# Apply execution and file permissions
RUN chmod +x /usr/local/bin/xray /usr/local/bin/entrypoint.sh /usr/local/bin/sub_server.py && \
    chmod 644 /etc/xray.json /etc/envoy/envoy.yaml /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
