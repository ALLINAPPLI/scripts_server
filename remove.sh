#!/bin/bash

show_help() {
    cat << 'EOF'
Usage: ./uninstall.sh [-h|--help]
 
Description :
  Script de désinstallation/nettoyage pour les "scripts communs" installés
  via /etc/my_common/scripts_server.
 
  Ce script effectue les actions suivantes :
    1. Si /etc/my_common existe :
       - Supprime tous les fichiers présents dans :
           /etc/my_common/scripts_server/scripts/
           /etc/my_common/scripts_server/sources/
           /etc/my_common/scripts_server/includes/
       - Supprime ensuite ces dossiers (une fois vides), puis
         /etc/my_common lui-même.
 
    2. Pour chaque fichier trouvé dans le dossier local ./links :
       - Si un fichier du même nom existe dans /etc/profile.d/,
         il est supprimé.
       - Sinon, un message indique qu'il n'existe pas.
 
Prérequis :
  - Doit généralement être exécuté avec les droits root (accès à /etc/*).
  - Le dossier ./links doit exister à côté du script pour l'étape 2.
 
Options :
  -h, --help    Affiche cette aide et quitte.
 
Aucune autre option n'est supportée.
EOF
}
 
# --- Gestion des arguments ---
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
    exit 0
fi
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
