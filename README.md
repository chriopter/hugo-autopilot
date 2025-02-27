# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

Automated CI/CD workflows for Hugo sites with automatic updates and dependency management.

## Overview

Hugo Autopilot provides a set of reusable GitHub Actions workflows that automate the build, deployment, and maintenance of Hugo sites. These workflows can be referenced from your Hugo site repositories, allowing you to maintain your CI/CD configuration in a single place.

## Features

- **Automated Hugo Builds and Deployments**: Build and deploy your Hugo site to GitHub Pages with optimized settings
- **Automatic Hugo Version Updates**: Automatically check for new Hugo versions and create PRs to update
- **Dependabot Auto-merge**: Automatically merge Dependabot PRs for GitHub Actions dependencies
- **Photo Import Processing**: Automatically process and import photos with proper formatting
- **Centralized Workflow Management**: Maintain your workflows in one place and reference them from multiple repositories

## Reusable Workflows

### 1. Hugo Builder (`hugo-builder.yml`)

Builds and deploys a Hugo site to GitHub Pages.

**Parameters:**
- `base_branch`: The branch to build from (default: 'main')
- `hugo_version_file`: Path to file containing Hugo version (default: '.hugoversion')
- `ignore_paths`: Paths to ignore for triggering builds (default: 'import/\*\*,.github/\*\*')
- `enable_git_info`: Enable Git info in Hugo build (default: true)

### 2. Hugo Updater (`hugo-updater.yml`)

Checks for Hugo updates weekly and creates PRs to update the version.

**Parameters:**
- `hugo_version_file`: Path to file containing Hugo version (default: '.hugoversion')
- `update_branch`: Branch name to use for update PRs (default: 'update-hugo')
- `pr_title_prefix`: Prefix for PR titles (default: 'Update Hugo:')

### 3. PR Merger (`pr-merger.yml`)

Automatically merges Dependabot PRs.

**Parameters:**
- `merge_method`: Merge method to use (merge, squash, rebase) (default: 'squash')
- `commit_message`: Commit message template (default: 'pull-request-title')

### 4. Hugo Photo Importer (`hugo-photoimporter.yml`)

Processes and imports photos to a Hugo site.

**Parameters:**
- `import_directory`: Directory containing photos to import (default: 'import')
- `content_directory`: Directory to store processed photos (default: 'content/photos')
- `trigger_build`: Whether to trigger a Hugo build after processing (default: true)

## Usage

To use these workflows in your Hugo site repository, create the following workflow files:

### 1. `.github/workflows/build-hugo-page.yml`

```yaml
name: Deploy Hugo Site to Pages

on:
  push:
    branches: ["main"]
    paths-ignore:
      - 'import/**'
      - '.github/**'
  workflow_dispatch:
  repository_dispatch:
    types: [trigger-hugo-build]

permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  build-and-deploy:
    uses: chriopter/hugo-autopilot/.github/workflows/hugo-builder.yml@main
    with:
      hugo_version_file: '.hugoversion'
      enable_git_info: true
```

### 2. `.github/workflows/update-hugo.yml`

```yaml
name: Update Hugo

on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday
  workflow_dispatch:

jobs:
  update-hugo:
    uses: chriopter/hugo-autopilot/.github/workflows/hugo-updater.yml@main
    with:
      hugo_version_file: '.hugoversion'
    permissions:
      contents: write
      pull-requests: write
```

### 3. `.github/workflows/automerge.yml`

```yaml
name: Dependabot Auto-merge
on: pull_request

permissions:
  contents: write
  pull-requests: write

jobs:
  dependabot-automerge:
    uses: chriopter/hugo-autopilot/.github/workflows/pr-merger.yml@main
    with:
      merge_method: 'squash'
```

### 4. `.github/workflows/process-photos.yml`

```yaml
name: Import Photos

on:
  push:
    paths:
      - 'import/**'
    branches: ["main"]
  workflow_dispatch:

permissions:
  contents: write
  actions: write

jobs:
  process-photos:
    uses: chriopter/hugo-autopilot/.github/workflows/hugo-photoimporter.yml@main
    with:
      import_directory: 'import'
      content_directory: 'content/photos'
      trigger_build: true
```

## Example Implementation

For a real-world example of these workflows in action, see [christopher-eller.de](https://github.com/chriopter/christopher-eller.de).

## Automation Risks

While automation provides significant benefits, it's important to be aware of potential risks:

1. **Cascading Automation**: These workflows are designed to trigger each other (e.g., photo import triggers site build). This can create cascading effects where one automated action leads to multiple subsequent actions.

2. **Dependency Updates**: Automatic dependency updates might introduce breaking changes. While the PR approach allows for review, frequent updates require vigilance.

3. **Resource Consumption**: Automated workflows consume GitHub Actions minutes. Monitor your usage to avoid unexpected charges.

4. **Security Considerations**: Workflows have permissions to modify repository content and create PRs. Ensure your repository is properly secured.

## Credits

This project builds upon and is inspired by several excellent GitHub Actions:

- [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo) - For Hugo setup and deployment patterns
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request) - For PR creation
- [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata) - For Dependabot PR handling

## Requirements

- A Hugo site hosted on GitHub
- GitHub Pages enabled for the repository
- A `.hugoversion` file in the root of your repository containing the Hugo version number (e.g., `0.123.8`)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
