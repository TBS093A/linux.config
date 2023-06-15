#!/bin/zsh

source /root/linux.config/vpn.config/vpns

for vpn_address in ${VPNS_LIST};
do
	
	sudo openconnect https://$vpn_address/ --background;

done
