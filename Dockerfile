ARG PG_VERSION=16
FROM postgres:${PG_VERSION}

ARG WALG_VERSION=v3.0.9

USER root

RUN set -eux; \
    if [ -f /etc/alpine-release ]; then \
        apk add --no-cache \
            curl \
            ca-certificates \
            tar \
            lz4 \
            gcompat \
            libc6-compat; \
    else \
        apt-get update; \
        apt-get install -y --no-install-recommends \
            curl \
            ca-certificates \
            tar \
            lz4 \
            daemontools; \
        rm -rf /var/lib/apt/lists/*; \
    fi; \
    \
    ARCH="$(dpkg --print-architecture 2>/dev/null || uname -m)"; \
    case "$ARCH" in \
        x86_64|amd64) WALG_ARCH="amd64" ;; \
        aarch64|arm64) WALG_ARCH="aarch64" ;; \
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac; \
    \
    URL="https://github.com/wal-g/wal-g/releases/download/${WALG_VERSION}/wal-g-pg-22.04-${WALG_ARCH}.tar.gz"; \
    curl -fsSL "$URL" -o /tmp/wal-g.tar.gz; \
    \
    tar -xzf /tmp/wal-g.tar.gz -C /tmp/; \
    mv /tmp/wal-g-pg-* /usr/local/bin/wal-g; \
    chmod +x /usr/local/bin/wal-g; \
    rm -rf /tmp/*; \
    \
    wal-g --version
