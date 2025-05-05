#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam et Ilias Assadki
##
#############################################################
##
##  Clonage d'instances
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
echo "Choisissez l'instance source que vous souhaitez cloner ?" ; echo " "
 
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

# Récupération des idenfifiants de l'instance source
while [ "$cms_instance_clone" == "wordpress" ] 
	do 
    getWordpressID_clone 
done 

while [ "$cms_instance_clone" == "drupal" ] 
	do
    getDrupalID_clone 
done 

## Choix de l'instance destination
echo -e '\e[93m=============================================\033[0m'
sleep 0.8
echo "Choisissez l'instance de destination ?" ; echo " "

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

# Condition si $folder_clone == $folder_destination, on arrête le script 
if [ "$folder_clone" == "$folder_destination" ]
	then
    echo "L'instance source est similaire à l'instance de destination"
    echo "Sortie du script" ; echo " "
    exit 0
fi

# Affichage en tableau de la/les base.s de données de $folder_destination (instance destination)
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

# Condition si les identifiants clone et destination sont les mêmes
if [ "$mysql_clone_user" == "$mysql_destination_user" ] && [ "$mysql_clone_mdp" == "$mysql_destination_mdp" ] && [ "$mysql_clone_database" == "$mysql_destination_database" ]
	then
		echo " " ; echo -e ">> [${RED}ERREUR${NC}] Les identifiants des domaines source et destination sont similaires, restaurer $folder_clone et/ou $folder_destination"	
    echo "Sortie du script" ; echo " "
		exit 0
fi 

echo -e '\e[93m===============================================\033[0m' 
echo -e "Vous allez cloner ${GREEN}$folder_clone${NC} vers ${GREEN}$folder_destination${NC}"	
echo -e '\e[93m================================================\033[0m' 

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
echo -e '\e[93m================================================\033[0m' ; echo " "

#***  Debut clonage  ***#
## Partie source
cd $vhosts/$folder_clone/httpdocs

if [[ ! -d "temp_clonage" ]]; then
		mkdir temp_clonage && cd temp_clonage
else 
		cd temp_clonage 
fi

cd $vhosts/$folder_clone

echo "> Début de l'archivage"
tar -czf - httpdocs | pv -s $(du -sb httpdocs | awk '{print $1}') > "$folder_clone.tar.gz" 

echo " "
mv $folder_clone.tar.gz $vhosts/$folder_destination

## Partie destination
cd $vhosts/$folder_destination
rm -rf httpdocs  

echo "> Début du désarchivage"
pv -s $(du -sb "$folder_clone.tar.gz" | awk '{print $1}') "$folder_clone.tar.gz" | tar -xzvf - -C $vhosts/$folder_destination > /dev/null 

echo " " ; echo -e '\e[93m================================================\033[0m' 

rm $folder_clone.tar.gz 

echo -e ">> [${GREEN}REUSSI${NC}] Archivage et désarchivage de $folder_clone effectué"

cd $vhosts/$folder_destination/httpdocs/temp_clonage  

# Modification des URLs dans la base de données des occurences de $folder_clone vers $folder_destination 
remplacementURL_BDD 
nettoyageAdressesElectroniques

#***  Fin clonage  ***#

cd $vhosts

# Modification des variables dans les fichiers de configuration (Conditions sur le CMS)
# Wordpress
while [ "$cms_instance_destination" == "wordpress" ] && ([[ "$folder_clone" != "parlemonde.org" || "$folder_clone" != "familles.sandbox.parlemonde.org" || "$folder_clone" != "prof.sandbox.parlemonde.org" || "$folder_clone" != "mediateurs.sandbox.parlemonde.org" || "$folder_clone" != "sandbox.parlemonde.org" ]])
	do 
		echo -e ">> [${WHITE}INFO${NC}] CMS : Wordpress"	
		majValeurs_Wordpress
   
		if test -e $vhosts/$folder_destination/httpdocs/.user.ini 
			then
				majValeurs_Wordfence 
			else
			  echo -e ">> [${WHITE}INFO${NC}] Fichiers générés par WordFence absents"	
		fi

		if test -e $vhosts/$folder_destination/httpdocs/wp-content/uploads/civicrm/civicrm.settings.php
			then
				majValeursCivicrm_Wordpress
			else 
			  echo -e ">> [${WHITE}INFO${NC}] CiviCRM pour Wordpress absent de wp-content/plugins/"	
		fi
  break
