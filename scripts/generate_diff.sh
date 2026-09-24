#!/usr/bin/env bash
set -euo pipefail

# generate_diff.sh
# Compare deux dumps MySQL (prod -> dev) et génère diff.sql + rapport.txt
# La configuration est lue depuis generate_diff.conf
# Mode d’emploi (rappel)
# Dans le même dossier, tu as maintenant :
# generate_diff.conf
# generate_diff.sh
# generate_diff.py
# Rends le Bash exécutable :
# chmod +x generate_diff.sh
# Lancer : ./generate_diff.sh
# Les fichiers générés seront :
#  - diff.sql
#  - rapport.txt
#  dans le dossier défini par OUTPUT_DIR (ou le dossier courant si vide).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/generate_diff.conf"

if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "Erreur : fichier de configuration introuvable : ${CONFIG_FILE}"
  exit 1
fi

# -----------------------------
# 1. Lecture de la configuration
# -----------------------------

load_config() {
  while IFS='=' read -r key value; do
    [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]] && continue
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    export "$key=$value"
  done < "$CONFIG_FILE"
}

load_config

# Vérification des variables obligatoires
for var in SOURCE_HOST SOURCE_PORT SOURCE_BDD_NAME SOURCE_BDD_USER SOURCE_BDD_PASS \
           DEST_HOST DEST_PORT DEST_BDD_NAME DEST_BDD_USER DEST_BDD_PASS \
           TMP_SOURCE_BDD TMP_DEST_BDD; do
  if [[ -z "${!var:-}" ]]; then
    echo "Erreur : variable manquante dans generate_diff.conf : $var"
    exit 1
  fi
done

# -----------------------------
# 2. Saisie des dumps
# -----------------------------

echo "=== Génération du diff SQL entre PROD et DEV ==="
echo "Configuration chargée depuis : ${CONFIG_FILE}"
echo

read -rp "Chemin du dump PROD (source) : " DUMP_PROD
read -rp "Chemin du dump DEV (destination) : " DUMP_DEV

# Optionnel : redemander si on veut inclure les grosses tables
if [[ "${INCLUDE_LARGE_TABLES:-0}" == "0" ]]; then
  echo
  echo "Dans generate_diff.conf, INCLUDE_LARGE_TABLES=0 (grosses tables exclues par défaut)."
  read -rp "Veux-tu inclure les grosses tables dans la comparaison ? (o/n) [n] : " INCLUDE_LARGE_INTERACT
  if [[ "$INCLUDE_LARGE_INTERACT" == "o" || "$INCLUDE_LARGE_INTERACT" == "O" ]]; then
    export INCLUDE_LARGE_TABLES=1
  fi
else
  echo
  echo "Dans generate_diff.conf, INCLUDE_LARGE_TABLES=1 (grosses tables incluses)."
fi

# -----------------------------
# 3. Création des bases temporaires
# -----------------------------

MYSQL_SOURCE="mysql -h${SOURCE_HOST} -P${SOURCE_PORT} -u${SOURCE_BDD_USER} -p${SOURCE_BDD_PASS}"
MYSQL_DEST="mysql -h${DEST_HOST} -P${DEST_PORT} -u${DEST_BDD_USER} -p${DEST_BDD_PASS}"

echo "Création des bases temporaires..."

$MYSQL_SOURCE -e "DROP DATABASE IF EXISTS \`${TMP_SOURCE_BDD}\`;"
$MYSQL_SOURCE -e "CREATE DATABASE \`${TMP_SOURCE_BDD}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

$MYSQL_DEST -e "DROP DATABASE IF EXISTS \`${TMP_DEST_BDD}\`;"
$MYSQL_DEST -e "CREATE DATABASE \`${TMP_DEST_BDD}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

echo "Import du dump PROD dans ${TMP_SOURCE_BDD} (sur ${SOURCE_HOST})..."
gzip -dc "${DUMP_PROD}" | $MYSQL_SOURCE "${TMP_SOURCE_BDD}"

echo "Import du dump DEV dans ${TMP_DEST_BDD} (sur ${DEST_HOST})..."
gzip -dc "${DUMP_DEV}" | $MYSQL_DEST "${TMP_DEST_BDD}"

# -----------------------------
# 4. Préparation des variables pour generate_diff.py
# -----------------------------

export DB_HOST_SOURCE="${SOURCE_HOST}"
export DB_PORT_SOURCE="${SOURCE_PORT}"
export DB_NAME_SOURCE="${TMP_SOURCE_BDD}"
export DB_USER_SOURCE="${SOURCE_BDD_USER}"
export DB_PASS_SOURCE="${SOURCE_BDD_PASS}"

export DB_HOST_DEST="${DEST_HOST}"
export DB_PORT_DEST="${DEST_PORT}"
export DB_NAME_DEST="${TMP_DEST_BDD}"
export DB_USER_DEST="${DEST_BDD_USER}"
export DB_PASS_DEST="${DEST_BDD_PASS}"

export EXCLUDED_TABLES_STR="${EXCLUDED_TABLES:-}"
export LARGE_TABLES_STR="${LARGE_TABLES:-}"
export TABLES_TO_PROCESS_STR="${TABLES_TO_PROCESS:-}"
export DATE_SEUIL="${DATE_SEUIL:-}"
export DATE_COLUMNS_CUSTOM_STR="${DATE_COLUMNS_CUSTOM:-}"

# On passe aussi le chemin du dump PROD au Python pour parser l'ordre des tables
export DUMP_PROD_PATH="${DUMP_PROD}"

# Dossier de sortie
if [[ -n "${OUTPUT_DIR:-}" ]]; then
  mkdir -p "${OUTPUT_DIR}"
  export OUTPUT_DIR_ABS="$(cd "${OUTPUT_DIR}" && pwd)"
else
  export OUTPUT_DIR_ABS="${SCRIPT_DIR}"
fi

# -----------------------------
# 5. Appel du script Python de diff
# -----------------------------

PYTHON_SCRIPT="${SCRIPT_DIR}/generate_diff.py"

if [[ ! -f "${PYTHON_SCRIPT}" ]]; then
  echo "Erreur : ${PYTHON_SCRIPT} introuvable."
  exit 1
fi

echo "Lancement de la comparaison avec generate_diff.py..."
echo "Dossier de sortie : ${OUTPUT_DIR_ABS}"

cd "${OUTPUT_DIR_ABS}"
python3 "${PYTHON_SCRIPT}"

echo
echo "=== Terminé ==="
echo "Fichiers générés dans : ${OUTPUT_DIR_ABS}"
echo "  - diff.sql"
echo "  - rapport.txt"
echo
echo "Vérifie rapport.txt avant d'appliquer diff.sql sur ta base de dev."