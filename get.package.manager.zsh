#!/bin/zsh

source /etc/os-release

typeset -A distro_mgr;
distro_mgr[debian]=apt-get
distro_mgr[ubuntu]=apt-get
distro_mgr[centos]=yum
distro_mgr[redhat]=yum
distro_mgr[arch]=pacman
distro_mgr[manjaro]=pacman
distro_mgr[void]=xbps-install

for key val in ${(@kv)distro_mgr}
do
	if [[ $key = $ID ]];
	then
		export PKG_MGR=$val
		echo Package manager: $val
	fi

done
