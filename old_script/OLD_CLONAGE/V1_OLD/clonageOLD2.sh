#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam et Ilias Assadki
##
#############################################################
##
##  Clonage instance
##
#############################################################

### todo 2
#? faire un clonage de n'importe quelle instance, et voir si les deux chaines sont bein mises a jour quand on change

vhosts="/var/www/vhosts" ; mysql_server="localhost:3306"

cd $vhosts # $vhosts
source clonage/clonageV2/functions.sh 
source clonage/clonageV2/databases.sh 

## Choix de l'instance source 
echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance source que vous souhaitez cloner ?"
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

# Affichage en tableau de la/les base.s de données de $folder_clone (instance source)
plesk db "select d.name as 'Domaine source', db.name as 'Base de donnees source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'"

# Récupération des idenfifiants de l'instance source
## Wordpress - Source
while [ "$cms_instance_clone" == "wordpress" ] # while test -e $folder_clone/httpdocs/wp-config.php
	do 
    getWordpressID_clone 
done 

## Drupal - Source
while [ "$cms_instance_clone" == "drupal" ] # while test -e $folder_clone/httpdocs/sites/default/settings.php
	do
    getDrupalID_clone 
done 

# TODO : Récupération des bases de données
# getDatabaseClone (fonction)

# getCheminActuel # $vhosts

## Choix de l'instance destination
echo -e '\e[93m=============================================\033[0m'
sleep 0.8
echo "Choisissez l'instance de destination ?"
echo " "

# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_destination in "${listSite[@]}";
	do 
    echo -e '\e[93m=============================================\033[0m'
		echo -e "L'instance de destination choisie est : \e[1;32m$folder_destination\e[0m"
    echo -e '\e[93m=============================================\033[0m'
    break;
done

# Affectation de variables selon le CMS de l'instance destination
test -e $folder_destination/httpdocs/wp-config.php && cms_instance_destination="wordpress"
test -e $folder_destination/httpdocs/sites/default/settings.php && cms_instance_destination="drupal"

# Condition si $folder_clone == $folder_destination, on arrête le script 
if [ "$folder_clone" == "$folder_destination" ]
	then
    echo "L'instance source est similaire à l'instance de destination"
    echo "Sortie du script" ; echo " "
    exit 0
fi

#! Affichage en tableau de la/les base.s de données de $folder_destination (instance destination)
plesk db "select d.name as 'Domaine destination', db.name as 'Base de donnees destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'" 

# getCheminActuel ## $vhosts

## Wordpress - Destination
# Récupération des idenfifiants de l'instance destination
while [ "$cms_instance_destination" == "wordpress" ] # while test -e $folder_destination/httpdocs/wp-config.php
	do 
    getWordpressID_Destination
done

## Drupal - Destination
while [ "$cms_instance_destination" == "drupal" ] # while test -e $folder_destination/httpdocs/sites/default/settings.php
	do
    getDrupalID_Destination
done

## Instance vide - Destination
while [ -e "$folder_destination/index.html" ] || [ -z "$(ls -A $folder_destination/httpdocs)" ]
	do
    instanceVide
done

# Condition si les identifiants clone et destination sont les mêmes
if [ "$mysql_clone_user" == "$mysql_destination_user" ] && [ "$mysql_clone_mdp" == "$mysql_destination_mdp" ] && [ "$mysql_clone_database" == "$mysql_destination_database" ]
	then
    echo "Les identifiants des domaines source et destination sont similaires, veuillez restaurer $folder_clone et/ou $folder_destination"
    echo "Sortie du script" ; echo " "
		exit 0
fi 

echo -e '\e[93m===============================================\033[0m' 
echo -e '\e[1;32m Vous allez cloner '$folder_clone' vers '$folder_destination' \032'
echo -e '\e[93m================================================\033[0m' 
# getCheminActuel ## $vhosts

echo " "

# Condition pour suppression recursive du repertoire httpdocs/ de $folder_destination
echo "Faut-il vider le dossier de $folder_destination ? o(oui) ou n(non)"
read reponse
if test "$reponse" = "o" 
	then
     vidageInstance_Destination 
fi

# echo -e '\e[93m=============================================\033[0m' 
# getCheminActuel ## $vhosts
# echo -e '\e[93m=============================================\033[0m' 

echo " "

# Condition pour suppression des tables de la base de données destination
echo "Faut-il vider la base de données de $folder_destination ? o(oui) ou n(non)"
read reponse1
if test "$reponse1" = "o"
	then
    vidageBDD_Destination
	else
    echo "Démarrage du clonage"  
fi
echo -e '\e[93m=============================================\033[0m' 
echo -e '\e[93m=============================================\033[0m' 


##  Debut clonage  ## 
cd $folder_clone/httpdocs

sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > $folder_clone.sql ####
sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $folder_clone.sql
cd ..
zip -r $folder_clone.zip httpdocs/   

