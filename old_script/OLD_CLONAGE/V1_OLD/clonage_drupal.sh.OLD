#!/bin/bash
##
## Développé par Renaud Fradin, Fawzy Elsam
## et Ilias Assadki
##
################################################
##
##  Clonage site
##
################################################

cd .. # vhosts/
source clonage/functions.sh

## Choix de l'instance source

echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance source ?"
echo " "
echo "Liste des domaines disponibles : "
echo " "

# Récupération de la liste des domaines 
listSite=($(plesk bin site --list))
select folder_clone in "${listSite[@]}";
    do 
        echo -e '\e[93m=============================================\033[0m'
        echo "L'instance source choisie est : $folder_clone"
        echo -e '\e[93m=============================================\033[0m'
    break;
done

cd $folder_clone

# echo "Wordpress (w) , Drupal (d) ou Autre (a) ?" 
# echo " "
# read choix

plesk db "select d.name as 'Domaine source', db.name as 'Base de donnees source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'"
echo " "
pwd # $folder_clone
echo " "

### Wordpress - Source
# while [ "$choix" == "w" ]  
while test -e httpdocs/wp-config.php
do 
    cd httpdocs/ 
    echo "Informations Wordpress - Source"
    mysql_clone_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php` # espace a remettre a la fin si ca ne fonctionne pas 
    mysql_clone_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`
    mysql_clone_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`
    echo "BDD : $mysql_clone_database"
    echo "USER : $mysql_clone_user"
    echo "MDP : $mysql_clone_mdp"
    cd .. # $folder_clone
    break
done 

### Drupal - Source
# while [ "$choix" == "d" ]
while test -e httpdocs/sites/default/settings.php
do
    cd httpdocs/sites/default/
    echo "Informations Drupal - Source"
    case $folder_clone in  
            "gestad.net")
                    ## 'database' => 'gestad',
                    bdd=`sed -n 252p settings.php` 
                    echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 253p settings.php` 
                    echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 254p settings.php` 
                    echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    echo "BDD : $mysql_clone_database"
                    echo "USER : $mysql_clone_user"
                    echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt
                    ;;
            "demo.gestad.net")
                    bdd=`sed -n 252p settings.php`
                    echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 253p settings.php`
                    echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 254p settings.php`
                    echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    echo "BDD : $mysql_clone_database"
                    echo "USER : $mysql_clone_user"
                    echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt
                    ;;
            "cnec.gestad.net")
                    bdd=`sed -n 257p settings.php`
                    echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 258p settings.php`
                    echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 259p settings.php`
                    echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    echo "BDD : $mysql_clone_database"
                    echo "USER : $mysql_clone_user"
                    echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt
                    ;;
            "sandbox.cnec.gestad.net")
                    bdd=`sed -n 256p settings.php`
                    echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 257p settings.php`
                    echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 258p settings.php`
                    echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    echo "BDD : $mysql_clone_database"
                    echo "USER : $mysql_clone_user"
                    echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt
                    ;;
            "snpmns.gestad.net")
                    bdd=`sed -n 253p settings.php`
                    echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 254p settings.php`
                    echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 255p settings.php`
                    echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    echo "BDD : $mysql_clone_database"
                    echo "USER : $mysql_clone_user"
                    echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt
                    ;;
            "sandbox.snpmns.gestad.net")
                    bdd=`sed -n 252p settings.php`
                    echo $bdd > mon_fichier_clone1.txt
                    user=`sed -n 253p settings.php`
                    echo $user > mon_fichier_clone2.txt  
                    mdp=`sed -n 254p settings.php`
                    echo $mdp > mon_fichier_clone3.txt

                    mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_clone1.txt`
                    mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_clone2.txt`
                    mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_clone3.txt`
                    echo "BDD : $mysql_clone_database"
                    echo "USER : $mysql_clone_user"
                    echo "MDP : $mysql_clone_mdp"
                    rm mon_fichier_clone1.txt
                    rm mon_fichier_clone2.txt
                    rm mon_fichier_clone3.txt 
                    ;;
    esac
    
