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

cd ..
source clonage/functions.sh

## Récupération de la liste des domaines 
########################################

echo -e '\e[93m=============================================\033[0m'
echo "Liste des domaines disponibles : "
echo " "
listSite=$(plesk bin site --list);
echo ${listSite[@]}
echo " "
echo "Quelle est l'instance source ?"
echo " "
read folder_clone
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'
echo "Nom de la base de données de l'instance source ?"
read mysql_clone_database
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'
echo "Nom de l'utilisateur de la base de données de l'instance source ?"
read mysql_clone_user
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'
echo "MDP de l'utilisateur de la base de données de l'instance source ?"
read mysql_clone_mdp
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'
echo " "
echo "Liste des domaines disponibles : "
echo " "
listSite=$(plesk bin site --list);
echo ${listSite[@]}
echo " "
echo "Quelle est l'instance cible ?"
echo " "
read folder_destination
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'
echo "Nom de la base de données de l'instance cible ?"
read mysql_destination_database
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'
echo "Nom de l'utilisateur de la base de données de l'instance cible ?"
read mysql_destination_user
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'
echo "MDP de l'utilisateur de la base de données de l'instance cible ?"
read mysql_destination_mdp
echo -e '\e[93m=============================================\033[0m'

## ------------------------------------------------------------------------------- ##

## LIGNES COMMENTEES CAR PROBLEME (DEBUT) ##

## Choix de l'instance source


# echo -e '\e[93m=============================================\033[0m'
# echo "Choisissez l'instance source ?"
# echo " "
# echo "Liste des domaines disponibles : "
# echo " "

# listSite=($(plesk bin site --list))
# select folder_clone in "${listSite[@]}";
#     do 
#         echo -e '\e[93m=============================================\033[0m'
#         echo "L'instance source choisie est : $folder_clone"
#         echo -e '\e[93m=============================================\033[0m'
#     break;
# done

# cd $folder_clone/httpdocs/

# # echo "Wordpress (w) , Drupal (d) ou Autre (a) ?" 
# # echo " "
# # read choix

# # pwd # a decommenter si besoin, commande qui sert à voir le chemin

# #echo -e '\e[93m=============================================\033[0m' 
# # plesk db "select d.name as 'Domaine', db.name as 'Base de donnee' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'"
# # plesk db "select d.name as 'Domaine source' from domains d where d.name='$folder_clone'" 
# plesk db "select d.name as 'Domaine source', db.name as 'Base de donnees source' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_clone'"
# echo " "
# #echo -e '\e[93m=============================================\033[0m'

# ### Wordpress 
# # while [ "$choix" == "w" ]  ## plus tard --> faire le test d'existence de fichiers pour WP
# while test -e wp-config.php
# do 
#     echo "Informations"
#     cd $folder_clone/httpdocs/ >/dev/null 2>&1
#     mysql_clone_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php` # espace a remettre a la fin si ca ne fonctionne pas 
#     mysql_clone_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`
#     mysql_clone_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`
#     echo "BDD : $mysql_clone_database"
#     echo "USER : $mysql_clone_user"
#     echo "MDP : $mysql_clone_mdp"
#     break
# done
# # echo " "

