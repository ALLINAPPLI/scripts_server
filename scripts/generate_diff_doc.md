# Outil de diff SQL entre PROD et DEV (Drupal + CiviCRM)

## 1. Présentation

Cet outil permet de comparer deux bases de données MySQL :

- **Source (PROD)** : base de production (état actuel).
- **Destination (DEV)** : base de développement (copie ancienne, éventuellement avec schéma plus récent).

L'objectif est de générer :

- un fichier **`diff.sql`** contenant uniquement les opérations nécessaires (`INSERT`, `UPDATE`, `DELETE`) pour appliquer sur DEV les changements survenus en PROD depuis une date donnée ;
- un fichier **`rapport.txt`** récapitulatif pour validation humaine avant application.

Cas d'usage typique :

- PROD : Drupal 9 + CiviCRM 5.75
- DEV : copie de PROD (juin 2026) migrée vers Drupal 11 + CiviCRM 6.x
- Besoin : synchroniser DEV avec les évolutions de PROD (contenu, contacts, contributions, etc.) sans écraser les spécificités de DEV (code, config, etc.).

---

## 2. Architecture et principes

### 2.1. Fichiers fournis

- `generate_diff.conf` : fichier de configuration (connexions, options, listes de tables, etc.).
- `generate_diff.sh` : script Bash principal.
- `generate_diff.py` : script Python de comparaison et génération du diff.

### 2.2. Fonctionnement global

1. Le script Bash :
   - Lit la configuration dans `generate_diff.conf`.
   - Te demande les chemins des deux dumps SQL (PROD et DEV).
   - Crée deux bases temporaires :
     - `TMP_SOURCE_BDD` (copie de PROD)
     - `TMP_DEST_BDD` (copie de DEV)
   - Importe les dumps dans ces bases temporaires.
   - Appelle `generate_diff.py` en lui passant les paramètres via l'environnement.

2. Le script Python :
   - Se connecte aux deux bases temporaires.
   - Extrait l'**ordre des tables** depuis le dump PROD (pour respecter l'ordre d'insertion d'origine).
   - Pour chaque table (dans cet ordre) :
     - Vérifie les filtres (tables exclues, liste de tables à traiter, etc.).
     - Détermine les **colonnes communes** entre les deux bases (Option A : on ignore les colonnes spécifiques à DEV).
     - Détecte la **clé primaire** (ou utilise `id` par défaut).
     - Détecte une **colonne date** (ou utilise une configuration personnalisée).
     - Compare les lignes :
       - Lignes dans PROD mais pas dans DEV → `INSERT`.
       - Lignes dans les deux mais différentes → `UPDATE`.
       - Lignes dans DEV mais plus dans PROD → `DELETE`.
   - Génère `diff.sql` et `rapport.txt`.

3. Résultat :
   - `diff.sql` : fichier SQL à appliquer manuellement sur la base de DEV (ou une copie).
   - `rapport.txt` : rapport lisible listant, par table, le nombre d'`INSERT`, `UPDATE`, `DELETE`.

---

## 3. Prérequis

### 3.1. Environnement

- Système : Linux (bash).
- Outils :
  - `bash`
  - `mysql` (client en ligne de commande)
  - `python3`
  - `gzip` (pour les dumps compressés `.sql.gz`)

### 3.2. Modules Python

Le script Python utilise `mysql-connector-python`.

Installation :

```bash
pip3 install mysql-connector-python
```

### 3.3. Droits MySQL

Les utilisateurs MySQL configurés doivent avoir, au minimum, sur les bases temporaires :

