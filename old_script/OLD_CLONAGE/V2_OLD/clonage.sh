#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam et Ilias Assadki
##
#############################################################
##
##  Clonage instance
##
#############################################################

### todo 2
#? faire un clonage de n'importe quelle instance, et voir si les deux chaines sont bein mises a jour quand on change

GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No color

vhosts="/var/www/vhosts" ; mysql_server="localhost:3306"

cd $vhosts
source clonage/functions.sh 
 
## Choix de l'instance source 
echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance source que vous souhaitez cloner ?" && echo " "
 
# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_clone in "${listSite[@]}";
	do 
    echo -e '\e[93m=============================================\033[0m'
		echo -e "L'instance source choisie est : \e[1;32m$folder_clone\e[0m"
		echo " "
		sleep 0.6
    break;
done

# Affectation de variables selon le CMS de l'instance source
test -e $folder_clone/httpdocs/wp-config.php && cms_instance_clone="wordpress"
test -e $folder_clone/httpdocs/sites/default/settings.php && cms_instance_clone="drupal"

# Affichage en tableau de la/les base.s de données de $folder_clone (instance source)
plesk db "select d.name as 'Domaine source', db.name as 'Base de donnees source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'"

# Récupération des idenfifiants de l'instance source
## Wordpress - Source
while [ "$cms_instance_clone" == "wordpress" ] # while test -e $folder_clone/httpdocs/wp-config.php
	do 
    getWordpressID_clone 
done 

## Drupal - Source
while [ "$cms_instance_clone" == "drupal" ] # while test -e $folder_clone/httpdocs/sites/default/settings.php
	do
    getDrupalID_clone 
done 

## Choix de l'instance destination
echo -e '\e[93m=============================================\033[0m'
sleep 0.8
echo "Choisissez l'instance de destination ?"
echo " "

# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_destination in "${listSite[@]}";
	do 
    echo -e '\e[93m=============================================\033[0m'
		echo -e "L'instance de destination choisie est : \e[1;32m$folder_destination\e[0m"
		echo " "
    break;
done

# Affectation de variables selon le CMS de l'instance destination
test -e $folder_destination/httpdocs/wp-config.php && cms_instance_destination="wordpress"
test -e $folder_destination/httpdocs/sites/default/settings.php && cms_instance_destination="drupal"

# Condition si $folder_clone == $folder_destination, on arrête le script 
if [ "$folder_clone" == "$folder_destination" ]
	then
    echo "L'instance source est similaire à l'instance de destination"
    echo "Sortie du script" ; echo " "
    exit 0
fi

#! Affichage en tableau de la/les base.s de données de $folder_destination (instance destination)
plesk db "select d.name as 'Domaine destination', db.name as 'Base de donnees destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'" 

## Wordpress - Destination
# Récupération des idenfifiants de l'instance destination
while [ "$cms_instance_destination" == "wordpress" ] # while test -e $folder_destination/httpdocs/wp-config.php
	do 
    getWordpressID_Destination
done

## Drupal - Destination
while [ "$cms_instance_destination" == "drupal" ] # while test -e $folder_destination/httpdocs/sites/default/settings.php
	do
    getDrupalID_Destination
done

## Instance vide - Destination
while [ -e "$folder_destination/index.html" ] || [ -z "$(ls -A $folder_destination/httpdocs)" ]
	do
    instanceVide
done

# Condition si les identifiants clone et destination sont les mêmes
if [ "$mysql_clone_user" == "$mysql_destination_user" ] && [ "$mysql_clone_mdp" == "$mysql_destination_mdp" ] && [ "$mysql_clone_database" == "$mysql_destination_database" ]
	then
		echo " "
	  echo -e ">> [${RED}ERREUR${NC}] Les identifiants des domaines source et destination sont similaires, restaurer $folder_clone et/ou $folder_destination"	
    echo "Sortie du script" ; echo " "
		exit 0
fi 

echo -e '\e[93m===============================================\033[0m' 
echo -e '\e[1;32m Vous allez cloner '$folder_clone' vers '$folder_destination' \032'
echo -e '\e[93m================================================\033[0m' 