# ### Drupal
# # while [ "$choix" == "d" ] ## plus tard --> faire le test d'existence de fichiers pour Drupal
# while test -e sites/default/settings.php
# do
#     cd sites/default/
#     echo "Infos BDD a copier"
#     case $folder_clone in
#             "gestad.net")
#             ## 'database' => 'gestad',
#                     bdd=`sed -n 252p settings.php` 
#                     user=`sed -n 253p settings.php`  
#                     mdp=`sed -n 254p settings.php` 
#                     echo $bdd
#                     echo $user
#                     echo $mdp
#                     ;;
#             "demo.gestad.net")
#                     bdd=`sed -n 252p settings.php`
#                     user=`sed -n 253p settings.php`
#                     mdp=`sed -n 254p settings.php`
#                     echo $bdd
#                     echo $user
#                     echo $mdp
#                     ;;
#             "cnec.gestad.net")
#                     bdd=`sed -n 257p settings.php` 
#                     user=`sed -n 258p settings.php` 
#                     mdp=`sed -n 259p settings.php`
#                     echo $bdd
#                     echo $user
#                     echo $mdp 
#                     ;;
#             "sandbox.cnec.gestad.net")
#                     bdd=`sed -n 256p settings.php` 
#                     user=`sed -n 257p settings.php` 
#                     mdp=`sed -n 258p settings.php`
#                     echo $bdd
#                     echo $user
#                     echo $mdp 
#                     ;;
#             "snpmns.gestad.net")
#                     bdd=`sed -n 253p settings.php`
#                     user=`sed -n 254p settings.php` 
#                     mdp=`sed -n 255p settings.php`
#                     echo $bdd
#                     echo $user
#                     echo $mdp 
#                     ;;
#             "sandbox.snpmns.gestad.net")
#                     bdd=`sed -n 252p settings.php` 
#                     user=`sed -n 253p settings.php` 
#                     mdp=`sed -n 254p settings.php`
#                     echo $bdd
#                     echo $user
#                     echo $mdp 
#                     ;;
#     esac
    
#     echo "Nom de la base de données de l'instance source ?" 
#     echo " "
#     read mysql_clone_database
#     echo -e '\e[93m=============================================\033[0m'
#     echo -e '\e[93m=============================================\033[0m' 
#     echo "Nom de l'utilisateur de la base de données de l'instance source ?"
#     echo " "
#     read mysql_clone_user
#     echo -e '\e[93m=============================================\033[0m'
#     echo -e '\e[93m=============================================\033[0m' 
#     echo "MDP de l'utilisateur de la base de données de l'instance source ?" 
# 	echo " " 
#     read mysql_clone_mdp
# 	echo " " 
#     break

#     # echo " "
#     # echo -e '\e[93m=============================================\033[0m'
#     # echo -e '\e[93m=============================================\033[0m'
#     # echo "Nom de la base de données de l'instance source ?" 
#     # echo " "
#     # read mysql_clone_database 
#     # if grep -w "$mysql_clone_database" "settings.php" >/dev/null 2>&1 # if n°1 
#     # then 
#     #     echo "Bon" 
#     #     # break
#     # else 
#     #     echo "Réessayez"
#     # fi # fi n°1 



#     # echo "Informations"
#     # cd sites/default
#     # mysql_clone_database=`grep -oP "(?<=database' => ').*(?=',)" settings.php`
#     # mysql_clone_user=`grep -oP "(?<=username' => ').*(?=',)" settings.php`
#     # mysql_clone_mdp=`grep -oP "(?<=password' => ').*(?=',)" settings.php`
#     # echo "BDD : $mysql_clone_database"
#     # echo "USER : $mysql_clone_user"
#     # echo "MDP : $mysql_clone_mdp"
#     # break
# done 


# ##### a decommenter une fois le probleme trouvé !! #####

# # while [ "$choix" == "d" ] 
# # while test -e sites/default/settings.php
# # do
# #     cd sites/default/ ##
# #     echo "User BDD a copier"
# #     case $folder_clone in
# #             "gestad.net")
# #                     sed -n 253p settings.php 
# #                     ;;
# #             "demo.gestad.net")
# #                     sed -n 253p settings.php 
# #                     ;;
# #             "cnec.gestad.net")
# #                     sed -n 258p settings.php 
# #                     ;;
# #             "sandbox.cnec.gestad.net")
# #                     sed -n 257p settings.php 
# #                     ;;
# #             "snpmns.gestad.net")
# #                     sed -n 254p settings.php 
# #                     ;;
# #             "sandbox.snpmns.gestad.net")
# #                     sed -n 253p settings.php 
# #                     ;;
# #     esac

