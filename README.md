# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

Automated CI/CD workflows for Hugo sites with automatic updates and dependency management.

> **Note:** This project was primarily created with LLM Code and should be used with caution. Be aware of automation risks including cascading effects (workflows use other parent workflows), potential breaking changes from automatic updates, GitHub Actions resource consumption, and security considerations as workflows have permissions to modify repository content.

## Overview

Hugo Autopilot provides a set of reusable GitHub Actions workflows that automate the build, deployment, and maintenance of Hugo sites. These workflows can be referenced from your Hugo site repositories, allowing you to maintain your CI/CD configuration in a single place.

## Features & Workflows

Hugo Autopilot offers four reusable workflows:

1. **Hugo Builder** (`hugo-builder.yml`) - Builds and deploys Hugo sites to GitHub Pages
   - Parameters: `base_branch`, `hugo_version_file`, `ignore_paths`, `enable_git_info`

2. **Hugo Updater** (`hugo-updater.yml`) - Checks for Hugo updates and creates PRs that are automerged to trigger rebuilds on newest Hugo-Version
   - Parameters: `hugo_version_file`, `update_branch`, `pr_title_prefix`

3. **PR Merger** (`pr-merger.yml`) - Auto-merges Dependabot PRs
   - Parameters: `merge_method`, `commit_message`

4. **Hugo Photo Importer** (`hugo-photoimporter.yml`) - Processes and imports photos
   - Parameters: `import_directory`, `content_directory`, `trigger_build`

## Installation

To set up Hugo Autopilot for your Hugo site:

1. [ ] Create a `.hugoversion` file in your repository root with your Hugo version (e.g., `0.123.8`)
2. [ ] Copy the dependabot.yml template to your repository at `.github/dependabot.yml`
3. [ ] Create the workflow files in your `.github/workflows/` directory:
   - [ ] `build-hugo-page.yml`
   - [ ] `update-hugo.yml`
   - [ ] `automerge.yml`
   - [ ] `process-photos.yml` (if using photo import feature)
4. [ ] Ensure GitHub Pages is enabled for your repository
5. [ ] Push changes to your repository

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

## Credits

This project builds upon and is inspired by several excellent GitHub Actions:

- [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo) - For Hugo setup and deployment patterns
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request) - For PR creation
- [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata) - For Dependabot PR handling