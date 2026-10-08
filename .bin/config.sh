#!/bin/bash -eu

check_only=false

if [ "${1:-}" = "--check" ]; then
  check_only=true
elif [ "$#" -gt 0 ]; then
  echo "Usage: $0 [--check]" >&2
  exit 2
fi

# shellcheck source=.bin/config-path.sh
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/config-path.sh"
resolve_config_definitions

definition_dir="${DOTFILES_CONFIG_DEFINITIONS_DIR}"

gitconfig_source="${definition_dir}/git/.gitconfig"
gitignore_source="${definition_dir}/git/.gitignore_global"
ssh_source="${definition_dir}/ssh/config"
zprofile_source="${definition_dir}/zsh/.zprofile"
zshrc_source="${definition_dir}/zsh/.zshrc"

for source_file in \
  "${gitconfig_source}" \
  "${gitignore_source}" \
  "${ssh_source}" \
  "${zprofile_source}" \
  "${zshrc_source}"
do
  if [ ! -r "${source_file}" ]; then
    echo "Resource definition not found or unreadable: ${source_file}" >&2
    exit 1
  fi
done

if [ "${check_only}" = true ]; then
  echo "Resource definitions are valid: ${definition_dir}"
  exit 0
fi

echo "------- Start resource file operation."

mkdir -p "${HOME}/.dotbackup" "${HOME}/.ssh"
chmod 700 "${HOME}/.ssh"

install_link() {
  source_file="$1"
  destination="$2"

  if [ -L "${destination}" ]; then
    unlink "${destination}"
  elif [ -f "${destination}" ]; then
    cp "${destination}" "${HOME}/.dotbackup/"
    rm -f "${destination}"
  fi

  ln -s "${source_file}" "${destination}"
}

install_link "${gitconfig_source}" "${HOME}/.gitconfig"
install_link "${gitignore_source}" "${HOME}/.gitignore_global"
install_link "${ssh_source}" "${HOME}/.ssh/config"
chmod 644 "${HOME}/.ssh/config"
install_link "${zprofile_source}" "${HOME}/.zprofile"
install_link "${zshrc_source}" "${HOME}/.zshrc"

echo "------- Finish resource file operation."
