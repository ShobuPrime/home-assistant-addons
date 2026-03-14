---
name: ha-ci-pipeline
description: Diagnose and fix GitHub Actions CI/CD pipeline issues for the ShobuPrime/home-assistant-addons repository. Use this skill when PRs are not auto-merging after validation passes, when CI checks are running unnecessarily for unrelated addons, when GitHub Actions workflows need to be scoped to specific addon paths, when the user reports issues with validation-passed labels not triggering merges, or when debugging any workflow interaction between pr-validate.yml, auto-merge.yml, builder.yml, and the update workflows. Also use when adding new workflows or modifying existing CI/CD behavior.
---

# Home Assistant CI Pipeline Skill

This skill helps diagnose and fix CI/CD pipeline issues in the `ShobuPrime/home-assistant-addons` repository. It covers the three interconnected workflows and the auto-merge system.

## Workflow Architecture Overview

The repository has three core workflows that interact:

```
Update workflow (e.g., update-arcane.yml)
  → Creates PR with `automated` label
  → Fires `repository_dispatch` event
       ↓
  ┌────────────────────┐    ┌──────────────┐
  │  pr-validate.yml   │    │  builder.yml  │
  │  (validates files) │    │ (test builds) │
  └────────┬───────────┘    └──────┬───────┘
           │                       │
  Adds `validation-passed`         │
  label if all pass                │
           │                       │
           ├───────────────────────┘
           ↓
  ┌────────────────────────────┐
  │  Auto-merge (two paths)    │
  │  1. Primary: inside        │
  │     pr-validate.yml        │
  │     (polls for Builder)    │
  │  2. Fallback: auto-merge   │
  │     .yml (every 30 min)    │
  └────────────────────────────┘
```

### Workflow Files

| File | Purpose | Triggers |
|------|---------|----------|
| `.github/workflows/pr-validate.yml` | Structure, changelog, YAML validation + primary auto-merge | `pull_request`, `repository_dispatch` |
| `.github/workflows/auto-merge.yml` | Fallback auto-merge sweep | Schedule (30min), `check_suite`, manual |
| `.github/workflows/builder.yml` | Test-build changed addons | `push`, `pull_request`, `repository_dispatch` |
| `.github/workflows/update-*.yml` | Check for upstream updates, create PRs | Schedule (daily), manual |

## How Validation Scoping Works

All validation jobs in `pr-validate.yml` are scoped to only check addons/files that changed in the PR. This prevents unrelated addon issues from blocking PRs.

### Current Implementation

| Validation | How it's scoped | Key detail |
|-----------|----------------|------------|
| Structure validation | `git diff` detects changed addon dirs, only validates those | Requires `fetch-depth: 0` for diff |
| Changelog validation | `git diff` detects changed addon dirs, checks their CHANGELOGs | Already had `fetch-depth: 0` |
| YAML lint | `git diff` detects changed `.yaml`/`.yml` files, only lints those | Skips Python/yamllint install if no YAML changed |
| Builder | `tj-actions/changed-files` detects changed addons, matrix builds only those | Auto-discovers addons from `*/config.yaml` |

### If a validation fails for an unrelated addon

This shouldn't happen with scoped validation. If it does, check:

