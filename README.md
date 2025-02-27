# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

Automated CI/CD workflows for Hugo sites with automatic updates and dependency management.

> **Note:** This project was primarily created with LLM Code and should be used with caution. Be aware of automation risks including cascading effects (workflows triggering each other), potential breaking changes from automatic updates, GitHub Actions resource consumption, and security considerations as workflows have permissions to modify repository content.

## Overview

Hugo Autopilot provides a set of reusable GitHub Actions workflows that automate the build, deployment, and maintenance of Hugo sites. These workflows can be referenced from your Hugo site repositories, allowing you to maintain your CI/CD configuration in a single place.

## Features & Usage Example

Hugo Autopilot combines three powerful workflows into a single, easy-to-use solution:

1. **Hugo Builder** - Builds and deploys Hugo sites to GitHub Pages
2. **Hugo Updater** - Checks for Hugo updates and creates PRs
3. **PR Merger** - Auto-merges Dependabot PRs

All these features are accessed through a single router workflow that you can reference from your Hugo site with just one file, as shown in this real-world example from [christopher-eller.de](https://github.com/chriopter/christopher-eller.de):

### Installation

1. [ ] Create a `.hugoversion` file in your repository root with your Hugo version (e.g., `0.123.8`)
2. [ ] Copy the dependabot.yml template to your repository at `.github/dependabot.yml`
3. [ ] Create the following workflow file:

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
