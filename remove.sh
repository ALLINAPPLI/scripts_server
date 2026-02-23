#!/bin/bash
if [ -e "/etc/my_common" ]; then
    if [ "$(ls -A "/etc/my_common/scripts_server/scripts")" ]; then
        for ele in /etc/my_common/scripts_server/scripts/*; do
            echo "removing $ele"
            rm $ele;
        done
    fi

    if [ "$(ls -A "/etc/my_common/scripts_server/sources/")" ]; then
        for ele in /etc/my_common/scripts_server/sources/*; do
            echo "removing $ele"
            rm $ele;
        done
    fi

    if [ "$(ls -A "/etc/my_common/scripts_server/includes/")" ]; then
        for ele in /etc/my_common/scripts_server/includes/*; do
            echo "removing $ele"
            rm $ele;
        done
    fi
fi

for ele in $(ls ./links); do
    echo "$ele";
    if [ -f "/etc/profile.d/$ele" ]; then 
        echo "removing /etc/profile.d/$ele"
        rm /etc/profile.d/$ele
    else
        echo "$ele not existing in /etc/profile.d"
    fi
done

test -e /etc/my_common/scripts_server/scripts/ && rmdir /etc/my_common/scripts_server/scripts/
test -e /etc/my_common/scripts_server/sources && rmdir /etc/my_common/scripts_server/sources/
test -e /etc/my_common/scripts_server/includes && rmdir /etc/my_common/scripts_server/includes
test -e /etc/my_common && rmdir /etc/my_common
exit 0
