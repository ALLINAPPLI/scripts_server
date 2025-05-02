#!/bin/bash

for ele in $(ls /etc/my_common/sources); do
    if [ -r "$ele" ]; then
        if [ "$PS1" ]; then
            . "/etc/my_common/sources/$ele"
        else
            . "/etc/my_common/sources/$ele" >/dev/null
        fi
    fi
done

export PATH="$PATH:/etc/my_common/bin"
