#!/bin/bash

# Hugo Autopilot Setup Script
# This script sets up the necessary files for Hugo Autopilot in your Hugo site repository

echo "Setting up Hugo Autopilot..."

# Create necessary directories
mkdir -p .github/workflows

# Copy .hugoversion file if it doesn't exist
if [ ! -f .hugoversion ]; then
  echo "Creating .hugoversion file..."
  echo "0.123.8" > .hugoversion
  echo "Created .hugoversion with default Hugo version 0.123.8"
  echo "You may want to update this to your preferred Hugo version"
fi

# Download dependabot.yml
echo "Downloading dependabot.yml..."
curl -s -o .github/dependabot.yml https://raw.githubusercontent.com/chriopter/hugo-autopilot/main/.github/dependabot.yml

# Download workflow files
echo "Downloading workflow files..."
curl -s -o .github/workflows/hugo-autopilot-builder.yml https://raw.githubusercontent.com/chriopter/hugo-autopilot/main/.github/workflows/hugo-autopilot-builder.yml
curl -s -o .github/workflows/hugo-autopilot-updater.yml https://raw.githubusercontent.com/chriopter/hugo-autopilot/main/.github/workflows/hugo-autopilot-updater.yml
curl -s -o .github/workflows/hugo-autopilot-dependabot-merger.yml https://raw.githubusercontent.com/chriopter/hugo-autopilot/main/.github/workflows/hugo-autopilot-dependabot-merger.yml

echo "Setup complete!"
echo "Don't forget to configure GitHub repository settings:"
echo "  Repository → Actions → General → Workflow permissions:"
echo "    - Enable 'Read and write permissions'"
echo "    - Enable 'Allow GitHub Actions to create and approve pull requests'"
echo "    - Enable 'Allow GitHub Actions to request the id-token write permission'"
