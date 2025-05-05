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
select folder_source in "${listSite[@]}"; 
  do 
    echo -e '\e[93m=============================================\033[0m'
		echo -e "L'instance source choisie est : \e[1;32m$folder_source\e[0m" ; echo " "
  	sleep 0.6
    break;
done

# Affectation de variables selon le CMS de l'instance source
test -e $vhosts/$folder_source/httpdocs/wp-config.php && cms_instance_source="wordpress"
test -e $vhosts/$folder_source/httpdocs/sites/default/settings.php && cms_instance_source="drupal"

# Affichage en tableau de la/les base.s de données de $folder_source (instance source)
plesk db "select d.name as 'Domaine source', db.name as 'Base de donnees source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_source'"

# Récuperation des identifiants de l'instance
while [ "$cms_instance_source" == "wordpress" ] 
  do 
    getWordpressID_Source 
done 

while [ "$cms_instance_source" == "drupal" ] 
  do
    getDrupalID_Source 
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
    break;
done

# Affectation de variables selon le CMS de l'instance destination
test -e $vhosts/$folder_destination/httpdocs/wp-config.php && cms_instance_destination="wordpress"
test -e $vhosts/$folder_destination/httpdocs/sites/default/settings.php && cms_instance_destination="drupal"

# Point de contrôle de vérification de $folder_source == $folder_destination 
if [ "$folder_source" == "$folder_destination" ]
  then
    echo "L'instance source est similaire à l'instance destination"
    echo "Sortie du script" ; echo " "
    exit 0
fi

# Affichage en tableau de la base de données de $folder_destination (instance destination)
plesk db "select d.name as 'Domaine destination', db.name as 'Base de donnees destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'" 

# Récupération des idenfifiants de l'instance destination
while [ "$cms_instance_destination" == "wordpress" ] 
  do 
    getWordpressID_Destination
done

while [ "$cms_instance_destination" == "drupal" ] 
  do
    getDrupalID_Destination
done 

# Point de contrôle de vérification ou non de l'égalité de l'utilisateur et la base de données destination
if [ "$mysql_source_user" == "$mysql_destination_user" ] && [ "$mysql_source_database" == "$mysql_destination_database" ]
	then
		echo " " ; echo -e ">> [${RED}ERREUR${NC}] Les identifiants des domaines source et destination sont similaires, restaurer $folder_source et/ou $folder_destination"	
    echo "Sortie du script" ; echo " "
		exit 0
fi 

echo -e '\e[93m=============================================\033[0m' 
echo -e '\e[1;32m Vous allez cloner la BDD '$mysql_source_database' de '$folder_source' vers la BDD '$mysql_destination_database' de '$folder_destination' \032'
echo -e '\e[93m=============================================\033[0m' 

echo " "

# Condition pour suppression des tables de la base de données destination
echo "Faut-il vider la base de données $mysql_destination_database de $folder_destination ? o(oui) ou n(non)"
read reponse1
if test "$reponse1" = "o"
	then
		sleep 0.6 && vidageBDD_Destination && echo " "
		sleep 0.6 && dbSize_Source && dbSize_Destination && echo " "
	else
    echo "> Démarrage du clonage"  
fi
echo -e '\e[93m============================================================\033[0m' ; echo " "

#***  Debut du clonage de BDD  ***#
cd $vhosts/$folder_source/httpdocs

# Export de la BDD
exportBDD_Source 

tar -czvf $folder_source.tar.gz $folder_source.sql
rm $folder_source.sql
mv $folder_source.zip $vhosts/$folder_destination/httpdocs/

cd $vhosts/$folder_destination/httpdocs
tar -xzvf - -C $vhosts/$folder_destination > /dev/null
rm -f $folder_source.zip

# Modification des URLs dans la base de données des occurences de $folder_source vers $folder_destination 
remplacementURL_BDD
nettoyageAdressesElectroniques

rm $folder_source.sql

# Point de contrôle de vérification ou non de l'égalité de l'utilisateur et la base de données destination
if [ "$mysql_source_user" == "$mysql_destination_user" ] && [ "$mysql_source_database" == "$mysql_destination_database" ]
	then
		echo " " ; echo -e ">> [${RED}ERREUR${NC}] Les identifiants des domaines source et destination sont similaires, veuillez restaurer $folder_source et/ou $folder_destination" ; echo " "
		exit 0
fi 

echo " " ; echo -e ">> [${GREEN}REUSSI${NC}] BDD de $folder_source bien clonée sur la BDD de $folder_destination" ; echo " "