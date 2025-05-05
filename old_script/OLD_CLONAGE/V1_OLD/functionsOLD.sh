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

# getDatabasesDestination() {
#     cd $vhosts && cd "clonage" #cd $folder_clone    

#     # Affichage des BDD
#     plesk db "select db.name as 'Databases' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'"
#     plesk db "select db.name as 'Databases' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'" > ${folder_clone}_databases.txt

#     ## Extraction des bases de données, de la commande plesk vers un fichier texte, formalisé ligne par ligne
#     # echo " "
#     # echo "Fichier ${folder_clone}_databases.txt contenant la/les base.s de données créees"
#     databases=$(awk 'NR>0 {print $2}' "${folder_clone}_databases.txt")
#     echo $databases > ${folder_clone}_databases.txt
#     sed -i 's/Databases //' ${folder_clone}_databases.txt
#     sed -i 's/ /\n/g' ${folder_clone}_databases.txt

#     # ... a continuer
# }

#! OLD
# boucleBDD_Clone() {
#     ## Si le fichier a qu'une seule ligne
#     ## Parcours des lignes du fichier avec un for
#     if [ -f "${folder_clone}_databases.txt" ]; then
#         # Lire chaque ligne du fichier et afficher son contenu
#         for line in $(cat "${folder_clone}_databases.txt"); do
#             echo " "
#             let "compteur++" # Compteur + 1 a chaque ligne lue
#             eval "mysql_clone_database_$compteur=\"$line\""
#             echo -e "La variable attribuée à \e[1;32m$line\e[0m est : \e[1;32m "mysql_clone_database_$compteur"\e[0m" 
#             sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp "mysql_clone_database_$compteur" > $mysql_clone_database.sql
#             sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $mysql_clone_database.sql
#             #? -i ${folder_clone}-{line}.sql (nom du fichier SQL)
#         done
#     else
#         echo "Le fichier ${folder_clone}_databases.txt n'existe pas."
#     fi
    #? -i ${folder_clone}-{line}.sql (nom du fichier SQL)
# }

boucleBDD_Clone() {
    ## Si le fichier a qu'une seule ligne
    ## Parcours des lignes du fichier avec un for
    cd $vhosts && cd $folder_clone
    if [ -f "${folder_clone}_databases.txt" ]; then
        # Lire chaque ligne du fichier et afficher son contenu
        for line in $(cat "${folder_clone}_databases.txt"); do
            echo " "
            # eval "mysql_clone_database_$compteur=\"$line\"" 
            mysql_clone_database=$line
            echo -e "La variable attribuée à \e[1;32m$line\e[0m est : \e[1;32m "mysql_clone_database"\e[0m" 
            echo $mysql_clone_user
            echo $mysql_clone_mdp
            echo $mysql_clone_database
            sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > temp_clonage/$mysql_clone_database.sql
            sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i temp_clonage/$mysql_clone_database.sql
        done
    else
        echo "Le fichier ${folder_clone}_databases.txt n'existe pas."
    fi
}

## Récupérer les bases de données pour pouvoir les manipuler
getDatabasesClone() {
    #*** AWK COMMAND 
    #* Si le numero de la ligne est egal a 2e  - Récupere la 5e colonne
    #* awk 'NR==2 {print $5}' 

    cd $vhosts && cd $folder_clone    

    # Affichage des BDD
    # plesk db "select db.name as 'Databases' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'" > /dev/null 2>&1
    plesk db "select db.name as 'Databases' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'" > ${folder_clone}_databases.txt

    ## Extraction des bases de données, de la commande plesk vers un fichier texte, formalisé ligne par ligne
    databases=$(awk 'NR>0 {print $2}' "${folder_clone}_databases.txt")
    echo $databases > ${folder_clone}_databases.txt
    sed -i 's/Databases //' ${folder_clone}_databases.txt
    sed -i 's/ /\n/g' ${folder_clone}_databases.txt
}