# Condition pour suppression des tables de la base de données destination
echo "Faut-il vider la base de données $mysql_destination_database de $folder_destination ? o(oui) ou n(non)"
read reponse1
if test "$reponse1" = "o"
	then
		sleep 0.6
    vidageBDD_Destination
		echo " "
		sleep 0.6
		dbSizeClone
		dbSizeDestination
		echo " "
	else
    echo "> Démarrage du clonage"  
fi
echo -e '\e[93m================================================\033[0m' 
echo " "

#***  Debut clonage  ***#
#*** Partie source ***#
source $vhosts/clonage/databases.sh 

cd $vhosts/$folder_clone/httpdocs

if [[ ! -d "temp_clonage" ]]; then
		mkdir temp_clonage && cd temp_clonage
else 
		cd temp_clonage 
fi

getDatabasesClone # Récuperer les DB du fichier clone et envoie du fichier .txt

cd $vhosts/$folder_clone
# tar -czvf $folder_clone.tar.gz httpdocs # ZIP du dossier httpdocs/ de $folder_clone
echo "> Début de l'archivage"
tar -czf - httpdocs | pv -s $(du -sb httpdocs | awk '{print $1}') > "$folder_clone.tar.gz" 

echo " "
mv $folder_clone.tar.gz $vhosts/$folder_destination # déplacement du ZIP à la racine de l'instance destination

#*** Partie destination ***#
cd $vhosts/$folder_destination
rm -rf httpdocs # suppression du dossier httpdocs/ 

# tar -xzvf $folder_clone.tar.gz # extraction du ZIP (httpdocs)
echo "> Début du désarchivage"
pv -s $(du -sb "$folder_clone.tar.gz" | awk '{print $1}') "$folder_clone.tar.gz" | tar -xzvf - -C $vhosts/$folder_destination > /dev/null 
# pv "$folder_clone.tar.gz" | tar -xzvf - -C $vhosts/$folder_destination

echo " "
echo -e '\e[93m================================================\033[0m' 
# echo " "

rm $folder_clone.tar.gz # suppression du ZIP

cd $vhosts/$folder_destination/httpdocs/temp_clonage  

getDatabasesDestination # Récuperer les DB du fichier clone et envoie du fichier .txt

# Choix des bases de données à cloner et potentiellement remplacer (Source et Destination)
chooseDatabasesClone # functions_databases.sh
chooseDatabasesDestination # functions_databases.sh

# echo "Nombre de BDD Source : $nombreBDD_Source"
# echo "Nombre de BDD Destination : $nombreBDD_Destination"
echo " "

# Variables recuperées depuis functions_databases.sh
combined_databases="${nombreBDD_Source}_${nombreBDD_Destination}"

# Modification des URLs dans la base de données des occurences de $folder_clone vers $folder_destination 
case $combined_databases in
    1_1)
        echo "Source : 1 | Destination : 1" && echo " "
        if_case_1_1 # 1 BDD vers 1 BDD
        nettoyageAddresseElec_1_1
				# remplacement_occurences_@_dest
        ;;
    2_2)
        echo "Source : 2 | Destination : 2" && echo " "
        # if_case_2_2 # 2 BDD vers 2 BDD
        echo "Veuillez vérifier les bases de données Sources/Destination"
        exit 0
        ;;
    1_2)
        echo "Source : 1 | Destination : 2"
        echo "Veuillez vérifier les bases de données Sources/Destination"
        exit 0
        ;;
    2_1)
        echo "Source : 2 | Destination : 1"
        echo "Veuillez vérifier les bases de données Sources/Destination"
        exit 0
        ;;
    *)
        echo "Variables mal initialisées, fin du script"
        exit 0
        ;;
esac
#***  Fin clonage  ***#

echo -e ">> [${GREEN}REUSSI${NC}] La modification des URLs a été effectuée"
echo " "

cd $vhosts

