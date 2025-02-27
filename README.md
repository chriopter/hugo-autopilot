# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

Automated CI/CD workflows for Hugo sites with automatic updates and dependency management.

> **Note:** This project was primarily created with LLM Code and should be used with caution. Be aware of automation risks including cascading effects (workflows triggering each other), potential breaking changes from automatic updates, GitHub Actions resource consumption, and security considerations as workflows have permissions to modify repository content.

## Overview

Hugo Autopilot provides a set of reusable GitHub Actions workflows that automate the build, deployment, and maintenance of Hugo sites. These workflows can be referenced from your Hugo site repositories, allowing you to maintain your CI/CD configuration in a single place.

## Features & Workflows

Hugo Autopilot offers three reusable workflows combined into a single router workflow:

1. **Hugo Builder** (`hugo-builder.yml`) - Builds and deploys Hugo sites to GitHub Pages
   - Parameters: `base_branch`, `hugo_version_file`, `ignore_paths`, `enable_git_info`

2. **Hugo Updater** (`hugo-updater.yml`) - Checks for Hugo updates and creates PRs that are automerged to trigger rebuilds on newest Hugo-Version
   - Parameters: `hugo_version_file`, `update_branch`, `pr_title_prefix`

3. **PR Merger** (`pr-merger.yml`) - Auto-merges Dependabot PRs
   - Parameters: `merge_method`, `commit_message`

4. **Router** (`hugo-autopilot-router.yml`) - Routes events to the appropriate workflow based on the trigger
   - Combines all workflows into a single entry point

## Installation

To set up Hugo Autopilot for your Hugo site:

1. [ ] Create a `.hugoversion` file in your repository root with your Hugo version (e.g., `0.123.8`)
2. [ ] Copy the dependabot.yml template to your repository at `.github/dependabot.yml`
3. [ ] Create a single workflow file at `.github/workflows/hugo-autopilot.yml`
4. [ ] Ensure GitHub Pages is enabled for your repository
5. [ ] Push changes to your repository

## Usage Example

To use Hugo Autopilot in your Hugo site repository, create a single workflow file as shown in this real-world example from [christopher-eller.de](https://github.com/chriopter/christopher-eller.de):

### `.github/workflows/hugo-autopilot.yml`

```yaml
name: Hugo Autopilot

on:
  # Triggers the build and deploy job when you push to main branch
  # Ignores changes to import directory to avoid conflicts with photo processing
  push:
    branches: ["main"]
    paths-ignore:
      - 'import/**'
  
  # Triggers the Hugo update job weekly to check for new Hugo versions
  # Runs at 6:00 AM on Mondays to minimize disruption
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday
  
  # Triggers the PR auto-merge job when Dependabot creates a PR
  # Automatically handles dependency updates
  pull_request:
  
  # Allows manual triggering of all jobs from the GitHub Actions tab
  # Useful for testing or forcing updates
  workflow_dispatch:
  
  # Allows other workflows to trigger the build job
  # Used by the photo processing workflow to rebuild after adding photos
  repository_dispatch:
    types: [trigger-hugo-build]

jobs:
  # Single job that routes to the appropriate workflow based on the trigger
  autopilot:
    uses: chriopter/hugo-autopilot/.github/workflows/hugo-autopilot-router.yml@main
    with:
      # Path to your Hugo version file
      hugo_version_file: '.hugoversion'
      # Enable Git info for Hugo (last modified dates, etc.)
      enable_git_info: true
      # Method to use when merging PRs
      merge_method: 'squash'
```

This single workflow file handles all Hugo CI/CD tasks:
- Building and deploying your site on push to main
- Updating Hugo weekly and creating PRs
- Auto-merging Dependabot PRs
- Responding to manual triggers and repository dispatch events

## Credits

This project builds upon and is inspired by several excellent GitHub Actions:

- [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo) - For Hugo setup and deployment patterns
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request) - For PR creation
- [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata) - For Dependabot PR handling

## License

This project is licensed under the MIT License - see the LICENSE file for details.