1. Is the failing addon actually modified in the PR? (`git diff` against base branch)
2. Did the `fetch-depth: 0` get removed from the checkout step? (shallow clones can't diff)
3. Is the `changed_addons` output empty? (workflow-only changes correctly skip addon validation)

### Workflow-only changes (no addon files)

When a PR only modifies `.github/` files (workflows, scripts) and no addon directories, all scoped validations skip gracefully with messages like "No addon-specific changes detected" and "No YAML files changed." This is correct behavior — the checks show as passed (not failed or skipped), so auto-merge still works.

### New addon's first PR

When adding a brand new addon, all of its files appear as "new" in the diff. The scoping logic correctly detects the new addon directory as changed and validates only that addon. Existing addons are not affected.

## How Auto-Merge Works

There are two merge paths — a primary path that runs inline with validation, and a fallback sweep.

### Primary Path (inside `pr-validate.yml`)

Runs as the final job after all validations pass:
1. Checks PR is by `github-actions[bot]` with `automated` label, no blocking labels
2. Polls Builder check runs for up to **15 minutes** (45 attempts * 20 seconds)
3. Verifies all Builder checks passed
4. Checks GitHub mergeability state
5. Merges with squash

### Fallback Path (`auto-merge.yml`)

Runs every 30 minutes and on `check_suite` completion:
1. Lists all open PRs from `github-actions[bot]` with `automated` label
2. Requires `validation-passed` label (added by the summary job)
3. Checks no blocking labels (`do-not-merge`, `needs-review`, `on-hold`)
4. Verifies all check runs completed successfully
5. Merges with squash

### Label Requirements

| Path | Required labels | Blocking labels |
|------|----------------|-----------------|
| Primary | `automated` | `do-not-merge`, `needs-review`, `on-hold` |
| Fallback | `automated` + `validation-passed` | `do-not-merge`, `needs-review`, `on-hold` |

## Troubleshooting: PR Not Auto-Merging

When an automated PR has `validation-passed` but isn't merging, check these causes in order:

### 1. Builder checks not finishing in time

The primary merge path polls for 15 minutes. If Builder is queued or slow, it gives up. The fallback sweep should catch it within 30 minutes.

**Check:** Look at the `pr-validate.yml` "Auto-merge if eligible" step logs. If it says "Builder did not complete in time", the fallback will retry.

### 2. Check run name mismatch

The auto-merge filters for check run names:
- `Build *` or `Initialize build` (Builder workflow)
- `Validate Repository Structure`, `Validate CHANGELOG Updates`, `Lint YAML Files`, `Validation Summary` (validation workflow)

If names change (e.g., matrix strategy changes), filters won't match.

**Check:** List actual check run names for a PR and compare against the filter patterns:

```bash
# With gh CLI
gh pr checks <PR-NUMBER> --json name --jq '.[].name'

# Without gh CLI (using curl + GitHub API)
curl -s -H "Authorization: token $(git config github.token 2>/dev/null || echo $GITHUB_TOKEN)" \
  "https://api.github.com/repos/ShobuPrime/home-assistant-addons/commits/<HEAD-SHA>/check-runs" \
  | jq -r '.check_runs[].name'

# Or just check locally what names the workflows define
grep -E "^    name:" .github/workflows/pr-validate.yml .github/workflows/builder.yml
grep "name: Build" .github/workflows/builder.yml
```

The auto-merge code filters for these exact patterns:
- Starts with `Build ` (note trailing space) — from builder.yml matrix jobs
- Equals `Initialize build` — from builder.yml init job
- Equals `Validate Repository Structure`, `Validate CHANGELOG Updates`, `Lint YAML Files`, `Validation Summary` — from pr-validate.yml jobs

### 3. Missing `validation-passed` label

The fallback path requires this label. If the summary job failed to add it (API rate limit, permissions), the fallback won't merge.

**Check:** PR labels and the `summary` job logs.

### 4. Mergeability state

GitHub takes time to calculate. Both paths poll but may time out if there are conflicts.

### Quick fix

```bash
# Manual trigger of fallback sweep
gh workflow run auto-merge.yml

# Or merge directly
gh pr merge <PR-NUMBER> --squash
```

## Adding a New Update Workflow

When creating update workflows for new addons:

### Cron Schedule (avoid conflicts)

Existing schedule:
- 1:00 AM UTC - Base image updates
- 2:00 AM UTC - Portainer LTS + STS
- 3:00 AM UTC - Arcane + Dockhand
- 3:30 AM UTC - Huly

New addons should use unoccupied slots: 4:00, 4:30, 5:00 AM UTC, etc.

### Required conventions

1. Apply the `automated` label for auto-merge eligibility
2. Use `sign-commits: true` (repo enforces signed commits)
3. Fire `repository_dispatch` after PR creation — GitHub doesn't trigger `pull_request` events for PRs created by `GITHUB_TOKEN`:

```yaml
- name: Trigger downstream workflows
  run: |
    curl -X POST \
      -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
      -H "Accept: application/vnd.github.v3+json" \
      https://api.github.com/repos/${{ github.repository }}/dispatches \
      -d '{
        "event_type": "automated-pr-created",
        "client_payload": {
          "pull_request_number": "${{ steps.create-pr.outputs.pull-request-number }}",
          "head_sha": "${{ steps.create-pr.outputs.pull-request-head-sha }}",
          "branch": "update-<addon>-${{ version }}",
          "addon": "<addon-slug>"
        }
      }'
```

## Debugging Checklist

When a PR isn't merging or validations are failing unexpectedly:

1. **Check PR labels**: Has `automated`? Has `validation-passed`? Any blocking labels?
2. **Check workflow runs**: Did `pr-validate.yml` and `builder.yml` both complete and succeed?
3. **Check auto-merge logs**: Both the primary merge (in pr-validate.yml) and fallback sweep (auto-merge.yml)
4. **Check scoping**: Is validation failing for an unrelated addon? Check if `fetch-depth: 0` is present and `git diff` is detecting changed addons correctly
5. **Check run names**: Do they match the filter patterns in the auto-merge code?
6. **Manual intervention**: `gh pr merge <number> --squash` or `gh workflow run auto-merge.yml`

## Managing Auto-Merge

Use the helper script to control auto-merge behavior on specific PRs:

```bash
# Check status
.github/scripts/manage-automerge.sh <pr-number> status

# Block auto-merge
.github/scripts/manage-automerge.sh <pr-number> block

# Unblock
.github/scripts/manage-automerge.sh <pr-number> unblock
```

## File Locations

- Validation workflow: `.github/workflows/pr-validate.yml`
- Fallback auto-merge: `.github/workflows/auto-merge.yml`
- Builder workflow: `.github/workflows/builder.yml`
- Auto-merge helper: `.github/scripts/manage-automerge.sh`
- Update workflows: `.github/workflows/update-*.yml`
- Update scripts: `.github/scripts/update-*.sh`
