

#*** Partie source ***#
## Création d'un fichier folder_clone_databases.txt (liste des bases de données), pour pouvoir les manipuler
getDatabasesClone() {
    plesk db "select db.name as 'Databases Source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'" > ${folder_clone}_databases.txt

    touch "${folder_clone}_databases.txt"

    ## Extraction des bases de données, de la commande plesk vers un fichier texte, formalisé ligne par ligne
    databases=$(awk 'NR>0 {print $2}' "${folder_clone}_databases.txt")
    echo $databases > ${folder_clone}_databases.txt
    sed -i 's/Databases //' ${folder_clone}_databases.txt
    sed -i 's/ /\n/g' ${folder_clone}_databases.txt
}

loopDatabasesClone() {
    cd $vhosts/$folder_clone
    if [ -f "${folder_clone}_databases.txt" ]; then
        # Lire chaque ligne du fichier et afficher son contenu
        for line_clone in $(cat "${folder_clone}_databases.txt"); do
            echo " "
            # eval "mysql_clone_database_$compteur=\"$line_clone\"" 
            mysql_clone_database=$line_clone
            echo -e "La variable attribuée à \e[1;32m$line_clone\e[0m est : \e[1;32m "mysql_clone_database"\e[0m" 
            echo $mysql_clone_user
            echo $mysql_clone_mdp
            echo $mysql_clone_database
            # sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > temp_clonage/"$mysql_clone_database.sql"
            # sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i temp_clonage/"$mysql_clone_database.sql"
        done
    else
        echo "Le fichier ${folder_clone}_databases.txt n'existe pas."
    fi  
}

## Récupération des BDD existantes
chooseDatabasesClone() {
    # Compte le nombre de lignes dans le fichier
    lines_count=$(wc -l < "${folder_clone}_databases.txt")

    # Si le fichier ne retourne qu'une seule ligne, on garde le meme nom de BDD pris dans le fichier wp_config
	if [ "$lines_count" -eq 1 ]
	  then
        echo " " && echo -e "La base de données de $folder_clone est : \e[1;32m$mysql_clone_database\e[0m" 
        nombreBDD_Source=1
    # Sinon, si il retourne plus d'une ligne, on parcourt les lignes du fichier et on les affecte à des variables différentes, allant de 1 à 3 par exemple
    # Dedans, on va tester la connexion aux bases de données, dans l'ordre, en effectuant un DUMP + PUMP des differents noms de BDD trouvés
	elif [ "$lines_count" -gt 1 ] 
	  then
        echo "Souhaitez vous choisir les deux bases de données (o / n) ?"
        read choix2 ; echo " "
        
        case $choix2 in
            "o")
                echo "Vous avez choisi de cloner les deux bases de données"
                if [ -f "${folder_clone}_databases.txt" ]; then
                    compteur=0
                    # Lire chaque ligne du fichier et afficher son contenu
                    for line_clone in $(cat "${folder_clone}_databases.txt"); do
                        echo " " #eval "mysql_clone_database_$compteur=\"$line_clone\"" 
                        mysql_clone_database=$line_clone
                        echo -e "La variable attribuée à \e[1;32m$line_clone\e[0m est : \e[1;32m "mysql_clone_database"\e[0m" 
                        echo $mysql_clone_user ; echo $mysql_clone_mdp ; echo $mysql_clone_database
                        nombreBDD_Source=2
                    done
                else
                    echo "Le fichier ${folder_clone}_databases.txt n'existe pas."
                fi                
                ;;
            "n")
                echo "Veuillez choisir la base de données que vous souhaitez cloner :"
                select mysql_clone_database in $(cat "${folder_clone}_databases.txt")
                  do 
                    if [ -n "$mysql_clone_database" ]; then
                        echo -e "La base de données choisie est : \e[1;32m$mysql_clone_database\e[0m"
                        nombreBDD_Source=1
                        break
                    else
                        echo "Aucune base de données sélectionnée. Veuillez réessayer."
                    fi
                done
                ;;
	          *)
	        	echo -e "La base de données (par défaut) choisie est : \e[1;32m$mysql_clone_database\e[0m"
                ;;
        esac
	fi
}