# #     echo " "
# # 	echo -e '\e[93m=============================================\033[0m'
# #     echo -e '\e[93m=============================================\033[0m'
# #     echo "Nom de l'utilisateur de la base de données de l'instance source ?"
# #     echo " "
# #     read mysql_clone_user
# # 	echo " " 

# #     # echo " "
# #     # echo -e '\e[93m=============================================\033[0m'
# #     # echo -e '\e[93m=============================================\033[0m'
# #     # echo "Nom de l'utilisateur de la base de données de l'instance source ?" 
# # 	# echo " " 
# #     # read mysql_clone_user
# #     # if grep -w "$mysql_clone_user" "settings.php" >/dev/null 2>&1 # if n°1 
# #     # then 
# #     #     echo "Bon" 
# #     #     # break
# #     # else 
# #     #     echo "Réessayez"
# #     # fi # fi n°1 
# #     break
# # done 

# # # while [ "$choix" == "d" ] 
# # while test -e sites/default/settings.php 
# # do 
# #     cd sites/default/
# #     echo "MDP BDD a copier"
# #     case $folder_clone in
# #             "gestad.net")
# #                     sed -n 254p settings.php 
# #                     ;;
# #             "demo.gestad.net")
# #                     sed -n 254p settings.php 
# #                     ;;
# #             "cnec.gestad.net")
# #                     sed -n 259p settings.php 
# #                     ;;
# #             "sandbox.cnec.gestad.net")
# #                     sed -n 258p settings.php 
# #                     ;;
# #             "snpmns.gestad.net")
# #                     sed -n 255p settings.php 
# #                     ;;
# #             "sandbox.snpmns.gestad.net")
# #                     sed -n 254p settings.php 
# #                     ;;
# #     esac
    
# #     echo " "
# #     echo -e '\e[93m=============================================\033[0m'
# #     echo -e '\e[93m=============================================\033[0m'
# #     echo "MDP de l'utilisateur de la base de données de l'instance source ?"
# # 	echo " " 
# #     read mysql_clone_mdp
# # 	echo " " 

# #     # echo " "
# #     # echo -e '\e[93m=============================================\033[0m'
# #     # echo -e '\e[93m=============================================\033[0m' 
# #     # echo "MDP de l'utilisateur de la base de données de l'instance source ?" 
# # 	# echo " " 
# #     # read mysql_clone_mdp
# #     # if grep -w "$mysql_clone_mdp" "settings.php" >/dev/null 2>&1 # if n°1 
# #     # then 
# #     #     echo "Bon" 
# #     #     # break
# #     # else 
# #     #     echo "Réessayez"
# #     # fi # fi n°1 
# #     break
# # done 


# ## Choix de l'instance destination

# ## INSTANCE VIDE
# ## INSTANCE REMPLIE PAR LA MEME
# ## recuperer les credentials de l'instance dest

# echo -e '\e[93m=============================================\033[0m'
# echo -e '\e[93m=============================================\033[0m'
# echo "Choisissez l'instance destination ?"
# echo " "
# echo "Liste des domaines disponibles : "
# echo " "

# listSite=($(plesk bin site --list))
# select folder_destination in "${listSite[@]}";
#     do 
#         echo -e '\e[93m=============================================\033[0m'
#         echo "L'instance destination choisie est : $folder_destination"
#     break;
# done
 
# # echo "Wordpress (w) , Drupal (d) ou Autre (a) ?" 
# # echo " "
# # read choix
# echo -e '\e[93m=============================================\033[0m' 
# # plesk db "select d.name as 'Domaine', db.name as 'Base de donnee' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'"
# plesk db "select d.name as 'Domaine destination', db.name as 'Base de donnees destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'" 
# echo " "

