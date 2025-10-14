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

## Git Commit Guidelines

- **Always sign commits**: All commits must be signed with GPG/SSH signatures
- SSH agent should have the signing identity loaded
- Use `git commit -S` for GPG signing or ensure `commit.gpgsign` is configured
- For SSH signing, ensure `gpg.format` is set to `ssh` and `user.signingkey` points to your SSH key

## Notes

- Always test add-ons locally before pushing to the repository
- Follow Home Assistant add-on best practices
- Keep dependencies up to date
- Document all configuration options clearly
