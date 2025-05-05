#!/bin/bash
##
## Développé par Ilias Assadki
##
#############################################################
##
##  Affichage de bases de données d'instances (creer un alias pour ça)
##
#############################################################

vhosts="/var/www/vhosts" ; mysql_server="localhost:3306"

source functions.sh 
cd $vhosts

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

## Wordpress - Source
# Récupération des idenfifiants de l'instance source
while [ "$cms_instance_clone" == "wordpress" ] # while test -e $folder_clone/httpdocs/wp-config.php
	do 
    getWordpressID_clone 
done 

## Drupal - Source 
while [ "$cms_instance_clone" == "drupal" ] # while test -e $folder_clone/httpdocs/sites/default/settings.php
	do
    getDrupalID_clone 
done 

# Affichage en tableau de la/les base.s de données de $folder_clone (instance source)
plesk db "select d.name as 'Domaine source', db.name as 'Base de donnees source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'"

#! SCRIPT
dbSizeClone

##!!!!!!!! DATABASES
##* +------------------------+
##* | Base de donnees source |
##* +------------------------+
##* | aspasnat_              |
##* | aspasnatadmin_drupal   |
##* +------------------------+




