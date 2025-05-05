#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam et Ilias Assadki
##
#############################################################
##
##  Vidage base de données 
##
#############################################################

GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No color

vhosts="/var/www/vhosts" ; mysql_server="localhost:3306"

source functions.sh
cd $vhosts
 
## Choix de l'instance destination 
echo -e '\e[93m=====================================\033[0m'
echo "De quelle instance souhaitez vous en vider la base de données ?" && echo " "

# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_destination in "${listSite[@]}";
  do 
    echo -e '\e[93m=============================================\033[0m'
  	echo -e "L'instance choisie est : \e[1;32m$folder_destination\e[0m"
  	sleep 0.6
    break;
done

# Affectation de variables selon le CMS de l'instance 
test -e $vhosts/$folder_destination/httpdocs/wp-config.php && cms_instance_destination="wordpress"
test -e $vhosts/$folder_destination/httpdocs/sites/default/settings.php && cms_instance_destination="drupal"

# Affichage en tableau de la base de données de $folder_destination (instance destination)
plesk db "select d.name as 'Domaine', db.name as 'Base de donnees' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'"

## Wordpress 
# Récuperation des identifiants de l'instance sur laquelle vous souhaitez changer les valeurs
while [ "$cms_instance_destination" == "wordpress" ] # while test -e $folder_destination/httpdocs/wp-config.php
  do 
    getWordpressID_Destination 
done 

## Drupal 
while [ "$cms_instance_destination" == "drupal" ] # while test -e $folder_destination/httpdocs/sites/default/settings.php
  do
    getDrupalID_Destination 
done 

echo -e '\e[93m=============================================\033[0m' 

# Condition pour suppression des tables mysql de $folder_destination
echo "Voulez vous vider la base de données de $folder_destination ? o(oui) ou n(non)"
read reponse1
if test "$reponse1" = "o"
  then
	vidageBDD_Destination
else
    echo "Sortie du script"
    exit 0
fi

echo " " ; echo -e ">> [${GREEN}REUSSI${NC}] Le vidage de la BDD de $folder_destination a bien été effectué" ; echo " "