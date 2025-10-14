ARG BUILD_FROM
FROM $BUILD_FROM

# Build arguments for version
ARG DOCKGE_VERSION=1.5.0

# Install requirements and Node.js
RUN \
    apk add --no-cache \
        bash \
        ca-certificates \
        curl \
        jq \
        nodejs \
        npm \
        git

# Install Dockge
WORKDIR /app
RUN \
    git clone --branch ${DOCKGE_VERSION} https://github.com/louislam/dockge.git /tmp/dockge \
    && cd /tmp/dockge \
    && npm ci --production \
    && npm run build \
    && mv /tmp/dockge/backend /app/ \
    && mv /tmp/dockge/frontend /app/ \
    && mv /tmp/dockge/node_modules /app/ \
    && mv /tmp/dockge/package.json /app/ \
    && rm -rf /tmp/dockge

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
    maintainer="Dockge for Home Assistant" \
    dockge.version="${DOCKGE_VERSION}" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Add-ons" \
    org.opencontainers.image.authors="Dockge for Home Assistant" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://github.com/louislam/dockge" \
    org.opencontainers.image.source="https://github.com/louislam/dockge" \
    org.opencontainers.image.documentation="https://github.com/louislam/dockge" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
