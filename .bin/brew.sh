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

definition_dir="${CONFIG_DEFINITIONS_DIR}"

for definition in \
  "${definition_dir}/Homebrew/brew.txt" \
  "${definition_dir}/Homebrew/cask.txt"
do
  if [ ! -r "${definition}" ]; then
    echo "Homebrew definition not found or unreadable: ${definition}" >&2
    exit 1
  fi
done

case "$(uname -m)" in
  arm64|x86_64) ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

if [ "${check_only}" = true ]; then
  echo "Config repository is ready: ${CONFIG_REPO_DIR}"
  exit 0
fi

echo "------- Start Homebrew install."

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "Homebrew executable not found after installation." >&2
  exit 1
fi

xargs brew install < "${definition_dir}/Homebrew/brew.txt"
xargs brew install --cask --force < "${definition_dir}/Homebrew/cask.txt"

echo "------- Finish Homebrew install."

exit 0
