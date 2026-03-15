# Global ARGs must be declared before the first FROM
ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.0.1
ARG MUNINNDB_VERSION=0.4.1-alpha

# Stage 1: Build MuninnDB from source with embedded ONNX model
# The release binary does NOT include the local embedder (-tags localassets).
# Building from source ensures semantic search works out of the box.
FROM golang:1.26-bookworm AS builder

ARG MUNINNDB_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl make ca-certificates nodejs npm \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Clone the specific release tag
RUN git clone --depth 1 --branch "v${MUNINNDB_VERSION}" \
    https://github.com/scrypster/muninndb.git .

# Detect target architecture for ORT library
ARG TARGETARCH

# Fetch ONNX model and platform-specific ORT native library
RUN make fetch-model _ort-linux-${TARGETARCH}

# Build web assets (Tailwind CSS via Vite)
RUN cd web && npm ci --ignore-scripts && npm run build

# Build the server binary WITH local assets embedded
RUN go build -tags localassets -ldflags="-s -w" -o /muninndb-server ./cmd/muninn/...

# Collect the glibc runtime libs the binary needs into a single directory.
# This handles both amd64 and aarch64 architectures transparently.
RUN mkdir -p /glibc-libs \
    && ARCH="$(uname -m)" \
    && if [ "${ARCH}" = "x86_64" ]; then \
        LIB_DIR="/lib/x86_64-linux-gnu"; \
        LD_PATH="/lib64/ld-linux-x86-64.so.2"; \
    elif [ "${ARCH}" = "aarch64" ]; then \
        LIB_DIR="/lib/aarch64-linux-gnu"; \
        LD_PATH="/lib/ld-linux-aarch64.so.1"; \
    fi \
    && cp "${LIB_DIR}/libc.so.6" /glibc-libs/ \
    && cp "${LIB_DIR}/libm.so.6" /glibc-libs/ \
    && cp "${LIB_DIR}/libdl.so.2" /glibc-libs/ \
    && cp "${LIB_DIR}/libpthread.so.0" /glibc-libs/ \
    && cp "${LIB_DIR}/librt.so.1" /glibc-libs/ \
    && cp "${LIB_DIR}/libgcc_s.so.1" /glibc-libs/ \
    && cp "${LIB_DIR}/libstdc++.so.6" /glibc-libs/ \
    && cp "${LD_PATH}" /glibc-libs/ld-linux.so \
    && echo "${LIB_DIR}" > /glibc-libs/.lib_dir \
    && echo "${LD_PATH}" > /glibc-libs/.ld_path

# Stage 2: Runtime image
FROM $BUILD_FROM

# Install requirements
# Upgrade first to resolve base image package version mismatches (e.g. libcrypto3/libssl3)
RUN \
    apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates \
        curl \
        jq

# Copy glibc runtime from the builder stage (Debian bookworm).
# MuninnDB is a CGO binary linked against glibc for ONNX Runtime, but Alpine
# uses musl. Copying the exact glibc that the binary was compiled against
# avoids third-party compatibility packages.
COPY --from=builder /glibc-libs /tmp/glibc-libs
RUN LIB_DIR=$(cat /tmp/glibc-libs/.lib_dir) \
    && LD_PATH=$(cat /tmp/glibc-libs/.ld_path) \
    && mkdir -p "${LIB_DIR}" "$(dirname "${LD_PATH}")" \
    && cp /tmp/glibc-libs/libc.so.6 "${LIB_DIR}/" \
    && cp /tmp/glibc-libs/libm.so.6 "${LIB_DIR}/" \
    && cp /tmp/glibc-libs/libdl.so.2 "${LIB_DIR}/" \
    && cp /tmp/glibc-libs/libpthread.so.0 "${LIB_DIR}/" \
    && cp /tmp/glibc-libs/librt.so.1 "${LIB_DIR}/" \
    && cp /tmp/glibc-libs/libgcc_s.so.1 "${LIB_DIR}/" \
    && cp /tmp/glibc-libs/libstdc++.so.6 "${LIB_DIR}/" \
    && cp /tmp/glibc-libs/ld-linux.so "${LD_PATH}" \
    && rm -rf /tmp/glibc-libs

# Copy the built binary from the builder stage
RUN mkdir -p /opt/muninndb
COPY --from=builder /muninndb-server /opt/muninndb/muninn
RUN chmod +x /opt/muninndb/muninn \
    && echo "MuninnDB installed successfully" \
    && ls -lh /opt/muninndb/muninn

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
ARG MUNINNDB_VERSION

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
