#!/usr/bin/env bash
#
# cleanupdir.sh
# Supprime les fichiers d'un dossier plus vieux qu'une durée donnée.
#
# Usage :
#   ./cleanupdir.sh /chemin/du/dossier 7d
#   ./cleanupdir.sh /chemin/du/dossier 12h
#   ./cleanupdir.sh /chemin/du/dossier 3m    (mois, approx 30j/mois)
#
# Paramètres possibles pour la durée : Nh (heures), Nd (jours), Nm (mois)

set -euo pipefail

DOSSIER="${1:-}"
DUREE="${2:-7d}"
LOGFILE="/var/log/cleanupdir.log"
DRY_RUN="${DRY_RUN:-0}"   # DRY_RUN=1 pour tester sans supprimer

if [[ -z "$DOSSIER" ]]; then
    echo "Usage: $0 <dossier> <durée: Nh|Nd|Nm>"
    exit 1
fi

if [[ ! -d "$DOSSIER" ]]; then
    echo "Erreur : le dossier '$DOSSIER' n'existe pas." >&2
    exit 1
fi

# Extraction du nombre et de l'unité (h/d/m)
if [[ "$DUREE" =~ ^([0-9]+)([hdm])$ ]]; then
    NOMBRE="${BASH_REMATCH[1]}"
    UNITE="${BASH_REMATCH[2]}"
else
    echo "Erreur : format de durée invalide ('$DUREE'). Exemples valides : 7d, 12h, 3m" >&2
    exit 1
fi

# Conversion en minutes pour find -mmin
case "$UNITE" in
    h) MINUTES=$(( NOMBRE * 60 )) ;;
    d) MINUTES=$(( NOMBRE * 60 * 24 )) ;;
    m) MINUTES=$(( NOMBRE * 60 * 24 * 30 )) ;;  # approximation
esac

TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

echo "[$TIMESTAMP] Nettoyage de '$DOSSIER' (fichiers > $DUREE, soit $MINUTES min)" >> "$LOGFILE"

if [[ "$DRY_RUN" == "1" ]]; then
    # Mode test : liste seulement, ne supprime rien
    find "$DOSSIER" -maxdepth 1 -type f -mmin +"$MINUTES" -print | tee -a "$LOGFILE"
else
    # Suppression réelle, avec log de chaque fichier supprimé
    find "$DOSSIER" -maxdepth 1 -type f -mmin +"$MINUTES" -print -delete >> "$LOGFILE" 2>&1
fi

echo "[$TIMESTAMP] Nettoyage terminé." >> "$LOGFILE"