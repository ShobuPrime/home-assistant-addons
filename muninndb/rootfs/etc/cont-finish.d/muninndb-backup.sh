#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: MuninnDB
# Pre-shutdown backup: triggers a native MuninnDB backup via REST API
# before the container stops. The backup is stored in /data/muninndb/backups/
# which is included in Home Assistant's addon backup.
# ==============================================================================

# Check if backup on shutdown is enabled
if ! bashio::config.true 'backup_on_shutdown'; then
    bashio::log.info "Backup on shutdown disabled, skipping"
    exit 0
fi

# Check if MuninnDB is still responding
if ! curl -sf http://127.0.0.1:8476/api/health > /dev/null 2>&1; then
    bashio::log.warning "MuninnDB not responding, cannot create shutdown backup"
    exit 0
fi

# Determine credentials for login
CURRENT_PASSWORD="password"
STORED_PASS_FILE="/data/muninndb/.admin_pass_set"
if [[ -f "${STORED_PASS_FILE}" ]]; then
    CURRENT_PASSWORD=$(cat "${STORED_PASS_FILE}")
fi

# Login to get session cookie
SESSION_COOKIE=$(mktemp)
LOGIN_PAYLOAD=$(jq -n --arg user "root" --arg pass "${CURRENT_PASSWORD}" \
    '{username: $user, password: $pass}')

LOGIN_CODE=$(curl -s -w "%{http_code}" -o /dev/null -c "${SESSION_COOKIE}" \
    -X POST http://127.0.0.1:8476/api/auth/login \
    -H 'Content-Type: application/json' \
    -d "${LOGIN_PAYLOAD}" 2>/dev/null)

if [[ "${LOGIN_CODE}" != "200" ]]; then
    bashio::log.warning "Could not login for shutdown backup (HTTP ${LOGIN_CODE})"
    rm -f "${SESSION_COOKIE}"
    exit 0
fi

# Create timestamped backup directory
BACKUP_DIR="/data/muninndb/backups/shutdown-$(date +%Y%m%d-%H%M%S)"
BACKUP_PAYLOAD=$(jq -n --arg dir "${BACKUP_DIR}" '{output_dir: $dir}')

bashio::log.info "Creating shutdown backup: ${BACKUP_DIR}"

BACKUP_RESPONSE=$(curl -s -w "\n%{http_code}" -b "${SESSION_COOKIE}" \
    -X POST http://127.0.0.1:8476/api/admin/backup \
    -H 'Content-Type: application/json' \
    -d "${BACKUP_PAYLOAD}" 2>/dev/null)

BACKUP_CODE=$(echo "${BACKUP_RESPONSE}" | tail -1)
BACKUP_BODY=$(echo "${BACKUP_RESPONSE}" | sed '$d')

if [[ "${BACKUP_CODE}" == "200" ]]; then
    BACKUP_SIZE=$(echo "${BACKUP_BODY}" | jq -r '.size_bytes // "unknown"')
    BACKUP_ELAPSED=$(echo "${BACKUP_BODY}" | jq -r '.elapsed // "unknown"')
    bashio::log.info "Shutdown backup complete (${BACKUP_SIZE} bytes, ${BACKUP_ELAPSED})"
else
    bashio::log.warning "Shutdown backup failed (HTTP ${BACKUP_CODE}): ${BACKUP_BODY}"
fi

# Prune old shutdown backups (keep last 3)
BACKUP_BASE="/data/muninndb/backups"
if [[ -d "${BACKUP_BASE}" ]]; then
    SHUTDOWN_BACKUPS=$(ls -dt "${BACKUP_BASE}"/shutdown-* 2>/dev/null)
    COUNT=0
    for backup in ${SHUTDOWN_BACKUPS}; do
        COUNT=$((COUNT + 1))
        if [[ ${COUNT} -gt 3 ]]; then
            bashio::log.info "Pruning old backup: ${backup}"
            rm -rf "${backup}"
        fi
    done
fi

# Clean up
rm -f "${SESSION_COOKIE}"
