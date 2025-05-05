#!/bin/bash

set -e

echo "🛠 Installation de wp-cli, cv, et drush pour tous les utilisateurs..."

# Vérification que le script est lancé en tant que root
if [ "$(id -u)" -ne 0 ]; then
  echo "❌ Ce script doit être exécuté en tant que root (sudo)."
  exit 1
fi

# -----------------------------
# 1. Installer wp-cli
# -----------------------------
echo "➡️ Installation de wp-cli..."
curl -s -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp
echo "✅ wp installé dans /usr/local/bin/wp"

# -----------------------------
# 2. Installer cv (CiviCRM CLI)
# -----------------------------
echo "➡️ Installation de cv (CiviCRM CLI)..."
curl -Ls https://download.civicrm.org/cv/cv.phar -o /usr/local/bin/cv
chmod +x /usr/local/bin/cv
echo "✅ cv installé dans /usr/local/bin/cv"

# -----------------------------
# 3. Installer Drush globalement
# -----------------------------
echo "➡️ Installation de Drush via Composer dans /opt/drush..."
apt update
apt install -y php-cli php-mbstring unzip curl git composer

mkdir -p /opt/drush
cd /opt/drush
composer create-project drush/drush .

# Lien symbolique global
ln -sf /opt/drush/drush /usr/local/bin/drush
echo "✅ drush installé dans /usr/local/bin/drush"

# -----------------------------
# Vérification finale
# -----------------------------
echo "📦 Vérification des versions installées :"
echo "----------------------------------------"
wp --version
cv --version
drush --version
echo "----------------------------------------"

echo "✅ Tous les outils ont été installés globalement avec succès."

