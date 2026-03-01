# Changelog

## Version 0.7.375-2 (2026-03-01)

### Fixed
- Fix "undefined volume cr_certs" error by using a bind mount path for
  CockroachDB certs instead of a Docker named volume

## Version 0.7.375-1 (2026-03-01)

### Fixed
- Fix Docker Compose segfault (SIGSEGV) on aarch64 by installing compose as a
  standalone binary instead of a Docker CLI plugin (docker/cli#4900)

## Version 0.7.375 (2026-03-01)

### Initial Release
- Initial Home Assistant addon for Huly self-hosted
- Full Huly platform stack with all 14 services
- Ingress integration for Home Assistant sidebar access
- WebSocket support for real-time updates
- Automatic secret generation on first run
- Persistent data storage included in Home Assistant backups
- Configurable instance title, language, and display preferences
- Docker Compose orchestration of the complete Huly stack

---

For full release notes, see: https://github.com/hcengineering/huly-selfhost
