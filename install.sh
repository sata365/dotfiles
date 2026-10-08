#!/bin/bash -eu

echo "------- Start configuration."

export DOTFILES_REPO_DIR="${DOTFILES_REPO_DIR:-${HOME}/git/dotfiles}"
export DOTFILES_CONFIG_REPO_DIR="${DOTFILES_CONFIG_REPO_DIR:-${HOME}/git/dotfiles-config}"

if [ ! -d "${DOTFILES_REPO_DIR}/.git" ]; then
  git clone https://github.com/sata365/dotfiles.git "${DOTFILES_REPO_DIR}"
else
  git -C "${DOTFILES_REPO_DIR}" pull --ff-only origin
fi

# shellcheck source=.bin/config-path.sh
source "${DOTFILES_REPO_DIR}/.bin/config-path.sh"
resolve_config_definitions

/bin/bash "${DOTFILES_REPO_DIR}/.bin/defaults.sh" --check
/bin/bash "${DOTFILES_REPO_DIR}/.bin/brew.sh" --check
/bin/bash "${DOTFILES_REPO_DIR}/.bin/config.sh" --check

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
fi

/bin/bash "${DOTFILES_REPO_DIR}/.bin/defaults.sh"
/bin/bash "${DOTFILES_REPO_DIR}/.bin/brew.sh"
/bin/bash "${DOTFILES_REPO_DIR}/.bin/config.sh"

echo "------- Finish configuration."
