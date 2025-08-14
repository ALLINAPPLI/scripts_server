#!/bin/bash
if [ -e "/etc/my_common" ]; then
    if [ "$(ls -A "/etc/my_common/bin")" ]; then
        for ele in /etc/my_common/bin/*; do
            echo "removing $ele"
            rm $ele;
        done
    fi

    if [ "$(ls -A "/etc/my_common/sources/")" ]; then
        for ele in /etc/my_common/sources/*; do
            echo "removing $ele"
            rm $ele;
        done
    fi

    if [ "$(ls -A "/etc/my_common/includes/")" ]; then
        for ele in /etc/my_common/includes/*; do
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

test -e /etc/my_common/bin/ && rmdir /etc/my_common/bin/
test -e /etc/my_common/sources && rmdir /etc/my_common/sources/
test -e /etc/my_common/includes && rmdir /etc/my_common/includes
test -e /etc/my_common && rmdir /etc/my_common
exit 0
