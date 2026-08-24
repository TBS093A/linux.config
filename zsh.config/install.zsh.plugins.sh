#!/usr/bin/env bash
# Clones the zsh-users plugins listed in zsh.config/plugins into oh-my-zsh's
# custom plugins dir. "git" in that list is an oh-my-zsh BUILT-IN plugin
# (ships with oh-my-zsh itself, not a zsh-users/git repo - that clone would
# just 404) so it's skipped, along with anything already cloned/built-in.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
source "$DOTFILES_DIR/zsh.config/plugins"

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

for plugin in "${ZSH_INIT_PLUGINS[@]}"; do
    if [[ -d "$HOME/.oh-my-zsh/plugins/$plugin" ]]; then
        continue   # built-in oh-my-zsh plugin, nothing to clone
    fi
    if [[ -d "$ZSH_CUSTOM/plugins/$plugin" ]]; then
        continue   # already cloned
    fi
    git clone --depth 1 "https://github.com/zsh-users/$plugin.git" "$ZSH_CUSTOM/plugins/$plugin"
done
