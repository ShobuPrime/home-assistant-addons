# Claude AI Assistant

This repository was created and is maintained with assistance from Claude, an AI assistant by Anthropic.

## Repository Setup

This Home Assistant add-ons repository was initialized using Claude Code with the following structure:

- Git repository initialization
- GitHub Actions workflows for automated building and testing
- Standard documentation (README, LICENSE, CHANGELOG)
- Proper .gitignore configuration
- Repository metadata for Home Assistant integration

## Reference

The repository structure was modeled after: https://github.com/boomam/home-assistant-addons

## Adding New Add-ons

Each add-on should be created in its own directory with the following files:

- `config.yaml` - Main configuration file defining the add-on metadata
- `Dockerfile` - Container build instructions
- `README.md` - Add-on overview and quick start
- `DOCS.md` - Detailed documentation and configuration options
- `CHANGELOG.md` - Version history
- `icon.png` and `logo.png` - Visual assets

## Maintenance

When updating add-ons or adding new features, you can use Claude to:

- Review and improve Dockerfiles
- Update documentation
- Debug configuration issues
- Generate changelog entries
- Write GitHub Actions workflows

## GitHub Actions Builder Configuration

The repository uses the `home-assistant/builder` action for automated addon builds. Key configuration requirements:

- **Docker Hub username**: Use `--docker-hub <username>` flag to set the image repository
- **Image naming**: Use `--image <addon-name>` flag to specify the image name
- **Test mode**: Use `--test` flag to build without pushing to registry
- **Target directory**: Use `--target /data/<addon>` to specify which addon to build

Without proper `--docker-hub` and `--image` flags, the builder will generate invalid image tags like `/:version` instead of `username/image:version`.

## Automated PR Management

The repository includes comprehensive automation for managing pull requests:

### Automatic Version Updates
- Daily checks for new Portainer releases (LTS and STS)
- Automatically creates PRs with version updates and changelogs
- Updates documentation with conservative regex patterns to avoid breaking section headers

### PR Validation
- Validates repository structure (required files, config format)
- Checks CHANGELOG.md updates
- Lints YAML files
- Tests build configurations
- Adds `validation-passed` label on success

### Auto-merge
- Automatically merges PRs created by github-actions[bot] that pass all validations
- Requires `automated` and `validation-passed` labels
- Blocked by `do-not-merge`, `needs-review`, or `on-hold` labels
- Uses squash merge method

### Managing Auto-merge
Use the helper script to control auto-merge behavior:
```bash
# Check PR auto-merge status
.github/scripts/manage-automerge.sh <pr-number> status

# Block auto-merge
.github/scripts/manage-automerge.sh <pr-number> block

# Unblock auto-merge
.github/scripts/manage-automerge.sh <pr-number> unblock
```

See [`.github/AUTOMATION.md`](.github/AUTOMATION.md) for complete documentation.

## Git Commit Guidelines

- **Always sign commits**: All commits must be signed with GPG/SSH signatures
- SSH agent should have the signing identity loaded
- Use `git commit -S` for GPG signing or ensure `commit.gpgsign` is configured
- For SSH signing, ensure `gpg.format` is set to `ssh` and `user.signingkey` points to your SSH key
- **Never add Claude Code attribution**: Do not include "Generated with Claude Code" or "Co-Authored-By: Claude" lines in commits

## Notes

- Always test add-ons locally before pushing to the repository
- Follow Home Assistant add-on best practices
- Keep dependencies up to date
- Document all configuration options clearly
