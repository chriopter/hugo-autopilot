# Hugo Autopilot

Automated CI/CD workflows for Hugo sites with automatic updates and dependency management.

## Overview

Hugo Autopilot provides a set of reusable GitHub Actions workflows that automate the build, deployment, and maintenance of Hugo sites. These workflows can be referenced from your Hugo site repositories, allowing you to maintain your CI/CD configuration in a single place.

## Features

- **Automated Hugo Builds and Deployments**: Build and deploy your Hugo site to GitHub Pages with optimized settings
- **Automatic Hugo Version Updates**: Automatically check for new Hugo versions and create PRs to update
- **Dependabot Auto-merge**: Automatically merge Dependabot PRs for GitHub Actions dependencies
- **Centralized Workflow Management**: Maintain your workflows in one place and reference them from multiple repositories

## Repository Structure

```
hugo-autopilot/
├── .github/
│   ├── workflows/
│   │   ├── internal/           # Workflows for this repository itself
│   │   │   ├── dependabot-merger.yml
│   │   │   └── self-update.yml
│   │   └── reusable/           # Reusable workflows for other repositories
│   │       ├── hugo-builder.yml
│   │       ├── hugo-updater.yml
│   │       └── pr-merger.yml
│   └── dependabot.yml
└── README.md
```

## Reusable Workflows

### 1. Hugo Builder (`reusable/hugo-builder.yml`)

Builds and deploys a Hugo site to GitHub Pages.

**Parameters:**
- `base_branch`: The branch to build from (default: 'main')
- `hugo_version_file`: Path to file containing Hugo version (default: '.hugoversion')
- `ignore_paths`: Paths to ignore for triggering builds (default: 'import/\*\*,.github/\*\*')
- `enable_git_info`: Enable Git info in Hugo build (default: true)

### 2. Hugo Updater (`reusable/hugo-updater.yml`)

Checks for Hugo updates weekly and creates PRs to update the version.

**Parameters:**
- `hugo_version_file`: Path to file containing Hugo version (default: '.hugoversion')
- `update_branch`: Branch name to use for update PRs (default: 'update-hugo')
- `pr_title_prefix`: Prefix for PR titles (default: 'Update Hugo:')

### 3. PR Merger (`reusable/pr-merger.yml`)

Automatically merges Dependabot PRs.

**Parameters:**
- `merge_method`: Merge method to use (merge, squash, rebase) (default: 'squash')
- `commit_message`: Commit message template (default: 'pull-request-title')

## Usage

To use these workflows in your Hugo site repository, create the following workflow files:

### 1. `.github/workflows/hugo-build.yml`

```yaml
name: Deploy Hugo Site to Pages

on:
  # Runs on pushes targeting the default branch
  push:
    branches: ["main"]
    paths-ignore:
      - 'import/**'  # Ignore changes to import directory
      - '.github/**'  # Ignore changes to .github directory

  # Allows you to run this workflow manually from the Actions tab
  workflow_dispatch:

  # Triggered by process-photos workflow (if applicable)
  repository_dispatch:
    types: [trigger-hugo-build]

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build-and-deploy:
    uses: your-username/hugo-autopilot/.github/workflows/reusable/hugo-builder.yml@main
    with:
      hugo_version_file: '.hugoversion'
      enable_git_info: true
```

### 2. `.github/workflows/hugo-update.yml`

```yaml
name: Update Hugo

on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  update-hugo:
    uses: your-username/hugo-autopilot/.github/workflows/reusable/hugo-updater.yml@main
    with:
      hugo_version_file: '.hugoversion'
    permissions:
      contents: write
      pull-requests: write
```

### 3. `.github/workflows/dependabot-automerge.yml`

```yaml
name: Dependabot Auto-merge
on: pull_request

permissions:
  contents: write
  pull-requests: write

jobs:
  dependabot-automerge:
    uses: your-username/hugo-autopilot/.github/workflows/reusable/pr-merger.yml@main
    with:
      merge_method: 'squash'
```

## Version Control

For stability, you can pin to specific versions of the workflows:

```yaml
jobs:
  build-and-deploy:
    uses: your-username/hugo-autopilot/.github/workflows/reusable/hugo-builder.yml@v1.0.0
```

## Requirements

- A Hugo site hosted on GitHub
- GitHub Pages enabled for the repository
- A `.hugoversion` file in the root of your repository containing the Hugo version number (e.g., `0.111.3`)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
