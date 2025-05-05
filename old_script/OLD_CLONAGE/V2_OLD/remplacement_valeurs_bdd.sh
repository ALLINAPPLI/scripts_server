#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam et Ilias Assadki
##
#############################################################
##
##  Remplacement de valeurs dans base de données
##
#############################################################
  
vhosts="/var/www/vhosts"

cd $vhosts 
source clonage/functions.sh 
 
## Choix de l'instance destination
echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance dont vous souhaitez changer les valeurs ?"
echo " "
   
# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_destination in "${listSite[@]}";
  do 
	#TODO : Iterer sur toute les instances qui existent, et arreter le script si le chiffre écrit n'existe pas
    echo -e '\e[93m=============================================\033[0m'
	echo -e "L'instance choisie est : \e[1;32m$folder_destination\e[0m"
    echo -e '\e[93m=============================================\033[0m' 
	sleep 0.6
    break;
done

# Affectation de variables selon le CMS de l'instance 
test -e $folder_destination/httpdocs/wp-config.php && cms_instance_destination="wordpress"
test -e $folder_destination/httpdocs/sites/default/settings.php && cms_instance_destination="drupal"

# Affichage en tableau de la base de données de $folder_destination (instance destination)
plesk db "select d.name as 'Domaine', db.name as 'Base de donnees' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'"

## Wordpress
# Récuperation des identifiants de l'instance 
while [ "$cms_instance_destination" == "wordpress" ] # while test -e $folder_destination/httpdocs/wp-config.php
  do 
    getWordpressID_Destination 
done 

## Drupal 
while [ "$cms_instance_destination" == "drupal" ] # while test -e $folder_destination/httpdocs/sites/default/settings.php
  do
    getDrupalID_Destination 
done 
 
getCheminActuel # $vhosts
echo -e '\e[93m============================================================\033[0m'

# Remplacement de valeurs
echo " "
echo "Quelles occurrences de la BDD '$mysql_destination_database' voulez vous changer ?"
read ancienne_valeur
echo " "
echo "Par quoi voulez vous remplacer ces occurrences ?"
read nouvelle_valeur
echo " "

echo -e '\e[93m=============================================\033[0m'
quote="'" ## variable du simple quote
echo -e '\e[1;32m Vous allez remplacer les occurrences \033[1;93m'$ancienne_valeur'\033[1;32m par \033[1;93m'$nouvelle_valeur'\033[1;32m dans la BDD \033[1;93m'$mysql_destination_database'\033[1;32m de l'$quote'instance \033[1;93m'$folder_destination'\033 \e[0m'
echo -e '\e[93m=============================================\033[0m'

# Condition pour commencer le script
echo "Voulez vous commencer ? o(oui) ou n(non)"
read reponse
if test "$reponse" = "n"
then
     exit 0 && echo "Fin du script"
fi
 
# Opérations de remplacement de valeurs SQL
cd $folder_destination/httpdocs

# Export de la BDD actuelle
sudo mysqldump --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database > $folder_destination.sql

sed -i "s/DEFINER=[^*]*\*/\*/g" "$folder_destination.sql"
sed -i "s|$ancienne_valeur|$nouvelle_valeur|g" "$folder_destination.sql"

# Import de la nouvelle BDD
sudo mysql --user=$mysql_destination_user --password=$mysql_destination_mdp $mysql_destination_database < $folder_destination.sql

rm -rf $folder_destination.sql

echo " "
echo -e '\e[93m========================================\033[0m'
echo "Le remplacement des valeurs a bien été effectué"
echo -e '\e[93m========================================\033[0m'

#sed -i 's/\BDES\b/DESE/g' bdese.sql # Modifier les valeurs, pour le cas de l'instance BDESE

