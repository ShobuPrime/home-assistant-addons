# Changelog

## Version 1.13.2 (2026-01-20)

> [!IMPORTANT]
> Huge shoutout to @PvtSec for reporting GHSA-2jv8-39rp-cqqr, We recomend upgrading arcane to this version ASAP to fix that issue. 

### Backend - Bug fixes

* apply auth check before proxying request to environments ([#1532](https://github.com/getarcaneapp/arcane/pull/1532) by @kmendell)
* allow HTTP_PROXY and HTTPS_PROXY environment variables ([#1534](https://github.com/getarcaneapp/arcane/pull/1534) by @kmendell)
* use image pull timeout for project pull ([#1533](https://github.com/getarcaneapp/arcane/pull/1533) by @kmendell)
* update color of port badge to be more distinguishable([b0e8b54](https://github.com/getarcaneapp/arcane/commit/b0e8b54ec7c416ef089476106f23c365a74724cd) by @kmendell)

### Dependencies

* bump go version to 1.25.6([501baaf](https://github.com/getarcaneapp/arcane/commit/501baaf7708e8fc83b030650abd04919880da2e4) by @kmendell)
* bump pnpm to 10.28.1([c5ef93e](https://github.com/getarcaneapp/arcane/commit/c5ef93e54db76e44b932953af9f8303

---


## Version 1.13.1 (2026-01-19)


### Backend - Bug fixes

* ability to resize editor panels horizontally ([#1500](https://github.com/getarcaneapp/arcane/pull/1500) by @kmendell)
* allow oidc endpoints to be defined manually ([#1510](https://github.com/getarcaneapp/arcane/pull/1510) by @kmendell)
* remove file line from db debug logs([fbe204c](https://github.com/getarcaneapp/arcane/commit/fbe204c5ce919282a65313cfc0c889b763eebd64) by @kmendell)
* self update binary path for remote envrionments([974c675](https://github.com/getarcaneapp/arcane/commit/974c675550a0d5408f662d13fe3f8b07edb2267e) by @kmendell)
* generic webhooks do not allow ports ([#1517](https://github.com/getarcaneapp/arcane/pull/1517) by @kmendell)
* logo color not applying on refreshes([fe53985](https://github.com/getarcaneapp/arcane/commit/fe539851d621a35c1ebaa08217151e65bbaae64c) by @kmendell)

### Dependencies

* bump @sveltejs/kit from 2.49.4 to 2.49.5 in the npm_and_yarn group across 1 directory ([#1492](https://github.com/getarcaneapp/arcane/pull/1

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
