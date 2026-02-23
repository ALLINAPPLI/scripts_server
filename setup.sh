#!/bin/bash

test -e "/etc/my_common" || {
    mkdir /etc/my_common && chmod 755 /etc/my_common
}

test -e "/etc/my_common/scripts_server/scripts" || {
    mkdir /etc/my_common/scripts_server/scripts && chmod 755 /etc/my_common/scripts_server/scripts
}

test -e "/etc/my_common/scripts_server/sources" || {
    mkdir /etc/my_common/scripts_server/sources && chmod 755 /etc/my_common/scripts_server/sources
}

test -e "/etc/my_common/scripts_server/includes" || {
    mkdir /etc/my_common/scripts_server/includes && chmod 755 /etc/my_common/scripts_server/includes
}

if [ -e "./scripts" ]; then
    for ele in $(ls ./scripts); do
        cp ./scripts/$ele /etc/my_common/scripts_server/scripts/$ele
        chmod 755 /etc/my_common/scripts_server/scripts/$ele
    done
fi

if [ -e "./sources" ]; then
    for ele in $(ls ./sources); do
        cp ./sources/$ele /etc/my_common/scripts_server/sources/$ele
        chmod 755 /etc/my_common/scripts_server/sources/$ele
    done
fi

if [ -e "./links" ]; then
    for ele in $(ls ./links); do
        cp ./links/$ele /etc/profile.d/$ele
        chmod 644 /etc/profile.d/$ele
    done
fi

if [ -e "./includes" ]; then
    for ele in $(ls ./includes); do
        cp ./includes/$ele /etc/my_common/scripts_server/includes/$ele
        chmod 755 /etc/my_common/scripts_server/includes/$ele
    done
fi
