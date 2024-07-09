#!/bin/bash -eu

echo "------- Start resource file operation."

[ -d ~/.dotbackup ] || mkdir ~/.dotbackup

# gitconfig
[ -L ~/.gitconfig ] && unlink ~/.gitconfig
[ -f ~/.gitconfig ] && cp ~/.gitconfig ~/.dotbackup/ && rm -f ~/.gitconfig
ln -s ${DOTFILES_REPO_DIR}/macOS/.resources/git/.gitconfig ~/.gitconfig

[ -L ~/.gitignore_global ] && unlink ~/.gitignore_global
[ -f ~/.gitignore_global ] && cp ~/.gitignore_global ~/.dotbackup/ && rm -f ~/.gitignore_global
ln -s ${DOTFILES_REPO_DIR}/macOS/.resources/git/.gitignore_global ~/.gitignore_global

# sshconfig
[ -L ~/.ssh/config ] && unlink ~/.ssh/config
[ -f ~/.ssh/config ] && cp -r ~/.ssh/config ~/.dotbackup/ && rm -f ~/.ssh/config
[ -d ~/.ssh ] || mkdir ~/.ssh && chmod 700 ~/.ssh
ln -s ${DOTFILES_REPO_DIR}/macOS/.resources/ssh/config ~/.ssh/config && chmod -R 644 ~/.ssh/config

# zsh
[ -L ~/.zprofile ] && unlink ~/.zprofile
[ -f ~/.zprofile ] && cp ~/.zprofile ~/.dotbackup/ && rm -f ~/.zprofile
ln -s ${DOTFILES_REPO_DIR}/macOS/.resources/zsh/.zprofile ~/.zprofile
[ -L ~/.zshrc ] && unlink ~/.zshrc
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.dotbackup/ && rm -f ~/.zshrc
ln -s ${DOTFILES_REPO_DIR}/macOS/.resources/zsh/.zshrc ~/.zshrc


echo "------- Finish resource file operation."
