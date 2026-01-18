# Changelog

## Version 1.13.0 (2026-01-18)

> [!IMPORTANT]
> This updated patches/removes the attack surface for GHSA-gjqq-6r35-w3r8. Credit to @DenizParlak for reporting this vulnerability.

### Backend - New features

* allow sensitive env variables to be read from _FILE ([#1423](https://github.com/getarcaneapp/arcane/pull/1423) by @kmendell)
* add JSON parsing and structured log display functionality ([#1463](https://github.com/getarcaneapp/arcane/pull/1463) by @FusionStreak)
* use shoutrrr for notifications (apprise deprecated) ([#1424](https://github.com/getarcaneapp/arcane/pull/1424) by @kmendell)
* bulk actions for containers and projects ([#1466](https://github.com/getarcaneapp/arcane/pull/1466) by @kmendell)
* auto-prune/prune scheduler job ([#1467](https://github.com/getarcaneapp/arcane/pull/1467) by @kmendell)
* project status filter selector ([#1484](https://github.com/getarcaneapp/arcane/pull/1484) by @kmendell)

### Backend - Bug fixes

* add option for ssh host key verification and known hosts ([#144

---


## Version 1.12.2 (2026-01-14)

> [!IMPORTANT]
> Sorry for the double release, this release however should fix the path issues by making all projects directories absolute paths instead of relative paths.

### Backend - Bug fixes

* template editor heights being cutoff([7057deb](https://github.com/getarcaneapp/arcane/commit/7057deb42174cef218c623b1c431546c4a771396) by @kmendell)
* double label text on template buttons([6316833](https://github.com/getarcaneapp/arcane/commit/6316833c79f5b3e17c194c701ddc1446cab0b038) by @kmendell)
* use full absolute path for projects directory ([#1409](https://github.com/getarcaneapp/arcane/pull/1409) by @kmendell)
* editor cursor misalignment ([#1412](https://github.com/getarcaneapp/arcane/pull/1412) by @kmendell)



**Full Changelog**: https://github.com/getarcaneapp/arcane/compare/v1.12.1...v1.12.2

---


## Version 1.11.3 (2026-01-04)

### Initial Release

- Initial Home Assistant addon release
- Based on Arcane v1.11.3
- Features:
  - Container management with real-time stats
  - Docker Compose stack management
  - Resource monitoring with graphs
  - Image, volume, and network management
  - Automatic container image updates
  - Modern, mobile-friendly UI
  - Home Assistant ingress integration
  - Persistent data storage

### Arcane v1.11.3 Release Notes

For full upstream release notes, see: https://github.com/getarcaneapp/arcane/releases/tag/v1.11.3

---
