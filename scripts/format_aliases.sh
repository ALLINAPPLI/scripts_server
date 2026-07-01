#!/bin/bash
#
# Ce script sert à colorer certaines lignes de texte en fonction de leur format, 
# pour rendre un fichier plus lisible dans un terminal. 
# Il lit le fichier passé en argument ($1) ligne par ligne et applique une mise en formee
#
while IFS= read -r line; do
    if [[ "$line" =~ ^===.*=== ]]; then
        # Titre encadré par === → violet
        printf "${RED}%s${NC}\n" "$line"
    elif [[ "$line" =~ ^([a-zA-Z0-9_-]+[[:space:]]*:) ]]; then
        # Capture de la clé avant les deux-points
        key="${BASH_REMATCH[1]}"
        rest="${line#$key}"
        printf "${PURPLE}%s${NC}%s\n" "$key" "$rest"
    else
        # Ligne quelconque
        echo "$line"
    fi
done < "$1"
