# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

Automate your Hugo site maintenance with GitHub Actions workflows. Set up once, then let it handle builds, deployments, and updates automatically.

**Live example:** [christopher-eller.de](https://github.com/chriopter/christopher-eller.de)

## Table of Contents
- [Quick Start](#quick-start)
- [Features](#features)
- [Setup Guide](#setup-guide)
- [Credits](#credits)
- [License](#license)

## Quick Start

1. Copy example files to your Hugo repository:
   ```
   .hugoversion
   .github/dependabot.yml
   .github/workflows/hugo-autopilot-*.yml
   ```

2. Enable GitHub Actions permissions in repository settings

3. Push to main branch to trigger your first automated build

⚠️ **CAUTION:** This project uses automated updates that may introduce breaking changes. Workflows have permissions to modify repository content.

## Features

Hugo Autopilot provides three automated workflows:

| Workflow | Purpose | Triggers | Actions |
|----------|---------|----------|---------|
| **Hugo Builder** | Builds & deploys site | Push to main, manual, external API | Checkout repo with submodules, build with Hugo version from `.hugoversion`, deploy to Pages |
| **Hugo Updater** | Updates Hugo version | Weekly schedule, manual | Check for updates, create PR, auto-merge, trigger Builder |
| **Dependabot Merger** | Auto-merges dependencies | Dependabot PRs, manual | Verify PR, auto-merge |

**External Triggering:** The Builder workflow can be called from other workflows:

```yaml
- name: Trigger Hugo site rebuild
  uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    event-type: hugo-autopilot-build
```

## Setup Guide

1. **Copy required files** from the `example-user-repo`:
   - `.hugoversion` - Contains your Hugo version
   - `.github/dependabot.yml` - Enables automatic dependency updates
   - `.github/workflows/` - Contains all three workflow files

2. **Configure GitHub settings**:
   - Repository → Actions → General → Workflow permissions:
     - ✅ Read and write permissions
     - ✅ Allow GitHub Actions to create and approve pull requests
     - ✅ Allow GitHub Actions to request the id-token write permission

## Credits

Built with these excellent GitHub Actions:
- [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo)
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request)
- [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata)

## License

MIT License - see the LICENSE file for details.
