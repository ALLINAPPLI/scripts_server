#!/bin/bash
##
## Développé par Ilias Assadki
##
#############################################################
##
##  Sauvegarde instance (BDD et fichiers)
##
#############################################################

GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No color

vhosts="/var/www/vhosts" ; mysql_server="localhost:3306"

source functions.sh 
cd $vhosts
 
## Choix de l'instance source 
echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance que vous souhaitez sauvegarder ?" && echo " "
 
# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_clone in "${listSite[@]}";
	do 
		#TODO : Iterer sur toute les instances qui existent, et arreter le script si le chiffre écrit n'existe pas
    echo -e '\e[93m=============================================\033[0m'
		echo -e "L'instance choisie est : \e[1;32m$folder_clone\e[0m"
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

#**** Début de la sauvegarde
echo -e '\e[93m================================================\033[0m' 
# echo " "

cd $vhosts/$folder_clone

# Obtenir la date et l'heure actuelles
DATE=$(date +"%d_%m_%Y__%H_%M")

# Créer le répertoire avec le format de nom souhaité
mkdir -p "save_$DATE" && cd "save_$DATE"

#*** Sauvegarde BDD
dbSizeClone
sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > $mysql_clone_database.sql 
echo " "
echo -e ">> [${GREEN}REUSSI${NC}] Export de $mysql_clone_database effectué"
echo " "

#*** Sauvegarde Fichiers
cd $vhosts/$folder_clone
echo "> Archivage de httpdocs de $folder_clone"
tar -czf - httpdocs | pv -s $(du -sb httpdocs | awk '{print $1}') > "$folder_clone.tar.gz" # ZIP du httpdocs/ de l'instance
mv $folder_clone.tar.gz $vhosts/$folder_clone/save_$DATE # déplacement du ZIP à la racine de l'instance destination/

echo " "

echo "> Archivage du dossier de sauvegarde"
tar -czf - save_$DATE | pv -s $(du -sb save_$DATE | awk '{print $1}') > "save_$DATE.tar.gz" # ZIP du fichier de sauvegarde

echo " "
echo -e ">> [${GREEN}REUSSI${NC}] Archivage de $mysql_clone_database effectué"

rm -rf save_$DATE

cd $vhosts/$folder_clone

echo " "
echo -e '\e[93m================================================\033[0m' 