- `CREATE`, `DROP`
- `SELECT` sur toutes les tables
- `INSERT`, `UPDATE`, `DELETE` (si tu veux tester des écritures dans les bases temporaires, mais ce n'est pas obligatoire pour le diff)

---

## 4. Installation

1. Place les trois fichiers dans un même dossier, par exemple :

   ```bash
   /opt/cfonb_diff/
   ├── generate_diff.conf
   ├── generate_diff.sh
   └── generate_diff.py
   ```

2. Rends le script Bash exécutable :

   ```bash
   chmod +x /opt/cfonb_diff/generate_diff.sh
   ```

3. Sécurise le fichier de configuration (contient des mots de passe) :

   ```bash
   chmod 600 /opt/cfonb_diff/generate_diff.conf
   ```

---

## 5. Configuration (`generate_diff.conf`)

Exemple de fichier :

```ini
# generate_diff.conf
# Configuration pour la génération du diff SQL entre PROD et DEV

# -----------------------------
# 1. Connexion à la base SOURCE (PROD)
# -----------------------------
SOURCE_HOST=localhost
SOURCE_PORT=3306
SOURCE_BDD_NAME=cfonb_prod
SOURCE_BDD_USER=cfonb_user
SOURCE_BDD_PASS=ton_mot_de_passe_prod

# -----------------------------
# 2. Connexion à la base DESTINATION (DEV)
# -----------------------------
DEST_HOST=localhost
DEST_PORT=3306
DEST_BDD_NAME=cfonb_dev
DEST_BDD_USER=cfonb_user_dev
DEST_BDD_PASS=ton_mot_de_passe_dev

# -----------------------------
# 3. Bases temporaires utilisées pour la comparaison
# -----------------------------
TMP_SOURCE_BDD=cfonb_prod_tmp
TMP_DEST_BDD=cfonb_dev_tmp

# -----------------------------
# 4. Dossier de sortie pour diff.sql et rapport.txt
# -----------------------------
# Laisser vide pour utiliser le dossier courant
OUTPUT_DIR=

# -----------------------------
# 5. Options de comparaison
# -----------------------------
# Date de début de différentiel (YYYY-MM-DD). Laisser vide pour tout prendre.
DATE_SEUIL=2026-06-01

# Tables systématiquement exclues (cache, session, temporaire, logs, etc.)
# Séparées par des espaces ou des virgules.
EXCLUDED_TABLES=cache,cache_bootstrap,cache_config,cache_container,cache_data,cache_default,cache_discovery,cache_dynamic_page_cache,cache_entity,cache_menu,cache_page,cache_render,cache_toolbar,cache_views,cache_views_data,sessions,watchdog,queue,civicrm_cache,civicrm_session,civicrm_log

# Grosses tables potentielles (exclues si INCLUDE_LARGE_TABLES=0)
LARGE_TABLES=civicrm_activity,civicrm_activity_contact,civicrm_mailing_event_queue,civicrm_mailing_event_delivered,civicrm_mailing_event_opened,civicrm_mailing_event_click,civicrm_mailing_event_bounce,civicrm_mailing_event_forward,civicrm_mailing_event_reply,civicrm_mailing_event_unsubscribe,civicrm_mailing_event_subscribe,civicrm_mailing_recipients,history,users_data

# Inclure ou non les grosses tables dans la comparaison (1 = oui, 0 = non)
INCLUDE_LARGE_TABLES=0

# -----------------------------
# 6. Liste de tables à traiter (optionnel)
# -----------------------------
# Si non vide, le script ne traitera QUE ces tables (en plus des autres filtres).
# Séparées par des espaces ou des virgules.
# Exemple : TABLES_TO_PROCESS=civicrm_contact,civicrm_activity,users
TABLES_TO_PROCESS=

# -----------------------------
# 7. Personnalisation des colonnes "date" par table (optionnel)
# -----------------------------
# Format : TABLE_NAME:COLUMN_NAME, TABLE2:COLUMN2, ...
# Exemple : DATE_COLUMNS_CUSTOM=civicrm_activity:activity_date_time,civicrm_contact:modified_date
# Laisser vide pour utiliser la détection automatique.
DATE_COLUMNS_CUSTOM=
```

### 5.1. Paramètres principaux

- `SOURCE_*` : connexion à la base de PROD.
- `DEST_*` : connexion à la base de DEV.
- `TMP_SOURCE_BDD`, `TMP_DEST_BDD` : noms des bases temporaires créées pour la comparaison.
- `OUTPUT_DIR` : dossier où seront écrits `diff.sql` et `rapport.txt` (laisser vide pour le dossier courant).
- `DATE_SEUIL` : date à partir de laquelle on prend en compte les modifications (basée sur une colonne date détectée ou configurée).
- `EXCLUDED_TABLES` : tables ignorées (cache, sessions, logs, etc.).
- `LARGE_TABLES` + `INCLUDE_LARGE_TABLES` : permet d'exclure les très grosses tables par défaut, avec confirmation interactive.
- `TABLES_TO_PROCESS` : si renseigné, ne traite que ces tables.
- `DATE_COLUMNS_CUSTOM` : mapping table → colonne date pour le filtre temporel.

---

## 6. Utilisation

### 6.1. Lancement

Depuis le dossier contenant les scripts :

```bash
./generate_diff.sh
```

Le script va :

1. Charger `generate_diff.conf`.
2. Te demander :
   - Le chemin du dump PROD (ex. `prod_2026_09_23.sql.gz`).
   - Le chemin du dump DEV (ex. `dev_2026_06_01.sql.gz`).
   - Eventuellement, si tu veux inclure les grosses tables (si `INCLUDE_LARGE_TABLES=0`).
3. Créer les bases temporaires.
4. Importer les dumps.
5. Lancer la comparaison via `generate_diff.py`.
6. Générer `diff.sql` et `rapport.txt`.

### 6.2. Vérification du rapport

Ouvre `rapport.txt` :

```bash
less rapport.txt
# ou
cat rapport.txt
```

Tu y trouveras, par table :

- Le nombre d'`INSERT`, `UPDATE`, `DELETE`.
- Un résumé global en fin de fichier.

Vérifie en particulier :

- Les tables avec beaucoup d'`INSERT`/`UPDATE`/`DELETE`.
- Les tables critiques (`civicrm_contact`, `civicrm_contribution`, `civicrm_group_contact`, etc.).

### 6.3. Application du diff sur DEV

**Important** : applique toujours `diff.sql` d'abord sur une **copie de test** de ta base DEV.

Exemple :

```bash
# Créer une copie de test
mysql -hDEST_HOST -PDEST_PORT -uDEST_BDD_USER -pDEST_BDD_PASS -e "CREATE DATABASE cfonb_dev_test DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Restaurer un dump DEV dedans (si besoin)
gzip -dc dev_2026_06_01.sql.gz | mysql -hDEST_HOST -PDEST_PORT -uDEST_BDD_USER -pDEST_BDD_PASS cfonb_dev_test

# Appliquer le diff
mysql -hDEST_HOST -PDEST_PORT -uDEST_BDD_USER -pDEST_BDD_PASS cfonb_dev_test -e "SET FOREIGN_KEY_CHECKS=0; SOURCE /chemin/vers/diff.sql; SET FOREIGN_KEY_CHECKS=1;"
```

Ou en deux étapes :

```sql
SET FOREIGN_KEY_CHECKS=0;
SOURCE /chemin/vers/diff.sql;
SET FOREIGN_KEY_CHECKS=1;
```

Une fois validé sur l'environnement de test, tu peux l'appliquer sur la vraie base DEV (ou un environnement de staging).

---

## 7. Détails techniques

### 7.1. Option A : colonnes communes uniquement

Le script ne compare que les **colonnes présentes dans les deux bases** :

- Si DEV a des colonnes supplémentaires (schéma plus récent), elles sont ignorées.
- Aucune modification de schéma (`ALTER TABLE`) n'est générée.

C'est l'option retenue pour éviter des problèmes de compatibilité entre versions de Drupal/CiviCRM.

### 7.2. Ordre des tables

L'ordre des tables dans `diff.sql` suit l'ordre d'apparition dans le **dump PROD** :

- Extraction via les lignes `DROP TABLE` / `CREATE TABLE`.
- Respecte l'ordre logique de `mysqldump`, généralement compatible avec les contraintes de clés étrangères.

Cela augmente les chances que :

- Les tables "parentes" (`civicrm_contact`, `civicrm_group`, etc.) soient traitées avant les tables "enfants" (`civicrm_group_contact`, `civicrm_activity_contact`, etc.).

### 7.3. Gestion des clés étrangères

Le script ne modifie pas les contraintes de clés étrangères.  
Pour éviter des erreurs lors de l'application de `diff.sql`, il est recommandé de :

```sql
SET FOREIGN_KEY_CHECKS=0;
SOURCE diff.sql;
SET FOREIGN_KEY_CHECKS=1;
```

Cela permet d'insérer/mettre à jour/supprimer des lignes même si l'ordre n'est pas parfait par rapport aux FK.

### 7.4. Filtre par date

Le filtre `DATE_SEUIL` s'applique si une colonne date est détectée :

- Détection automatique (colonnes `TIMESTAMP` / `DATETIME` dont le nom contient `created`, `changed`, `modified`, `date`, etc.).
- Ou via `DATE_COLUMNS_CUSTOM` pour forcer une colonne précise par table.

Exemple :

```ini
DATE_SEUIL=2026-06-01
DATE_COLUMNS_CUSTOM=civicrm_activity:activity_date_time,civicrm_contact:modified_date
```

Seules les lignes avec `colonne_date >= '2026-06-01'` seront comparées pour ces tables.

---

## 8. Exemples de configurations

### 8.1. Mode "full" (toutes les tables, pas de filtre date)

```ini
DATE_SEUIL=
EXCLUDED_TABLES=cache,cache_bootstrap,sessions,watchdog,queue,civicrm_cache,civicrm_session,civicrm_log
LARGE_TABLES=
INCLUDE_LARGE_TABLES=1
TABLES_TO_PROCESS=
DATE_COLUMNS_CUSTOM=
```

### 8.2. Mode "ciblé" (quelques tables, avec filtre date)

```ini
DATE_SEUIL=2026-06-01
EXCLUDED_TABLES=cache,cache_bootstrap,sessions,watchdog,queue,civicrm_cache,civicrm_session,civicrm_log
LARGE_TABLES=civicrm_activity,civicrm_activity_contact
INCLUDE_LARGE_TABLES=0
TABLES_TO_PROCESS=civicrm_contact,civicrm_group,civicrm_group_contact
DATE_COLUMNS_CUSTOM=civicrm_contact:modified_date,civicrm_group:modified_date
```

---

## 9. Bonnes pratiques

- **Toujours tester sur une copie** de la base DEV avant d'appliquer en direct.
- **Vérifier soigneusement `rapport.txt`** :
  - En particulier les tables avec beaucoup de modifications.
  - Les tables critiques (contacts, contributions, adhésions, etc.).
- **Désactiver les checks de FK** lors de l'application de `diff.sql` :

  ```sql
  SET FOREIGN_KEY_CHECKS=0;
  SOURCE diff.sql;
  SET FOREIGN_KEY_CHECKS=1;
  ```

- **Ne pas committer `generate_diff.conf`** dans Git s'il contient des mots de passe, ou utiliser des variables d'environnement / vault.

---

## 10. Limitations et évolutions possibles

### 10.1. Limitations actuelles

- Pas de gestion des différences de schéma (pas d'`ALTER TABLE`).
- Pas de tri explicite basé sur les contraintes de clés étrangères (on s'appuie sur l'ordre du dump).
- Pas de mode "dry-run" (simulation sans génération de SQL) pour l'instant.

### 10.2. Évolutions envisageables

- Ajouter un mode `DRY_RUN=1` dans la config pour :
  - Générer uniquement `rapport.txt` sans `diff.sql`.
- Ajouter un tri des tables basé sur `information_schema.KEY_COLUMN_USAGE` pour respecter explicitement les FK.
- Ajouter un logging détaillé (`diff.log`) avec les requêtes générées par table.
- Ajouter un wrapper Bash pour appliquer automatiquement `diff.sql` sur une base cible avec gestion des erreurs.

---

## 11. Dépannage

### 11.1. Erreur : `DUMP_PROD_PATH non défini`

Vérifie que `generate_diff.sh` exporte bien :

```bash
export DUMP_PROD_PATH="${DUMP_PROD}"
```

et que tu as bien saisi le chemin du dump PROD.

### 11.2. Erreur : variable manquante dans `generate_diff.conf`

Vérifie que toutes les variables obligatoires sont présentes et non vides :

- `SOURCE_HOST`, `SOURCE_PORT`, `SOURCE_BDD_NAME`, `SOURCE_BDD_USER`, `SOURCE_BDD_PASS`
- `DEST_HOST`, `DEST_PORT`, `DEST_BDD_NAME`, `DEST_BDD_USER`, `DEST_BDD_PASS`
- `TMP_SOURCE_BDD`, `TMP_DEST_BDD`

### 11.3. Erreur MySQL : accès refusé

Vérifie :

- Les identifiants dans `generate_diff.conf`.
- Que l'utilisateur a bien les droits sur les bases temporaires.
- Que le host/port sont corrects.

### 11.4. `diff.sql` très volumineux

- Vérifie les tables exclues (`EXCLUDED_TABLES`).
- Utilise `TABLES_TO_PROCESS` pour ne traiter que les tables critiques.
- Active `INCLUDE_LARGE_TABLES=0` pour exclure les très grosses tables.

---

## 12. Résumé des commandes clés

```bash
# Installation des dépendances Python
pip3 install mysql-connector-python

# Rendre le script exécutable
chmod +x generate_diff.sh

# Lancer la génération du diff
./generate_diff.sh

# Vérifier le rapport
less rapport.txt

# Appliquer le diff (sur une base de test)
mysql -h... -u... -p... cfonb_dev_test -e "SET FOREIGN_KEY_CHECKS=0; SOURCE /chemin/vers/diff.sql; SET FOREIGN_KEY_CHECKS=1;"
```