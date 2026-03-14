#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Add-on: MuninnDB
# Runs initialization for MuninnDB
# ==============================================================================

# Create data directory structure
bashio::log.info "Creating data directories..."
mkdir -p /data/muninndb
chmod 755 /data/muninndb

# Check if MuninnDB binary exists and is executable
if [[ ! -f /opt/muninndb/muninn ]]; then
    bashio::log.error "MuninnDB binary not found at /opt/muninndb/muninn!"
    exit 1
fi

if [[ ! -x /opt/muninndb/muninn ]]; then
    bashio::log.warning "MuninnDB binary not executable, fixing permissions..."
    chmod +x /opt/muninndb/muninn
fi

# Log MuninnDB version
bashio::log.info "Checking MuninnDB installation..."
if /opt/muninndb/muninn version 2>/dev/null; then
    bashio::log.info "MuninnDB binary is working correctly"
else
    bashio::log.warning "Could not get MuninnDB version, but continuing..."
fi

# Report last backup if any exist
BACKUP_BASE="/data/muninndb/backups"
if [[ -d "${BACKUP_BASE}" ]]; then
    LATEST_BACKUP=$(ls -dt "${BACKUP_BASE}"/shutdown-* 2>/dev/null | head -1)
    if [[ -n "${LATEST_BACKUP}" ]]; then
        BACKUP_NAME=$(basename "${LATEST_BACKUP}")
        BACKUP_SIZE=$(du -sh "${LATEST_BACKUP}" 2>/dev/null | cut -f1)
        bashio::log.info "Last shutdown backup: ${BACKUP_NAME} (${BACKUP_SIZE})"
    else
        bashio::log.info "No shutdown backups found"
    fi
fi

bashio::log.info "MuninnDB initialization complete"
