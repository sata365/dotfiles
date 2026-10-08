#!/bin/bash -eu

echo "------- Start Defaults settings."

definition_file="${DOTFILES_DEFAULTS_DEFINITION_FILE:-${DOTFILES_REPO_DIR}/config/defaults.json}"
check_only=false

if [ "${1:-}" = "--check" ]; then
  check_only=true
elif [ "$#" -gt 0 ]; then
  echo "Usage: $0 [--check]" >&2
  exit 2
fi

if [ ! -f "${definition_file}" ]; then
  echo "Defaults definition not found: ${definition_file}" >&2
  exit 1
fi

/usr/bin/plutil -convert json -o /dev/null "${definition_file}"

read_value() {
  /usr/bin/plutil -extract "$1" raw "${definition_file}"
}

apply_group() {
  group="$1"
  privileged="$2"
  count="$(read_value "${group}")"
  index=0

  while [ "${index}" -lt "${count}" ]; do
    path="${group}.${index}"
    domain="$(read_value "${path}.domain")"
    key="$(read_value "${path}.key")"
    type="$(read_value "${path}.type")"

    case "${type}" in
      bool|float|int|string)
        value="$(read_value "${path}.value")"
        if [ "${type}" = "string" ] && [[ "${value}" = '${HOME}/'* ]]; then
          value="${HOME}/${value#*/}"
        fi
        if [ "${check_only}" = false ]; then
          if [ "${privileged}" = true ]; then
            sudo defaults write "${domain}" "${key}" "-${type}" "${value}"
          else
            defaults write "${domain}" "${key}" "-${type}" "${value}"
          fi
        fi
        ;;
      array)
        value_count="$(read_value "${path}.value")"
        values=()
        value_index=0
        while [ "${value_index}" -lt "${value_count}" ]; do
          values+=("$(read_value "${path}.value.${value_index}")")
          value_index=$((value_index + 1))
        done
        if [ "${check_only}" = false ]; then
          if [ "${privileged}" = true ]; then
            sudo defaults write "${domain}" "${key}" -array "${values[@]}"
          else
            defaults write "${domain}" "${key}" -array "${values[@]}"
          fi
        fi
        ;;
      *)
        echo "Unsupported defaults type '${type}' at ${path}" >&2
        exit 1
        ;;
    esac

    index=$((index + 1))
  done
}

apply_keyboard_mappings() {
  count="$(read_value keyboardMappings)"
  index=0
  builtin_keyboard_id=""

  while [ "${index}" -lt "${count}" ]; do
    path="keyboardMappings.${index}"
    keyboard_id="$(read_value "${path}.keyboard")"
    source_key="$(read_value "${path}.source")"
    destination_key="$(read_value "${path}.destination")"

    if [ "${check_only}" = false ]; then
      if [ "${keyboard_id}" = "builtin" ]; then
        if [ -z "${builtin_keyboard_id}" ]; then
          builtin_keyboard_id="$(ioreg -c AppleEmbeddedKeyboard -r | grep -Eiw "VendorID|ProductID" | awk '{ print $4 }' | paste -s -d'-' -)-0"
        fi
        keyboard_id="${builtin_keyboard_id}"
      fi

      defaults -currentHost write -g "com.apple.keyboard.modifiermapping.${keyboard_id}" -array-add "
<dict>
  <key>HIDKeyboardModifierMappingDst</key>
  <integer>${destination_key}</integer>
  <key>HIDKeyboardModifierMappingSrc</key>
  <integer>${source_key}</integer>
</dict>
"
    fi

    index=$((index + 1))
  done
}

apply_directories() {
  count="$(read_value directories)"
  index=0

  while [ "${index}" -lt "${count}" ]; do
    directory="$(read_value "directories.${index}")"
    if [[ "${directory}" = '${HOME}/'* ]]; then
      directory="${HOME}/${directory#*/}"
    fi
    if [ "${check_only}" = false ]; then
      mkdir -p "${directory}"
    fi
    index=$((index + 1))
  done
}

apply_group userDefaults false
apply_group systemDefaults true
apply_keyboard_mappings
apply_directories

if [ "${check_only}" = true ]; then
  echo "Defaults definition is valid: ${definition_file}"
  exit 0
fi

killall Dock
killall Finder

echo "------- Finish Defaults settings."

exit 0
