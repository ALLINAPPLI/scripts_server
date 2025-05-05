#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam et Ilias Assadki
##
#############################################################
##
##  Clonage base de données
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
echo "Choisissez l'instance source dont vous souhaitez cloner la BDD ?" ; echo " "

# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_clone in "${listSite[@]}"; 
  do 
    echo -e '\e[93m=============================================\033[0m'
		echo -e "L'instance source choisie est : \e[1;32m$folder_clone\e[0m" ; echo " "
  	sleep 0.6
    break;
done

# Affectation de variables selon le CMS de l'instance source
test -e $vhosts/$folder_clone/httpdocs/wp-config.php && cms_instance_clone="wordpress"
test -e $vhosts/$folder_clone/httpdocs/sites/default/settings.php && cms_instance_clone="drupal"

# Affichage en tableau de la/les base.s de données de $folder_clone (instance source)
plesk db "select d.name as 'Domaine source', db.name as 'Base de donnees source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'"

# Récuperation des identifiants de l'instance
while [ "$cms_instance_clone" == "wordpress" ] # while test -e $folder_clone/httpdocs/wp-config.php
  do 
    getWordpressID_clone 
done 

while [ "$cms_instance_clone" == "drupal" ] # while test -e $folder_clone/httpdocs/sites/default/settings.php
  do
    getDrupalID_clone 
done 

## Choix de l'instance destination 
echo -e '\e[93m=============================================\033[0m'
sleep 0.8
echo "Choisissez l'instance destination qui va recevoir la BDD ?" && echo " "

# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_destination in "${listSite[@]}";
  do 
    echo -e '\e[93m=============================================\033[0m'
		echo -e "L'instance de destination choisie est : \e[1;32m$folder_destination\e[0m" ; echo " "
    echo -e '\e[93m=============================================\033[0m'
    break;
done

# Affectation de variables selon le CMS de l'instance destination
test -e $vhosts/$folder_destination/httpdocs/wp-config.php && cms_instance_destination="wordpress"
test -e $vhosts/$folder_destination/httpdocs/sites/default/settings.php && cms_instance_destination="drupal"

# Condition si $folder_clone == $folder_destination, on arrête le script 
if [ "$folder_clone" == "$folder_destination" ]
  then
    echo "L'instance source est similaire à l'instance destination"
    echo "Sortie du script" ; echo " "
    exit 0
fi

# Affichage en tableau de la base de données de $folder_destination (instance destination)
plesk db "select d.name as 'Domaine destination', db.name as 'Base de donnees destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'" 

# Récupération des idenfifiants de l'instance destination
while [ "$cms_instance_destination" == "wordpress" ] # while test -e $folder_destination/httpdocs/wp-config.php
  do 
    getWordpressID_Destination
done

while [ "$cms_instance_destination" == "drupal" ] # while test -e $folder_destination/httpdocs/sites/default/settings.php
  do
    getDrupalID_Destination
done 

# Condition si les identifiants clone et destination sont les mêmes
if [ "$mysql_clone_user" == "$mysql_destination_user" ] && [ "$mysql_clone_mdp" == "$mysql_destination_mdp" ] && [ "$mysql_clone_database" == "$mysql_destination_database" ]
	then
		echo " " ; echo -e ">> [${RED}ERREUR${NC}] Les identifiants des domaines source et destination sont similaires, restaurer $folder_clone et/ou $folder_destination"	
    echo "Sortie du script" ; echo " "
		exit 0
fi 

echo -e '\e[93m=============================================\033[0m' 
echo -e '\e[1;32m Vous allez cloner la BDD '$mysql_clone_database' de '$folder_clone' vers la BDD '$mysql_destination_database' de '$folder_destination' \032'
echo -e '\e[93m=============================================\033[0m' 
# getCheminActuel ## $vhosts
# echo -e '\e[93m============================================================\033[0m'

echo " "

# Condition pour suppression des tables de la base de données destination
echo "Faut-il vider la base de données $mysql_destination_database de $folder_destination ? o(oui) ou n(non)"
read reponse1
if test "$reponse1" = "o"
	then
		sleep 0.6 && vidageBDD_Destination && echo " "
		sleep 0.6 && dbSizeClone && dbSizeDestination && echo " "
	else
    echo "> Démarrage du clonage"  
fi
echo -e '\e[93m============================================================\033[0m' ; echo " "

# Début du clonage de BDD
cd $vhosts/$folder_clone/httpdocs

# Export de la BDD
sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > $folder_clone.sql
sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $folder_clone.sql

zip $folder_clone.zip $folder_clone.sql

cd ../..

rm -f $folder_clone/httpdocs/$folder_clone.sql

mv $folder_clone/httpdocs/$folder_clone.zip $folder_destination/httpdocs/

cd $folder_destination/httpdocs

unzip $folder_clone.zip

rm -f $folder_clone.zip

# Modification des URLs dans la base de données des occurences de $folder_clone vers $folder_destination 
remplacementURL_BDD
nettoyageAdressesElectroniques

rm -rf $folder_clone.sql


echo " "
echo -e '\e[93m========================================\033[0m'
echo "La modification des URLs a été effectuée"
echo -e '\e[93m========================================\033[0m'
