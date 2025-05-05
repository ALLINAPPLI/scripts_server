# * Documentation : 
#  * [[ $civi_type_version == "p" || $civi_type_version == "d" ]] && commande 
#  * Si la condition '[[ $civi_type_version == "p" || $civi_type_version == "d" ]]' est validée, tout ce qui est après le '&&' est exécuté 
#  ! cd /var/www/vhosts/$civi_folder/httpdocs/sites/all/modules/civicrm.zip
# * Fin

updateCivicrm(){ 

    cd $vhosts/$civi_folder/httpdocs

    civicrm="civicrm"
    un="1"

    # Condition d'existence ou non du plugin CiviCRM dans l'instance choisie
    [ $cms_instance == "wordpress" ] && cd $chemin_plugins_wordpress && [ ! -d "civicrm" ] && echo "Le plugin CiviCRM n'est pas installé, fin du script" && exit 0
    [ $cms_instance == "drupal" ] && cd $chemin_plugins_drupal && [ ! -d "civicrm" ] && echo "Le plugin CiviCRM n'est pas installé, fin du script" && exit 0

    # Condition pour se placer dans le bon dossier contenant les plugins, et affectation de valeurs pour toutes les variables
    [ $cms_instance == "wordpress" ] && cd $chemin_plugins_wordpress && extension="zip" && [[ -e $civicrm && -n "$(ls -A $civicrm)" ]] && echo " " 
    [ $cms_instance == "drupal" ] && cd $chemin_plugins_drupal && extension="tar.gz" && [[ -e $civicrm && -n "$(ls -A $civicrm)" ]] && echo " " 
    [ $cms_instance == "standalone" ] && cd $chemin_plugins_standalone && extension="tar.gz" && echo " " #&& [[ -e $civicrm && -n "$(ls -A $civicrm)" ]] && echo " " 


    case $civi_type_version in
        "p"|"d")
            download_link="https://download.civicrm.org/civicrm-$civi_version-$cms_instance.$extension"
            civi_download=$civicrm-$civi_version-$cms_instance.$extension
        ;;
        "b")
            version_type="RC"
            download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension"
            civi_type="Beta"
            civi_download=$civicrm-$version_type-$cms_instance.$extension
        ;;
        "a")
            version_type="NIGHTLY"
            download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension"
            civi_type="Alpha"
            civi_download=$civicrm-$version_type-$cms_instance.$extension
        ;;
        *)
            echo "Pas de CMS trouvé, fin du script"
            exit 0
        ;;
    esac

    if wget --spider -q $download_link; then
        echo -e ">> la version existe bien !"
        [[ $cms_instance == "wordpress" || $cms_instance == "drupal" ]] && echo -e ">> Suppression du dossier de CiviCRM ..." && rm -rf civicrm 	
        [ $cms_instance == "standalone" ] && echo -e ">> Vidage du contenu du dossier core/* ..." && rm -rf core/*
    else
        echo -e '\e[93m=======================================\033[0m'
        echo -e '\e[93m\033[31m Aucune version de Civicrm trouvée\033[31m'
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi

    # Déclaration des variables
    echo -e ">> Téléchargement de la version ${GREEN}${civi_version:-${civi_type}}${NC} de CiviCRM ..."
    echo -e '\e[93m================================================\033[0m' ; echo " "
    wget $download_link
    echo -e '\e[93m================================================\033[0m' ; echo " "

    # Conditions sur le CMS
    if [ $cms_instance == "wordpress" ]; then
        echo ">> Décompression de l'archive dans le dossier $chemin_plugins_wordpress ..."
        cd $chemin_plugins_wordpress && unzip -qq $civi_download || unzip -qq $civi_download.$un

    elif [ $cms_instance == "drupal" ]; then
        echo ">> Décompression de l'archive dans le dossier $chemin_plugins_drupal ..."
        cd $chemin_plugins_drupal && tar -xzf $civi_download || tar -xzf $civi_download.$un

    elif [ $cms_instance == "standalone" ]; then
        echo ">> Décompression de l'archive dans le dossier $vhosts/$civi_folder/httpdocs ..."
        cd $chemin_plugins_standalone && tar -xzf $civi_download || tar -xzf $civi_download.$un
        mv $vhosts/$civi_folder/httpdocs/civicrm-standalone/core/* $vhosts/$civi_folder/httpdocs/core && rm -rf civicrm-standalone
    else
        echo "Pas de CMS trouvé, fin du script" && exit 0
    fi

    echo -e ">> Suppression de l'archive ..." && rm $civi_download 2>/dev/null

    [[ $civi_type_version == "p" || $civi_type_version == "d" ]] && echo -e ">> Installation de la version ${GREEN}$civi_version${NC} ..."
    [[ $civi_type_version == "b" || $civi_type_version == "a" ]] && echo -e ">> Installation de la version ${GREEN}$civi_type${NC} ..."

    cd $vhosts/$civi_folder/httpdocs

    # [ $cms_instance == "drupal" ] && drush pm-updatestatus civicrm && drush cc all # Check plugin status

    echo " " ; cv updb ; cv flush 
    echo " " ; echo -e ">> Plesk repair ..." && plesk repair fs $civi_folder -y 
    [[ $civi_type_version == "p" || $civi_type_version == "d" ]] && echo -e ">> Montée de version vers ${GREEN}${cms_instance}:${civi_version}${NC} effectuée" ; echo " "
    [[ $civi_type_version == "b" || $civi_type_version == "a" ]] && echo -e ">> Montée de version vers ${GREEN}${cms_instance}:${civi_type}${NC} effectuée" ; echo " "
    cd $vhosts
}
