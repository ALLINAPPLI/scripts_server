#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam et Ilias Assadki
##
#############################################################
##
##  Clonage base de données
##
#############################################################

vhosts="/var/www/vhosts"

cd $vhosts # $vhosts
source clonage/functions.sh 
 
## Choix de l'instance source 
echo -e '\e[93m=============================================\033[0m'
echo "Choisissez la BDD de l'instance source que vous souhaitez cloner ?"
echo " "

# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_clone in "${listSite[@]}"; 
  do 
    #TODO : Iterer sur toute les instances qui existent, et arreter le script si le chiffre écrit n'existe pas
    echo -e '\e[93m=============================================\033[0m'
	echo -e "L'instance source choisie est : \e[1;32m$folder_clone\e[0m"
    echo -e '\e[93m=============================================\033[0m'
	sleep 0.6
    break;
done

# Affectation de variables selon le CMS de l'instance source
test -e $folder_clone/httpdocs/wp-config.php && cms_instance_clone="wordpress"
test -e $folder_clone/httpdocs/sites/default/settings.php && cms_instance_clone="drupal"

# Affichage en tableau de la base de données de $folder_clone (instance source)
plesk db "select d.name as 'Domaine source', db.name as 'Base de donnees source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'"

## Wordpress - Source
# Récuperation des identifiants de l'instance
while [ "$cms_instance_clone" == "wordpress" ] # while test -e $folder_clone/httpdocs/wp-config.php
  do 
    getWordpressID_clone 
done 

## Drupal - Source
while [ "$cms_instance_clone" == "drupal" ] # while test -e $folder_clone/httpdocs/sites/default/settings.php
  do
    getDrupalID_clone 
done 

# getCheminActuel # $vhosts

## Choix de l'instance destination 
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'
sleep 0.8
echo "Choisissez l'instance destination ?"
echo " "

# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_destination in "${listSite[@]}";
  do 
    echo -e '\e[93m=============================================\033[0m'
	  echo -e "L'instance destination choisie est : \e[1;32m$folder_destination\e[0m"
    echo -e '\e[93m=============================================\033[0m'
    break;
done

# Affectation de variables selon le CMS de l'instance destination
test -e $folder_destination/httpdocs/wp-config.php && cms_instance_destination="wordpress"
test -e $folder_destination/httpdocs/sites/default/settings.php && cms_instance_destination="drupal"

# Condition si $folder_clone == $folder_destination, on arrête le script 
if [ "$folder_clone" == "$folder_destination" ]
  then
    echo "L'instance source est similaire à l'instance destination"
    echo "Sortie du script" ; echo " "
    exit 0
fi

# Affichage en tableau de la base de données de $folder_destination (instance destination)
plesk db "select d.name as 'Domaine destination', db.name as 'Base de donnees destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'" 

# getCheminActuel ## $vhosts

## Wordpress - Destination
while [ "$cms_instance_destination" == "wordpress" ] # while test -e $folder_destination/httpdocs/wp-config.php
  do 
    getWordpressID_Destination
done

## Drupal - Destination
while [ "$cms_instance_destination" == "drupal" ] # while test -e $folder_destination/httpdocs/sites/default/settings.php
  do
    getDrupalID_Destination
done 

# Condition si les identifiants clone et destination sont les mêmes
if [ "$mysql_clone_user" == "$mysql_destination_user" ] && [ "$mysql_clone_mdp" == "$mysql_destination_mdp" ] && [ "$mysql_clone_database" == "$mysql_destination_database" ]
  then
    echo "Les identifiants source et destination sont similaires, veuillez restaurer $folder_clone et/ou $folder_destination"
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
echo "Faut-il vider la base de données de $folder_destination ? o(oui) ou n(non)"
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
     echo "Démarrage du clonage de base de données"  
fi
echo -e '\e[93m============================================================\033[0m'
echo -e '\e[93m============================================================\033[0m'


cd $folder_clone/httpdocs
sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > $folder_clone.sql
sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $folder_clone.sql
## cd ..
zip $folder_clone.zip $folder_clone.sql
cd ../..
rm -f $folder_clone/httpdocs/$folder_clone.sql
mv $folder_clone/httpdocs/$folder_clone.zip $folder_destination/httpdocs/
cd $folder_destination/httpdocs
unzip $folder_clone.zip
rm -f $folder_clone.zip

remplacementURLfichierSQL
echo -e ">> [${GREEN}REUSSI${NC}] La modification des URLs a été effectuée"

rm -rf $folder_clone.sql

# remplacement_occurences_@_dest
nettoyageAddresseElec_1_1

echo " "
echo -e '\e[93m========================================\033[0m'
echo "La modification des URLs a été effectuée"
echo -e '\e[93m========================================\033[0m'
