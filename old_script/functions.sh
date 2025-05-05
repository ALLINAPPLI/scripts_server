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
    echo " " ; echo "Taille de $mysql_source_database"
    # plesk db "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) 'Taille de la base source' FROM information_schema.TABLES WHERE table_schema = '$mysql_source_database';"
    plesk db "SELECT CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' Mo') AS 'Taille de la base source' FROM information_schema.TABLES WHERE table_schema = '$mysql_source_database';"
    echo " "
}

dbSize_Destination() {
    echo " " ; echo "Taille de $mysql_destination_database"
    # plesk db "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) 'Taille de la base destination' FROM information_schema.TABLES WHERE table_schema = '$mysql_destination_database';"
    plesk db "SELECT CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' Mo') AS 'Taille de la base destination' FROM information_schema.TABLES WHERE table_schema = '$mysql_destination_database';"
    echo " "
}

## Recuperation des identifiants de l'instance source 
getWordpressID_Source(){
    cd $vhosts/$folder_source/httpdocs/ 
    mysql_source_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php`  
    mysql_source_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`
    mysql_source_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`
    echo "BDD  : $mysql_source_database"
    echo "USER : $mysql_source_user"
    echo "MDP  : $mysql_source_mdp"  
    cd $vhosts
    break
}

getDrupalID_Source() {
    cd $vhosts/$folder_source/httpdocs/sites/default/
    mysql_source_database=$(sed -n "s/^[[:space:]]*'database' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_source_user=$(sed -n "s/^[[:space:]]*'username' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_source_mdp=$(sed -n "s/^[[:space:]]*'password' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    echo "BDD  : $mysql_source_database"
    echo "USER : $mysql_source_user"
    echo "MDP  : $mysql_source_mdp"
    cd $vhosts
    break
}

getStandaloneID_source() {
    echo "Pas encore fonctionnel"
    exit 0
}

## Recuperation des identifiants de l'instance destination
getWordpressID_Destination(){
    cd $vhosts/$folder_destination/httpdocs/ 
    mysql_destination_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php` 
    mysql_destination_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`
    mysql_destination_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`
    echo "BDD : $mysql_destination_database"
    echo "USER : $mysql_destination_user"
    echo "MDP : $mysql_destination_mdp"
    cd $vhosts
    break
}

