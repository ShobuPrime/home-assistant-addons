# Repository Automation

This repository uses GitHub Actions to automate addon updates, validation, and merging.

## Workflows

### 1. Portainer Version Updates

**Files:**
- [`.github/workflows/update-portainer-lts.yml`](workflows/update-portainer-lts.yml)
- [`.github/workflows/update-portainer-sts.yml`](workflows/update-portainer-sts.yml)

**Trigger:** Daily at 2 AM UTC (or manual via workflow_dispatch)

**What it does:**
1. Checks for new Portainer releases via GitHub API
2. Compares with current version in `config.yaml`
3. If update available:
   - Updates version in `config.yaml`, `build.yaml`, `Dockerfile`
   - Updates version references in `README.md` and `DOCS.md`
   - Prepends changelog to `CHANGELOG.md`
   - Creates a PR with detailed information

**Labels applied:** `automated`, `portainer`, `lts`/`sts`, `update`

### 2. PR Validation

**File:** [`.github/workflows/pr-validate.yml`](workflows/pr-validate.yml)

**Trigger:** When a PR is opened, synchronized, or reopened

**Checks performed:**

#### Structure Validation
- Verifies all required files exist (`config.yaml`, `Dockerfile`, `README.md`, `DOCS.md`, `CHANGELOG.md`)
- Validates `config.yaml` has required fields (name, version, slug, description, arch)
- Validates version format follows semver (X.Y.Z)
- Checks Dockerfile has FROM instruction

#### Changelog Validation
- Ensures CHANGELOG.md is updated when addon files are modified
- Verifies CHANGELOG.md contains an entry for the current version

#### YAML Linting
- Runs yamllint on all `.yaml` and `.yml` files
- Enforces consistent formatting

#### Build Testing
- Validates Dockerfile syntax for changed addons

**On success:** Adds `validation-passed` label to the PR

**On failure:** Posts a comment with detailed errors

### 3. Auto-merge

**File:** [`.github/workflows/auto-merge.yml`](workflows/auto-merge.yml)

**Trigger:** When PR validation completes, or when PR is labeled/unlabeled

**Conditions for auto-merge:**
- PR created by `github-actions[bot]`
- Has `automated` label
- Has `validation-passed` label
- Does NOT have blocking labels: `do-not-merge`, `needs-review`, `on-hold`
- All required checks have passed
- PR is not a draft
- PR is in open state

**Merge method:** Squash merge

**What it does:**
1. Verifies all conditions are met
2. Attempts to merge the PR automatically
3. Falls back to enabling auto-merge if direct merge fails
4. Posts a comment on success or failure

## Preventing Auto-merge

To prevent a PR from being auto-merged, add one of these labels:
- `do-not-merge` - Completely blocks merging
- `needs-review` - Indicates human review is required
- `on-hold` - Temporarily holds the PR

## Manual Triggering

You can manually trigger the update workflows:

1. Go to **Actions** tab
2. Select the workflow (e.g., "Update Portainer EE LTS")
3. Click **Run workflow**
4. Select branch and click **Run workflow**

## Customizing Validation

### Adding Custom Checks

Edit [`.github/workflows/pr-validate.yml`](workflows/pr-validate.yml) and add a new job:

```yaml
custom-check:
  name: My Custom Check
  runs-on: ubuntu-latest
  steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Run check
      run: |
        # Your validation logic here
        echo "Running custom validation..."
```

Then add it to the `needs` array in the `summary` job.

### Modifying Auto-merge Behavior

Edit [`.github/workflows/auto-merge.yml`](workflows/auto-merge.yml):

- **Change merge method:** Modify the `merge_method` parameter (options: `merge`, `squash`, `rebase`)
- **Add more blocking labels:** Update the `blockingLabels` array
- **Change conditions:** Modify the `if` condition in the `auto-merge` job

## Documentation Update Strategy

The update script (`.github/scripts/update-portainer.sh`) uses conservative regex patterns to update documentation:

**What gets updated:**
- "Currently running Portainer X.X.X" statements
- "running version X.X.X" statements
- Version badges/shields

**What does NOT get updated:**
- Section headers (e.g., "Portainer 2.33+ Ingress Compatibility")
- Generic "Portainer" references without version numbers
- Historical changelog entries

This prevents unintended modifications to documentation that references specific version requirements or compatibility notes.

## Troubleshooting

### Validation Failing

Check the PR comments for specific error messages. Common issues:
- Missing CHANGELOG.md entry
- Invalid version format
- YAML syntax errors

### Auto-merge Not Triggering

Verify:
1. PR has `automated` label
2. PR has `validation-passed` label
3. No blocking labels are present
4. All checks are green
5. PR was created by `github-actions[bot]`

### Update Script Issues

If the update script fails:
1. Check GitHub API rate limits
2. Verify network connectivity in Actions
3. Check script logs in workflow run details

## Security Considerations

- Auto-merge only works for PRs created by `github-actions[bot]`
- Validation checks prevent malformed addons from being merged
- Manual review can be forced with the `needs-review` label
- All workflows use `GITHUB_TOKEN` with minimal required permissions
