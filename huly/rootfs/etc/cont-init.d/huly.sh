#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: Huly
# Initializes Huly configuration and data directories
# ==============================================================================
bashio::require.unprotected

# Create data directories for all Huly services
bashio::log.info "Creating data directories..."
mkdir -p /data/huly
mkdir -p /data/huly/cockroach
mkdir -p /data/huly/elastic
mkdir -p /data/huly/minio
mkdir -p /data/huly/redpanda

# Ensure proper permissions
chmod 755 /data/huly
chmod 755 /data/huly/cockroach
chmod 755 /data/huly/elastic
chmod 755 /data/huly/minio
chmod 755 /data/huly/redpanda

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
elif [[ -S /run/docker.sock ]]; then
    bashio::log.info "Docker socket found at /run/docker.sock"
else
    bashio::log.error "Docker socket not found! Huly requires Docker access."
    bashio::log.error "Please ensure the addon has the proper permissions."
fi

# Verify docker compose is available
if docker compose version >/dev/null 2>&1; then
    bashio::log.info "Docker Compose is available"
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

# Volumes (use bind mounts for HA persistence)
VOLUME_CR_DATA_PATH=/data/huly/cockroach
VOLUME_CR_CERTS_PATH=cr_certs
VOLUME_ELASTIC_PATH=/data/huly/elastic
VOLUME_FILES_PATH=/data/huly/minio
VOLUME_REDPANDA_PATH=/data/huly/redpanda
EOF

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
