# Portainer EE (STS) Add-on for Home Assistant

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

Manage your Docker environment with ease using Portainer Enterprise Edition (Short Term Support).

## About

Portainer is a lightweight management UI which allows you to easily manage your Docker environments. This add-on brings Portainer EE STS (Short Term Support) to Home Assistant, integrating it seamlessly with the sidebar and providing easy access to all Docker management features.

**Note**: This is the STS version which tracks Portainer's Short Term Support releases for the latest features and bleeding-edge updates. For stable Long Term Support, see the `portainer_ee_lts` addon.

## Features

- 🐳 Full Docker management interface
- 🔒 SSL/TLS support using Home Assistant certificates
- 🎯 Ingress support for seamless sidebar integration
- 🔐 Agent secret configuration for edge deployments
- 🏷️ Option to hide Home Assistant system containers
- 💾 Persistent data storage included in backups
- 📊 Container stats, logs, and console access
- 🚀 Stack deployment and management
- 📁 Access to Home Assistant media and share folders
- Auto-updating: Automatically checks for new STS releases
- Native HA integration: Shows in sidebar with Docker icon
- Persistent storage: Data survives updates and is included in backups
- Container filtering: Option to hide HA system containers

## Installation

1. Add this repository to your Home Assistant instance
2. Search for "Portainer EE (STS)" in the add-on store
3. Click Install
4. Configure the add-on options (if needed)
5. Start the add-on
6. Click "OPEN WEB UI" or access via the sidebar

## Configuration

### Option: `log_level`

The `log_level` option controls the level of log output by the addon and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `warning`: Exceptional occurrences that are not errors.
- `error`: Runtime errors that do not require immediate action.
- `fatal`: Something went terribly wrong. Add-on becomes unusable.

### Option: `ssl`

Enables/Disables custom SSL certificates for HTTPS (port 9443). When enabled, 
Portainer will use the certificates from `/ssl/fullchain.pem` and `/ssl/privkey.pem`.
When disabled, Portainer uses self-signed certificates. Both HTTP (9000) and HTTPS 
(9443) are always available.

### Option: `agent_secret`

Sets a secret for the Portainer agent. This is useful when managing edge agents
or remote Docker environments.

### Option: `license_key`

Provides your Portainer Business Edition license key. When configured, this enables
Business Edition features including:
- Advanced RBAC and team management
- GitOps automation
- Registry management
- Edge compute features
- And more enterprise capabilities

To obtain a license key, visit [Portainer.io](https://www.portainer.io/pricing) to
purchase or request a trial. Leave empty to use the free Community Edition features.

**Note**: The license key is stored as a password field for security and is passed
to Portainer via the `LICENSE_KEY` environment variable.

### Option: `hide_hassio_containers`

When enabled (default), hides Home Assistant system containers from the Portainer 
interface. This includes supervisor, core, audio, dns, multicast, cli, observer, 
and addon containers.

**Note**: Due to Portainer's caching, toggling this option may require manual
intervention. See the documentation for details.

## Folder Access

This addon has access to the following Home Assistant directories:

- `/ssl` - SSL certificates (read-only)
- `/data` - Addon persistent data (read/write)
- `/media` - Home Assistant media folder (read/write)
- `/share` - Home Assistant share folder (read/write)

These folders are accessible from within Portainer and can be mounted as volumes when creating or managing containers. For example, you can mount `/share` into a container to share files between Home Assistant and your Docker containers.

## First Time Setup

1. When you first access Portainer, you'll need to create an admin user
2. Choose "Get Started" to connect to the local Docker environment
3. You'll now have access to all your Docker containers, images, volumes, and networks

## Known Issues

### Portainer 2.33.0+ Ingress Compatibility

**Issue**: Portainer versions 2.33.0 and later introduced Content-Security-Policy headers that block iframe embedding, which prevents access through Home Assistant's ingress.

**Fix**: This add-on automatically sets `CSP=false` to disable the restrictive CSP headers and restore ingress functionality. If you experience access issues after updating, rebuild the add-on.

**Security Note**: Disabling CSP is necessary for Home Assistant integration but reduces some security protections. For enhanced security, you can access Portainer directly via ports 9000 (HTTP) or 9443 (HTTPS) instead of through ingress.

## Support

Got questions or found a bug? Please open an issue on the GitHub repository.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg

## Updates

**Note**: As a local addon, updates require the Home Assistant integration package.

### Quick Setup:
1. Copy the package to your config:
   ```bash
   cp /addons/portainer_ee_sts/homeassistant/packages/portainer_updates.yaml /config/packages/
   ```

2. Add to `configuration.yaml`:
   ```yaml
   homeassistant:
     packages: !include_dir_named packages
   ```

3. Restart Home Assistant

You'll get:
- 🔔 Automatic update notifications
- 📊 Update status sensors
- 🚀 One-click updates from notifications
- 📅 Daily automatic checks

For manual updates and more details, see [UPDATE_GUIDE.md](UPDATE_GUIDE.md).

## Version

Currently running Portainer 2.35.0 STS

