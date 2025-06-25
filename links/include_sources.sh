#!/bin/bash
echo "sources"

if id -nG | grep -qw root; then
    IS_ROOT="Y"
else 
	if sudo -l -n su - &>/dev/null; then
	    exec sudo su -
	    exit $?
	else
		echo -e "\e[1;31mAttention, vous n'êtes pas en mode root, certaines commandes ne fonctionneront pas.\e[0m"
	fi
    # exec sudo su -
    # exit $?
fi

export PATH="$PATH:/etc/my_common/bin:/etc/my_common/officialbin"
export CUSTOM_DIR="/etc/my_common"
export racine="/var/www/vhosts"
export GREEN='\e[1;38;5;2m'
export BLACK='\e[1;90m'
export RED='\e[1;31m'
export YELLOW='\e[1;33m'
export BLUE='\e[1;34m'
export PURPLE='\e[1;35m'
export CYAN='\e[1;36m'
export WHITE='\e[97m'
export GREY='\e[90m'
export NC='\e[0m'


for ele in $(ls /etc/my_common/sources); do
    fullpath="/etc/my_common/sources/$ele"
    if [ -r "$fullpath" ]; then
        if [ "$PS1" ]; then
            . "$fullpath"
        else
            . "$fullpath" >/dev/null
        fi
    fi
done


if [ "$PS1" ]; then
	green='\e[32m'
	red='\e[31m'
	cyan='\e[00;36m'
	color_return()
	{
	    return_value=$?
	    if [ $return_value == 0 ]; then
	        echo -e "$green[${return_value}]$NC"
	    else
	        echo -e "$red[${return_value}]$NC"
	    fi
	    return ${return_value}
	}

	PS1='$(color_return)[\u@\W]'$cyan'\$ \[\e[00m\]'
	PS1='$(color_return)[\u@\W]'$cyan'\$ \[\e[00m\]'
fi

