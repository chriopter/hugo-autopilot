# Hugo Autopilot

[![Project status: active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![license](https://img.shields.io/github/license/chriopter/hugo-autopilot.svg)](https://github.com/chriopter/hugo-autopilot/blob/main/LICENSE)

A reuseable Workflow to automate the building & updating of a Hugo site with a single workflow file!


> **Note:** Primarly LLM Code - use with caution. Be aware of cascading triggering, potential breaking changes from automatic updates (even major!), resource consumption. Workflows have permissions to modify repository content.


## Features & Workflow Architecture

Hugo Autopilot combines three powerful workflows into a single, easy-to-use solution that you can reference from your Hugo site with just one file. The system uses a smart router mechanism with state management to determine which workflows to run based on the trigger event:

| Event Type | Hugo Builder | Hugo Updater | PR Merger |
|------------|:----------------------------------:|:-----------------------------------:|:------------------------------:|
| | **Rebuilds site cache-free**<br>Checks for pending updates before building | **Updates to newest Hugo version**<br>Creates PR when update found | **Auto-merges Dependabot PRs** |
| Content Change<br>(`push` to main) | ✅ | ❌ | ❌ |
| Weekly Check<br>(`schedule` weekly) | ✅* | ✅ | ❌ |
| After Hugo Update<br>(`repository_dispatch`) | ✅ | ❌ | ❌ |
| Dependency Update<br>(`pull_request`) | ❌ | ❌ | ✅ |
| Manual Trigger<br>(`workflow_dispatch`) | ✅ | ✅ | ✅ |

\* *Triggered indirectly via repository_dispatch after the Hugo Updater completes*

**Safety Mechanism:** 
- When Hugo Updater finds an update, it creates a PR and sets a pending state
- Hugo Builder checks this state before building - if an update is pending, it skips the build to prevent race conditions
- After the PR is merged, a new build is automatically triggered with the updated Hugo version
- When no update is found during weekly checks, a build is still triggered to ensure the site stays up-to-date
- Content changes (push events) always trigger a build as long as there are no pending updates

**Workflow Components:**
- **Hugo Builder:** Rebuilds site cache-free (Triggered by: content changes, manual triggers, after Hugo updates, and indirectly after weekly checks)
- **Hugo Updater:** Updates to newest Hugo version (Triggered by: weekly schedule, manual triggers). Uses PR-based state management to prevent race conditions - when an update is found, it creates a PR with a specific title prefix, which prevents builds until the PR is merged, ensuring the site is always built with the correct Hugo version. When no update is found, it still triggers a build to keep the site up-to-date.
- **PR Merger:** Auto-merges Dependabot PRs (Triggered by: dependency updates, manual triggers)

Note: Dependency updates are also used by this repo to always use newest sub-workflows like peaceiris/actions-hugo.

Here's a real-world example from [christopher-eller.de](https://github.com/chriopter/christopher-eller.de):

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
   - This ensures the workflow can trigger other workflows after Hugo updates

4. **Create the workflow file** at `.github/workflows/hugo-autopilot.yml` (see below)

## Workflow File

Create this file at `.github/workflows/hugo-autopilot.yml`:

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
    types: [hugo-autopilot-build]

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
      # Prefix for Hugo update PR titles (used for state tracking)
      pr_title_prefix: 'Update Hugo:'
```

### External Triggers

The hugo-autopilot.yml file you created above is configured to listen for the `repository_dispatch` event with type `hugo-autopilot-build`. You can use this to trigger your Hugo site build from other workflows:

<details>
<summary>Click to expand external trigger example</summary>

```yaml
# Add this to your other workflow files when you need to trigger a site rebuild
- name: Trigger Hugo site rebuild
  uses: peter-evans/repository-dispatch@v3
  with:
    # This targets your own repository
    token: ${{ secrets.GITHUB_TOKEN }}
    # This matches the event type in your hugo-autopilot.yml file
    event-type: hugo-autopilot-build
```
</details>

## Credits

This project builds upon and is inspired by several excellent GitHub Actions:

- [peaceiris/actions-hugo](https://github.com/peaceiris/actions-hugo) - For Hugo setup and deployment patterns
- [peter-evans/create-pull-request](https://github.com/peter-evans/create-pull-request) - For PR creation
- [dependabot/fetch-metadata](https://github.com/dependabot/fetch-metadata) - For Dependabot PR handling

## License

This project is licensed under the MIT License - see the LICENSE file for details.
