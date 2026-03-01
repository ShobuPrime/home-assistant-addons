# Changelog

## Version 0.7.375-5 (2026-03-01)

### Fixed
- Fix init crash (exit 22) when resolving host data path. The Docker API curl
  call now handles errors gracefully with a `/proc/self/mountinfo` fallback.
  Added debug logging of the container ID for troubleshooting.

## Version 0.7.375-4 (2026-03-01)

### Fixed
- Fix init script segfault (exit 139) caused by `docker inspect` on aarch64.
  Query the Docker API directly via the Unix socket with `curl`/`jq` instead of
  using Alpine's `docker-cli` which segfaults on aarch64 (docker/cli#4900).

## Version 0.7.375-3 (2026-03-01)

### Fixed
- Fix "read-only file system" error for volume mounts by resolving host-side
  paths at runtime via `docker inspect`. Sub-containers are created by the host
  Docker daemon and need real host paths, not addon-internal `/data` paths.

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
