#!/bin/bash -eu

# Keep fail-fast behavior when invoked as /bin/bash config.sh.
set -eu

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

definition_dir="$(cd "${DOTFILES_CONFIG_DEFINITIONS_DIR}" && pwd -P)"
definition_file="${DOTFILES_LINKS_DEFINITION_FILE:-${definition_dir}/links.json}"

if [ ! -r "${definition_file}" ]; then
  echo "Link definition not found or unreadable: ${definition_file}" >&2
  exit 1
fi

/usr/bin/plutil -convert json -o /dev/null "${definition_file}"
count="$(/usr/bin/plutil -extract links raw -expect array "${definition_file}")"
sources=()
destinations=()
modes=()
parent_modes=()

read_string() {
  /usr/bin/plutil -extract "$1" raw -expect string "${definition_file}"
}

read_mode() {
  local key="$1"
  local mode=""
  if /usr/bin/plutil -type "${key}" "${definition_file}" >/dev/null 2>&1; then
    mode="$(read_string "${key}")" || return 1
    if [[ ! "${mode}" =~ ^[0-7]{3,4}$ ]]; then
      echo "Invalid permission mode at ${key}: ${mode}" >&2
      return 1
    fi
  fi
  printf '%s' "${mode}"
}

resolve_path() {
  local path="$1"
  local base="$2"
  case "${path}" in
    '${HOME}/'*) path="${HOME}/${path#*/}" ;;
    '~/'*) path="${HOME}/${path#*/}" ;;
    /*) ;;
    *) path="${base}/${path}" ;;
  esac
  # Keep destinations unambiguous when checking duplicate and nested links.
  if [[ "${path}" = *'//'* ]] || [[ "${path}/" = *'/./'* ]] || [[ "${path}/" = *'/../'* ]]; then
    echo "Path must not contain empty, '.' or '..' components: ${path}" >&2
    return 1
  fi
  printf '%s' "${path%/}"
}

for ((index = 0; index < count; index++)); do
  source_path="$(read_string "links.${index}.source")"
  destination="$(read_string "links.${index}.dest")"
  if [ -z "${source_path}" ] || [ -z "${destination}" ]; then
    echo "Link source and dest must not be empty at links.${index}." >&2
    exit 1
  fi
  source_path="$(resolve_path "${source_path}" "${definition_dir}")"
  destination="$(resolve_path "${destination}" "${HOME}")"
  mode="$(read_mode "links.${index}.mode")"
  parent_mode="$(read_mode "links.${index}.parentMode")"

  if { [ ! -f "${source_path}" ] && [ ! -d "${source_path}" ]; } || [ ! -r "${source_path}" ]; then
    echo "Link source is not a readable file or directory: ${source_path}" >&2
    exit 1
  fi
  if [ -d "${source_path}" ] && [ ! -x "${source_path}" ]; then
    echo "Link source directory is not searchable: ${source_path}" >&2
    exit 1
  fi
  if [ -z "${destination}" ] || [ "${destination}" = "${HOME}" ]; then
    echo "Link destination must not be the filesystem root or HOME." >&2
    exit 1
  fi
  if [ "${source_path}" = "${destination}" ] || [[ "${source_path}" = "${destination}/"* ]] || [[ "${destination}" = "${source_path}/"* ]]; then
    echo "Link source and dest must not overlap: ${source_path} -> ${destination}" >&2
    exit 1
  fi
  for ((previous_index = 0; previous_index < index; previous_index++)); do
    previous="${destinations[previous_index]}"
    if [ "${previous}" = "${destination}" ] || [[ "${previous}" = "${destination}/"* ]] || [[ "${destination}" = "${previous}/"* ]]; then
      echo "Duplicate or nested link destinations: ${previous}, ${destination}" >&2
      exit 1
    fi
  done
  parent="$(dirname "${destination}")"
  while [ ! -d "${parent}" ]; do
    if [ -e "${parent}" ] || [ -L "${parent}" ]; then
      echo "Link destination parent is not a directory: ${parent}" >&2
      exit 1
    fi
    parent="$(dirname "${parent}")"
  done
  if [ -e "${destination}" ] && [ ! -L "${destination}" ] && [ ! -f "${destination}" ] && [ ! -d "${destination}" ]; then
    echo "Link destination is not a file, directory or symlink: ${destination}" >&2
    exit 1
  fi

  sources+=("${source_path}")
  destinations+=("${destination}")
  modes+=("${mode}")
  parent_modes+=("${parent_mode}")
done

if [ "${check_only}" = true ]; then
  echo "Link definitions are valid: ${definition_file}"
  exit 0
fi

echo "------- Start resource file operation."

for ((index = 0; index < count; index++)); do
  source_path="${sources[index]}"
  destination="${destinations[index]}"
  parent="$(dirname "${destination}")"
  mkdir -p "${parent}"
  if [ -n "${parent_modes[index]}" ]; then
    chmod "${parent_modes[index]}" "${parent}"
  fi

  if [ -L "${destination}" ]; then
    unlink "${destination}"
  elif [ -e "${destination}" ]; then
    mkdir -p "${HOME}/.dotbackup"
    backup_dir="$(mktemp -d "${HOME}/.dotbackup/link.XXXXXXXX")"
    mv "${destination}" "${backup_dir}/"
    echo "Backed up ${destination} to ${backup_dir}/"
  fi

  ln -s "${source_path}" "${destination}"
  if [ -n "${modes[index]}" ]; then
    chmod "${modes[index]}" "${destination}"
  fi
done

echo "------- Finish resource file operation."
