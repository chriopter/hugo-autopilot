# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

Automate your Hugo site maintenance with GitHub Actions workflows. Set up once, then let it handle builds, deployments, and updates automatically.

Used for example here [christopher-eller.de](https://github.com/chriopter/christopher-eller.de).

> **Note:** Primarly LLM Code - use with caution. Be aware of cascading triggering, potential breaking changes from automatic updates (even major!), resource consumption. Workflows have permissions to modify repository content.


## Features & Workflow Architecture

Three reusable workflows that automate your Hugo site maintenance:

| Workflow | Purpose | Triggers & Actions |
|----------|---------|-------------------|
| **Hugo Builder** | Builds and deploys your Hugo site to GitHub Pages. Automatically checks out Git submodules and installs npm dependencies during the build process. | **Triggers:** Push to main, external calls via `repository_dispatch`, manual UI trigger<br>**Actions:** Checkout repo, install npm deps if present, build with Hugo version from `.hugoversion`, deploy to Pages |
| **Hugo Updater** | Updates Hugo version and triggers rebuild with newest version. | **Triggers:** Weekly schedule, manual UI trigger<br>**Actions:** Check for updates, create PR, auto-merge, trigger Builder workflow |
| **Dependabot Merger** | Auto-merges dependency updates of github workflows. Used in this repo as well to update what's used in builder, updater. | **Triggers:** Dependabot PRs, manual UI trigger<br>**Actions:** Verify Dependabot PR, auto-merge |


## Setup Guide

### One-line setup

```bash
curl -s https://raw.githubusercontent.com/chriopter/hugo-autopilot/main/setup.sh | bash
```

This script copies the .hugoversion file and downloads all required workflow files.

### Manual setup

1. **Copy required files** from the `example-user-repo`:
   - `.hugoversion` - Contains your Hugo version
   - `.github/dependabot.yml` - Enables automatic dependency updates
   - `.github/workflows/` - Contains all three workflow files

2. **Configure GitHub settings**:
   - Repository → Actions → General → Workflow permissions:
     - ✅ Read and write permissions
     - ✅ Allow GitHub Actions to create and approve pull requests
     - ✅ Allow GitHub Actions to request the id-token write permission


## External Triggers

The **Hugo Builder** workflow can be triggered from external sources using the `repository_dispatch` event with type `hugo-autopilot-build`. Add this to your workflows to trigger a site rebuild:

```yaml
- name: Trigger Hugo site rebuild
  uses: peter-evans/repository-dispatch@v3
  with:
    token: ${{ secrets.GITHUB_TOKEN }}
    event-type: hugo-autopilot-build
```


## Credits

This project builds upon and is inspired by several excellent GitHub Actions:

- [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo) - For Hugo setup and deployment patterns
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request) - For PR creation
- [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata) - For Dependabot PR handling

## License

This project is licensed under the MIT License - see the LICENSE file for details.
