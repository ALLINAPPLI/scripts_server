#!/bin/bash
echo "sources"

if {
    groups | grep "root" > /dev/null
}; then
    IS_ROOT="Y"
else 
    exec sudo su -
    exit $?
fi

export PATH="$PATH:/etc/my_common/bin:/etc/my_common/officialbin"
export CUSTOM_DIR="/etc/my_common"
export racine="/var/www/vhosts"

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