getDrupalID_Destination() {
    cd $vhosts/$folder_destination/httpdocs/sites/default/
    mysql_destination_database=$(sed -n "s/^[[:space:]]*'database' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_destination_user=$(sed -n "s/^[[:space:]]*'username' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    mysql_destination_mdp=$(sed -n "s/^[[:space:]]*'password' => '\([^']*\)',/\1/p" settings.php | head -n 1)
    echo "BDD  : $mysql_destination_database"
    echo "USER : $mysql_destination_user"
    echo "MDP  : $mysql_destination_mdp" 
    cd $vhosts
    break
}

getStandaloneID_destination() {
    echo "Pas encore fonctionnel"
    exit 0   
}

instanceVide_destination() {
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
    # Export de la BDD Source dans $folder_source.sql 
    sudo mysqldump --user=$mysql_source_user --password=$mysql_source_mdp $mysql_source_database > $mysql_source_database.sql
    echo -e ">> [${GREEN}REUSSI${NC}] Export de $mysql_source_database effectué"
    
    if [ -f "$mysql_source_database.sql" ]; then 
        sed -i "s/DEFINER=[^*]*\*/\*/g" "$mysql_source_database.sql"

        ## Parcours et modification de chaque BDD
        sed -i "s/`echo $folder_source`/`echo $folder_destination`/g" $mysql_source_database.sql
        sed -i "s/https:\/\/`echo $folder_source`/https:\/\/`echo $folder_destination`/g" $mysql_source_database.sql
        sed -i "s/http:\/\/`echo $folder_source`/https:\/\/`echo $folder_destination`/g" $mysql_source_database.sql
        sed -i "s/https:\/\/www.`echo $folder_source`/https:\/\/`echo $folder_destination`/g" $mysql_source_database.sql
        sed -i "s/http:\/\/www.`echo $folder_source`/https:\/\/`echo $folder_destination`/g" $mysql_source_database.sql
        sed -i "s/www.`echo $folder_source`/`echo $folder_destination`/g" $mysql_source_database.sql
        sed -i "s/\/vhosts\/`echo $folder_source`/\/vhosts\/`echo $folder_destination`/g" $mysql_source_database.sql

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
        
        echo -e ">> [${GREEN}REUSSI${NC}] Remplacement des URL et valeurs effectué"

        sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $mysql_source_database.sql > /dev/null 2>&1
        echo -e ">> [${GREEN}REUSSI${NC}] Import de $mysql_source_database dans $mysql_destination_database effectué"
        
        # Affichage des tailles des bases de données source et destination
        dbSize_Source
        dbSize_Destination
    else 
        echo -e ">> [${RED}ERREUR${NC}] "$mysql_source_database.sql" n'existe pas"
        #! Suppression de temp_clonage
        exit 0
    fi
}

## Test CMS - Drupal
majValeurs_Drupal() {
    cd $vhosts/$folder_destination/httpdocs/sites/default/ 
    [[ -f "settings.php" ]] && sed -i "s|'database' => '$mysql_source_database'|'database' => '$mysql_destination_database'|g" settings.php
    [[ -f "settings.php" ]] && sed -i "s|'username' => '$mysql_source_user'|'username' => '$mysql_destination_user'|g" settings.php
    [[ -f "settings.php" ]] && sed -i "s|'password' => '$mysql_source_mdp'|'password' => '$mysql_destination_mdp'|g" settings.php
    [[ -f "settings.php" ]] && sed -i "s|https://$folder_source|https://$folder_destination|g" settings.php
    cd $vhosts
}

## Recherche de la présence de CiviCRM pour Drupal
majValeursCivicrm_Drupal() {
    cd $vhosts/$folder_destination/httpdocs/sites/default/
    [[ -f "civicrm.settings.php" ]] && sed -i "s|mysql://$mysql_source_user:$mysql_source_mdp@$mysql_server/$mysql_source_database|mysql://$mysql_destination_user:$mysql_destination_mdp@$mysql_server/$mysql_destination_database|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|https://$folder_source/|https://$folder_destination/|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|/vhosts/$folder_source|/vhosts/$folder_destination|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|'https://$folder_source'|'https://$folder_destination'|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|'https://www.$folder_source'|'https://$folder_destination'|g" civicrm.settings.php
    cd $vhosts 
}

## Test CMS - WordPress
majValeurs_Wordpress() {
    cd $vhosts/$folder_destination/httpdocs
    [[ -f "wp-config.php" ]] && sed -i "s|/vhosts/$folder_source|/vhosts/$folder_destination|g" wp-config.php    
    [[ -f "wp-config.php" ]] && sed -i "s|'DB_NAME', '$mysql_source_database'|'DB_NAME', '$mysql_destination_database'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|'DB_USER', '$mysql_source_user'|'DB_USER', '$mysql_destination_user'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|'DB_PASSWORD', '$mysql_source_mdp'|'DB_PASSWORD', '$mysql_destination_mdp'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|'https://$folder_source'|'https://$folder_destination'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|'https://www.$folder_source'|'https://www.$folder_destination'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|'www.$folder_source'|'www.$folder_destination'|g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s|$folder_source|$folder_destination|g" wp-config.php
 
    ## parlemonde.org (modification de deux variables de plus sur wp-config.php) 
    # [[ -f "wp-config.php" ]] && sed -i "s/define('DOMAIN_CURRENT_SITE', '`echo $folder_source`');/define('DOMAIN_CURRENT_SITE', '`echo $folder_destination`');/g" wp-config.php ##109 sans www sans espace
    # [[ -f "wp-config.php" ]] && sed -i "s/define( 'DOMAIN_CURRENT_SITE', '`echo $folder_source`' );/define( 'DOMAIN_CURRENT_SITE', '`echo $folder_destination`' );/g" wp-config.php ##109 sans www avec espace
    # [[ -f "wp-config.php" ]] && sed -i "s/define( 'NOBLOGREDIRECT', 'https:\/\/www.`echo $folder_source`' );/define( 'NOBLOGREDIRECT', 'https:\/\/`echo $folder_destination`' );/g" wp-config.php 
    cd $vhosts
}

## Recherche de WordFence pour WordPress
majValeurs_Wordfence() {
    cd $vhosts/$folder_destination/httpdocs
    [[ -f ".user.ini" ]] && sed -i "s/\/vhosts\/`echo $folder_source`\//\/vhosts\/`echo $folder_destination`\//g" .user.ini
    [[ -f "wordfence-waf.php" ]] && sed -i "s/\/vhosts\/`echo $folder_source`\//\/vhosts\/`echo $folder_destination`\//g" wordfence-waf.php
    cd $vhosts
}

## Recherche de la présence de CiviCRM pour WordPress  
majValeursCivicrm_Wordpress() { 
    cd $vhosts/$folder_destination/httpdocs/wp-content/uploads/civicrm
    [[ -f "civicrm.settings.php" ]] && sed -i "s|$mysql_source_user|$mysql_destination_user|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|$mysql_source_mdp|$mysql_destination_mdp|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|$mysql_source_database|$mysql_destination_database|g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s|vhosts/$folder_source|vhosts/$folder_destination|g" civicrm.settings.php 
    [[ -f "civicrm.settings.php" ]] && sed -i "s|https://$folder_source|https:\/\/$folder_destination|g" civicrm.settings.php 
    [[ -f "civicrm.settings.php" ]] && sed -i "s|https://www.$folder_source|https://$folder_destination|g" civicrm.settings.php    
    [[ -f "civicrm.settings.php" ]] && sed -i "s|mysql://`echo $mysql_source_user`:`echo $mysql_source_mdp`@`echo $mysql_server`/`echo $mysql_source_database`|mysql://`echo $mysql_destination_user`:`echo $mysql_destination_mdp`@`echo $mysql_server`/`echo $mysql_destination_database`|g" civicrm.settings.php
    cd $vhosts
}

## Vidage de l'instance destination
vidageInstance_Destination(){
    # condition remplie si et seulement si $folder_destination contient un httpdocs/
    while test -e $vhosts/$folder_destination/httpdocs 
        do
            cd $vhosts/$folder_destination
            rm -rf httpdocs/* > /dev/null 2>&1 # suppression du contenu de httpdocs/
            rm -rf httpdocs/.* > /dev/null 2>&1 # suppression des fichiers cachés de httpdocs/
            echo "Dossier httpdocs/ de l'instance $folder_destination bien vidé !" 
            cd $vhosts 
        break
    done
}
 
## Vidage des tables de la base de données destination 
vidageBDD_Destination(){
    # Vérifier si la base de données contient des tables
    table_count=$(mysql -u "$mysql_destination_user" -p"$mysql_destination_mdp" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$mysql_destination_database';" -s -N)

    # Si aucune table n'est présente, informer et continuer
    if [ "$table_count" -eq 0 ]; then
        echo " "
    else
        echo "SET FOREIGN_KEY_CHECKS = 0;" > ./temp_vidage.sql 

        # Tentative de connexion et dump des tables sans données
        sudo mysqldump --add-drop-table --no-data -u "$mysql_destination_user" -p"$mysql_destination_mdp" "$mysql_destination_database" | grep 'DROP TABLE' >> ./temp_vidage.sql
        echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./temp_vidage.sql 
        sudo mysql -u $mysql_destination_user -p$mysql_destination_mdp $mysql_destination_database < ./temp_vidage.sql
        rm temp_vidage.sql ; echo " "
        echo -e ">> [${GREEN}REUSSI${NC}] Base de données de ${GREEN}$mysql_destination_database${NC} vidée"
    fi
}

nettoyageAdressesElectroniques() {
    sudo mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database > $mysql_destination_database.sql 
    sed -i 's|@'"$folder_destination"'|@'"$folder_source"'|g' $mysql_destination_database.sql
    sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $mysql_destination_database.sql
    echo -e ">> [${GREEN}REUSSI${NC}] Nettoyage des adresses electroniques de $mysql_destination_database effectué"
}

exportBDD_Source() {
    sudo mysqldump --user=$mysql_source_user --password=$mysql_source_mdp $mysql_source_database > $folder_source.sql
    sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $folder_source.sql
    echo -e ">> [${GREEN}REUSSI${NC}] Export de $mysql_source_database effectué"
    # echo -e ">> [${GREEN}REUSSI${NC}] Import de $mysql_source_database dans $mysql_destination_database effectué"
}

exportBDD_Source_Without_Definer() {
    sudo mysqldump --user=$mysql_source_user --password=$mysql_source_mdp $mysql_source_database > $folder_source.sql
}

importBDD_Source() {
    sudo mysql --user=$mysql_source_user --password=$mysql_source_mdp $mysql_source_database < $folder_source.sql
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
