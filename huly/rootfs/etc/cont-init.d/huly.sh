#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Huly
# Initializes Huly configuration and data directories
# ==============================================================================
bashio::require.unprotected

bashio::log.debug "Huly init script starting..."
bashio::log.debug "Architecture: $(uname -m)"
bashio::log.debug "Kernel: $(uname -r)"

# Create data directories for all Huly services
bashio::log.info "Creating data directories..."
for dir in /data/huly /data/huly/cockroach /data/huly/cockroach-certs \
           /data/huly/elastic /data/huly/minio /data/huly/redpanda; do
    mkdir -p "${dir}"
    chmod 755 "${dir}"
    bashio::log.debug "Created directory: ${dir}"
done

# Generate secrets if they don't exist
SECRETS_FILE="/data/huly/.secrets"
if [[ ! -f "${SECRETS_FILE}" ]]; then
    bashio::log.info "Generating Huly secrets..."
    SECRET=$(openssl rand -hex 32)
    CR_USER_PASSWORD=$(openssl rand -hex 16)
    REDPANDA_ADMIN_PWD=$(openssl rand -hex 16)
    cat > "${SECRETS_FILE}" << EOF
SECRET=${SECRET}
CR_USER_PASSWORD=${CR_USER_PASSWORD}
REDPANDA_ADMIN_PWD=${REDPANDA_ADMIN_PWD}
EOF
    chmod 600 "${SECRETS_FILE}"
    bashio::log.info "Secrets generated and saved"
else
    bashio::log.info "Using existing secrets"
fi

# Check Docker socket
if [[ -S /var/run/docker.sock ]]; then
    bashio::log.info "Docker socket found at /var/run/docker.sock"
    bashio::log.debug "Docker socket permissions: $(ls -la /var/run/docker.sock)"
elif [[ -S /run/docker.sock ]]; then
    bashio::log.info "Docker socket found at /run/docker.sock"
    bashio::log.debug "Docker socket permissions: $(ls -la /run/docker.sock)"
else
    bashio::log.error "Docker socket not found! Huly requires Docker access."
    bashio::log.error "Please ensure the addon has the proper permissions."
fi

# Resolve the host-side path for /data.
# Inside the addon container /data is a bind mount from the host. Sub-containers
# spawned via Docker Compose are created by the HOST Docker daemon, so their
# bind-mount paths must reference the real host path, not the container path.
#
# In HAOS the Docker inspect source for /data returns a path like
# /supervisor/addons/data/<slug> — but that's relative to the data partition,
# NOT the host root. The host root is read-only; the data partition is mounted
# at e.g. /mnt/data. We discover the data partition mount point from Docker's
# own DockerRootDir (typically /mnt/data/docker → prefix is /mnt/data).
#
# NOTE: We avoid Alpine's docker-cli entirely (segfaults on aarch64, docker/cli#4900).
HOST_DATA_PATH=""
DATA_PARTITION_PREFIX=""

# Step 1: Discover the HAOS data partition prefix from Docker's root dir.
# DockerRootDir is typically /mnt/data/docker — strip the /docker suffix.
bashio::log.info "Discovering HAOS data partition layout..."
DOCKER_INFO=$(curl -s --unix-socket /var/run/docker.sock \
    "http://localhost/info" 2>/dev/null) || true
if [[ -n "${DOCKER_INFO}" ]]; then
    DOCKER_ROOT_DIR=$(echo "${DOCKER_INFO}" | jq -r '.DockerRootDir // empty' 2>/dev/null) || true
    bashio::log.debug "DockerRootDir: '${DOCKER_ROOT_DIR}'"
    # Strip the trailing /docker to get the data partition mount point
    if [[ "${DOCKER_ROOT_DIR}" == */docker ]]; then
        DATA_PARTITION_PREFIX="${DOCKER_ROOT_DIR%/docker}"
        bashio::log.debug "Data partition prefix: '${DATA_PARTITION_PREFIX}'"
    fi
