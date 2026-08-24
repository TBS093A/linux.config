#!/bin/zsh

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"

source "$DOTFILES_DIR/vpn.config/vpns"
[ -f "$DOTFILES_DIR/vpn.config/vpns.local" ] && source "$DOTFILES_DIR/vpn.config/vpns.local"

for vpn_address in ${VPNS_LIST};
do
	
	sudo openconnect https://$vpn_address/ --background;

done
