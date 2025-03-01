# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

A set of reusable workflows to automate the building & updating of a Hugo site!

Used for example here [christopher-eller.de](https://github.com/chriopter/christopher-eller.de).

> **Note:** Primarly LLM Code - use with caution. Be aware of cascading triggering, potential breaking changes from automatic updates (even major!), resource consumption. Workflows have permissions to modify repository content.


## Features & Workflow Architecture

Three reusable workflows that automate your Hugo site maintenance:

### 1. Hugo Builder
- **Purpose:** Builds and deploys your Hugo site to GitHub Pages  
- **Triggers:** Push to main, external calls via `repository_dispatch`, manual UI trigger  
- **Actions:** Checkout repo, build with Hugo version from `.hugoversion`, deploy to Pages
- **Note:** Automatically checks out Git submodules during the build process (updates themes etc.).

### 2. Hugo Updater
- **Purpose:** Updates Hugo version and triggers rebuild  
- **Triggers:** Weekly schedule, manual UI trigger  
- **Actions:** Check for updates, create PR, auto-merge, trigger Builder workflow

### 3. Dependabot Merger
**Purpose:** Auto-merges dependency updates  
**Triggers:** Dependabot PRs, manual UI trigger  
**Actions:** Verify Dependabot PR, auto-merge
**Note:** Used in this repo itself to keep sub-workflows like peaceiris/actions-hugo updated.

## Setup Guide

See the `example-user-repo` folder for reference files. To set up Hugo Autopilot in your repository:

1. **Create a `.hugoversion` file** in your repository root with your Hugo version (e.g., `0.123.8`)

2. **Add a dependabot.yml file** at `.github/dependabot.yml` to enable automatic dependency updates

3. **Configure GitHub settings**:
   - Repository settings → Actions → General → Workflow permissions:
     - Enable "Read and write permissions"
     - Enable "Allow GitHub Actions to create and approve pull requests"
     - Enable "Allow GitHub Actions to request the id-token write permission"

4. **Create workflow files** in `.github/workflows/`:
   - `hugo-autopilot-builder.yml` - Builds and deploys your site
   - `hugo-autopilot-updater.yml` - Checks for Hugo updates
   - `hugo-autopilot-dependabot-merger.yml` - Auto-merges dependency PRs



## External Triggers

### Callable Triggers

The only workflow that can be explicitly triggered from external sources is the **Hugo Builder** workflow. It listens for the `repository_dispatch` event with type `hugo-autopilot-build`.

You can trigger a Hugo site build from:
- Other workflows in your repository
- External systems that can make API calls to GitHub
- Custom scripts or automation tools

### How to Call the Hugo Builder Workflow

Add this to your other workflow files when you need to trigger a site rebuild:

```yaml
- name: Trigger Hugo site rebuild
  uses: peter-evans/repository-dispatch@v3
  with:
    # This targets your own repository
    token: ${{ secrets.GITHUB_TOKEN }}
    # This matches the event type in your hugo-autopilot-builder.yml file
    event-type: hugo-autopilot-build
```



## Credits

This project builds upon and is inspired by several excellent GitHub Actions:

- [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo) - For Hugo setup and deployment patterns
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request) - For PR creation
- [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata) - For Dependabot PR handling

## License

This project is licensed under the MIT License - see the LICENSE file for details.
