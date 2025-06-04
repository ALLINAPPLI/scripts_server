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
    plesk db "SELECT CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' Mo') AS 'Taille de la base source' FROM information_schema.TABLES WHERE table_schema = '$mysql_source_database';"
    echo " "
}

dbSize_Destination() {
    echo " " ; echo -e "Taille de ${GREEN}$mysql_destination_database${NC}"
    plesk db "SELECT CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' Mo') AS 'Taille de la base destination' FROM information_schema.TABLES WHERE table_schema = '$mysql_destination_database';"
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
       
    else 
        echo -e ">> [${RED}ERREUR${NC}] "$mysql_source_database.sql" n'existe pas"
        exit 0
    fi
}


## Test CMS - Drupal
majValeurs_Drupal() {
    cd $vhosts/$folder_destination/httpdocs/sites/default/ 
    [[ -f "settings.php" ]] && sed -i "s|'database' => '$mysql_source_database'|'database' => '$mysql_destination_database'|g" settings.php
    [[ -f "settings.php" ]] && sed -i "s|'username' => '$mysql_source_user'|'username' => '$mysql_destination_user'|g" settings.php
    [[ -f "settings.php" ]] && sed -i "s|'password' => '$mysql_source_mdp'|'password' => '$mysql_destination_mdp'|g" settings.php
 ## [[ -f "settings.php" ]] && sed -i "s|https://$folder_source|https://$folder_destination|g" settings.php
    [[ -f "settings.php" ]] && sed -i "s|$base_url = 'https://$folder_source'|$base_url = 'https://$folder_destination'|g" settings.php
    cd $vhosts
}

## Recherche de la présence de CiviCRM pour Drupal
majValeursCivicrm_Drupal() {
    if [ ! -e $vhosts/$folder_destination/httpdocs/sites/default/civicrm.settings.php ]; then
        echo -e "${PURPLE}[WARNING] ${NC} CiviCRM pour Drupal absent"
    fi
    cd $vhosts/$folder_destination/httpdocs/sites/default/
    [[ -f "civicrm.settings.php" ]] && sed -i "s|mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database|mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|$folder_source|$folder_destination|g" civicrm.settings.php
    cd $vhosts 
}

## Test CMS - WordPress
majValeurs_Wordpress() {
    cd $vhosts/$folder_destination/httpdocs
    [[ -f "wp-config.php" ]] && sed -i "s|/vhosts/$folder_source|/vhosts/$folder_destination|g" wp-config.php    
    [[ -f "wp-config.php" ]] && sed -i "s|'DB_NAME', '$mysql_source_database'|'DB_NAME', '$mysql_destination_database'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|'DB_USER', '$mysql_source_user'|'DB_USER', '$mysql_destination_user'|g" wp-config.php
    [[ -f "wp-config.php" ]] && replace "$mysql_source_mdp" "$mysql_destination_mdp" -- wp-config.php
    # [[ -f "wp-config.php" ]] && sed -i "s|'DB_PASSWORD', '$mysql_source_mdp'|'DB_PASSWORD', '$mysql_destination_mdp'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|$folder_source|$folder_destination|g" wp-config.php
     cd $vhosts
}

## Recherche de WordFence pour WordPress
majValeurs_Wordfence() {
    if [ ! -e $vhosts/$folder_destination/httpdocs/.user.ini ]; then
        echo -e "${PURPLE}[WARNING]${NC} Fichiers générés par WordFence absents"    
        return 1
    fi
    cd $vhosts/$folder_destination/httpdocs
    [[ -f ".user.ini" ]] && sed -i "s/\/vhosts\/`echo $folder_source`\//\/vhosts\/`echo $folder_destination`\//g" .user.ini
    [[ -f "wordfence-waf.php" ]] && sed -i "s/\/vhosts\/`echo $folder_source`\//\/vhosts\/`echo $folder_destination`\//g" wordfence-waf.php
    cd $vhosts
}