done

while [ "$cms_instance_destination" == "wordpress" ] && ([[ "$folder_clone" == "parlemonde.org" || "$folder_clone" == "familles.sandbox.parlemonde.org" || "$folder_clone" == "prof.sandbox.parlemonde.org" || "$folder_clone" == "mediateurs.sandbox.parlemonde.org" || "$folder_clone" == "sandbox.parlemonde.org" ]])
  do 
		echo -e ">> [${WHITE}INFO${NC}] CMS : Wordpress & instance Parlemonde"	
		majValeurs_Wordpress

		if test -e $vhosts/$folder_destination/httpdocs/.user.ini 
			then
				majValeurs_Wordfence 
			else
			  echo -e ">> [${WHITE}INFO${NC}] Fichiers générés par WordFence absents"	
		fi
  break
done

# Drupal
while [ "$cms_instance_destination" == "drupal" ] 
	do
		echo -e ">> [${WHITE}INFO${NC}] CMS : Drupal"	
		majValeurs_Drupal 

		if test -e $vhosts/$folder_destination/httpdocs/sites/default/civicrm.settings.php
			then
				majValeursCivicrm_Drupal
			else
				echo -e ">> [${WHITE}INFO${NC}] CiviCRM pour Drupal absent"	
		fi
  break
done

# Standalone
# while [ "$cms_instance_destination" == "standalone" ] 
# 	do
# 		echo -e ">> [${WHITE}INFO${NC}] CMS : Standalone"	
#   break
# done

# Aucun CMS trouvé
# while [[ "$cms_instance_destination" != "wordpress" || "$cms_instance_destination" != "drupal" ]]
#   do
#     echo -e ">> [${RED}ECHEC${NC}] Aucun CMS trouvé"
#     echo "Affichages..."
#     exit 0
# done

echo -e ">> [${GREEN}REUSSI${NC}] Modification des valeurs des fichiers de configuration effectuée" && echo " "

# Nettoyage des repertoire source et destination
cd $vhosts/$folder_clone/httpdocs && rm -rf temp_clonage && echo -e ">> [${GREEN}REUSSI${NC}] Suppression du dossier temp_clonage source effectué" && cd $vhosts 
cd $vhosts/$folder_destination/httpdocs && rm -rf temp_clonage && echo -e ">> [${GREEN}REUSSI${NC}] Suppression du dossier temp_clonage destination effectué" && cd $vhosts 

# Correction de la propriété des fichiers 
plesk repair fs `echo $folder_destination` -y && echo " " && echo -e ">> [${GREEN}REUSSI${NC}] Plesk repair"

# Condition si les identifiants clone et destination sont les mêmes
if [ "$mysql_clone_user" == "$mysql_destination_user" ] && [ "$mysql_clone_mdp" == "$mysql_destination_mdp" ] && [ "$mysql_clone_database" == "$mysql_destination_database" ]
	then
		echo " " ; echo -e ">> [${RED}ERREUR${NC}] Les identifiants des domaines source et destination sont similaires, veuillez restaurer $folder_clone et/ou $folder_destination" ; echo " "
		exit 0
fi 
	
echo " " ; echo -e ">> [${GREEN}REUSSI${NC}] Site $folder_clone bien cloné vers $folder_destination" ; echo " "

[ -e $folder_destination/httpdocs/wp-config.php ] && echo -e ">>>> [${WHITE}INFO${NC}] PENSER À VÉRIFIER LES FICHIERS WP-CONFIG.PHP AINSI QUE LE CIVICRM.SETTINGS.PHP" && echo " "
[ -e $folder_destination/httpdocs/sites/default/settings.php ] && echo -e ">>>> [${WHITE}INFO${NC}] PENSER À VÉRIFIER SETTINGS.PHP AINSI QUE LE CIVICRM.SETTINGS.PHP" && echo " "