## Récupération des BDD existantes
chooseDatabasesClone() {
    getDatabasesClone # création d'un fichier folder_clone_databases.txt contenant la liste des bases de données

    cd $vhosts && cd $folder_clone    

    # Compter le nombre de lignes dans le fichier
    lines_count=$(wc -l < "${folder_clone}_databases.txt")

    # Si le fichier ne retourne qu'une seule ligne, on garde le meme nom de BDD pris dans le fichier wp_config
	if [ "$lines_count" -eq 1 ]
	  then
        echo " "
        echo -e "La base de données de $folder_clone est : \e[1;32m$mysql_clone_database\e[0m"
        echo " "

    # Sinon, on parcourt les lignes du fichier et on les affecte à des variables différentes, allant de 1 à 3
    # Dedans, on va tester la connexion aux bases de données, dans l'ordre, en effectuant un DUMP + PUMP des differents noms de BDD trouvés
	elif [ "$lines_count" -gt 1 ] 
	  then
        # compteur=0
        echo " "
		echo "Le domaine contient plus d'une base de données"
        echo " "
        # echo "Souhaitez vous choisir une (1) ou les deux bases de données (2) ?"
        echo "Souhaitez vous choisir les deux bases de données (2) ?"
        read choix2
        
        case $choix2 in
            # 1)
            #     echo " "
            #     echo "Veuillez choisir la base de données que vous souhaitez cloner :"
            #     echo "Pas encore fonctionnel"
            #     exit 0
            #     select mysql_clone_database in $(cat "${folder_clone}_databases.txt")
            #       do 
            #         if [ -n "$mysql_clone_database" ]; then
            #             # cat ${folder_clone}_databases.txt
            #             echo -e "La base de données choisie est : \e[1;32m$mysql_clone_database\e[0m"
            #             sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > $mysql_clone_database.sql ####
            #             sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $mysql_clone_database.sql
            #             break
            #         else
            #             echo "Aucune base de données sélectionnée. Veuillez réessayer."
            #         fi
            #     done
            #     ;;
            2)
                echo " "
                echo "Vous avez choisi de cloner les deux bases de données"
                ## Parcours des lignes du fichier avec un for, récupération des deux bases de données
                boucleBDD_Clone 
                ;;
	        *)
	        	echo " "
                echo -e "La base de données (par défaut) choisie est : \e[1;32m$mysql_clone_database\e[0m"
                ;;
        esac
	fi

    echo " "    
}

#### Pour clonage.sh - remplacementbdd.sh - vidagebdd.sh - clonagebdd.sh
## Recuperation des identifiants de l'instance Wordpress source
getWordpressID_clone(){
    cd $folder_clone/httpdocs/ 
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
    cd $folder_clone/httpdocs/sites/default/
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
    cd $folder_destination/httpdocs/ 
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
    cd $folder_destination/httpdocs/sites/default/
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
    cd $folder_destination/httpdocs/sites/default/ 
    [[ ! -d "settings.php" ]] && sed -i "s/'`echo $mysql_clone_database`'/'`echo $mysql_destination_database`'/g" settings.php 
    [[ ! -d "settings.php" ]] && sed -i "s/'`echo $mysql_clone_user`'/'`echo $mysql_destination_user`'/g" settings.php 
    [[ ! -d "settings.php" ]] && sed -i "s/'`echo $mysql_clone_mdp`'/'`echo $mysql_destination_mdp`'/g" settings.php
    cd $vhosts
}

