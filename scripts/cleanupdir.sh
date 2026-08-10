#!/usr/bin/env bash
#
# cleanup_dossier.sh
# Supprime récursivement les fichiers d'un dossier (et sous-dossiers)
# plus vieux qu'une durée donnée.
#
# Usage :
#   ./cleanup_dossier.sh /chemin/du/dossier 7d
#   ./cleanup_dossier.sh /chemin/du/dossier 12h
#   ./cleanup_dossier.sh /chemin/du/dossier 3m
#
# Options :
#   DRY_RUN=1        -> simulation, rien n'est supprimé
#   DELETE_EMPTY=1   -> supprime aussi les dossiers vides restants après nettoyage

set -euo pipefail

DOSSIER="${1:-}"
DUREE="${2:-7d}"
LOGFILE="/var/log/cleanup_dossier.log"
DRY_RUN="${DRY_RUN:-0}"
DELETE_EMPTY="${DELETE_EMPTY:-0}"

if [[ -z "$DOSSIER" ]]; then
    echo "Usage: $0 <dossier> <durée: Nh|Nd|Nm>"
    exit 1
fi

if [[ ! -d "$DOSSIER" ]]; then
    echo "Erreur : le dossier '$DOSSIER' n'existe pas." >&2
    exit 1
fi

if [[ "$DUREE" =~ ^([0-9]+)([hdm])$ ]]; then
    NOMBRE="${BASH_REMATCH[1]}"
    UNITE="${BASH_REMATCH[2]}"
else
    echo "Erreur : format de durée invalide ('$DUREE'). Exemples valides : 7d, 12h, 3m" >&2
    exit 1
fi

case "$UNITE" in
    h) MINUTES=$(( NOMBRE * 60 )) ;;
    d) MINUTES=$(( NOMBRE * 60 * 24 )) ;;
    m) MINUTES=$(( NOMBRE * 60 * 24 * 30 )) ;;
esac

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

echo "[$TIMESTAMP] Nettoyage récursif de '$DOSSIER' (fichiers > $DUREE, soit $MINUTES min)" >> "$LOGFILE"

if [[ "$DRY_RUN" == "1" ]]; then
    # Simulation : liste tous les fichiers concernés, dossiers inclus
    find "$DOSSIER" -type f -mmin +"$MINUTES" -print | tee -a "$LOGFILE"
else
    # Suppression réelle des fichiers, récursive
    find "$DOSSIER" -type f -mmin +"$MINUTES" -print -delete >> "$LOGFILE" 2>&1

    # Suppression optionnelle des dossiers vides restants
    if [[ "$DELETE_EMPTY" == "1" ]]; then
        find "$DOSSIER" -mindepth 1 -type d -empty -print -delete >> "$LOGFILE" 2>&1
    fi
fi

echo "[$TIMESTAMP] Nettoyage terminé." >> "$LOGFILE"