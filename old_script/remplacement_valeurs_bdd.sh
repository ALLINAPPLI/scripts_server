#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam et Ilias Assadki
##
#############################################################
##
##  Remplacement de valeurs dans base de données 
##  sed -i 's/\BDES\b/DESE/g' bdese.sql # Modifier les valeurs, pour le cas de l'instance BDESE
##
#############################################################

GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No color

vhosts="/var/www/vhosts"

source functions.sh 
cd $vhosts 
 
## Choix de l'instance source
echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance dont vous souhaitez changer les valeurs ?" && echo " "
   
# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_source in "${listSite[@]}";
  do 
    echo -e '\e[93m=============================================\033[0m'
	  echo -e "L'instance choisie est : \e[1;32m$folder_source\e[0m"
	  sleep 0.6
    break;
done

# Affectation de variables selon le CMS de l'instance 
test -e $vhosts/$folder_source/httpdocs/wp-config.php && cms_instance_source="wordpress"
test -e $vhosts/$folder_source/httpdocs/sites/default/settings.php && cms_instance_source="drupal"

# Affichage en tableau de la base de données de $folder_source (instance source)
plesk db "select d.name as 'Domaine', db.name as 'Base de donnees' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_source'"

## Wordpress
# Récuperation des identifiants de l'instance 
while [ "$cms_instance_source" == "wordpress" ] 
  do 
    getWordpressID_Source 
done 

## Drupal 
while [ "$cms_instance_source" == "drupal" ] 
  do
    getDrupalID_Source 
done 
 
echo -e '\e[93m============================================================\033[0m' && echo " "

# Remplacement de valeurs
echo "Quelles occurrences de la BDD '$mysql_source_database' voulez vous changer ?"
read ancienne_valeur && echo " "
echo "Par quoi voulez vous remplacer ces occurrences ?"
read nouvelle_valeur && echo " "

echo -e '\e[93m=============================================\033[0m'
quote="'" ## Pour afficher le simple quote
echo -e '\e[1;32m Vous allez remplacer les occurrences \033[1;93m'$ancienne_valeur'\033[1;32m par \033[1;93m'$nouvelle_valeur'\033[1;32m dans la BDD \033[1;93m'$mysql_source_database'\033[1;32m de l'$quote'instance \033[1;93m'$folder_source'\033 \e[0m'
echo -e '\e[93m=============================================\033[0m'

# Condition pour commencer le script
echo "Voulez vous commencer ? o(oui) ou n(non)"
read reponse
if test "$reponse" = "n"
then
     exit 0 && echo "Fin du script"
fi
 
#***  Debut remplacement valeurs BDD  ***#
cd $folder_source/httpdocs

# Export de la BDD actuelle
exportBDD_Source  # ou exportBDD_Source_Without_Definer 

# Changement de valeurs
sed -i "s/DEFINER=[^*]*\*/\*/g" "$folder_source.sql"
sed -i "s|$ancienne_valeur|$nouvelle_valeur|g" "$folder_source.sql"

# Import de la nouvelle BDD
importBDD_Source

rm -rf $folder_source.sql

echo " " ; echo -e ">> [${GREEN}REUSSI${NC}] Occurences de la BDD de $folder_source changées" ; echo " "