fi

# Step 2: Get the /data mount source from container inspect.
CONTAINER_ID="$(hostname)"
bashio::log.info "Resolving host data path (container: ${CONTAINER_ID})..."
bashio::log.debug "Querying Docker API: /containers/${CONTAINER_ID}/json"
INSPECT_JSON=$(curl -s --unix-socket /var/run/docker.sock \
    "http://localhost/containers/${CONTAINER_ID}/json" 2>/dev/null) || true
if [[ -n "${INSPECT_JSON}" ]]; then
    bashio::log.debug "Docker API response received (${#INSPECT_JSON} bytes)"
    bashio::log.debug "All mounts: $(echo "${INSPECT_JSON}" | jq -c '[.Mounts[] | {Source, Destination}]' 2>/dev/null)" || true
    MOUNT_SOURCE=$(echo "${INSPECT_JSON}" \
        | jq -r '.Mounts[] | select(.Destination == "/data") | .Source' 2>/dev/null) || true
    bashio::log.debug "Extracted /data mount source: '${MOUNT_SOURCE}'"

    if [[ -n "${MOUNT_SOURCE}" ]]; then
        # If the mount source already starts with the data partition prefix, use as-is.
        # Otherwise, prepend the prefix (HAOS stores paths relative to the data partition).
        if [[ -n "${DATA_PARTITION_PREFIX}" && "${MOUNT_SOURCE}" != "${DATA_PARTITION_PREFIX}"* ]]; then
            HOST_DATA_PATH="${DATA_PARTITION_PREFIX}${MOUNT_SOURCE}"
            bashio::log.debug "Prepended data partition prefix: '${HOST_DATA_PATH}'"
        else
            HOST_DATA_PATH="${MOUNT_SOURCE}"
        fi
    fi
else
    bashio::log.debug "Docker API returned empty response"
fi

# Step 3: Parse /proc/self/mountinfo as fallback.
if [[ -z "${HOST_DATA_PATH}" ]]; then
    bashio::log.warning "Docker API lookup failed, trying /proc/self/mountinfo..."
    bashio::log.debug "/proc/self/mountinfo /data entries:"
    bashio::log.debug "$(grep ' /data ' /proc/self/mountinfo 2>/dev/null)" || true
    MOUNT_ROOT=$(awk '$5 == "/data" { print $4; exit }' /proc/self/mountinfo 2>/dev/null) || true
    bashio::log.debug "mountinfo root field: '${MOUNT_ROOT}'"
    if [[ -n "${MOUNT_ROOT}" && "${MOUNT_ROOT}" != "/" ]]; then
        if [[ -n "${DATA_PARTITION_PREFIX}" ]]; then
            HOST_DATA_PATH="${DATA_PARTITION_PREFIX}${MOUNT_ROOT}"
        else
            HOST_DATA_PATH="${MOUNT_ROOT}"
        fi
    fi
fi

if [[ -z "${HOST_DATA_PATH}" || "${HOST_DATA_PATH}" == "/" ]]; then
    bashio::log.error "Could not determine host path for /data — volume mounts will fail."
    bashio::log.error "Falling back to /data (will only work if /data is a real host path)."
    HOST_DATA_PATH="/data"
else
    bashio::log.info "Resolved host data path: ${HOST_DATA_PATH}"
fi

# Verify docker compose is available
COMPOSE_VER=$(/usr/local/bin/docker-compose version 2>&1) || true
if [[ -n "${COMPOSE_VER}" ]]; then
    bashio::log.info "Docker Compose is available"
    bashio::log.debug "Docker Compose version: ${COMPOSE_VER}"
else
    bashio::log.error "Docker Compose not available!"
fi

# Read config values
bashio::log.info "Generating Huly configuration..."
HOST_ADDRESS=$(bashio::config 'host_address')
TITLE=$(bashio::config 'title')
DEFAULT_LANGUAGE=$(bashio::config 'default_language')
LAST_NAME_FIRST=$(bashio::config 'last_name_first')

