ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.0.1
FROM $BUILD_FROM

# Build arguments for version
ARG HULY_VERSION=0.7.375

# Install requirements
# Upgrade first to resolve base image package version mismatches (e.g. libcrypto3/libssl3)
RUN \
    apk upgrade --no-cache \
    && apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        docker-cli \
        docker-cli-compose \
        jq \
        openssl

# Copy root filesystem
COPY rootfs /

# Ensure scripts are executable
RUN chmod a+x /etc/cont-init.d/*.sh \
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
    maintainer="Huly for Home Assistant" \
    huly.version="${HULY_VERSION}" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Add-ons" \
    org.opencontainers.image.authors="Huly for Home Assistant" \
    org.opencontainers.image.licenses="EPL-2.0" \
    org.opencontainers.image.url="https://huly.io/" \
    org.opencontainers.image.source="https://github.com/hcengineering/huly-selfhost" \
    org.opencontainers.image.documentation="https://docs.huly.io/" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
