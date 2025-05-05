#!/bin/bash

test -e "/etc/my_common" || {
    mkdir /etc/my_common && chmod 755 /etc/my_common
}

test -e "/etc/my_common/bin" || {
    mkdir /etc/my_common/bin && chmod 755 /etc/my_common/bin
}

test -e "/etc/my_common/sources" || {
    mkdir /etc/my_common/sources && chmod 755 /etc/my_common/sources
}

test -e "/etc/my_common/includes" || {
    mkdir /etc/my_common/includes && chmod 755 /etc/my_common/includes
}

for ele in $(ls ./scripts); do
    cp ./scripts/$ele /etc/my_common/bin/$ele
    chmod 755 /etc/my_common/bin/$ele
done

for ele in $(ls ./sources); do
    cp ./sources/$ele /etc/my_common/sources/$ele
    chmod 755 /etc/my_common/sources/$ele
done

for ele in $(ls ./links); do
    cp ./links/$ele /etc/profile.d/$ele
    chmod 644 /etc/profile.d/$ele
done

for ele in $(ls ./includes); do
    cp ./includes/$ele /etc/my_common/includes/$ele
    chmod 755 /etc/my_common/includes/$ele
done
