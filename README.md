# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

A set of reusable workflows to automate the building & updating of a Hugo site!

Used for example here [christopher-eller.de](https://github.com/chriopter/christopher-eller.de).

> **Note:** Primarly LLM Code - use with caution. Be aware of cascading triggering, potential breaking changes from automatic updates (even major!), resource consumption. Workflows have permissions to modify repository content.


## Features & Workflow Architecture

Three reusable workflows that automate your Hugo site maintenance:

### **Hugo Builder** (`hugo-autopilot-builder.yml`)
Builds and deploys your Hugo site to GitHub Pages.

**Triggers:** Push to main, external calls via `repository_dispatch`, manual UI trigger

**Actions:** Checkout repo, build with Hugo version from `.hugoversion`, deploy to Pages

### **Hugo Updater** (`hugo-autopilot-updater.yml`)
Updates Hugo version and triggers rebuild.

**Triggers:** Weekly schedule, manual UI trigger

**Actions:** Check for updates, create PR, auto-merge, trigger Builder workflow

### **Dependabot Merger** (`hugo-autopilot-dependabot-merger.yml`)
Auto-merges dependency updates.

**Triggers:** Dependabot PRs, manual UI trigger

**Actions:** Verify Dependabot PR, auto-merge

**Note:** Keeps sub-workflows like peaceiris/actions-hugo updated.

## Prepare Repo

1. **Create a `.hugoversion` file** in your repository root with your Hugo version (e.g., `0.123.8`)

2. **Copy the dependabot.yml template** to your repository at `.github/dependabot.yml`:

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

3. **Enable required GitHub settings**: 
   - In repository settings → Actions → General → Workflow permissions:
     - Select "Read and write permissions"
     - Check "Allow GitHub Actions to create and approve pull requests"
     - Enable "Allow GitHub Actions to request the id-token write permission"
   - This ensures the workflow can trigger other workflows and handle cross-organization permissions

4. **Create the three workflow files** in your `.github/workflows/` directory (see below)

## Workflow Files

### 1. Hugo Builder Workflow

Create this file at `.github/workflows/hugo-autopilot-builder.yml`:

```yaml
name: Hugo Autopilot Builder

on:
  # Triggers the build and deploy job when you push to main branch
  push:
    branches: ["main"]
    paths-ignore:
      - 'import/**'
      - '.github/**'
  
  # Allows manual triggering from the GitHub Actions tab
  workflow_dispatch:
  
  # Allows other workflows to trigger the build job
  repository_dispatch:
    types: [hugo-autopilot-build]

# Sets permissions of the GITHUB_TOKEN to allow deployment to GitHub Pages
permissions:
  contents: read
  pages: write
  id-token: write

jobs:
  # Build and deploy Hugo site
  build:
    uses: chriopter/hugo-autopilot/.github/workflows/hugo-autopilot-builder.yml@main
    permissions:
      contents: read
      pages: write
      id-token: write
    with:
      # Path to your Hugo version file
      hugo_version_file: '.hugoversion'
      # Enable Git info for Hugo (last modified dates, etc.)
      enable_git_info: true
      # The branch to build from
      base_branch: 'main'
      # Paths to ignore for triggering builds
      ignore_paths: 'import/**,.github/**'
```

### 2. Hugo Updater Workflow

Create this file at `.github/workflows/hugo-autopilot-updater.yml`:

```yaml
name: Hugo Autopilot Updater

on:
  # Triggers the Hugo update job weekly to check for new Hugo versions
  schedule:
    - cron: '0 6 * * 1'  # Weekly on Monday
  
  # Allows manual triggering from the GitHub Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow PR creation and merging
permissions:
  contents: write
  pull-requests: write

jobs:
  # Update Hugo version
  update:
    uses: chriopter/hugo-autopilot/.github/workflows/hugo-autopilot-updater.yml@main
    permissions:
      contents: write
      pull-requests: write
    with:
      # Path to your Hugo version file
      hugo_version_file: '.hugoversion'
      # Branch name to use for update PRs
      update_branch: 'update-hugo'
      # Prefix for Hugo update PR titles
      pr_title_prefix: 'Update Hugo:'
```

### 3. Dependabot Merger Workflow

Create this file at `.github/workflows/hugo-autopilot-dependabot-merger.yml`:

```yaml
name: Hugo Autopilot Dependabot Merger

on:
  # Triggers the PR auto-merge job when Dependabot creates a PR
  pull_request:
  
  # Allows manual triggering from the GitHub Actions tab
  workflow_dispatch:

# Sets permissions of the GITHUB_TOKEN to allow PR merging
permissions:
  contents: write
  pull-requests: write

jobs:
  # Auto-merge Dependabot PRs
  automerge:
    uses: chriopter/hugo-autopilot/.github/workflows/hugo-autopilot-dependabot-merger.yml@main
    permissions:
      contents: write
      pull-requests: write
    with:
      # Method to use when merging PRs
      merge_method: 'squash'
      # Commit message template
      commit_message: 'pull-request-title'
```

### Git Submodules Support

Hugo Autopilot automatically checks out Git submodules during the build process. If your Hugo site uses submodules (e.g., for themes), make sure you've committed and pushed all changes to both your theme repository and your main site repository.

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

Note: The Hugo Updater workflow automatically triggers the Hugo Builder workflow after updating the Hugo version, using this same mechanism.

## Credits

This project builds upon and is inspired by several excellent GitHub Actions:

- [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo) - For Hugo setup and deployment patterns
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request) - For PR creation
- [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata) - For Dependabot PR handling

## License

This project is licensed under the MIT License - see the LICENSE file for details.
