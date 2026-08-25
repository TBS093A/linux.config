#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

link_user_configs() {
	ln -sf "$DOTFILES_DIR/git.config/.gitconfig" ~/.gitconfig
	ln -sf "$DOTFILES_DIR/zsh.config/.zshrc" ~/.zshrc
	ln -sf "$DOTFILES_DIR/zsh.config/lambda-00x097.zsh-theme" ~/.oh-my-zsh/themes/lambda-00x097.zsh-theme
	ln -sf "$DOTFILES_DIR/tmux.config/tmux.conf" ~/.tmux.conf

	mkdir -p ~/.config/nvim
	ln -sf "$DOTFILES_DIR/vim.config/init.vim" ~/.config/nvim/init.vim
}

link_system_configs() {
	sudo ln -sf "$DOTFILES_DIR/sshd.ssh.config/welcome.sh" /etc/updated-motd.d/welcome.sh
	sudo ln -sf "$DOTFILES_DIR/sshd.ssh.config/welcome.sh" /etc/profile.d/welcome.sh
	sudo ln -sf "$DOTFILES_DIR/sshd.ssh.config/sshd_config" /etc/ssh/sshd_config
}

link_user_configs

if [[ "${1:-}" == "--system" ]]; then
	link_system_configs
else
	echo "Skipped system-wide configs (motd, sshd_config) - re-run with --system to link those (needs sudo)."
fi
