ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.0.1
FROM $BUILD_FROM

# Build arguments for version
ARG MUNINNDB_VERSION=0.4.1-alpha

# Install requirements
# Upgrade first to resolve base image package version mismatches (e.g. libcrypto3/libssl3)
# gcompat + libstdc++: MuninnDB is a CGO binary linked against glibc (ONNX runtime embedder),
# but Alpine uses musl — gcompat provides the glibc compatibility shim
RUN \
    apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates \
        curl \
        gcompat \
        jq \
        libstdc++

# Download and install MuninnDB
# Release assets are raw binaries named: muninn-linux-amd64, muninn-linux-arm64
RUN \
    mkdir -p /opt/muninndb \
    && ARCH="$(uname -m)" \
    && if [ "${ARCH}" = "aarch64" ]; then \
        MUNINN_ARCH="arm64"; \
    elif [ "${ARCH}" = "x86_64" ]; then \
        MUNINN_ARCH="amd64"; \
    else \
        echo "Unsupported architecture: ${ARCH}"; \
        exit 1; \
    fi \
    && echo "Downloading MuninnDB v${MUNINNDB_VERSION} for ${MUNINN_ARCH}..." \
    && curl -L -f -S -o /opt/muninndb/muninn \
        "https://github.com/scrypster/muninndb/releases/download/v${MUNINNDB_VERSION}/muninn-linux-${MUNINN_ARCH}" \
    && echo "Download complete. File size:" && ls -lh /opt/muninndb/muninn \
    && chmod +x /opt/muninndb/muninn \
    && echo "MuninnDB installed successfully"

# Copy root filesystem
COPY rootfs /

# Ensure scripts are executable
RUN chmod a+x /etc/cont-init.d/*.sh \
    && chmod a+x /etc/cont-finish.d/*.sh \
    && chmod a+x /etc/services.d/*/run \
    && chmod a+x /etc/services.d/*/finish

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="MuninnDB for Home Assistant" \
    muninndb.version="${MUNINNDB_VERSION}" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Add-ons" \
    org.opencontainers.image.authors="MuninnDB for Home Assistant" \
    org.opencontainers.image.licenses="BSL-1.1" \
    org.opencontainers.image.url="https://muninndb.com" \
    org.opencontainers.image.source="https://github.com/scrypster/muninndb" \
    org.opencontainers.image.documentation="https://muninndb.com/docs" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
