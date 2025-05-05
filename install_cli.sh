#!/bin/bash

set -e

# Vérification que le script est lancé en tant que root
if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Ce script doit être exécuté en tant que root (sudo)."
    exit 1
fi

test -e /etc/my_common || {
    mkdir /etc/my_common && chmod 755 /etc/my_common
}

test -e /etc/my_common/officialbin || {
    mkdir /etc/my_common/officialbin && chmod 755 /etc/my_common/officialbin
}

path_bin=/etc/my_common/officialbin

if ! which php > /dev/null 2>&1 ; then
    rm -f $path_bin/php > /dev/null 2>&1
    php_bin=$(ls /opt/plesk/php | sort -r | head -n 1)
    echo bin : $php_bin
    ln -s /opt/plesk/php/$php_bin/bin/php $path_bin/php
fi

if [ ! -e "$path_bin/cv" ]; then
    echo "➡️ Installation de cv..."
    sudo curl -LsS https://download.civicrm.org/cv/cv.phar -o $path_bin/cv
    chmod +x $path_bin/cv
    echo "✅ cv installé dans ${path_bin}."
fi

if [ ! -e "$path_bin/wp" ]; then
    echo "➡️ Installation de wp-cli..."
    curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    mv wp-cli.phar $path_bin/wp
    chmod +x $path_bin/wp
    echo "✅ wp-cli installé dans $path_bin."
fi

if [ ! -e "$path_bin/drush" ]; then
    if command -v composer &> /dev/null; then
        echo "➡️ Installation de drush via Composer..."
        composer global require drush/drush
        drush_path=$(composer global config home)/vendor/bin/drush;
        chmod +x $drush_path
        ln -s $drush_path /etc/my_common/officialbin/drush
        echo "✅ drush installé dans /etc/my_common/officialbin."
    else
        echo "🚨 Composer n'est pas installé. Impossible d'installer drush."
    fi
fi
