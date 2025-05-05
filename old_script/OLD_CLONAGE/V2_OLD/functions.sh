#!/bin/bash

deleteContent(){
    cd ..
    pwd
    rm -rf httpdocs/*
    cd ..
}
 
moveContent(){
    cd ../..
}

getCheminActuel() {
    echo " "
    echo "Vous êtes placé ici : "
    pwd 
    echo " "
}

finduscript() {
    echo "Fin du script, checkpoint"
    exit 0
}

# Taille de la base de données
dbSizeClone() {
    echo " "
    echo "Taille de $mysql_clone_database"
    plesk db "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) 'Taille de la base source' FROM information_schema.TABLES WHERE table_schema = '$mysql_clone_database';"
}

dbSizeDestination() {
    echo " "
    echo "Taille de $mysql_destination_database"
    plesk db "SELECT ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) 'Taille de la base destination' FROM information_schema.TABLES WHERE table_schema = '$mysql_destination_database';"
    echo " "
}

#### Pour clonage.sh - remplacementbdd.sh - vidagebdd.sh - clonagebdd.sh
## Recuperation des identifiants de l'instance Wordpress source
getWordpressID_clone(){
    cd $vhosts/$folder_clone/httpdocs/ 
    #echo "Informations Wordpress - Source"
    mysql_clone_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php` # espace à remettre a la fin si ca ne fonctionne pas 
    mysql_clone_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`
    mysql_clone_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`
    echo "BDD : $mysql_clone_database"
    echo "USER : $mysql_clone_user"
    echo "MDP : $mysql_clone_mdp" 
    cd $vhosts
    break
}

## Recuperation des identifiants de l'instance Drupal source
getDrupalID_clone(){
    cd $vhosts/$folder_clone/httpdocs/sites/default/
    #echo "Informations Drupal - Source"
    case $folder_clone in  
            "gestad.net")
                    ## 'database' => 'gestad',
                    bdd=`sed -n 252p settings.php` ; echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 253p settings.php` ; echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 254p settings.php` ; echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    #echo "BDD : $mysql_clone_database"
                    #echo "USER : $mysql_clone_user"
                    #echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt
                    ;;
            "cnec.gestad.net")
                    bdd=`sed -n 257p settings.php` ; echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 258p settings.php` ; echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 259p settings.php` ; echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    #echo "BDD : $mysql_clone_database"
                    #echo "USER : $mysql_clone_user"
                    #echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt
                    ;;
            "sandbox.cnec.gestad.net")
                    bdd=`sed -n 257p settings.php` ; echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 258p settings.php` ; echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 259p settings.php` ; echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    #echo "BDD : $mysql_clone_database"
                    #echo "USER : $mysql_clone_user"
                    #echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt
                    ;;
            "snpmns.gestad.net")
                    bdd=`sed -n 253p settings.php` ; echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 254p settings.php` ; echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 255p settings.php` ; echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    #echo "BDD : $mysql_clone_database"
                    #echo "USER : $mysql_clone_user"
                    #echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt
                    ;;
            "sandbox.snpmns.gestad.net")
                    bdd=`sed -n 253p settings.php` ; echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 254p settings.php` ; echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 255p settings.php` ; echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    #echo "BDD : $mysql_clone_database"
                    #echo "USER : $mysql_clone_user"
                    #echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt 
                    ;;
            "aspas.all-in-appli.com")
                    bdd=`sed -n 257p settings.php` ; echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 258p settings.php` ; echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 259p settings.php` ; echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    #echo "BDD : $mysql_clone_database"
                    #echo "USER : $mysql_clone_user"
                    #echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt 
                    ;;
    esac
    cd $vhosts
    break
}

## Recuperation des identifiants de l'instance Wordpress destination
getWordpressID_Destination(){
    cd $vhosts/$folder_destination/httpdocs/ 
    #echo "Informations Wordpress - Destination"
    mysql_destination_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php` # espace a remettre a la fin si ca ne fonctionne pas 
    mysql_destination_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`
    mysql_destination_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`
    echo "BDD : $mysql_destination_database"
    echo "USER : $mysql_destination_user"
    echo "MDP : $mysql_destination_mdp"
    cd $vhosts
    break
}

## Recuperation des identifiants de l'instance Drupal destination
getDrupalID_Destination() {
    cd $vhosts/$folder_destination/httpdocs/sites/default/
    #echo "Informations Drupal - Destination"
    case $folder_destination in  
            "gestad.net")
                    # 'database' => 'gestad',
                    bdd=`sed -n 252p settings.php` 
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 253p settings.php` 
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 254p settings.php` 
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    #echo "BDD : $mysql_destination_database"
                    #echo "USER : $mysql_destination_user"
                    #echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt
                    ;;
            "cnec.gestad.net")
                    bdd=`sed -n 257p settings.php`
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 258p settings.php`
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 259p settings.php`
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    #echo "BDD : $mysql_destination_database"
                    #echo "USER : $mysql_destination_user"
                    #echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt
                    ;;
            "sandbox.cnec.gestad.net")
                    bdd=`sed -n 257p settings.php`
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 258p settings.php`
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 259p settings.php`
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    #echo "BDD : $mysql_destination_database"
                    #echo "USER : $mysql_destination_user"
                    #echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt
                    ;;
            "snpmns.gestad.net")
                    bdd=`sed -n 253p settings.php`
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 254p settings.php`
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 255p settings.php`
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    #echo "BDD : $mysql_destination_database"
                    #echo "USER : $mysql_destination_user"
                    #echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt
                    ;;
            "sandbox.snpmns.gestad.net")
                    bdd=`sed -n 253p settings.php`
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 254p settings.php`
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 255p settings.php`
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    #echo "BDD : $mysql_destination_database"
                    #echo "USER : $mysql_destination_user"
                    #echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt 
                    ;;
            *) ## si l'instance destination ne concerne aucune des 6 instances Drupal
                    # question sur le 1 ou 2 bases de données

                    echo "Instance destination Drupal, ne fait pas partie des instances drupal de base"
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
                    ;;
    esac
    cd $vhosts
    break
}

## Affichage des questions d'identifiants si l'instance destination est vide
instanceVide() {
    echo "Instance destination vide, veuillez ecrire les identifiants"
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

## Remplacement des URL dans le fichier SQL 
remplacementURLfichierSQL_OLD() {
    #### temp_clonage/$mysql_clone_database.sql
    #### eval "mysql_clone_database_$compteur=\"$line\"" 

    #? : Boucler sur les fichiers.sql qui existent (for)
    #! Soucis au niveau de la BDD Destination. 
    #! Si la destination possède que une BDD, ou si l'instance destination possède 2 BDD
    #! On en choisit une ??

    ## Parcours des lignes du fichier avec un for
    sed -i "s/`echo $folder_clone`/`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/https:\/\/`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/http:\/\/`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/https:\/\/www.`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/http:\/\/www.`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/www.`echo $folder_clone`/`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" $mysql_clone_database.sql

    #? [ $folder_destination == "parlemonde" ] && changements
    ## spécifique parlemonde :: sous-domaines prof.parlemonde.org - mediateurs.parlemonde.org - familles.parlemonde.org
    sed -i "s/https:\/\/prof.`echo $folder_clone`/https:\/\/prof.`echo $folder_destination`/g" $mysql_clone_database.sql 
    sed -i "s/http:\/\/prof.`echo $folder_clone`/https:\/\/prof.`echo $folder_destination`/g" $mysql_clone_database.sql 
    sed -i "s/https:\/\/mediateurs.`echo $folder_clone`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/http:\/\/mediateurs.`echo $folder_clone`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/https:\/\/familles.`echo $folder_clone`/https:\/\/familles.`echo $folder_destination`/g" $mysql_clone_database.sql ##
    sed -i "s/http:\/\/familles.`echo $folder_clone`/https:\/\/familles.`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/prof.`echo $folder_clone`/prof.`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/mediateurs.`echo $folder_clone`/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
    sed -i "s/familles.`echo $folder_clone`/familles.`echo $folder_destination`/g" $mysql_clone_database.sql ##

    ## import du SQL dans la bonne BDD
    sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $mysql_clone_database.sql
} 

## Remplacement des URL dans le fichier SQL 
remplacementURLfichierSQL() {
    #### temp_clonage/$mysql_clone_database.sql
    #### eval "mysql_clone_database_$compteur=\"$line\"" 

    #? : Boucler sur les fichiers.sql qui existent (for)
    #! Soucis au niveau de la BDD Destination. 
    #! Si la destination possède que une BDD, ou si l'instance destination possède 2 BDD
    #! On en choisit une ??

    cd $vhosts && cd $folder_clone

    ## Parcours des lignes du fichier avec un for
    if [ -f "${folder_clone}_databases.txt" ]; then
        # Lire chaque ligne du fichier et afficher son contenu
        for line in $(cat "${folder_clone}_databases.txt"); do
            echo " "
            mysql_clone_database=$line
            echo -e "La variable attribuée à \e[1;32m$line\e[0m est : \e[1;32m "mysql_clone_database"\e[0m" 
            
            ## Parcours et modification de chaque BDD
            sed -i "s/`echo $folder_clone`/`echo $folder_destination`/g" $mysql_clone_database.sql
            sed -i "s/https:\/\/`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" $mysql_clone_database.sql
            sed -i "s/http:\/\/`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" $mysql_clone_database.sql
            sed -i "s/https:\/\/www.`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" $mysql_clone_database.sql
            sed -i "s/http:\/\/www.`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" $mysql_clone_database.sql
            sed -i "s/www.`echo $folder_clone`/`echo $folder_destination`/g" $mysql_clone_database.sql
            sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" $mysql_clone_database.sql

            #? [ $folder_destination == "parlemonde" ] && changements
            ## spécifique parlemonde :: sous-domaines prof.parlemonde.org - mediateurs.parlemonde.org - familles.parlemonde.org
            [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org"  ]] && sed -i "s/https:\/\/prof.`echo $folder_clone`/https:\/\/prof.`echo $folder_destination`/g" $mysql_clone_database.sql 
            [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org"  ]] && sed -i "s/http:\/\/prof.`echo $folder_clone`/https:\/\/prof.`echo $folder_destination`/g" $mysql_clone_database.sql 
            [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org"  ]] && sed -i "s/https:\/\/mediateurs.`echo $folder_clone`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
            [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org"  ]] && sed -i "s/http:\/\/mediateurs.`echo $folder_clone`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
            [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org"  ]] && sed -i "s/https:\/\/familles.`echo $folder_clone`/https:\/\/familles.`echo $folder_destination`/g" $mysql_clone_database.sql 
            [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org"  ]] && sed -i "s/http:\/\/familles.`echo $folder_clone`/https:\/\/familles.`echo $folder_destination`/g" $mysql_clone_database.sql
            [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org"  ]] && sed -i "s/prof.`echo $folder_clone`/prof.`echo $folder_destination`/g" $mysql_clone_database.sql
            [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org"  ]] && sed -i "s/mediateurs.`echo $folder_clone`/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
            [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org"  ]] && sed -i "s/familles.`echo $folder_clone`/familles.`echo $folder_destination`/g" $mysql_clone_database.sql 
        
            ## import du SQL dans la bonne BDD
            ###?? Boucler sur les différentes $mysql_destination_database pour que ça se fasse au même endroit ??
            # condition de nommage de variable de la BDD
            # controle sur la clone
            sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $mysql_clone_database.sql
        done
    else
        echo "Le fichier ${folder_clone}_databases.txt n'existe pas."
    fi
}

## Test CMS - Drupal
testDrupal() {
    cd $vhosts/$folder_destination/httpdocs/sites/default/ 
    [[ -f "settings.php" ]] && sed -i "s/'`echo $mysql_clone_database`'/'`echo $mysql_destination_database`'/g" settings.php 
    [[ -f "settings.php" ]] && sed -i "s/'`echo $mysql_clone_user`'/'`echo $mysql_destination_user`'/g" settings.php 
    [[ -f "settings.php" ]] && sed -i "s/'`echo $mysql_clone_mdp`'/'`echo $mysql_destination_mdp`'/g" settings.php
    cd $vhosts
}

## Recherche de la présence de CiviCRM pour Drupal
testCiviCRM_Drupal() {
    cd $vhosts/$folder_destination/httpdocs/sites/default/
    # echo "CiviCRM trouvé"
    [[ -f "civicrm.settings.php" ]] && sed -i "s/mysql:\/\/`echo $mysql_clone_user`:`echo $mysql_clone_mdp`@`echo $mysql_server`\/`echo $mysql_clone_database`/mysql:\/\/`echo $mysql_destination_user`:`echo $mysql_destination_mdp`@`echo $mysql_server`\/`echo $mysql_destination_database`/g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s/https:\/\/`echo $folder_clone`\//https:\/\/`echo $folder_destination`\//g" civicrm.settings.php 
    [[ -f "civicrm.settings.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s/'https:\/\/`echo $folder_clone`'/'https:\/\/`echo $folder_destination`'/g" civicrm.settings.php 
    [[ -f "civicrm.settings.php" ]] && sed -i "s/'https:\/\/www.`echo $folder_clone`\'/https:\/\/`echo $folder_destination`\'/g" civicrm.settings.php
    cd $vhosts 
}

## Test CMS - WordPress
testWP() {
    cd $vhosts/$folder_destination/httpdocs
    [[ -f "wp-config.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" wp-config.php

    # TODO : modif globale des variables
    #[[ -f "wp-config.php" ]] && sed -i "s/`echo $mysql_clone_user`/`echo $mysql_destination_user`/g" wp-config.php
    #[[ -f "wp-config.php" ]] && sed -i "s/`echo $mysql_clone_database`/`echo $mysql_destination_database`/g" wp-config.php
    #[[ -f "wp-config.php" ]] && sed -i "s/`echo $mysql_clone_mdp`/`echo $mysql_destination_mdp`/g" wp-config.php

    # A suivre
    # sed -i "s/@$folder_destination/@$folder_clone/g" "$folder_destination.sql"
    
    ## define de wp-config.php avec espace = define( 'DB_..', '...' );        
    [[ -f "wp-config.php" ]] && sed -i "s/define( 'DB_NAME', '`echo $mysql_clone_database`' );/define( 'DB_NAME', '`echo $mysql_destination_database`' );/g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s/define( 'DB_USER', '`echo $mysql_clone_user`' );/define( 'DB_USER', '`echo $mysql_destination_user`' );/g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s/define( 'DB_PASSWORD', '`echo $mysql_clone_mdp`' );/define( 'DB_PASSWORD', '`echo $mysql_destination_mdp`' );/g" wp-config.php
    
    ## define de wp-config.php sans espace = define('DB_..', '...');
    [[ -f "wp-config.php" ]] && sed -i "s/define('DB_NAME', '`echo $mysql_clone_database`');/define('DB_NAME', '`echo $mysql_destination_database`');/g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s/define('DB_USER', '`echo $mysql_clone_user`');/define('DB_USER', '`echo $mysql_destination_user`');/g" wp-config.php
    [[ -f "wp-config.php" ]] && sed -i "s/define('DB_PASSWORD', '`echo $mysql_clone_mdp`');/define('DB_PASSWORD', '`echo $mysql_destination_mdp`');/g" wp-config.php    
    
    ## parlemonde.org (modification de deux variables de plus sur wp-config.php) 
    [[ -f "wp-config.php" ]] && sed -i "s/define('DOMAIN_CURRENT_SITE', '`echo $folder_clone`');/define('DOMAIN_CURRENT_SITE', '`echo $folder_destination`');/g" wp-config.php ##109 sans www sans espace
    [[ -f "wp-config.php" ]] && sed -i "s/define( 'DOMAIN_CURRENT_SITE', '`echo $folder_clone`' );/define( 'DOMAIN_CURRENT_SITE', '`echo $folder_destination`' );/g" wp-config.php ##109 sans www avec espace
    [[ -f "wp-config.php" ]] && sed -i "s/define( 'NOBLOGREDIRECT', 'https:\/\/www.`echo $folder_clone`' );/define( 'NOBLOGREDIRECT', 'https:\/\/`echo $folder_destination`' );/g" wp-config.php ##113
    cd $vhosts
}

## Recherche de la présence de CiviCRM - instance parlemonde 
testCiviCRM_parlemonde() {
    cd $vhosts/$folder_destination/httpdocs
    # echo "CiviCRM parlemonde trouvé"
    [[ -f "civicrm.settings.php" ]] && sed -i "s/define('DB_CIVI_NAME', '`echo $mysql_clone_database`');/define('DB_CIVI_NAME', '`echo $mysql_destination_database`');/g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s/define('DB_CIVI_USER', '`echo $mysql_clone_user`');/define('DB_CIVI_USER', '`echo $mysql_destination_user`');/g" civicrm.settings.php
    [[ -f "civicrm.settings.php" ]] && sed -i "s/define('DB_CIVI_PASSWORD', '`echo $mysql_clone_mdp`');/define('DB_CIVI_PASSWORD', '`echo $mysql_destination_mdp`');/g" civicrm.settings.php
    	
    ## parlemonde.org (modification de deux URLs à la fin du fichier - vhosts/$.../ -  https://$...
    [[ -f "civicrm.settings.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" civicrm.settings.php ##220-222-611
    [[ -f "civicrm.settings.php" ]] && sed -i "s/https:\/\/www.`echo $folder_clone`\//https:\/\/`echo $folder_destination`\//g" civicrm.settings.php ##612
    cd $vhosts
}

## Recherche de WordFence pour WordPress
testWordfence() {
    cd $vhosts/$folder_destination/httpdocs
    # echo "Fichiers générés par WordFence présents - .user.ini - wordfence-waf.php"
    [[ -f ".user.ini" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`\//\/vhosts\/`echo $folder_destination`\//g" .user.ini
    [[ -f "wordfence-waf.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`\//\/vhosts\/`echo $folder_destination`\//g" wordfence-waf.php
    cd $vhosts
}

## Recherche de la présence de CiviCRM pour WordPress  
testCiviCRM_WP() { 
    # echo "CiviCRM trouvé"
    cd $vhosts/$folder_destination/httpdocs/wp-content/uploads/civicrm
    # [[ -f "civicrm.settings.php" ]] && sed -i "s/`echo $folder_clone`/`echo $folder_destination`/g" civicrm.settings.php
    # [[ -f "civicrm.settings.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" civicrm.settings.php ##196
    # [[ -f "civicrm.settings.php" ]] && sed -i "s/'https:\/\/`echo $folder_clone`'/'https:\/\/`echo $folder_destination`'/g" civicrm.settings.php 
    # [[ -f "civicrm.settings.php" ]] && sed -i "s/'https:\/\/www.`echo $folder_clone`\'/https:\/\/`echo $folder_destination`\'/g" civicrm.settings.php

    [[ -f "civicrm.settings.php" ]] && sed -i "s|vhosts/$folder_clone|vhosts/$folder_destination|g" civicrm.settings.php 
    [[ -f "civicrm.settings.php" ]] && sed -i "s|https://$folder_clone|https:\/\/$folder_destination|g" civicrm.settings.php 
    [[ -f "civicrm.settings.php" ]] && sed -i "s|https://www.$folder_clone|https://$folder_destination|g" civicrm.settings.php
    
    # sed -i "s|$ancienne_valeur|$nouvelle_valeur|g" "$folder_destination.sql"
    [[ -f "civicrm.settings.php" ]] && sed -i "s|mysql://`echo $mysql_clone_user`:`echo $mysql_clone_mdp`@`echo $mysql_server`/`echo $mysql_clone_database`|mysql://`echo $mysql_destination_user`:`echo $mysql_destination_mdp`@`echo $mysql_server`/`echo $mysql_destination_database`|g" civicrm.settings.php
    cd $vhosts
}

## Vidage de l'instance destination
vidageInstance_Destination(){
while test -e $folder_destination/httpdocs # condition remplie si et seulement si $folder_destination contient un httpdocs/
do
    cd $vhosts/$folder_destination
    # rm -rf httpdocs/* ; rm .user.ini
    rm -rf httpdocs/* > /dev/null 2>&1 
    rm -rf httpdocs/.* > /dev/null 2>&1 # suppression des fichiers cachés de httpdocs/
    echo "Dossier httpdocs/ de l'instance $folder_destination bien vidé !" 
    cd $vhosts 
    break
done
}
 
## Vidage des tables de la base de données Destination 
vidageBDD_Destination(){
    # Vérifier si la base de données contient des tables
    table_count=$(mysql -u "$mysql_destination_user" -p"$mysql_destination_mdp" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$mysql_destination_database';" -s -N)

    # Si aucune table n'est présente, informer et continuer
    if [ "$table_count" -eq 0 ]; then
        echo "La base de données $mysql_destination_database est déjà vide."
    else
        echo "SET FOREIGN_KEY_CHECKS = 0;" > ./temp_vidage.sql 

        # Tentative de connexion et dump des tables sans données
        sudo mysqldump --add-drop-table --no-data -u "$mysql_destination_user" -p"$mysql_destination_mdp" "$mysql_destination_database" | grep 'DROP TABLE' >> ./temp_vidage.sql
        echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./temp_vidage.sql 
        sudo mysql -u $mysql_destination_user -p$mysql_destination_mdp $mysql_destination_database < ./temp_vidage.sql
        rm temp_vidage.sql
        echo -e ">> [${GREEN}REUSSI${NC}] Base de données de $mysql_destination_database bien vidée"
    fi
}

nettoyageAddresseElec_1_1() {
    # Gérer le cas contraire, sanbox.domain.com -> domain.com
    sudo mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database > $mysql_destination_database.sql 
    sed -i 's|@'"$folder_destination"'|@'"$folder_clone"'|g' $mysql_destination_database.sql
    sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $mysql_destination_database.sql
    echo -e ">> [${GREEN}REUSSI${NC}] Nettoyage des adresses electroniques de $mysql_destination_database effectué"
}

nettoyageAddresseElec_2_2() {
    # Gérer le cas contraire, sanbox.domain.com -> domain.com
    echo "En cours de développement..."
}

## Remplacement des occurences '@folder_destination' vers '@folder_clone', dans folder_destination.sql. Utile que dans quelque cas précis 
remplacement_occurences_@_dest(){  
    # Export du SQL 
    sudo mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database > $folder_destination.sql && echo "Connexion et DUMP SQL réussi"

    # Remplacement de chaines contenant un '@folder_destination' par '@folder_clone'
    sed -i "s/@$folder_destination/@$folder_clone/g" "$folder_destination.sql"

    # Import du SQL dans la bonne BDD
    sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $folder_destination.sql && echo "Connexion et PUMP SQL réussi"
}
