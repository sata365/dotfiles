#!/bin/bash -eu

resolve_config_definitions() {
  local config_name="${CONFIG_NAME:-}"
  local config_dir
  local selection
  local index
  local candidates=()

  export CONFIG_REPO_DIR="${CONFIG_REPO_DIR:-${HOME}/git/dotfiles-config}"

  if [ -n "${CONFIG_DEFINITIONS_DIR:-}" ]; then
    if [ ! -d "${CONFIG_DEFINITIONS_DIR}" ]; then
      echo "Configuration directory not found: ${CONFIG_DEFINITIONS_DIR}" >&2
      return 1
    fi
    export CONFIG_DEFINITIONS_DIR
    return 0
  fi

  if [ ! -d "${CONFIG_REPO_DIR}/.git" ]; then
    echo "Config repository not found: ${CONFIG_REPO_DIR}" >&2
    echo "Clone the private config repository before running the installer." >&2
    return 1
  fi

  if [ -z "${config_name}" ]; then
    for config_dir in "${CONFIG_REPO_DIR}"/*/config; do
      [ -d "${config_dir}" ] || continue
      config_name="${config_dir%/config}"
      candidates+=("${config_name##*/}")
    done

    case "${#candidates[@]}" in
      0)
        echo "No configuration found under ${CONFIG_REPO_DIR}/*/config." >&2
        return 1
        ;;
      1)
        config_name="${candidates[0]}"
        ;;
      *)
        echo "Available configurations:" >&2
        for ((index = 0; index < ${#candidates[@]}; index++)); do
          printf '  %d) %s\n' "$((index + 1))" "${candidates[index]}" >&2
        done
        if [ ! -t 0 ]; then
          echo "Set CONFIG_NAME to select a configuration in non-interactive mode." >&2
          return 1
        fi
        while true; do
          printf 'Select configuration [1-%d]: ' "${#candidates[@]}" >&2
          if ! read -r selection; then
            echo "Configuration selection cancelled." >&2
            return 1
          fi
          for ((index = 0; index < ${#candidates[@]}; index++)); do
            if [ "${selection}" = "$((index + 1))" ]; then
              config_name="${candidates[index]}"
              break 2
            fi
          done
          echo "Enter one of the listed numbers." >&2
        done
        ;;
    esac
  fi

  case "${config_name}" in
    .|..|*/*)
      echo "CONFIG_NAME must name a directory directly under CONFIG_REPO_DIR." >&2
      return 1
      ;;
  esac

  export CONFIG_NAME="${config_name}"
  export CONFIG_DEFINITIONS_DIR="${CONFIG_REPO_DIR}/${config_name}/config"
  if [ ! -d "${CONFIG_DEFINITIONS_DIR}" ]; then
    echo "Configuration directory not found: ${CONFIG_DEFINITIONS_DIR}" >&2
    return 1
  fi
}
