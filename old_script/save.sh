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
select folder_source in "${listSite[@]}";
	do 
		#TODO : Iterer sur toute les instances qui existent, et arreter le script si le chiffre écrit n'existe pas
    echo -e '\e[93m=============================================\033[0m'
		echo -e "L'instance choisie est : \e[1;32m$folder_source\e[0m"
		echo " "
		sleep 0.6
    break;
done

# Affectation de variables selon le CMS de l'instance source
test -e $folder_source/httpdocs/wp-config.php && cms_instance_source="wordpress"
test -e $folder_source/httpdocs/sites/default/settings.php && cms_instance_source="drupal"

# Affichage en tableau de la/les base.s de données de $folder_source (instance source)
plesk db "select d.name as 'Domaine source', db.name as 'Base de donnees source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_source'"

# Récupération des idenfifiants de l'instance source
## Wordpress - Source
while [ "$cms_instance_source" == "wordpress" ] # while test -e $folder_source/httpdocs/wp-config.php
	do 
    getWordpressID_Source 
done 

## Drupal - Source
while [ "$cms_instance_source" == "drupal" ] # while test -e $folder_source/httpdocs/sites/default/settings.php
	do
    getDrupalID_Source 
done 

echo -e '\e[93m================================================\033[0m' 

#***  Debut de la sauvegarde de l'instance  ***#
cd $vhosts/$folder_source

# Obtenir la date et l'heure actuelles
DATE=$(date +"%d_%m_%Y__%H_%M")

# Créer le répertoire avec le format de nom souhaité
mkdir -p "save_$DATE" && cd "save_$DATE"

# Sauvegarde BDD
dbSize_Source
sudo mysqldump --user=$mysql_source_user --password=$mysql_source_mdp $mysql_source_database > $mysql_source_database.sql 
echo " "
echo -e ">> [${GREEN}REUSSI${NC}] Export de $mysql_source_database effectué"
echo " "

#*** Sauvegarde Fichiers
cd $vhosts/$folder_source
echo "> Archivage de httpdocs de $folder_source"
tar -czf - httpdocs | pv -s $(du -sb httpdocs | awk '{print $1}') > "$folder_source.tar.gz" # ZIP du httpdocs/ de l'instance
mv $folder_source.tar.gz $vhosts/$folder_source/save_$DATE # déplacement du ZIP à la racine de l'instance destination/

echo " "

echo "> Archivage du dossier de sauvegarde"
tar -czf - save_$DATE | pv -s $(du -sb save_$DATE | awk '{print $1}') > "save_$DATE.tar.gz" # ZIP du fichier de sauvegarde

echo " "
echo -e ">> [${GREEN}REUSSI${NC}] Archivage de $mysql_source_database effectué"

rm -rf save_$DATE

cd $vhosts/$folder_source

echo -e ">> [${GREEN}REUSSI${NC}] Sauvegarde de $folder_source effectuée" ; echo " "