## Recherche de la présence de CiviCRM pour WordPress  
majValeursCivicrm_Wordpress() {
    if [ ! -e $vhosts/$folder_destination/httpdocs/wp-content/uploads/civicrm/civicrm.settings.php ]; then
        echo -e "${PURPLE}[WARNING]${NC} CiviCRM pour Wordpress absent des extensions"
        return 1
    fi

    cd $vhosts/$folder_destination/httpdocs/wp-content/uploads/civicrm
    [[ -f "civicrm.settings.php" ]] && sed -i "s|mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database|mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|$folder_source|$folder_destination|g" civicrm.settings.php
    cd $vhosts
}

maj_valeur_civicrm_settings_php()
{
    file_path=$1
    if [ ! -e "$file_path/civicrm.settings.php" ]; then
        echo -e "${PURPLE}[WARNING]${NC} chemin ver civicrm.settings.php invalid"
        return 1
    fi

    cd $file_path
    [[ -f "civicrm.settings.php" ]] && sed -i "s|mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database|mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|$folder_source|$folder_destination|g" civicrm.settings.php
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
    sudo mysqldump --add-drop-table --no-data -u "$mysql_source_user" -p"$mysql_source_mdp" "$mysql_source_database" | grep 'DROP TABLE' >> ./temp_vidage.sql
    echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./temp_vidage.sql 
    sudo mysql -u $mysql_source_user -p$mysql_source_mdp $mysql_source_database < ./temp_vidage.sql
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
    sudo mysqldump --lock-tables=false --add-drop-table --no-data -u "$mysql_destination_user" -p"$mysql_destination_mdp" "$mysql_destination_database" | grep 'DROP TABLE' >> ./temp_vidage.sql
    echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./temp_vidage.sql 
    sudo mysql -u $mysql_destination_user -p$mysql_destination_mdp $mysql_destination_database < ./temp_vidage.sql
    rm temp_vidage.sql ; echo " "
}

nettoyageAdressesElectroniques() {
    echo -e "${BLUE}[ INFO ]${NC} Nettoyage des adresses électroniques dans ${GREEN}$mysql_destination_database${NC} ..."
    sed -i 's|@'"$folder_destination"'|@'"$folder_source"'|g' $mysql_source_database.sql
}

exportBDD_Source() {
    echo -e "${BLUE}[ INFO ]${NC} Dump de la base de données ${GREEN}$mysql_source_database${NC} ..."
    sudo mysqldump --skip-triggers --user=$mysql_source_user --password=$mysql_source_mdp $mysql_source_database > $mysql_source_database.sql  # ajout skip-triggers
}

importBDD_Source() {
    echo -e "${BLUE}[ INFO ]${NC} Import de la base de données ${GREEN}$mysql_source_database${NC} ..."
    sudo mysql --user=$mysql_source_user --password=$mysql_source_mdp $mysql_source_database < $mysql_source_database.sql   
}

# Sert au script de clonage et clonage BDD
importBDD_Destination() {
    echo -e "${BLUE}[ INFO ]${NC} Import de la base de données ${GREEN}$mysql_destination_database${NC} ..."
    sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $mysql_source_database.sql
}

## Remplacement des occurences '@folder_destination' vers '@folder_source', dans folder_destination.sql. Utile que dans quelque cas précis 
remplacement_occurences_@_dest(){  
    # Export du SQL 
    sudo mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database > $folder_destination.sql && echo "Connexion et DUMP SQL réussi"

    # Remplacement de chaines contenant un '@folder_destination' par '@folder_source'
    sed -i "s/@$folder_destination/@$folder_source/g" "$folder_destination.sql"

    # Import du SQL dans la bonne BDD
    sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $folder_destination.sql && echo "Connexion et PUMP SQL réussi"
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

    cd "$current_pwd"
}


unset_maintenance_mode() {
    local site="$1"
    local instance_support=$2
    local current_pwd=$(pwd)
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
