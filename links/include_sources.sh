#!/bin/bash
echo "sources"

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

export PATH="$PATH:/etc/my_common/bin"
export CUSTOM_DIR="/etc/my_common"
export racine="/var/www/vhosts"
