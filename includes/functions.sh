#!/bin/bash
##
## Développé par Ilias Assadki
##
#############################################################
##
##  Fonctions utiles aux scripts
##
#############################################################

finduscript() {
    echo "Fin du script, checkpoint"
    exit 0
}

dbSize_Source() {
    echo " " ; echo -e "Taille de ${GREEN}$mysql_source_database${NC}"
    echo "SELECT CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' Mo') AS 'Taille de la base source' FROM information_schema.TABLES WHERE table_schema = '$mysql_source_database';" | sql
    echo " "
}

dbSize_Destination() {
    echo " " ; echo -e "Taille de ${GREEN}$mysql_destination_database${NC}"
    echo "SELECT CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' Mo') AS 'Taille de la base destination' FROM information_schema.TABLES WHERE table_schema = '$mysql_destination_database';" | sql
    echo " "
}

## Récupération des identifiants de l'instance source 
getWordpressID_Source(){
    cd $vhosts/$folder_source/httpdocs/ 
    mysql_source_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php`  
    mysql_source_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`
    mysql_source_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`
    cd $vhosts
}

getDrupalID_Source() {
    cd $vhosts/$folder_source/httpdocs/sites/default/
    mysql_source_database=$(sed -n "s/^[[:space:]]*'database' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_source_user=$(sed -n "s/^[[:space:]]*'username' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_source_mdp=$(sed -n "s/^[[:space:]]*'password' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    cd $vhosts
}

getBackdropID_Source() {
	cd $vhosts/$folder_source/httpdocs/
    mysql_source_database=$(sed -n "s/^[[:space:]]*'database' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_source_user=$(sed -n "s/^[[:space:]]*'username' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_source_mdp=$(sed -n "s/^[[:space:]]*'password' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    cd $vhosts
}

getStandaloneID_Source() {
    echo "Pas encore fonctionnel"
    exit 0
}


## Récupération des identifiants de l'instance destination
getWordpressID_Destination(){
    cd $vhosts/$folder_destination/httpdocs/ 
    mysql_destination_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php` 
    mysql_destination_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`
    mysql_destination_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`
    cd $vhosts
}

