#!/bin/sh
# Title: Software Application Installation Script
# Description: This script installs Homebrew (if not already installed), updates it,
# upgrades existing packages, and installs various applications and command-line tools.
# Date: 2024-12-15
# Version: 1.0

set -e

# This script will:
# - Check if Homebrew is installed and install it if not.
# - Update Homebrew to the latest version.
# - Upgrade any already-installed formulae.
# - Install specified command-line tools and applications.
if ! command -v brew >/dev/null; then
  echo "Installing Homebrew 🍺 ..."
    /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make sure we’re using the latest Homebrew.
echo "Updating Homebrew formulae ..."
brew update --force # https://github.com/Homebrew/brew/issues/1151

# Upgrade any already-installed formulae.
echo "Upgrade any already-installed formulae ..."
brew upgrade

# Install unix commandline tools
brew install gnupg
brew install pinentry-mac
brew install ykman
brew install spaceship

# Apps I use
# brew install --cask bitwarden
brew install --cask ccleaner
# brew install --cask microsoft-excel
# brew install --cask microsoft-onenote
# brew install --cask microsoft-powerpoint
# brew install --cask microsoft-word
# brew install --cask microsoft-edge
brew install --cask protonvpn
# brew install --cask spotify
brew install --cask visual-studio-code

# Remove outdated versions from the cellar.
brew cleanup
