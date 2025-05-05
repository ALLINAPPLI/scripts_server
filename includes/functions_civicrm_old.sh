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

    ## ajouter un test sur la disponibilité de l'archive AVANT d'effacer le dossier de l'extension. Une sauvegarde ne servirait à rien, il faut juste ne pas continuer si l'archive n'existe pas et renvoyer un message adapté

    # récupérer d'abord le $download_link (quelque soit la version ou le CMS)
    # tester si la cible du download_link existe
    # si oui, on continue, si non affiche d'un message et sorti du script

    # Suppression du dossier civicrm dans le dossier de l'instance
    # [ $cms_instance == "standalone" ] && [[ $civi_type_version == "p" || $civi_type_version == "d" ]] && echo -e ">> Vidage du contenu du dossier web/core/* ..." && rm -rf web/core/* 	 ## Obsolète
    # [ $cms_instance == "standalone" ] && [[ $civi_type_version == "b" || $civi_type_version == "a" ]] && echo -e ">> Vidage du contenu du dossier core/* ..." && rm -rf core/* 	 
    # Condition selon le CMS et le choix de version choisie (Prod - Beta - Alpha), affectation de la variable $download_link
    if [[ $cms_instance == "wordpress" || $cms_instance == "drupal" ]]; then 
        # Condition de version choisie
        if [[ $civi_type_version == "p" || $civi_type_version == "d" ]]; then
            download_link="https://download.civicrm.org/civicrm-$civi_version-$cms_instance.$extension"
        elif [ $civi_type_version == "b" ]; then
            version_type="RC" && download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension" && civi_type="Beta"
        elif [ $civi_type_version == "a" ]; then
            version_type="NIGHTLY" && download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension" && civi_type="Alpha"
        else 
          echo "Pas de CMS trouvé, fin du script" && exit 0
        fi
    fi

    if [ $cms_instance == "standalone" ]; then
        if [[ $civi_type_version == "p" || $civi_type_version == "d" ]]; then
            download_link="https://download.civicrm.org/civicrm-$civi_version-$cms_instance.$extension" 
        elif [ $civi_type_version == "b" ]; then
            version_type="RC" && download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension" && civi_type="Beta"
        elif [ $civi_type_version == "a" ]; then
            version_type="NIGHTLY" && download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension" && civi_type="Alpha" 
        else 
          echo "Pas de CMS trouvé, fin du script" && exit 0
        fi
    fi



    if wget --spider -q $download_link; then
        [[ $cms_instance == "wordpress" || $cms_instance == "drupal" ]] && echo -e ">> Suppression du dossier de CiviCRM ..." && rm -rf civicrm 	
        [ $cms_instance == "standalone" ] && echo -e ">> Vidage du contenu du dossier core/* ..." && rm -rf core/*
    else
        echo -e '\e[93m=======================================\033[0m'
        echo -e '\e[93m\033[31m Aucune version de Civicrm trouvée\033[31m'
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi

  # Déclaration des variables
    civi_download_prod=$civicrm-$civi_version-$cms_instance.$extension
    civi_download_beta_alpha=$civicrm-$version_type-$cms_instance.$extension

    echo -e ">> Téléchargement de la version ${GREEN}${civi_version:-${civi_type}}${NC} de CiviCRM ..." && echo " " && wget $download_link

    echo " " ; echo -e '\e[93m================================================\033[0m' ; echo " "

    # Conditions sur le type de version choisie
    if [[ $civi_type_version == "p" || $civi_type_version == "d" ]]; then 
        # Conditions sur le CMS      
        if [ $cms_instance == "wordpress" ]; then
            echo ">> Décompression de l'archive dans le dossier $chemin_plugins_wordpress ..."
            cd $chemin_plugins_wordpress && unzip -qq $civi_download_prod || unzip -qq $civi_download_prod.$un

        elif [ $cms_instance == "drupal" ]; then
            echo ">> Décompression de l'archive dans le dossier $chemin_plugins_drupal ..."
            cd $chemin_plugins_drupal && tar -xzf $civi_download_prod || tar -xzf $civi_download_prod.$un

        elif [ $cms_instance == "standalone" ]; then
            echo ">> Décompression de l'archive dans le dossier $vhosts/$civi_folder/httpdocs ..."       
            cd $chemin_plugins_standalone && tar -xzf $civi_download_prod || tar -xzf $civi_download_prod.$un

            #!!! A REVOIR
            # Déplacement du dossier civicrm-standalone dans le bon endroit
            version_telechargee=$civicrm-$civi_version-$cms_instance
            mv $vhosts/$civi_folder/httpdocs/civicrm-standalone/core/* $vhosts/$civi_folder/httpdocs/core && rm -rf civicrm-standalone
        else
            echo "Pas de CMS trouvé, fin du script" && exit 0
        fi

        echo -e ">> Suppression de l'archive ..." && rm $civi_download_prod 2>/dev/null ; rm $civi_download_prod.$un 2>/dev/null
    fi


    # Conditions sur le type de version choisie. Télécharge le dossier dans le bon chemin
    if [[ $civi_type_version == "b" || $civi_type_version == "a" ]]; then 
        # Conditions sur le CMS
        if [ $cms_instance == "wordpress" ]; then
          echo ">> Décompression de l'archive dans le dossier $chemin_plugins_wordpress ..."
          cd $chemin_plugins_wordpress && unzip -qq $civi_download_beta_alpha || unzip -qq $civi_download_beta_alpha.$un

        elif [ $cms_instance == "drupal" ]; then
          echo ">> Décompression de l'archive dans le dossier $chemin_plugins_drupal ..."
          cd $chemin_plugins_drupal && tar -xzf $civi_download_beta_alpha || tar -xzf $civi_download_beta_alpha.$un

        elif [ $cms_instance == "standalone" ]; then
          echo ">> Décompression de l'archive dans le dossier $vhosts/$civi_folder/httpdocs ..."
          cd $chemin_plugins_standalone && tar -xzf $civi_download_beta_alpha || tar -xzf $civi_download_beta_alpha.$un

          # Déplacement du dossier civicrm-standalone dans le bon endroit
          mv $vhosts/$civi_folder/httpdocs/civicrm-standalone/core/* $vhosts/$civi_folder/httpdocs/core && rm -rf civicrm-standalone

        else 
          echo "Pas de CMS trouvé, fin du script" && exit 0
        fi
        
        echo -e ">> Suppression de l'archive ..." && rm $civi_download_beta_alpha 2>/dev/null ; rm $civi_download_beta_alpha.$un 2>/dev/null
    fi
    

    [[ $civi_type_version == "p" || $civi_type_version == "d" ]] && echo -e ">> Installation de la version ${GREEN}$civi_version${NC} ..."
    [[ $civi_type_version == "b" || $civi_type_version == "a" ]] && echo -e ">> Installation de la version ${GREEN}$civi_type${NC} ..."

    cd $vhosts/$civi_folder/httpdocs

    # [ $cms_instance == "drupal" ] && drush pm-updatestatus civicrm && drush cc all # Check plugin status

    echo " " ; cv updb ; cv flush 
    echo " " ; echo -e ">> Plesk repair ..." && plesk repair fs $civi_folder -y 
    [[ $civi_type_version == "p" || $civi_type_version == "d" ]] && echo -e ">> Montée de version vers ${GREEN}$civi_version${NC} effectuée" ; echo " "
    [[ $civi_type_version == "b" || $civi_type_version == "a" ]] && echo -e ">> Montée de version vers ${GREEN}$civi_type${NC} effectuée" ; echo " "
    cd $vhosts
}