# echo "Nom de la base de données de l'instance destination ?" 
# echo " "
# read mysql_destination_database
# # plesk db "select db.name as 'Base de donnees destination' from data_bases db,domains d,clients c where d.cl_id=c.id and db.dom_id=d.id and d.name='$folder_destination'\G" > affichagebdd.txt 2> /dev/null ##
# # mysql_destination_database=`grep -oP "(?<=Base de donnees destination: ).*(?=)" affichagebdd.txt`
# # echo "BDD : $mysql_destination_database" ##
# # rm affichagebdd.txt
# echo -e '\e[93m=============================================\033[0m'
# echo -e '\e[93m=============================================\033[0m' 
# echo "Nom de l'utilisateur de la base de données de l'instance destination ?"
# echo " "
# read mysql_destination_user
# echo -e '\e[93m=============================================\033[0m'
# echo -e '\e[93m=============================================\033[0m' 
# echo "MDP de l'utilisateur de la base de données de l'instance destination ?" 
# echo " " 
# read mysql_destination_mdp
# echo " "
# break

# echo " "
# echo -e '\e[93m============================================================\033[0m'
# echo -e '\e[1;32m Vous allez cloner '$folder_clone' vers '$folder_destination' \032'
# echo -e '\e[93m============================================================\033[0m'
# echo " "


## LIGNES COMMENTEES CAR PROBLEME (FIN) ##

## ------------------------------------------------------------------------------- ##


# retour au repertoire vhosts/
#cd ../..
pwd 
#echo -e '\e[93m============================================================\033[0m'

## Suppression des tables de la base de données destination, et condition sur le vidage du domaine httpdocs destination
## si oui, alors suppression des tables, sinon tout reste tel quel 

## condition pour suppression du repertoires httpdocs et ses sous repertoires
echo "Faut-il vider l'instance $folder_destination ? o(oui) ou n(non)"
read reponse
if test "$reponse" = "o"
then
     vidageInstanceDestination
     cd ..
     pwd
fi
pwd
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'

## condition pour suppression des tables mysql
echo "Faut-il vider la base de données de $folder_destination ? o(oui) ou n(non)"
read reponse1
if test "$reponse1" = "o"
then
	 vidageBDDDestination
else
     echo "Démarrage du clonage"  
fi
echo -e '\e[93m=============================================\033[0m'
echo -e '\e[93m=============================================\033[0m'

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
 
if find sites/default/ -iname "settings.php" >/dev/null 2>&1 ## >/dev/null 2>&1 annule l'affichage de la requete non reussie (1&2-> reussite d'affichage et affichage)
then
	testDrupal 

	## si on trouve Civicrm, les variables du fichier civicrm.settings.php sont modifiées avec les nouvelles variables destination //Drupal
	if find -iname "civicrm.settings.php" >/dev/null 2>&1
	then
		testCiviCRM_Drupal  
	else
		echo "Civicrm pour drupal absent"
	fi
	cd ../../  ## retour au dossier httpdocs - $folder_destination/httpdocs

## sinon, si c'est une instance WordPress, les variables du fichier wp-config.php sont remplacées par les nouvelles variables destination //WordPress
elif find -iname "wp-config.php" >/dev/null 2>&1
then 
	testWP 

	## parlemonde.org (modification du fichier civicrm.settings est présent à la racine)
	if find -iname "civicrm.settings.php" >/dev/null 2>&1
	then 
		testCiviCRM_parlemonde 
	else
		echo "Civicrm absent de la racine"
	fi

	## si un fichier généré par WordFence est present (.user.ini), les variables du fichier .user.ini sont remplacées par les nouvelles variables destination //WordPress
	if find -iname ".user.ini" >/dev/null 2>&1
	then
		testWordfence 
	else
		echo "Fichier généré par WordFence absent"
	fi

	## si on trouve Civicrm, les variables du fichier civicrm.settings.php sont remplacées avec les nouvelles variables destination //WordPress
	if find wp-content/uploads/civicrm -iname "civicrm.settings.php" >/dev/null 2>&1
	then
		testCiviCRM_WP  
	else 
		echo "Civicrm pour wordpress absent dans le wp-content"
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
