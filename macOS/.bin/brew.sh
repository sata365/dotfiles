#!/bin/bash -eu

echo "------- Start Homebrew install."

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap homebrew/cask-drivers
xargs brew install < ${DOTFILES_REPO_DIR}/macOS/.resources/Homebrew/brew.txt
xargs brew install --cask --force  < ${DOTFILES_REPO_DIR}/macOS/.resources/Homebrew/cask.txt

echo "------- Finish Homebrew install."

exit 0