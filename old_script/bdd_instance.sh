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
select folder_source in "${listSite[@]}";
	do 		
    echo -e '\e[93m=============================================\033[0m'
		echo -e "L'instance source choisie est : \e[1;32m$folder_source\e[0m"
    echo -e '\e[93m=============================================\033[0m' 
		sleep 0.6
    break;
done

# Affectation de variables selon le CMS de l'instance source
test -e $vhosts/$folder_source/httpdocs/wp-config.php && cms_instance_source="wordpress"
test -e $vhosts/$folder_source/httpdocs/sites/default/settings.php && cms_instance_source="drupal"

dbSize_Source && echo " "