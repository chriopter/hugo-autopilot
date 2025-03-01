# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

A set of reusable workflows to automate the building & updating of a Hugo site!

Used for example here [christopher-eller.de](https://github.com/chriopter/christopher-eller.de).

> **Note:** Primarly LLM Code - use with caution. Be aware of cascading triggering, potential breaking changes from automatic updates (even major!), resource consumption. Workflows have permissions to modify repository content.


## Features & Workflow Architecture

Three reusable workflows that automate your Hugo site maintenance:

### Hugo Builder
Builds and deploys your Hugo site to GitHub Pages. Automatically checks out Git submodules during the build process (updates themes etc.).
- **Triggers:** Push to main, external calls via `repository_dispatch`, manual UI trigger  
- **Actions:** Checkout repo, build with Hugo version from `.hugoversion`, deploy to Pages

### Hugo Updater
Updates Hugo version and triggers rebuild with newest version.
- **Triggers:** Weekly schedule, manual UI trigger  
- **Actions:** Check for updates, create PR, auto-merge, trigger Builder workflow

### Dependabot Merger
Auto-merges dependency updates of github workflows. Used in this repo as well to update whats used in builder, updater.
- **Triggers:** Dependabot PRs, manual UI trigger  
- **Actions:** Verify Dependabot PR, auto-merge


## Setup Guide

See the `example-user-repo` folder for reference files. To set up Hugo Autopilot in your repository:

1. **Copy all required files** from the example repository:
   - `.hugoversion` file in your repository root with your Hugo version (e.g., `0.123.8`)
   - `.github/dependabot.yml` to enable automatic dependency updates
   - `.github/workflows/` directory with all three workflow files:
     - `hugo-autopilot-builder.yml` - Builds and deploys your site
     - `hugo-autopilot-updater.yml` - Checks for Hugo updates
     - `hugo-autopilot-dependabot-merger.yml` - Auto-merges dependency PRs

2. **Configure GitHub settings**:
   - Repository settings → Actions → General → Workflow permissions:
     - Enable "Read and write permissions"
     - Enable "Allow GitHub Actions to create and approve pull requests"
     - Enable "Allow GitHub Actions to request the id-token write permission"



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