# Modification des variables dans les fichiers de configuration
# Conditions pour distinguer Drupal de WordPress
# Si c'est une instance Drupal, les variables du fichier settings.php sont remplacées par les nouvelles variables destination pour Drupal 
if test -e $folder_destination/httpdocs/sites/default/settings.php
	then
		echo -e ">> [${WHITE}INFO${NC}] CMS trouvé : Drupal"	
		testDrupal 

		# si on trouve Civicrm, les variables du fichier civicrm.settings.php sont modifiées avec les nouvelles variables destination pour Drupal
		if test -e $folder_destination/httpdocs/sites/default/civicrm.settings.php
			then
				testCiviCRM_Drupal  
			else
				echo -e ">> [${WHITE}INFO${NC}] CiviCRM pour Drupal absent"	
		fi

# sinon, si c'est une instance WordPress, les variables du fichier wp-config.php sont remplacées par les nouvelles variables destination pour WordPress
elif test -e $folder_destination/httpdocs/wp-config.php
	then 
		echo -e ">> [${WHITE}INFO${NC}] CMS trouvé : Wordpress"	
		testWP 
   
		# parlemonde.org (modification du fichier civicrm.settings est présent à la racine) 
		if test -e $folder_destination/httpdocs/civicrm.settings.php
			then 
				testCiviCRM_parlemonde 
		fi

		# si un fichier généré par WordFence est present (.user.ini), les variables du fichier .user.ini sont remplacées par les nouvelles variables destination pour WordPress
		if test -e $folder_destination/httpdocs/.user.ini >/dev/null 2>&1
			then
				testWordfence 
			else
			  echo -e ">> [${WHITE}INFO${NC}] Fichiers générés par WordFence absents"	
		fi

		# Si on trouve Civicrm, les variables du fichier civicrm.settings.php sont remplacées avec les nouvelles variables destination pour WordPress
		if test -e $folder_destination/httpdocs/wp-content/uploads/civicrm/civicrm.settings.php
			then
				testCiviCRM_WP  
			else 
			  echo -e ">> [${WHITE}INFO${NC}] CiviCRM pour Wordpress absent de wp-content/plugins/"	
		fi  

		# Si rien n'est trouvé, on retourne qu'aucun CMS n'a été trouvé
else
	echo "Aucun CMS n'a été trouvé"
fi

echo " "

# Nettoyage des repertoire
cd $vhosts/$folder_clone/httpdocs && rm -rf temp_clonage && echo -e ">> [${GREEN}REUSSI${NC}] Suppression du dossier temp_clonage source effectué" && cd $vhosts 
cd $vhosts/$folder_destination/httpdocs && rm -rf temp_clonage && echo -e ">> [${GREEN}REUSSI${NC}] Suppression du dossier temp_clonage destination effectué" && cd $vhosts 

# Correction de la propriété des fichiers  
echo " " && echo -e ">> [${WHITE}INFO${NC}] Plesk repair"
plesk repair fs `echo $folder_destination` -y

# Condition si les identifiants clone et destination sont les mêmes
if [ "$mysql_clone_user" == "$mysql_destination_user" ] && [ "$mysql_clone_mdp" == "$mysql_destination_mdp" ] && [ "$mysql_clone_database" == "$mysql_destination_database" ]
	then
		echo " "
	  echo -e ">> [${RED}ERREUR${NC}] Les identifiants des domaines source et destination sont similaires, veuillez restaurer $folder_clone et/ou $folder_destination"	
		echo " "
		exit 0
fi 
	
echo " "
echo -e ">> [${GREEN}REUSSI${NC}] Site $folder_clone bien cloné vers $folder_destination"	
echo " "

[ -e $folder_destination/httpdocs/wp-config.php ] && echo -e ">>>> [${WHITE}INFO${NC}] PENSER À VÉRIFIER LES FICHIERS WP-CONFIG.PHP AINSI QUE LE CIVICRM.SETTINGS.PHP"
[ -e $folder_destination/httpdocs/sites/default/settings.php ] && echo -e ">>>> [${WHITE}INFO${NC}] PENSER À VÉRIFIER SETTINGS.PHP AINSI QUE LE CIVICRM.SETTINGS.PHP"

echo " "

##!! Si la connexion au vidage ne marche pas, on ne contine pas (mettre une condition sur la connexion à la BDD)