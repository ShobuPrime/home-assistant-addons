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

bashio::log.info "MuninnDB initialization complete"