# decommenter  en cas de probleme - DEBUT #
    # echo " "
    # echo "Nom de la base de données de l'instance source ?" 
    # echo " "
    # read mysql_clone_database
    # echo -e '\e[93m=============================================\033[0m'
    # echo -e '\e[93m=============================================\033[0m' 
    # echo "Nom de l'utilisateur de la base de données de l'instance source ?"
    # echo " "
    # read mysql_clone_user
    # echo -e '\e[93m=============================================\033[0m'
    # echo -e '\e[93m=============================================\033[0m' 
    # echo "MDP de l'utilisateur de la base de données de l'instance source ?" 
	# echo " " 
    # read mysql_clone_mdp
# decommenter en cas de probleme - FIN #

    cd ../../.. # $folder_clone/
    break
done 



## Choix de l'instance destination

## INSTANCE VIDE
## INSTANCE REMPLIE PAR LA MEME
## recuperer les credentials de l'instance dest, en SQL

echo " "
cd ..  
pwd # vhosts/

echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'
echo "Choisissez l'instance destination ?"
echo " "
echo "Liste des domaines disponibles : "
echo " "

listSite=($(plesk bin site --list))
select folder_destination in "${listSite[@]}";
    do 
        echo -e '\e[93m=============================================\033[0m'
        echo "L'instance destination choisie est : $folder_destination"
        echo -e '\e[93m=============================================\033[0m'
    break;
done

cd $folder_destination

echo -e '\e[1;32m Vous allez cloner '$folder_clone' vers '$folder_destination' \032'
echo -e '\e[93m=============================================\033[0m' 

# echo "Wordpress (w) , Drupal (d) ou Autre (a) ?" 
# echo " "
# read choix

plesk db "select d.name as 'Domaine destination', db.name as 'Base de donnees destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'" 
echo " "
pwd # $folder_destination

