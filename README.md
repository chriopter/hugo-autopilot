# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

Automated CI/CD workflows for Hugo sites with automatic updates and dependency management.

> **Note:** This project was primarily created with LLM Code and should be used with caution. Be aware of automation risks including cascading effects (workflows triggering each other), potential breaking changes from automatic updates, GitHub Actions resource consumption, and security considerations as workflows have permissions to modify repository content.

## Overview

Hugo Autopilot provides a set of reusable GitHub Actions workflows that automate the build, deployment, and maintenance of Hugo sites. These workflows can be referenced from your Hugo site repositories, allowing you to maintain your CI/CD configuration in a single place.

## Features & Workflow Triggers

Hugo Autopilot combines three powerful workflows into a single, easy-to-use solution that you can reference from your Hugo site with just one file. The system uses a router mechanism to determine which workflows to run based on the trigger event:

### Hugo Builder
- **Triggered by**: 
  - `push` to main branch ✅
  - `repository_dispatch` events ✅
  - `workflow_dispatch` (manual) ✅
- **What it does**: Builds your Hugo site and deploys it to GitHub Pages
- **Customization**: Configure Git info, Hugo version, and other build parameters

### Hugo Updater
- **Triggered by**: 
  - `schedule` (weekly on Monday at 6 AM) ✅
  - `workflow_dispatch` (manual) ✅
  - Normal commits/pushes ❌
- **What it does**: 
  1. Checks for new Hugo versions by comparing your `.hugoversion` file with the latest release
  2. Creates a pull request to update your Hugo version if an update is available
  3. Automatically merges the PR after creation
- **Note**: This workflow does NOT run on normal commits - it only runs on schedule or when manually triggered to avoid creating too many PRs

### PR Merger
- **Triggered by**: 
  - `pull_request` events ✅
  - `workflow_dispatch` (manual) ✅
- **What it does**: Automatically merges dependency update PRs that meet certain criteria
- **Customization**: Configure merge method and PR filtering

Here's a real-world example from [christopher-eller.de](https://github.com/chriopter/christopher-eller.de):

## Installation

1. [ ] Create a `.hugoversion` file in your repository root with your Hugo version (e.g., `0.123.8`)
2. [ ] Copy the dependabot.yml template to your repository at `.github/dependabot.yml`:

<details>
<summary>Click to expand dependabot.yml template</summary>

```yaml
# Template: dependabot.yml
# Copy this file to your Hugo site repository at .github/dependabot.yml

version: 2
updates:
  # Maintain dependencies for GitHub Actions
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    # Limit to 5 open pull requests for version updates
    open-pull-requests-limit: 5
    # Add labels to pull requests
    labels:
      - "dependencies"
      - "github-actions"
    # Use custom commit message
    commit-message:
      prefix: "ci"
      include: "scope"
    # Group all updates together
    groups:
      github-actions:
        patterns:
          - "*"

  # Uncomment if using npm in your Hugo site (e.g., for JavaScript processing)
  # - package-ecosystem: "npm"
  #   directory: "/"
  #   schedule:
  #     interval: "monthly"
  #   open-pull-requests-limit: 5
  #   labels:
  #     - "dependencies"
  #     - "npm"
  #   commit-message:
  #     prefix: "build"
  #     include: "scope"
```
</details>

3. [ ] Enable required GitHub settings: In repository settings, enable Actions with write permissions, PR creation, and auto-merge.

4. [ ] Create the following workflow file:

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
    uses: chriopter/hugo-autopilot/.github/workflows/hugo-autopilot.yml@main
    with:
      # Path to your Hugo version file
      hugo_version_file: '.hugoversion'
      # Enable Git info for Hugo (last modified dates, etc.)
      enable_git_info: true
      # Method to use when merging PRs
      merge_method: 'squash'
```

## Credits

This project builds upon and is inspired by several excellent GitHub Actions:

- [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo) - For Hugo setup and deployment patterns
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request) - For PR creation
- [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata) - For Dependabot PR handling

## License

This project is licensed under the MIT License - see the LICENSE file for details.
