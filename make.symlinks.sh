#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

link_user_configs() {
	ln -sf "$DOTFILES_DIR/git.config/.gitconfig" ~/.gitconfig
	ln -sf "$DOTFILES_DIR/zsh.config/.zshrc" ~/.zshrc
	ln -sf "$DOTFILES_DIR/zsh.config/lambda-00x097.zsh-theme" ~/.oh-my-zsh/themes/lambda-00x097.zsh-theme
	ln -sf "$DOTFILES_DIR/tmux.config/tmux.conf" ~/.tmux.conf

	# fixed $HOME path so tmux.conf's status-right can reference it without
	# knowing where this repo was cloned (tmux config isn't shell, so it
	# can't resolve $DOTFILES_DIR itself the way .zshrc does)
	mkdir -p ~/.tmux
	ln -sf "$DOTFILES_DIR/tmux.config/status-sys.sh" ~/.tmux/status-sys.sh

	mkdir -p ~/.config/nvim
	ln -sf "$DOTFILES_DIR/vim.config/init.vim" ~/.config/nvim/init.vim
}

link_system_configs() {
	sudo ln -sf "$DOTFILES_DIR/sshd.ssh.config/welcome.sh" /etc/updated-motd.d/welcome.sh
	sudo ln -sf "$DOTFILES_DIR/sshd.ssh.config/welcome.sh" /etc/profile.d/welcome.sh
	sudo ln -sf "$DOTFILES_DIR/sshd.ssh.config/sshd_config" /etc/ssh/sshd_config
}

# Mutually exclusive, not additive: --system only does the system-level
# linking. A plain `sudo ./make.symlinks.sh --system` doesn't reset $HOME
# to root's on most distros (Void included), so if this also called
# link_user_configs, root would happily `ln -sf` over the invoking user's
# own ~/.zshrc, ~/.gitconfig, ~/.oh-my-zsh/themes/... - poisoning their
# ownership to root and breaking every later unprivileged re-run with a
# "Permission denied" trying to re-point that same symlink. install.sh
# calls this script twice for exactly this reason: once unprivileged
# (user configs) and, only if --system was requested, separately under
# sudo (system configs only).
if [[ "${1:-}" == "--system" ]]; then
	link_system_configs
else
	link_user_configs
	echo "Skipped system-wide configs (motd, sshd_config) - re-run with 'sudo ./make.symlinks.sh --system' to link those."
fi