### Wordpress - Destination
# while [ "$choix" == "w" ]  
while test -e httpdocs/wp-config.php
do 
    cd httpdocs/ 
    echo "Informations Wordpress - Destination"
    mysql_destination_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php` # espace a remettre a la fin si ca ne fonctionne pas 
    mysql_destination_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`
    mysql_destination_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`
    echo "BDD : $mysql_destination_database"
    echo "USER : $mysql_destination_user"
    echo "MDP : $mysql_destination_mdp"
    cd .. # $folder_destination
    break
done

### --- A DECOMMENTER QUAND LE PROBLEME EST REGLE - DEBUT --- ###
## Drupal - Destination
#while [ "$choix" == "d" ]
while test -e httpdocs/sites/default/settings.php
do
    cd httpdocs/sites/default/
    echo "Informations Drupal - Destination"
    case $folder_destination in  
            "gestad.net")
                    ## 'database' => 'gestad',
                    bdd=`sed -n 252p settings.php` 
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 253p settings.php` 
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 254p settings.php` 
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    echo "BDD : $mysql_destination_database"
                    echo "USER : $mysql_destination_user"
                    echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt
                    ;;
            "demo.gestad.net")
                    bdd=`sed -n 252p settings.php`
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 253p settings.php`
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 254p settings.php`
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    echo "BDD : $mysql_destination_database"
                    echo "USER : $mysql_destination_user"
                    echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt
                    ;;
            "cnec.gestad.net")
                    bdd=`sed -n 257p settings.php`
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 258p settings.php`
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 259p settings.php`
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    echo "BDD : $mysql_destination_database"
                    echo "USER : $mysql_destination_user"
                    echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt
                    ;;
            "sandbox.cnec.gestad.net")
                    bdd=`sed -n 256p settings.php`
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 257p settings.php`
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 258p settings.php`
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    echo "BDD : $mysql_destination_database"
                    echo "USER : $mysql_destination_user"
                    echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt
                    ;;
            "snpmns.gestad.net")
                    bdd=`sed -n 253p settings.php`
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 254p settings.php`
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 255p settings.php`
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    echo "BDD : $mysql_destination_database"
                    echo "USER : $mysql_destination_user"
                    echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt
                    ;;
            "sandbox.snpmns.gestad.net")
                    bdd=`sed -n 252p settings.php`
                    echo $bdd > mon_fichier_dest1.txt
                    user=`sed -n 253p settings.php`
                    echo $user > mon_fichier_dest2.txt  
                    mdp=`sed -n 254p settings.php`
                    echo $mdp > mon_fichier_dest3.txt

                    mysql_destination_database=`grep -oP "(?<=database' => ').*(?=',)" mon_fichier_dest1.txt`
                    mysql_destination_user=`grep -oP "(?<=username' => ').*(?=',)" mon_fichier_dest2.txt`
                    mysql_destination_mdp=`grep -oP "(?<=password' => ').*(?=',)" mon_fichier_dest3.txt`
                    echo "BDD : $mysql_destination_database"
                    echo "USER : $mysql_destination_user"
                    echo "MDP : $mysql_destination_mdp"
                    rm mon_fichier_dest1.txt
                    rm mon_fichier_dest2.txt
                    rm mon_fichier_dest3.txt 
                    ;;
    esac
    
# decommenter  en cas de probleme - DEBUT #
    # echo " "
    # echo "Nom de la base de données de l'instance source ?" 
    # echo " "
    # read mysql_destination_database
    # echo -e '\e[93m=============================================\033[0m'
    # echo -e '\e[93m=============================================\033[0m' 
    # echo "Nom de l'utilisateur de la base de données de l'instance source ?"
    # echo " "
    # read mysql_destination_user
    # echo -e '\e[93m=============================================\033[0m'
    # echo -e '\e[93m=============================================\033[0m' 
    # echo "MDP de l'utilisateur de la base de données de l'instance source ?" 
	# echo " " 
    # read mysql_destination_mdp
# decommenter en cas de probleme - FIN #

    cd ../../.. # $folder_destination/
    break
done 
### --- A DECOMMENTER QUAND LE PROBLEME EST REGLE - FIN --- ###



## Instance vide - Destination
# si le httpdocs/ ne contient ni le fichier wp-config, ni le fichier /sites/default/settings.php, 
# on demande a ecrire les valeurs
FICHIER_WP=/var/www/vhosts/$folder_destination/httpdocs/wp-config.php
FICHIER_DRUPAL=/var/www/vhosts/$folder_destination/httpdocs/sites/default/settings.php
while [ ! -f "$FICHIER_WP" ] && [ ! -f "$FICHIER_DRUPAL" ] ## non existence de deux FICHIERS
#while [ ! -f "$FICHIER_WP" ] ## non existence d'un fichier
do
echo "Instance vide, veuillez ecrire les valeurs"
echo " "
echo " "
echo "Nom de la base de données de l'instance destination ?" 
echo " "
read mysql_destination_database
# plesk db "select db.name as 'Base de donnees destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'\G" > affichagebdd.txt 2> /dev/null ##
# mysql_destination_database=`grep -oP "(?<=Base de donnees destination: ).*(?=)" affichagebdd.txt`
# echo "BDD : $mysql_destination_database" ##
# rm affichagebdd.txt
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m' 
echo "Nom de l'utilisateur de la base de données de l'instance destination ?"
echo " "
read mysql_destination_user
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m' 
echo "MDP de l'utilisateur de la base de données de l'instance destination ?" 
echo " " 
read mysql_destination_mdp
echo " "   
break
done 

echo -e '\e[93m=============================================\033[0m' 
echo -e '\e[1;32m Vous allez cloner '$folder_clone' vers '$folder_destination' \032'
echo -e '\e[93m=============================================\033[0m' 


# retour au repertoire vhosts/
echo " "
cd ..  
pwd # vhosts/
echo -e '\e[93m============================================================\033[0m'

## Suppression des tables de la base de données destination, et condition sur le vidage du domaine httpdocs destination
## si oui, alors suppression des tables, sinon tout reste tel quel 


## condition pour suppression recursive du repertoire httpdocs/
echo "Faut-il vider l'instance $folder_destination ? o(oui) ou n(non)"
read reponse
if test "$reponse" = "o"
then
     vidageInstanceDestination #testing
     cd .. 
fi
echo -e '\e[93m============================================================\033[0m'
pwd # /var/www/vhosts/

## condition pour suppression des tables mysql
echo "Faut-il vider la base de données de $folder_destination ? o(oui) ou n(non)"
read reponse1
if test "$reponse1" = "o"
then
	 vidageBDDDestination
else
     echo "Démarrage du clonage"  
fi
echo -e '\e[93m============================================================\033[0m'
echo -e '\e[93m============================================================\033[0m'

cd $folder_clone/httpdocs
sudo mysqldump --user=$mysql_clone_user --password=$mysql_clone_mdp $mysql_clone_database > $folder_clone.sql
sed 's/\sDEFINER=`[^`]*`@`[^`]*`//g' -i $folder_clone.sql
cd ..
zip -r $folder_clone.zip httpdocs/

cd httpdocs
rm -rf $folder_clone.sql
cd ../.. ##
cp $folder_clone/httpdocs/.[!.]* $folder_destination/httpdocs/ 2> /dev/null ## 
cd $folder_destination/httpdocs

[[ "$(ls -A /)" ]] && deleteContent || moveContent

mv $folder_clone/$folder_clone.zip $folder_destination/httpdocs

cd $folder_destination/httpdocs
unzip $folder_clone.zip

## a ameliorer
cd ..
mv httpdocs/httpdocs/* httpdocs
cd httpdocs


## Modification des URLs dans la base de donnnées de domain.com vers alias.domain.com
##
####################################################################################

remplacementURLfichierSQL

##sudo mysql -u $mysql_destination_user -p$mysql_destination_mdp  -D $mysql_destination_database < $folder_clone.sql
[[ ! -d "index.html" ]] && rm -rf index.html
rm -rf $folder_clone.zip
rm -rf $folder_clone.sql
rm -rf httpdocs




echo "La modification des URLs a été effectuée"
echo -e '\e[93m=====================================\033[0m'


## Modification des variables dans les fichiers de configuration
##
####################################################################################

## conditions pour distinguer Drupal de WordPress

## si c'est une instance Drupal, les variables du fichier settings.php sont remplacées par les nouvelles variables destination //Drupal
 

 
#if find sites/default/ -iname "settings.php" >/dev/null 2>&1 ## >/dev/null 2>&1 annule l'affichage de la requete non reussie (1&2-> reussite d'affichage et affichage)
if test -e sites/default/settings.php
then
	testDrupal 

	## si on trouve Civicrm, les variables du fichier civicrm.settings.php sont modifiées avec les nouvelles variables destination //Drupal
	#if find -iname "civicrm.settings.php" >/dev/null 2>&1
	if test -e civicrm.settings.php
	then
		testCiviCRM_Drupal  
	else
		echo "Civicrm pour Drupal absent"
	fi
	cd ../../  ## retour au dossier httpdocs - $folder_destination/httpdocs

## sinon, si c'est une instance WordPress, les variables du fichier wp-config.php sont remplacées par les nouvelles variables destination //WordPress
#elif find -iname "wp-config.php" >/dev/null 2>&1
elif test -e wp-config.php
then 
	testWP 

	## parlemonde.org (modification du fichier civicrm.settings est présent à la racine)
	#if find -iname "civicrm.settings.php" >/dev/null 2>&1
	if test -e civicrm.settings.php
	then 
		testCiviCRM_parlemonde 
	else
		echo "Civicrm absent de la racine"
	fi

	## si un fichier généré par WordFence est present (.user.ini), les variables du fichier .user.ini sont remplacées par les nouvelles variables destination //WordPress
	#if find -iname ".user.ini" >/dev/null 2>&1
	if test -e user.ini
	then
		testWordfence 
	else
		echo "Fichier généré par WordFence absent"
	fi

	## si on trouve Civicrm, les variables du fichier civicrm.settings.php sont remplacées avec les nouvelles variables destination //WordPress
	#if find wp-content/uploads/civicrm -iname "civicrm.settings.php" >/dev/null 2>&1
	if test -e wp-content/uploads/civicrm/civicrm.settings.php
	then
		testCiviCRM_WP  
	else 
		echo "Civicrm pour Wordpress absent dans wp-content/"
	fi  
	cd ../../../
## si rien on retourne qu'aucun CMS n'a été trouvé
else
	echo "Aucun CMS n'a été trouvé"
fi


## Correction de la propriété des fichiers
##
####################################################################################

plesk repair fs `echo $folder_destination` -y

echo -e '\e[93m============================================================\033[0m'
echo -e '\e[1;32m Site '$folder_clone' cloné vers '$folder_destination' \032' 
echo -e '\e[93m============================================================\033[0m'
echo -e '\033[31m PENSER À VÉRIFIER LES FICHIER WP-CONFIG AINSI QUE LE CIVICRM.SETTINGS.PHP'


