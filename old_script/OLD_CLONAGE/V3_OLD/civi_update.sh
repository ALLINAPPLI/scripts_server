#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam
## et Ilias Assadki
##
################################################
##
##  Scripts de mise a jour de CiviCRM pour les instances web
##
################################################
shopt -s expand_aliases
######################################################

# Security check
if [ ! -f ~/.bashrc ]; then
    printf -- '\033[41m  .bashrc must exist. abord. \033[0m\n'
    exit 1
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No color

vhosts="/var/www/vhosts"

source functions_civicrm.sh
source ~/.bashrc

echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance à mettre à jour parmi les domaines disponibles : "
echo " "
listSite=($(plesk bin site --list))
select instance in "${listSite[@]}";
    do 
        echo -e '\e[93m=============================================\033[0m'
        echo -e "L'instance cible choisie est : \e[1;32m$instance\e[0m"
        civi_folder=$instance
    break;
done

test -e /var/www/vhosts/$civi_folder/httpdocs/sites/default/settings.php && cms_instance="drupal"
chemin_plugins_drupal="/var/www/vhosts/$civi_folder/httpdocs/sites/all/modules"  

test -e /var/www/vhosts/$civi_folder/httpdocs/wp-config.php && cms_instance="wordpress"
chemin_plugins_wordpress="/var/www/vhosts/$civi_folder/httpdocs/wp-content/plugins"  

test -e /var/www/vhosts/$civi_folder/httpdocs/private/civicrm.settings.php && cms_instance="standalone"
chemin_plugins_standalone="/var/www/vhosts/$civi_folder/httpdocs"   

export CIVICRM_SETTINGS=$vhosts/$civi_folder/httpdocs/wp-content/uploads/civicrm/civicrm.settings.php

while [ ! -e $chemin_plugins_wordpress ] && [ ! -e $chemin_plugins_drupal ] && [ ! -e $chemin_plugins_standalone ] 
do
    echo -e '\e[93m=======================================\033[0m' 
    echo -e '\e[93m\033[31m Aucun CMS valide sélectionné \033[31m'
    echo -e '\e[93m=======================================\033[0m'   
    exit 1
break 
done 
 
# echo "Voulez vous vider le dossier de sauvegardes CiviCRM ? oui (o) - non (n)"
# read response  
# if [ "$response" = "o" ] 
# then 
#     suppression_sauvegarde_civicrm  
# fi

# Affectation de variables pour affichage de version de CiviCRM
versionCIVI_WP=$(grep "define('CIVICRM_PLUGIN_VERSION'" $chemin_plugins_wordpress/civicrm/civicrm.php 2>/dev/null | awk -F"'" '{print $4}')
versionCIVI_DRUPAL=$(grep '<version_no>' $chemin_plugins_drupal/civicrm/xml/version.xml 2>/dev/null | awk -F">" '{print $2}' | awk -F"<" '{print $1}')

# Affichage de la version de CiviCRM
[ $cms_instance == "wordpress" ] && [ -e $chemin_plugins_wordpress/civicrm/civicrm.php ] && echo "La version actuelle de CiviCRM est : $versionCIVI_WP" 
[ $cms_instance == "drupal" ] && [ -e $chemin_plugins_drupal/civicrm/xml/version.xml ] && echo "La version actuelle de CiviCRM est : $versionCIVI_DRUPAL" 
[ $cms_instance == "standalone" ] && echo "Vous avez choisi de mettre à jour une version Standalone" 

echo -e '\e[93m=============================================\033[0m' 

## Choix version Prod / Beta / Alpha
echo "Voulez-vous une version Prod (p) / Beta (b) / Alpha (a)?"
read civi_type_version
echo " "

## Choix version
case $civi_type_version in
        "p")
            echo "Choisissez la version que vous souhaitez installer (X.YY.Z)  ?"
            read civi_version

            if [[ $civi_version =~ ^[0-9]*.[0-9]*.[0-9]*$ ]]
            then
                updateCivicrm civi_folder civi_version
            else
                echo -e '\e[93m=======================================\033[0m'
                echo -e '\e[93m\033[31m Ce n`est pas une version connue\033[31m'
                echo -e '\e[93m=======================================\033[0m'
                exit 1
            fi
            ;; 

        "b")
            updateCivicrm civi_folder 
            ;;

        "a")
            updateCivicrm civi_folder
            ;;

		*)
			echo "Choix incorrect"
			;;
esac
