#!/bin/bash -eu

echo "------- Start AppStore install."

xargs mas install < ${DOTFILES_REPO_DIR}/macOS/.resources/AppStore/mas.txt

echo "------- Finish AppStore install."

exit 0