## PASTE ##
#*** Partie destination ***#
## Création d'un fichier folder_destination_databases.txt (liste des bases de données), pour pouvoir les manipuler
getDatabasesDestination() {
    plesk db "select db.name as 'Databases Destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'" > ${folder_destination}_databases.txt

    touch "${folder_destination}_databases.txt"

    ## Extraction des bases de données, de la commande plesk vers un fichier texte, formalisé ligne par ligne
    databases=$(awk 'NR>0 {print $2}' "${folder_destination}_databases.txt")
    echo $databases > ${folder_destination}_databases.txt
    sed -i 's/Databases //' ${folder_destination}_databases.txt
    sed -i 's/ /\n/g' ${folder_destination}_databases.txt
}

loopDatabasesDestination() {
    cd $vhosts/$folder_destination
    if [ -f "${folder_destination}_databases.txt" ]; then
        # Lire chaque ligne du fichier et afficher son contenu
        for line_destination in $(cat "${folder_destination}_databases.txt"); do
            echo " "
            # eval "mysql_destination_database_$compteur=\"$line_destination\"" 
            mysql_destination_database=$line_destination
            echo -e "La variable attribuée à \e[1;32m$line_destination\e[0m est : \e[1;32m "mysql_destination_database"\e[0m" 
            echo $mysql_destination_user
            echo $mysql_destination_mdp
            echo $mysql_destination_database
            # sudo mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database > temp_clonage/"$mysql_destination_database.sql"
            # sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i temp_clonage/"$mysql_destination_database.sql"
        done
    else
        echo "Le fichier ${folder_destination}_databases.txt n'existe pas."
    fi  
}

## Récupération des BDD existantes
chooseDatabasesDestination() {
    # Compte le nombre de lignes dans le fichier
    lines_count=$(wc -l < "${folder_destination}_databases.txt")

    # Si le fichier ne retourne qu'une seule ligne, on garde le meme nom de BDD pris dans le fichier wp_config
	if [ "$lines_count" -eq 1 ]
	  then
        echo -e "La base de données de $folder_destination est : \e[1;32m$mysql_destination_database\e[0m"
        nombreBDD_Destination=1
    # Sinon, si il retourne plus d'une ligne, on parcourt les lignes du fichier et on les affecte à des variables différentes, allant de 1 à 3 par exemple
    # Dedans, on va tester la connexion aux bases de données, dans l'ordre, en effectuant un DUMP + PUMP des differents noms de BDD trouvés
	elif [ "$lines_count" -gt 1 ] 
	  then
        echo "Souhaitez vous choisir les deux bases de données (o / n) ?"
        read choix2 ; echo " "
        
        case $choix2 in
            "o")
                echo "Vous avez choisi de destinationr les deux bases de données"
                if [ -f "${folder_destination}_databases.txt" ]; then
                    compteur=0
                    # Lire chaque ligne du fichier et afficher son contenu
                    for line_destination in $(cat "${folder_destination}_databases.txt"); do
                        echo " "
                        eval "mysql_destination_database_$compteur=\"$line_destination\"" 
                        # mysql_destination_database=$line_destination
                        echo -e "La variable attribuée à \e[1;32m$line_destination\e[0m est : \e[1;32m "mysql_destination_database_$compteur"\e[0m" 
                        echo $mysql_destination_user ; echo $mysql_destination_mdp ; echo $mysql_destination_database
                        nombreBDD_Destination=2
                    done
                else
                    echo "Le fichier ${folder_destination}_databases.txt n'existe pas."
                fi                
                ;;
            "n")
                echo "Veuillez choisir la base de données que vous souhaitez destinationr :"
                select mysql_destination_database in $(cat "${folder_destination}_databases.txt")
                  do 
                    if [ -n "$mysql_destination_database" ]; then
                        echo -e "La base de données choisie est : \e[1;32m$mysql_destination_database\e[0m"
                        nombreBDD_Destination=1
                        break
                    else
                        echo "Aucune base de données sélectionnée. Veuillez réessayer."
                    fi
                done
                ;;
	          *)
	        	echo -e "La base de données (par défaut) choisie est : \e[1;32m$mysql_destination_database\e[0m"
                ;;
        esac
	fi
}
## PASTE ##