# Source secrets
# shellcheck source=/dev/null
source "${SECRETS_FILE}"

# Determine HOST_ADDRESS - use config value or fall back to default
if bashio::var.has_value "${HOST_ADDRESS}"; then
    bashio::log.info "Using configured host address: ${HOST_ADDRESS}"
else
    HOST_ADDRESS="localhost:8087"
    bashio::log.info "No host_address configured, using default: ${HOST_ADDRESS}"
fi

# Determine HULY_VERSION from build arg or default
HULY_VERSION="${HULY_VERSION:-0.7.375}"

# Write the .env file for docker compose
bashio::log.info "Writing Huly environment configuration..."
cat > /data/huly/.env << EOF
# Huly version
HULY_VERSION=v${HULY_VERSION}
DOCKER_NAME=huly_ha

# Network
HOST_ADDRESS=${HOST_ADDRESS}
HTTP_PORT=80
HTTP_BIND=

# Huly settings
TITLE=${TITLE:-Huly}
DEFAULT_LANGUAGE=${DEFAULT_LANGUAGE:-en}
LAST_NAME_FIRST=${LAST_NAME_FIRST:-true}

# CockroachDB
CR_DATABASE=defaultdb
CR_USERNAME=selfhost
CR_USER_PASSWORD=${CR_USER_PASSWORD}
CR_DB_URL=postgres://selfhost:${CR_USER_PASSWORD}@cockroach:26257/defaultdb

# Redpanda
REDPANDA_ADMIN_USER=superadmin
REDPANDA_ADMIN_PWD=${REDPANDA_ADMIN_PWD}

# Secret
SECRET=${SECRET}

# Volumes (host-side paths for bind mounts into sub-containers)
VOLUME_CR_DATA_PATH=${HOST_DATA_PATH}/huly/cockroach
VOLUME_CR_CERTS_PATH=${HOST_DATA_PATH}/huly/cockroach-certs
VOLUME_ELASTIC_PATH=${HOST_DATA_PATH}/huly/elastic
VOLUME_FILES_PATH=${HOST_DATA_PATH}/huly/minio
VOLUME_REDPANDA_PATH=${HOST_DATA_PATH}/huly/redpanda

# Nginx config (host-side path for bind mount)
NGINX_CONF_PATH=${HOST_DATA_PATH}/huly/nginx.conf
EOF

# Log the generated .env for debugging (redact secrets)
bashio::log.debug "Generated .env file (secrets redacted):"
bashio::log.debug "$(grep -v -E '(PASSWORD|SECRET|PWD)=' /data/huly/.env)" || true

# Copy compose file template
bashio::log.info "Setting up docker-compose configuration..."
cp /opt/huly/compose.yaml.tmpl /data/huly/compose.yml

# Generate nginx config for routing
bashio::log.info "Generating nginx configuration..."
cat > /data/huly/nginx.conf << 'NGINXEOF'
server {
    listen 80;
    server_name _;

    client_max_body_size 256m;
    proxy_read_timeout 86400s;
    proxy_send_timeout 86400s;

    location / {
        proxy_pass http://front:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /_accounts {
        rewrite ^/_accounts(/.*)$ $1 break;
        proxy_pass http://account:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /_transactor {
        rewrite ^/_transactor(/.*)$ $1 break;
        proxy_pass http://transactor:3333;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /_collaborator {
        rewrite ^/_collaborator(/.*)$ $1 break;
        proxy_pass http://collaborator:3078;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /_rekoni {
        rewrite ^/_rekoni(/.*)$ $1 break;
        proxy_pass http://rekoni:4004;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /_stats {
        rewrite ^/_stats(/.*)$ $1 break;
        proxy_pass http://stats:4900;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /files {
        rewrite ^/files(/.*)$ $1 break;
        proxy_pass http://minio:9000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
NGINXEOF

bashio::log.info "Huly initialization complete"