cd httpdocs
rm -rf $folder_clone.sql 
cd ../.. 
cp $folder_clone/httpdocs/.[!.]* $folder_destination/httpdocs/ 2> /dev/null # Copie des fichiers cachés
cd $folder_destination/httpdocs

[[ "$(ls -A /)" ]] && deleteContent || moveContent 

# Envoi du $folder_clone.zip vers l'instance destination
mv $folder_clone/$folder_clone.zip $folder_destination/httpdocs 

cd $folder_destination/httpdocs
unzip $folder_clone.zip 

## a ameliorer
cd .. 
mv httpdocs/httpdocs/* httpdocs 
cd httpdocs

# Modification des URLs dans la base de donnnées des occurences de $folder_clone vers $folder_destination
remplacementURLfichierSQL 

##sudo mysql -u $mysql_destination_user -p$mysql_destination_mdp  -D $mysql_destination_database < $folder_clone.sql
[[ ! -d "index.html" ]] && rm -rf index.html
rm -rf $folder_clone.zip # 
rm -rf $folder_clone.sql # 
 
rm -rf httpdocs

# Remplacement des occurences '@folder_destination' vers '@folder_clone', dans folder_destination.sql. Utile que dans quelque cas précis 
#? DUMP & Travail au niveau du fichier sql & PUMP
remplacement_occurences_@_dest

rm -rf $folder_destination.sql #
##  Fin clonage  ##

echo " "
echo -e '\e[93m=====================================\033[0m'
echo "La modification des URLs a été effectuée"
echo -e '\e[93m=====================================\033[0m'
# cd $vhosts  ; getCheminActuel # $vhosts 
# echo -e '\e[93m=====================================\033[0m'

cd $vhosts

# Modification des variables dans les fichiers de configuration
# Conditions pour distinguer Drupal de WordPress
# Si c'est une instance Drupal, les variables du fichier settings.php sont remplacées par les nouvelles variables destination pour Drupal 
if test -e $folder_destination/httpdocs/sites/default/settings.php
	then
		echo "CMS trouvé : Drupal"
		testDrupal 

		# si on trouve Civicrm, les variables du fichier civicrm.settings.php sont modifiées avec les nouvelles variables destination pour Drupal
		if test -e $folder_destination/httpdocs/sites/default/civicrm.settings.php
			then
				testCiviCRM_Drupal  
			else
				echo "CiviCRM pour Drupal absent"
		fi

# sinon, si c'est une instance WordPress, les variables du fichier wp-config.php sont remplacées par les nouvelles variables destination pour WordPress
elif test -e $folder_destination/httpdocs/wp-config.php
	then 
		echo "CMS trouvé : WordPress"
		testWP 
   
		# parlemonde.org (modification du fichier civicrm.settings est présent à la racine) 
		if test -e $folder_destination/httpdocs/civicrm.settings.php
			then 
				testCiviCRM_parlemonde 
		fi

		# si un fichier généré par WordFence est present (.user.ini), les variables du fichier .user.ini sont remplacées par les nouvelles variables destination pour WordPress
		if test -e $folder_destination/httpdocs/.user.ini >/dev/null 2>&1
			then
				testWordfence 
			else
				echo "Fichiers générés par WordFence absents"
		fi

		# Si on trouve Civicrm, les variables du fichier civicrm.settings.php sont remplacées avec les nouvelles variables destination pour WordPress
		if test -e $folder_destination/httpdocs/wp-content/uploads/civicrm/civicrm.settings.php
			then
				testCiviCRM_WP  
			else 
				echo "CiviCRM pour Wordpress absent de wp-content/plugins/"
		fi  

		# Si rien n'est trouvé, on retourne qu'aucun CMS n'a été trouvé
else
	echo "Aucun CMS n'a été trouvé"
fi

# Correction de la propriété des fichiers  
plesk repair fs `echo $folder_destination` -y

echo " "
echo -e '\e[93m============================================================\033[0m'
echo -e '\e[1;32m Site '$folder_clone' cloné vers '$folder_destination' \032' 
echo -e '\e[93m============================================================\033[0m'
[ -e $folder_destination/httpdocs/sites/default/settings.php ] && echo -e '\033[31m PENSER À VÉRIFIER LES FICHIERS SETTINGS.PHP AINSI QUE LE CIVICRM.SETTINGS.PHP'
[ -e $folder_destination/httpdocs/wp-config.php ] && echo -e '\033[31m PENSER À VÉRIFIER LES FICHIERS WP-CONFIG.PHP AINSI QUE LE CIVICRM.SETTINGS.PHP'
#echo -e '\033[31m PENSER À VÉRIFIER LES FICHIERS WP-CONFIG.PHP/SETTINGS.PHP AINSI QUE LE CIVICRM.SETTINGS.PHP'
echo -e '\e[0m'
echo " "