getDrupalID_Destination() {
    cd $vhosts/$folder_destination/httpdocs/sites/default/
    mysql_destination_database=$(sed -n "s/^[[:space:]]*'database' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_destination_user=$(sed -n "s/^[[:space:]]*'username' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_destination_mdp=$(sed -n "s/^[[:space:]]*'password' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    cd $vhosts
}

getStandaloneID_Destination() {
    echo "Pas encore fonctionnel"
    exit 0   
}

instanceVide_Destination() {
    echo " "
    echo "Instance destination vide, veuillez ecrire les identifiants de l'instance"
    echo " "
    echo " "
    echo "Nom de la base de données de l'instance destination ?" 
    read mysql_destination_database
    echo -e '\e[93m=============================================\033[0m'
    echo -e '\e[93m=============================================\033[0m' 
    echo "Nom de l'utilisateur de la base de données de l'instance destination ?"
    read mysql_destination_user
    echo -e '\e[93m=============================================\033[0m'
    echo -e '\e[93m=============================================\033[0m' 
    echo "MDP de l'utilisateur de la base de données de l'instance destination ?" 
    read mysql_destination_mdp
    echo " "  
    cd $vhosts
    break
}

remplacementURL_BDD() {
    if [ -f "$mysql_source_database.sql" ]; then 
        echo -e "${BLUE}[ INFO ]${NC} Remplacement des URL de ${GREEN}$folder_source${NC} par ${GREEN}$folder_destination${NC} ..."
        sed -i "s/DEFINER=[^*]*\*/\*/g" "$mysql_source_database.sql"
        ## Parcours et modification des URL
        local folder_source_escaped=${folder_source//./\\.}
        cat $mysql_source_database.sql \
		| sed "s|$root_folder_src|$root_folder_dest|g"\
        | sed "s|$folder_source_escaped|$folder_destination|g"\
        | sed "s|www.$folder_source|$folder_destination|g"\
        > $mysql_source_database.sql.tmp
        mv $mysql_source_database.sql.tmp $mysql_source_database.sql


        ## Spécifique instance Parlemonde et ses sous-domaines : prof.parlemonde.org - mediateurs.parlemonde.org - familles.parlemonde.org     
        [[ "$folder_source" == "parlemonde.org" || "$folder_source" == "familles.sandbox.parlemonde.org" || "$folder_source" == "prof.sandbox.parlemonde.org" || "$folder_source" == "mediateurs.sandbox.parlemonde.org" || "$folder_source" == "sandbox.parlemonde.org" ]] && sed -i "s/https:\/\/prof.`echo $folder_source`/https:\/\/prof.`echo $folder_destination`/g" $mysql_source_database.sql 
        [[ "$folder_source" == "parlemonde.org" || "$folder_source" == "familles.sandbox.parlemonde.org" || "$folder_source" == "prof.sandbox.parlemonde.org" || "$folder_source" == "mediateurs.sandbox.parlemonde.org" || "$folder_source" == "sandbox.parlemonde.org" ]] && sed -i "s/http:\/\/prof.`echo $folder_source`/https:\/\/prof.`echo $folder_destination`/g" $mysql_source_database.sql 
        [[ "$folder_source" == "parlemonde.org" || "$folder_source" == "familles.sandbox.parlemonde.org" || "$folder_source" == "prof.sandbox.parlemonde.org" || "$folder_source" == "mediateurs.sandbox.parlemonde.org" || "$folder_source" == "sandbox.parlemonde.org" ]] && sed -i "s/https:\/\/mediateurs.`echo $folder_source`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_source_database.sql
        [[ "$folder_source" == "parlemonde.org" || "$folder_source" == "familles.sandbox.parlemonde.org" || "$folder_source" == "prof.sandbox.parlemonde.org" || "$folder_source" == "mediateurs.sandbox.parlemonde.org" || "$folder_source" == "sandbox.parlemonde.org" ]] && sed -i "s/http:\/\/mediateurs.`echo $folder_source`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_source_database.sql
        [[ "$folder_source" == "parlemonde.org" || "$folder_source" == "familles.sandbox.parlemonde.org" || "$folder_source" == "prof.sandbox.parlemonde.org" || "$folder_source" == "mediateurs.sandbox.parlemonde.org" || "$folder_source" == "sandbox.parlemonde.org" ]] && sed -i "s/https:\/\/familles.`echo $folder_source`/https:\/\/familles.`echo $folder_destination`/g" $mysql_source_database.sql 
        [[ "$folder_source" == "parlemonde.org" || "$folder_source" == "familles.sandbox.parlemonde.org" || "$folder_source" == "prof.sandbox.parlemonde.org" || "$folder_source" == "mediateurs.sandbox.parlemonde.org" || "$folder_source" == "sandbox.parlemonde.org" ]] && sed -i "s/http:\/\/familles.`echo $folder_source`/https:\/\/familles.`echo $folder_destination`/g" $mysql_source_database.sql
        [[ "$folder_source" == "parlemonde.org" || "$folder_source" == "familles.sandbox.parlemonde.org" || "$folder_source" == "prof.sandbox.parlemonde.org" || "$folder_source" == "mediateurs.sandbox.parlemonde.org" || "$folder_source" == "sandbox.parlemonde.org" ]] && sed -i "s/prof.`echo $folder_source`/prof.`echo $folder_destination`/g" $mysql_source_database.sql
        [[ "$folder_source" == "parlemonde.org" || "$folder_source" == "familles.sandbox.parlemonde.org" || "$folder_source" == "prof.sandbox.parlemonde.org" || "$folder_source" == "mediateurs.sandbox.parlemonde.org" || "$folder_source" == "sandbox.parlemonde.org" ]] && sed -i "s/mediateurs.`echo $folder_source`/mediateurs.`echo $folder_destination`/g" $mysql_source_database.sql
        [[ "$folder_source" == "parlemonde.org" || "$folder_source" == "familles.sandbox.parlemonde.org" || "$folder_source" == "prof.sandbox.parlemonde.org" || "$folder_source" == "mediateurs.sandbox.parlemonde.org" || "$folder_source" == "sandbox.parlemonde.org" ]] && sed -i "s/familles.`echo $folder_source`/familles.`echo $folder_destination`/g" $mysql_source_database.sql

        ## Recalcul des longueurs dans les chaînes sérialisées PHP
        echo -e "${BLUE}[ INFO ]${NC} Recalcul des longueurs de chaînes sérialisées ..."
        recalculer_serialisation "$mysql_source_database.sql"

    else 
        echo -e ">> [${RED}ERREUR${NC}] "$mysql_source_database.sql" n'existe pas"
        exit 0
    fi
}
recalculer_serialisation_old() {
    local fichier="$1"
    # local fichier_tmp="${fichier}.reserial.tmp"

    # cp "$fichier" "$fichier_tmp"

    # Extraire toutes les chaînes sérialisées uniques du fichier (guillemets échappés)
    grep -oP 's:\d+:\\"[^\\"]*\\";' "$fichier" | sort -u | while IFS= read -r token; do
        # Extraire la chaîne entre \"...\"
        str=$(echo "$token" | grep -oP '(?<=\\")[^\\"]*(?=\\")')

        # Calculer la longueur en octets
        len=$(echo -n "$str" | wc -c)

        # Reconstruire le bon token
        new_token="s:${len}:\\\"${str}\\\";"

        # Remplacer dans le fichier uniquement si différent
        if [ "$token" != "$new_token" ]; then
            token_escaped=$(echo "$token" | sed 's|[&/\]|\\&|g')
            new_token_escaped=$(echo "$new_token" | sed 's|[&/\]|\\&|g')
            sed -i "s|${token_escaped}|${new_token_escaped}|g" "$fichier"
        fi
    done
    if [ $? -eq 0 ]; then
        # mv "$fichier_tmp" "$fichier"
        echo -e "${GREEN}[ OK ]${NC} Longueurs sérialisées recalculées."
    else
        echo -e "${RED}[ ERREUR ]${NC} Échec du recalcul de la sérialisation."
        # rm -f "$fichier_tmp"
        exit 1
    fi
}
recalculer_serialisation_bash() {
    local fichier="$1"
    local fichier_tmp="${fichier}.reserial.tmp"

    cp "$fichier" "$fichier_tmp" || { echo -e "${RED}[ ERREUR ]${NC} Impossible de copier le fichier." ; exit 1; }

    # Extraire toutes les chaînes sérialisées uniques du fichier (guillemets échappés)
    while IFS= read -r token; do
        # Extraire la chaîne entre \"...\"
        str=$(echo "$token" | grep -oP '(?<=\\")[^\\"]*(?=\\")')

        # Calculer la longueur en octets
        len=$(echo -n "$str" | wc -c)

        # Reconstruire le bon token
        new_token="s:${len}:\\\"${str}\\\";"

        # Remplacer dans le fichier tmp uniquement si différent
        if [ "$token" != "$new_token" ]; then
            token_escaped=$(echo "$token" | sed 's|[&/\]|\\&|g')
            new_token_escaped=$(echo "$new_token" | sed 's|[&/\]|\\&|g')
            sed -i "s|${token_escaped}|${new_token_escaped}|g" "$fichier_tmp"
        fi
    done < <(grep -oP 's:\d+:\\"[^\\"]*\\";' "$fichier" | sort -u)

    # Vérifier que le fichier tmp n'est pas vide avant de remplacer
    if [ -s "$fichier_tmp" ]; then
        mv "$fichier_tmp" "$fichier"
        echo -e "${GREEN}[ OK ]${NC} Longueurs sérialisées recalculées."
    else
        echo -e "${RED}[ ERREUR ]${NC} Fichier tmp vide, annulation."
        rm -f "$fichier_tmp"
        exit 1
    fi
}

# Version python histoire d'accélerer
# Python — lit le fichier une seule fois en mémoire, applique le regex en une passe, réécrit le fichier une seule fois
# cas problématiques courants :
#    1. \r littéraux 
#       s:67:"adresse\r ville";  → longueur comptée faussement
#    2. Chaînes imbriquées — une sérialisation dans une sérialisation
#       s:45:"a:2:{s:4:"test";s:5:"hello";}";
#       Le regex peut se tromper sur les guillemets internes.
#    3. Caractères UTF-8 multi-octets
#        s:5:"éàü";  → é=2 octets, PHP compte en octets pas en caractères
#       Python avec .encode('utf-8') gère ça correctement ✅
#    4. Chaînes vides
#       s:0:"";  → pas de problème normalement mais à vérifier
#    5. Retours à la ligne réels \n dans la chaîne
#       s:20:"ligne1
#       ligne2";  → le \n compte 1 octet mais peut casser le regex sans re.DOTALL
#   6. Caractères spéciaux SQL comme \' ou \\
#       s:10:"l\'adresse";  → PHP compte l'apostrophe échappée différemment
#
# Le cas le plus piégeux reste les chaînes imbriquées — un vrai parser PHP sérialisé serait nécessaire pour les gérer parfaitement, mais en pratique dans un dump CiviCRM/WordPress c'est rarissime.
# En pratique le script actuel est compatible Drupal, Joomla et standalone sans modification majeure. Le seul cas où tu pourrais avoir un souci est si Drupal stocke des données binaires sérialisées, ce qui est rarissime.
recalculer_serialisation() {
    local fichier="$1"

    python3 - "$fichier" <<'EOF'
import re
import sys

fichier = sys.argv[1]
fichier_tmp = fichier + ".reserial.tmp"

def calc_length(str_value):
    """
    Calcule la longueur en octets comme PHP strlen() le fait.
    Chaque séquence échappée vaut 1 octet pour PHP mais 2 pour Python.
    """
    nb_backslash_r   = str_value.count('\\r')
    nb_backslash_n   = str_value.count('\\n')
    nb_backslash_t   = str_value.count('\\t')
    nb_double_slash  = str_value.count('\\\\')
    nb_escaped_quote = str_value.count("\\'")

    length = len(str_value.encode('utf-8')) \
           - nb_backslash_r   \
           - nb_backslash_n   \
           - nb_backslash_t   \
           - nb_double_slash  \
           - nb_escaped_quote

    return length

def fix_length_escaped(match):
    """Gère les chaînes avec guillemets échappés : s:N:\\"...\\"; """
    str_value = match.group(1)
    return 's:' + str(calc_length(str_value)) + ':\\"' + str_value + '\\";'

def fix_length_normal(match):
    """Gère les chaînes avec guillemets normaux : s:N:"..."; """
    str_value = match.group(1)
    return 's:' + str(calc_length(str_value)) + ':"' + str_value + '";'

try:
    with open(fichier, 'r', encoding='utf-8', errors='replace') as f:
        content = f.read()

    # 1. Guillemets échappés \"...\"  (dans les dumps MySQL)
    pattern_escaped = re.compile(r's:\d+:\\"([^\\"]*?)\\";', re.DOTALL)
    fixed_content = pattern_escaped.sub(fix_length_escaped, content)

    # 2. Guillemets normaux "..."  (hors dump ou après désérialisation)
    pattern_normal = re.compile(r's:\d+:"([^"]*?)";', re.DOTALL)
    fixed_content = pattern_normal.sub(fix_length_normal, fixed_content)

    with open(fichier_tmp, 'w', encoding='utf-8') as f:
        f.write(fixed_content)

    print("OK")
    sys.exit(0)

except Exception as e:
    print(f"ERREUR : {e}", file=sys.stderr)
    sys.exit(1)

EOF

    if [ $? -eq 0 ]; then
        mv "${fichier}.reserial.tmp" "$fichier"
        echo -e "${GREEN}[ OK ]${NC} Longueurs sérialisées recalculées."
    else
        echo -e "${RED}[ ERREUR ]${NC} Échec du recalcul de la sérialisation."
        rm -f "${fichier}.reserial.tmp"
        exit 1
    fi
}

## Test CMS - Drupal
majValeurs_Drupal() {
    cd $racine/$root_folder_dest/sites/default/
    if [[ -f "settings.php" ]]; then
	    replace "'database' => '$mysql_source_database'" "'database' => '$mysql_destination_database'" -- settings.php 2> /dev/null >&2
	    replace "'username' => '$mysql_source_user'" "'username' => '$mysql_destination_user'" -- settings.php 2> /dev/null >&2
	    replace "'password' => '$mysql_source_mdp'" "'password' => '$mysql_destination_mdp'" -- settings.php 2> /dev/null >&2
	 	# [[ -f "settings.php" ]] && sed -i "s|https://$folder_source|https://$folder_destination|g" settings.php
	    replace "$base_url = 'https://$folder_source'" "$base_url = 'https://$folder_destination'" -- settings.php 2> /dev/null >&2
	fi
    cd $racine
}

## Recherche de la présence de CiviCRM pour Drupal
majValeursCivicrm_Drupal() {
	cd $racine
	cd $root_folder_dest

    if [ ! -e ./sites/default/civicrm.settings.php ]; then
        echo -e "${PURPLE}[WARNING] ${NC} CiviCRM pour Drupal absent"
        return
    fi
    cd ./sites/default/
    if [ -v DEBUG ]; then
        echo "mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database"
    fi
    replace "mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database"\
			"mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database"\
      		-- civicrm.settings.php > /dev/null
    sed -i "s|mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database|mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database|g" civicrm.settings.php
    replace "$root_folder_src" "$root_folder_dest"\
    		"$folder_source" "$folder_destination" -- civicrm.settings.php 
}

majValeur_Backdrop() {
	cd $racine
	cd $root_folder_dest
	[[ -f "settings.php" ]] && sed -i "s|'database' => '$mysql_source_database'|'database' => '$mysql_destination_database'|g" settings.php
    [[ -f "settings.php" ]] && sed -i "s|'username' => '$mysql_source_user'|'username' => '$mysql_destination_user'|g" settings.php
    [[ -f "settings.php" ]] && sed -i "s|'password' => '$mysql_source_mdp'|'password' => '$mysql_destination_mdp'|g" settings.php
 ## [[ -f "settings.php" ]] && sed -i "s|https://$folder_source|https://$folder_destination|g" settings.php
    [[ -f "settings.php" ]] && sed -i "s|$base_url = 'https://$folder_source'|$base_url = 'https://$folder_destination'|g" settings.php

	
    if [ ! -e civicrm.settings.php ]; then
        echo -e "${PURPLE}[WARNING] ${NC} CiviCRM pour backdrop absent"
       	cd $racine
        return
    fi
    if [ -v DEBUG ]; then
        echo "mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database"
    fi
   	replace "mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database"\
		"mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database"\
   		-- civicrm.settings.php > /dev/null
   	replace "$root_folder_src" "$root_folder_dest"\
   			"$folder_source" "$folder_destination" -- civicrm.settings.php 
	cd $racine
}

## Test CMS - WordPress
majValeurs_Wordpress() {
	cd $racine
    cd $root_folder_dest
    [[ -f "wp-config.php" ]] && sed -i "s|/vhosts/$folder_source|/vhosts/$folder_destination|g" wp-config.php    
    [[ -f "wp-config.php" ]] && sed -i "s|'DB_NAME', '$mysql_source_database'|'DB_NAME', '$mysql_destination_database'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|'DB_USER', '$mysql_source_user'|'DB_USER', '$mysql_destination_user'|g" wp-config.php
    [[ -f "wp-config.php" ]] && replace "$mysql_source_mdp" "$mysql_destination_mdp" -- wp-config.php
    # [[ -f "wp-config.php" ]] && sed -i "s|'DB_PASSWORD', '$mysql_source_mdp'|'DB_PASSWORD', '$mysql_destination_mdp'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|$root_folder_src|$root_folder_dest|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|$folder_source|$folder_destination|g" wp-config.php
	cd $racine
}

## Recherche de WordFence pour WordPress
majValeurs_Wordfence() {
	cd $racine
    if [ ! -e $root_folder_dest/.user.ini ]; then
        echo -e "${PURPLE}[WARNING]${NC} Fichiers générés par WordFence absents"    
        return 1
    fi
    cd $root_folder_dest
    [[ -f ".user.ini" ]] && sed -i "s/\/vhosts\/`echo $folder_source`\//\/vhosts\/`echo $folder_destination`\//g" .user.ini
    [[ -f "wordfence-waf.php" ]] && sed -i "s/\/vhosts\/`echo $folder_source`\//\/vhosts\/`echo $folder_destination`\//g" wordfence-waf.php
	cd $racine
}

## Recherche de la présence de CiviCRM pour WordPress  
majValeursCivicrm_Wordpress() {
	cd $racine
    if [ ! -e $root_folder_dest/wp-content/uploads/civicrm/civicrm.settings.php ]; then
        echo -e "${PURPLE}[WARNING]${NC} CiviCRM pour Wordpress absent des extensions"
        return 1
    fi

    cd $root_folder_dest/wp-content/uploads/civicrm
    if [ -v DEBUG ]; then
        echo "mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database"
    fi

    replace "mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database"\
			"mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database"\
      		-- civicrm.settings.php > /dev/null
    replace "$root_folder_src" "$root_folder_dest"\
    		"$folder_source" "$folder_destination" -- civicrm.settings.php 

	cd $racine
}

maj_valeur_civicrm_settings_php()
{
    file_path=$1
    if [ ! -e "$file_path/civicrm.settings.php" ]; then
        echo -e "${PURPLE}[WARNING]${NC} chemin ver civicrm.settings.php invalid"
        return 1
    fi

    cd $file_path
    if [ -v DEBUG ]; then
    	echo "mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database"
    fi

    replace \
      "mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database" \
      "mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database" \
      -- civicrm.settings.php > /dev/null
    sed -i "s|mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database|mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database|g" civicrm.settings.php
    replace "$root_folder_src" "$root_folder_dest"\
    		"$folder_source" "$folder_destination" -- civicrm.settings.php 
}

## Vidage de l'instance destination
vidageInstance_Destination(){
    # Condition remplie si et seulement si $folder_destination contient un httpdocs/
    if test -e $vhosts/$folder_destination/httpdocs; then
        cd $vhosts/$folder_destination
        rm -rf httpdocs/* > /dev/null 2>&1 # suppression du contenu de httpdocs/*
        rm -rf httpdocs/.* > /dev/null 2>&1 # suppression des fichiers cachés de httpdocs/*
        echo "Dossier httpdocs/ de l'instance $folder_destination bien vidé !" 
        cd $vhosts 
    fi
}

vidageBDD_Source(){
    # Vérifier si la base de données contient des tables
    table_count=$(mysql -u "$mysql_source_user" -p"$mysql_source_mdp" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$mysql_source_database';" -s -N)

    # Si aucune table n'est présente, informer et continuer
    if [ "$table_count" -eq 0 ]; then
        return 0;
    fi
    # Tentative de connexion et dump des tables sans données
    echo "SET FOREIGN_KEY_CHECKS = 0;" > ./temp_vidage.sql 
    echo -e ">> Vidage de la base de données de ${GREEN}$mysql_source_database${NC} ..."
    mysqldump --add-drop-table --no-data -u "$mysql_source_user" -p"$mysql_source_mdp" "$mysql_source_database" | grep 'DROP TABLE' >> ./temp_vidage.sql
    echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./temp_vidage.sql 
    mysql -u $mysql_source_user -p$mysql_source_mdp $mysql_source_database < ./temp_vidage.sql
    rm temp_vidage.sql ; echo " "
}
 
vidageBDD_Destination(){
    # Vérifier si la base de données contient des tables
    table_count=$(mysql -u "$mysql_destination_user" -p"$mysql_destination_mdp" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$mysql_destination_database';" -s -N)

    # Si aucune table n'est présente, informer et continuer
    if [ -z "$table_count" ] | [ "$table_count" -eq 0 ]; then
        echo -e "${RED}[ERREUR]${NC} table_count = $table_count; $mysql_destination_user; $mysql_destination_mdp; $mysql_destination_database"
        return 0;
    fi
    # Tentative de connexion et dump des tables sans données
    echo "SET FOREIGN_KEY_CHECKS = 0;" > ./temp_vidage.sql 
    echo -e ">> Vidage de la base de données ${GREEN}$mysql_destination_database${NC} ..."
    mysqldump --lock-tables=false --add-drop-table --no-data -u "$mysql_destination_user" -p"$mysql_destination_mdp" "$mysql_destination_database" | grep 'DROP TABLE' >> ./temp_vidage.sql
    echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./temp_vidage.sql 
    mysql -u $mysql_destination_user -p$mysql_destination_mdp $mysql_destination_database < ./temp_vidage.sql
    rm temp_vidage.sql ; echo " "
}

nettoyageAdressesElectroniques() {
    echo -e "${BLUE}[ INFO ]${NC} Nettoyage des adresses électroniques dans ${GREEN}$mysql_destination_database${NC} ..."
    sed -i 's|@'"$folder_destination"'|@'"$folder_source"'|g' $mysql_source_database.sql
}

exportBDD_Source() {
    echo -e "${BLUE}[ INFO ]${NC} Dump de la base de données ${GREEN}$mysql_source_database${NC} ..."
    mysqldump --skip-triggers --user=$mysql_source_user --password=$mysql_source_mdp $mysql_source_database > $mysql_source_database.sql  # ajout skip-triggers
}

importBDD_Source() {
    echo -e "${BLUE}[ INFO ]${NC} Import de la base de données ${GREEN}$mysql_source_database${NC} ..."
    mysql --user=$mysql_source_user --password=$mysql_source_mdp $mysql_source_database < $mysql_source_database.sql   
}

# Sert au script de clonage et clonage BDD
importBDD_Destination() {
    echo -e "${BLUE}[ INFO ]${NC} Import de la base de données ${GREEN}$mysql_destination_database${NC} ..."
    mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $mysql_source_database.sql
}

## Remplacement des occurences '@folder_destination' vers '@folder_source', dans folder_destination.sql. Utile que dans quelque cas précis 
remplacement_occurences_@_dest(){  
    # Export du SQL 
    mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database > $folder_destination.sql && echo "Connexion et DUMP SQL réussi"
    # Remplacement de chaines contenant un '@folder_destination' par '@folder_source'
    sed -i "s/@$folder_destination/@$folder_source/g" "$folder_destination.sql"
    # Import du SQL dans la bonne BDD
    mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $folder_destination.sql && echo "Connexion et PUMP SQL réussi"
}



set_maintenance_mode() {
    local site="$1"
    local instance_support=$2
    local current_pwd=$(pwd)
    cd "/var/www/vhosts/$site/httpdocs/"

    if [[ "$instance_support" == "drupal" ]]; then
        drush vset site_offline 1
        drush cache-clear all
    fi

    if [[ "$instance_support" == "wordpress" ]]; then
        wp maintenance-mode activate --allow-root
    fi

    if [[ "$instance_support" == "standalone" ]]; then
        cv vset core_maintenance_mode=1
    fi

    if [[ "$instance_support" == "backdrop" ]]; then
      	bee maintenance-mode true;
    fi

    cd "$current_pwd"
}

get_site_root() {
	local current_pwd=$(pwd)
	cd $racine
	local result=$(find -maxdepth 2 -name $1 -type d -printf "%P\n" 2> /dev/null | grep -v "logs" | grep -v "system" | grep -v ".rapid-scan-db")
	test -d "$result/httpdocs" && result="$result/httpdocs"
	cd $current_pwd
	echo $result

    # # convertir en chemin absolu
    # result="$(realpath "$racine/$result" 2>/dev/null || echo "")"
    # cd "$current_pwd" || return 1
    # echo "$result"
}

unset_maintenance_mode() {
    local site="$1"
    local instance_support=$2
    local current_pwd=$(pwd)
    local site_root=$(get_site_root $site)
    cd "/var/www/vhosts/$site/httpdocs/"

    if [[ "$instance_support" == "drupal" ]]; then
        drush vset site_offline 0
        drush cache-clear all
    fi

    if [[ "$instance_support" == "wordpress" ]]; then
        wp maintenance-mode deactivate --allow-root
    fi

    if [[ "$instance_support" == "standalone" ]]; then
        cv vset core_maintenance_mode=0
    fi

    if [[ "$instance_support" == "backdrop" ]]; then
    	bee maintenance-mode false;
    fi

    cd "$current_pwd"
}

exit_on_equal()
{
    if [ "$1" = "$2" ]; then
        if [ -z "$3" ]; then
            echo -e "${RED}[ ERROR ]${NC} Two values should not be equal: $1 = $2"
        else
            echo -e "${RED}[ ERROR ]${NC} $3"
        fi
        exit 1
    fi
}

#################################################
## recuper la version de civicrm d'une instance
## Ajout Par Antoine 
#################################################
get_civi_version() {
    local instance="$1"
    local site_root
    local civi_version="---"
    local cms="N/A"

    site_root=$(get_site_root "$instance")
    cd "$racine/$site_root" 2>/dev/null || return 1

    if [[ -f "wp-config.php" ]]; then
        cms="wordpress"
        civi_version=$(cv status --out=shell 2>/dev/null \
            | grep "civicrm_value" | cut -d"'" -f2 | cut -d" " -f1)
    elif [[ -f "sites/default/settings.php" ]]; then
        cms="drupal"
        civi_version=$(cv status --out=shell 2>/dev/null \
            | grep "civicrm_value" | cut -d"'" -f2 | cut -d" " -f1)
    elif [[ -f "private/civicrm.settings.php" ]]; then
        cms="standalone"
        civi_version=$(cv status --out=shell 2>/dev/null \
            | grep "civicrm_value" | cut -d"'" -f2 | cut -d" " -f1)
    elif [[ -f "settings.php" ]]; then
        cms="backdrop"
        civi_version="---"
    else
        cms="N/A"
        civi_version="---"
    fi

    cd "$OLDPWD" 2>/dev/null || true
    echo "$civi_version"   # Ce echo sert de "return" pour $(get_civi_version ...)
}
