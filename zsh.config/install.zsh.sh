#!/usr/bin/env bash
set -euo pipefail

installer=$(mktemp)
trap 'rm -f "$installer"' EXIT

curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -o "$installer"
chmod +x "$installer"
"$installer"