# Lignes utiles
# Boucle sur mysql_destination_database
# for database_destination in $(cat "${folder_destination}_databases.txt"); do
#    echo "Connexion à $mysql_destination_database de $folder_destination"
#    sudo mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < "$folder_clone.sql"
# done

#************ NEW SCRIPT ******************************#
# sed -i "s|$ancienne_valeur|$nouvelle_valeur|g" "$folder_destination.sql"
# sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $folder_clone.sql
# CAS WORDPRESS, partir sur le script normal
# Mettre un grand if de corresppondance d'instance source et destination
# Revoir tout les cas de figure

# CAS DRUPAL
if_case_1_1() {
    # Export de la BDD Source dans $folder_clone.sql 
    sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > $mysql_clone_database.sql
    echo -e ">> [${GREEN}REUSSI${NC}] Export de $mysql_clone_database effectué"
    
    if [ -f "$mysql_clone_database.sql" ]; then 
        sed -i "s/DEFINER=[^*]*\*/\*/g" "$mysql_clone_database.sql"

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
        [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/https:\/\/prof.`echo $folder_clone`/https:\/\/prof.`echo $folder_destination`/g" $mysql_clone_database.sql 
        [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/http:\/\/prof.`echo $folder_clone`/https:\/\/prof.`echo $folder_destination`/g" $mysql_clone_database.sql 
        [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/https:\/\/mediateurs.`echo $folder_clone`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
        [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/http:\/\/mediateurs.`echo $folder_clone`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
        [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/https:\/\/familles.`echo $folder_clone`/https:\/\/familles.`echo $folder_destination`/g" $mysql_clone_database.sql 
        [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/http:\/\/familles.`echo $folder_clone`/https:\/\/familles.`echo $folder_destination`/g" $mysql_clone_database.sql
        [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/prof.`echo $folder_clone`/prof.`echo $folder_destination`/g" $mysql_clone_database.sql
        [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/mediateurs.`echo $folder_clone`/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
        [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/familles.`echo $folder_clone`/familles.`echo $folder_destination`/g" $mysql_clone_database.sql
        
        echo -e ">> [${GREEN}REUSSI${NC}] Remplacement des valeurs effectué"

        sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $mysql_clone_database.sql > /dev/null 2>&1
        echo -e ">> [${GREEN}REUSSI${NC}] Import de $mysql_clone_database dans $mysql_destination_database effectué"
        
        dbSizeClone
        dbSizeDestination
    else 
        echo -e ">> [${RED}ECHEC${NC}] "$mysql_clone_database.sql" n'existe pas"
        echo -e ">> Sortie du script"
        exit 0
    fi
}

if_case_2_2() {
    # Export de la BDD Source dans $folder_clone.sql
    #** Parcours des variables existantes
    for database_clone in $(cat "${folder_clone}_databases.txt"); do
        mysql_clone_database=$database_clone

        if [[ "$mysql_clone_database" == *_cms_prod* ]] || [[ "$mysql_clone_database" == *_cms_sandbox* ]] || [[ "$mysql_clone_database" == *_crm_prod* ]] || [[ "$mysql_clone_database" == *_crm_sandbox* ]]; then
            
            echo " " && echo ">> $mysql_clone_database valide la premiere condition" && echo " "

            # Boucle sur les BDD Destination
            for database_destination in $(cat "${folder_destination}_databases.txt"); do
        		mysql_destination_database=$database_destination
            
				if [[ "$mysql_clone_database" == *_cms_prod* ]] || [[ "$mysql_clone_database" == *_cms_sandbox* ]] && [[ "$mysql_destination_database" == *_cms_prod* ]] || [[ "$mysql_destination_database" == *_cms_sandbox* ]]; then
                	echo ">> CONDITION CMS"
                	echo "$mysql_clone_database = CMS"
                	echo "$mysql_destination_database = CMS"

                    sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > "$(folder_clone)_cms.sql" 
                    remplacementURLfichierSQL_2_2_CMS
                    sudo mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $(folder_clone)_cms.sql
                    rm $(folder_clone)_cms.sql
				elif [[ "$mysql_clone_database" == *_crm_prod* ]] || [[ "$mysql_clone_database" == *_crm_sandbox* ]] && [[ "$mysql_destination_database" == *_crm_prod* ]] || [[ "$mysql_destination_database" == *_crm_sandbox* ]]; then
                	echo ">> CONDITION CRM"
                	echo "$mysql_clone_database = CRM"
                	echo "$mysql_destination_database = CRM"

                    sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > "$(folder_clone)_crm.sql" 
                    remplacementURLfichierSQL_2_2_CRM
                    sudo mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $(folder_clone)_crm.sql
                    rm $(folder_clone)_crm.sql
                fi
            done
        fi
    done
}

# $mysql_clone_database.sql

# Remplacement 1 vers 1 
remplacementURLfichierSQL_1_1() {
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
    [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/https:\/\/prof.`echo $folder_clone`/https:\/\/prof.`echo $folder_destination`/g" $mysql_clone_database.sql 
    [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/http:\/\/prof.`echo $folder_clone`/https:\/\/prof.`echo $folder_destination`/g" $mysql_clone_database.sql 
    [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/https:\/\/mediateurs.`echo $folder_clone`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
    [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/http:\/\/mediateurs.`echo $folder_clone`/https:\/\/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
    [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/https:\/\/familles.`echo $folder_clone`/https:\/\/familles.`echo $folder_destination`/g" $mysql_clone_database.sql 
    [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/http:\/\/familles.`echo $folder_clone`/https:\/\/familles.`echo $folder_destination`/g" $mysql_clone_database.sql
    [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/prof.`echo $folder_clone`/prof.`echo $folder_destination`/g" $mysql_clone_database.sql
    [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/mediateurs.`echo $folder_clone`/mediateurs.`echo $folder_destination`/g" $mysql_clone_database.sql
    [[ "$folder_clone" == "prof.parlemonde.org" || "mediateurs.parlemonde.org" || "familles.parlemonde.org" ]] && sed -i "s/familles.`echo $folder_clone`/familles.`echo $folder_destination`/g" $mysql_clone_database.sql 

    echo "> Remplacement des valeurs de effectué"
    echo "> Import de $mysql_clone_database dans $mysql_destination_database"
}

# Remplacement 2 vers 2 (CMS)
remplacementURLfichierSQL_2_2_CMS() {
    echo "> Export de $mysql_clone_database CMS"
    
    ## Parcours et modification de chaque BDD
    sed -i "s/`echo $folder_clone`/`echo $folder_destination`/g" "$(folder_clone)_cms.sql"
    sed -i "s/https:\/\/`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" "$(folder_clone)_cms.sql"
    sed -i "s/http:\/\/`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" "$(folder_clone)_cms.sql"
    sed -i "s/https:\/\/www.`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" "$(folder_clone)_cms.sql"
    sed -i "s/http:\/\/www.`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" "$(folder_clone)_cms.sql"
    sed -i "s/www.`echo $folder_clone`/`echo $folder_destination`/g" "$(folder_clone)_cms.sql"
    sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" "$(folder_clone)_cms.sql"

    echo "> Import de $mysql_clone_database dans $mysql_destination_database"
}

# Remplacement 2 vers 2 (CRM)
remplacementURLfichierSQL_2_2_CRM() {
    echo "> Export de $mysql_clone_database CRM"

    ## Parcours et modification de chaque BDD
    sed -i "s/`echo $folder_clone`/`echo $folder_destination`/g" "$(folder_clone)_crm.sql"
    sed -i "s/https:\/\/`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" "$(folder_clone)_crm.sql"
    sed -i "s/http:\/\/`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" "$(folder_clone)_crm.sql"
    sed -i "s/https:\/\/www.`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" "$(folder_clone)_crm.sql"
    sed -i "s/http:\/\/www.`echo $folder_clone`/https:\/\/`echo $folder_destination`/g" "$(folder_clone)_crm.sql"
    sed -i "s/www.`echo $folder_clone`/`echo $folder_destination`/g" "$(folder_clone)_crm.sql"
    sed -i "s/\/vhosts\/`echo $folder_clone`/\/vhosts\/`echo $folder_destination`/g" "$(folder_clone)_crm.sql"

    echo "> Import de $mysql_clone_database dans $mysql_destination_database"
}