## Recherche de la présence de CiviCRM pour Drupal
testCiviCRM_Drupal() {
    cd $folder_destination/httpdocs/sites/default/
    # echo "CiviCRM trouvé"
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/mysql:\/\/`echo $mysql_clone_user`:`echo $mysql_clone_mdp`@`echo $mysql_server`\/`echo $mysql_clone_database`/mysql:\/\/`echo $mysql_destination_user`:`echo $mysql_destination_mdp`@`echo $mysql_server`\/`echo $mysql_destination_database`/g" civicrm.settings.php
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/https:\/\/`echo $folder_clone`\//https:\/\/`echo $folder_destination`\//g" civicrm.settings.php 
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" civicrm.settings.php
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/'https:\/\/`echo $folder_clone`'/'https:\/\/`echo $folder_destination`'/g" civicrm.settings.php 
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/'https:\/\/www.`echo $folder_clone`\'/https:\/\/`echo $folder_destination`\'/g" civicrm.settings.php
    cd $vhosts 
}

## Test CMS - WordPress
testWP() {
    cd $folder_destination/httpdocs
    [[ ! -d "wp-config.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" wp-config.php

    # TODO : modif globale des variables
    #[[ ! -d "wp-config.php" ]] && sed -i "s/`echo $mysql_clone_user`/`echo $mysql_destination_user`/g" wp-config.php
    #[[ ! -d "wp-config.php" ]] && sed -i "s/`echo $mysql_clone_database`/`echo $mysql_destination_database`/g" wp-config.php
    #[[ ! -d "wp-config.php" ]] && sed -i "s/`echo $mysql_clone_mdp`/`echo $mysql_destination_mdp`/g" wp-config.php

    # A suivre
    sed -i "s/@$folder_destination/@$folder_clone/g" "$folder_destination.sql"
    
    ## define de wp-config.php avec espace = define( 'DB_..', '...' );        
    [[ ! -d "wp-config.php" ]] && sed -i "s/define( 'DB_NAME', '`echo $mysql_clone_database`' );/define( 'DB_NAME', '`echo $mysql_destination_database`' );/g" wp-config.php
    [[ ! -d "wp-config.php" ]] && sed -i "s/define( 'DB_USER', '`echo $mysql_clone_user`' );/define( 'DB_USER', '`echo $mysql_destination_user`' );/g" wp-config.php
    [[ ! -d "wp-config.php" ]] && sed -i "s/define( 'DB_PASSWORD', '`echo $mysql_clone_mdp`' );/define( 'DB_PASSWORD', '`echo $mysql_destination_mdp`' );/g" wp-config.php
    
    ## define de wp-config.php sans espace = define('DB_..', '...');
    [[ ! -d "wp-config.php" ]] && sed -i "s/define('DB_NAME', '`echo $mysql_clone_database`');/define('DB_NAME', '`echo $mysql_destination_database`');/g" wp-config.php
    [[ ! -d "wp-config.php" ]] && sed -i "s/define('DB_USER', '`echo $mysql_clone_user`');/define('DB_USER', '`echo $mysql_destination_user`');/g" wp-config.php
    [[ ! -d "wp-config.php" ]] && sed -i "s/define('DB_PASSWORD', '`echo $mysql_clone_mdp`');/define('DB_PASSWORD', '`echo $mysql_destination_mdp`');/g" wp-config.php    
    
    ## parlemonde.org (modification de deux variables de plus sur wp-config.php) 
    [[ ! -d "wp-config.php" ]] && sed -i "s/define('DOMAIN_CURRENT_SITE', '`echo $folder_clone`');/define('DOMAIN_CURRENT_SITE', '`echo $folder_destination`');/g" wp-config.php ##109 sans www sans espace
    [[ ! -d "wp-config.php" ]] && sed -i "s/define( 'DOMAIN_CURRENT_SITE', '`echo $folder_clone`' );/define( 'DOMAIN_CURRENT_SITE', '`echo $folder_destination`' );/g" wp-config.php ##109 sans www avec espace
    [[ ! -d "wp-config.php" ]] && sed -i "s/define( 'NOBLOGREDIRECT', 'https:\/\/www.`echo $folder_clone`' );/define( 'NOBLOGREDIRECT', 'https:\/\/`echo $folder_destination`' );/g" wp-config.php ##113
    cd $vhosts
}

## Recherche de la présence de CiviCRM - instance parlemonde 
testCiviCRM_parlemonde() {
    cd $folder_destination/httpdocs
    # echo "CiviCRM parlemonde trouvé"
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/define('DB_CIVI_NAME', '`echo $mysql_clone_database`');/define('DB_CIVI_NAME', '`echo $mysql_destination_database`');/g" civicrm.settings.php
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/define('DB_CIVI_USER', '`echo $mysql_clone_user`');/define('DB_CIVI_USER', '`echo $mysql_destination_user`');/g" civicrm.settings.php
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/define('DB_CIVI_PASSWORD', '`echo $mysql_clone_mdp`');/define('DB_CIVI_PASSWORD', '`echo $mysql_destination_mdp`');/g" civicrm.settings.php
    	
    ## parlemonde.org (modification de deux URLs à la fin du fichier - vhosts/$.../ -  https://$...
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" civicrm.settings.php ##220-222-611
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/https:\/\/www.`echo $folder_clone`\//https:\/\/`echo $folder_destination`\//g" civicrm.settings.php ##612
    cd $vhosts
}

## Recherche de WordFence pour WordPress
testWordfence() {
    cd $folder_destination/httpdocs
    # echo "Fichiers générés par WordFence présents - .user.ini - wordfence-waf.php"
    [[ ! -d ".user.ini" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`\//\/vhosts\/`echo $folder_destination`\//g" .user.ini
    [[ ! -d "wordfence-waf.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`\//\/vhosts\/`echo $folder_destination`\//g" wordfence-waf.php
    cd $vhosts
}

## Recherche de la présence de CiviCRM pour WordPress  
testCiviCRM_WP() { 
    # echo "CiviCRM trouvé"
    cd $folder_destination/httpdocs/wp-content/uploads/civicrm
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/`echo $folder_clone`/`echo $folder_destination`/g" civicrm.settings.php
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" civicrm.settings.php ##196
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/'https:\/\/`echo $folder_clone`'/'https:\/\/`echo $folder_destination`'/g" civicrm.settings.php 
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/'https:\/\/www.`echo $folder_clone`\'/https:\/\/`echo $folder_destination`\'/g" civicrm.settings.php
    
    [[ ! -d "civicrm.settings.php" ]] && sed -i "s/mysql:\/\/`echo $mysql_clone_user`:`echo $mysql_clone_mdp`@`echo $mysql_server`\/`echo $mysql_clone_database`/mysql:\/\/`echo $mysql_destination_user`:`echo $mysql_destination_mdp`@`echo $mysql_server`\/`echo $mysql_destination_database`/g" civicrm.settings.php    
    cd $vhosts
}

## Vidage de l'instance destination
vidageInstance_Destination(){
while test -e $folder_destination/httpdocs # condition remplie si et seulement si $folder_destination contient un httpdocs/
do
    cd $folder_destination
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
    echo "SET FOREIGN_KEY_CHECKS = 0;" > ./temp_vidage.sql 
    sudo mysqldump --add-drop-table --no-data -u $mysql_destination_user -p$mysql_destination_mdp $mysql_destination_database | grep 'DROP TABLE' >> ./temp_vidage.sql 
    echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./temp_vidage.sql 
    sudo mysql -u $mysql_destination_user -p$mysql_destination_mdp $mysql_destination_database < ./temp_vidage.sql
    rm temp_vidage.sql
    echo "Base de données de $folder_destination bien vidée !" 
}

nettoyageAddresseElec() {
    # Gérer le cas contraire, sanbox.domain.com -> domain.com
    
    #? prompt (o) ou (n)
    #? Boucle sur les bases
    # Si oui
    sed -i 's/@'"$folder_destination"'/@'"$folder_clone"'/g' $mysql_clone_database.sql
    # Sinon
    # Ne rien faire

    # sed -i 's/@'"$folder_clone"'/@'"$folder_destination"'/g' $mysql_clone_database.sql
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
