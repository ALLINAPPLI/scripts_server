# * Documentation : 
#  * [[ $civi_type_version == "p" || $civi_type_version == "d" ]] && commande 
#  * Si la condition '[[ $civi_type_version == "p" || $civi_type_version == "d" ]]' est validée, tout ce qui est après le '&&' est exécuté 
#  ! cd /var/www/vhosts/$civi_folder/httpdocs/sites/all/modules/civicrm.zip
# * Fin

source $CUSTOM_DIR/includes/functions.sh
source $CUSTOM_DIR/sources/utils.sh

# Détecte si l'installation CiviCRM du site (drupal10+) est pilotée par Composer.
_civicrmIsComposerManaged(){
    local site_path="$1"
    [[ -f "$site_path/composer.json" ]] && grep -Eq '"civicrm/civicrm-(core|drupal-8)"' "$site_path/composer.json" 2>/dev/null
}

# Montée de version via Composer (Drupal 10+)
_updateCivicrmComposer(){
    local site_path="$vhosts/$civi_folder"

    if [[ "$civi_type_version" != "p" && "$civi_type_version" != "d" ]]; then
        echo -e '\e[93m=======================================\033[0m'
        echo -e "${RED}[ ERREUR ]${NC} Les versions Beta/Alpha ne sont pas automatisées pour une installation Composer (pas de paquet packagist correspondant). Merci de faire cette montée de version manuellement."
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi

    echo -e ">> Installation Composer détectée, montée de version vers ${GREEN}${civi_version}${NC} ..."
    cd "$site_path" || exit 1

    # ⚠️ À vérifier / adapter selon les paquets réellement déclarés dans votre composer.json
    composer require \
        "civicrm/civicrm-core:$civi_version" \
        "civicrm/civicrm-drupal-8:$civi_version" \
        "civicrm/civicrm-packages:$civi_version" \
        --update-with-dependencies --no-interaction

    if [[ $? -ne 0 ]]; then
        echo -e '\e[93m=======================================\033[0m'
        echo -e "${RED}[ ERREUR ]${NC} La mise à jour Composer a échoué"
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi

    echo -e ">> Montée de version Composer vers ${GREEN}${civi_version}${NC} effectuée"
}

updateCivicrm(){
    cd "$vhosts/$civi_folder" || exit 1

    civicrm="civicrm"
    un="1"

    # --- Cas Drupal 10+ : toujours via Composer, ou erreur explicite ---
    if [[ "$cms_instance" == "drupal10+" ]]; then
        if _civicrmIsComposerManaged "$vhosts/$civi_folder"; then
            _updateCivicrmComposer
            return
        else
            echo -e '\e[93m=======================================\033[0m'
            echo -e "${RED}[ ERREUR ]${NC} Site Drupal 10+ sans composer.json CiviCRM détecté."
            echo "CiviCRM ne fournit plus d'archive tarball pour Drupal 10+ : une installation Composer est requise pour automatiser la mise à jour."
            echo -e '\e[93m=======================================\033[0m'
            exit 1
        fi
    fi

    # --- Vérification que le plugin CiviCRM est déjà présent (wordpress / drupal7 / backdrop) ---
    case "$cms_instance" in
        wordpress)  cd "$chemin_plugins_wordpress"  || exit 1 ;;
        drupal)     cd "$chemin_plugins_drupal"     || exit 1 ;;
        backdrop)   cd "$chemin_plugins_backdrop"   || exit 1 ;;
        standalone) cd "$chemin_plugins_standalone" || exit 1 ;;
    esac

    if [[ "$cms_instance" != "standalone" && ! -d "$civicrm" ]]; then
        echo "Le plugin CiviCRM n'est pas installé, fin du script"
        exit 0
    fi

    # --- Extension d'archive selon le CMS ---
    case "$cms_instance" in
        wordpress) extension="zip" ;;
        drupal|backdrop|standalone) extension="tar.gz" ;;
    esac

    case "$civi_type_version" in
        "p"|"d")
            download_link="https://download.civicrm.org/civicrm-$civi_version-$cms_instance.$extension"
            civi_download="$civicrm-$civi_version-$cms_instance.$extension"
            ;;
        "b")
            version_type="RC"
            download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension"
            civi_type="Beta"
            civi_download="$civicrm-$version_type-$cms_instance.$extension"
            ;;
        "a")
            version_type="NIGHTLY"
            download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension"
            civi_type="Alpha"
            civi_download="$civicrm-$version_type-$cms_instance.$extension"
            ;;
        *)
            echo "Pas de CMS trouvé, fin du script"
            exit 0
            ;;
    esac

    if wget --spider -q "$download_link"; then
        echo -e ">> la version existe bien !"
        [[ "$cms_instance" == "wordpress" || "$cms_instance" == "drupal" || "$cms_instance" == "backdrop" ]] && \
            echo -e ">> Suppression du dossier de CiviCRM ..." && rm -rf civicrm
        [[ "$cms_instance" == "standalone" ]] && \
            echo -e ">> Vidage du contenu du dossier core/* ..." && rm -rf core/*
    else
        echo -e '\e[93m=======================================\033[0m'
        echo -e '\e[93m\033[31m Aucune version de Civicrm trouvée\033[31m'
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi

    echo -e ">> Téléchargement de la version ${GREEN}${civi_version:-${civi_type}}${NC} de CiviCRM ..."
    echo -e '\e[93m================================================\033[0m' ; echo " "
    wget "$download_link" -q
    echo -e '\e[93m================================================\033[0m' ; echo " "

    case "$cms_instance" in
        wordpress)
            echo ">> Décompression de l'archive dans le dossier $chemin_plugins_wordpress ..."
            cd "$chemin_plugins_wordpress" && (unzip -qq "$civi_download" || unzip -qq "$civi_download.$un")
            ;;
        drupal)
            echo ">> Décompression de l'archive dans le dossier $chemin_plugins_drupal ..."
            cd "$chemin_plugins_drupal" && (tar -xzf "$civi_download" || tar -xzf "$civi_download.$un")
            ;;
        backdrop)
            echo ">> Décompression de l'archive dans le dossier $chemin_plugins_backdrop ..."
            cd "$chemin_plugins_backdrop" && (tar -xzf "$civi_download" || tar -xzf "$civi_download.$un")
            ;;
        standalone)
            echo ">> Décompression de l'archive dans le dossier $vhosts/$civi_folder/httpdocs ..."
            cd "$chemin_plugins_standalone" && (tar -xzf "$civi_download" || tar -xzf "$civi_download.$un")
            mv "$vhosts/$civi_folder/civicrm-standalone/core/"* "$vhosts/$civi_folder/core" && rm -rf civicrm-standalone
            ;;
        *)
            echo "Pas de CMS trouvé, fin du script"
            exit 0
            ;;
    esac

    echo -e ">> Suppression de l'archive ..." && rm "$civi_download" 2>/dev/null

    [[ "$civi_type_version" == "p" || "$civi_type_version" == "d" ]] && echo -e ">> Installation de la version ${GREEN}$civi_version${NC} ..."
    [[ "$civi_type_version" == "b" || "$civi_type_version" == "a" ]] && echo -e ">> Installation de la version ${GREEN}$civi_type${NC} ..."

    cd "$vhosts/$civi_folder"

    [[ "$civi_type_version" == "p" || "$civi_type_version" == "d" ]] && { echo -e ">> Montée de version vers ${GREEN}${cms_instance}:${civi_version}${NC} effectuée"; echo " "; }
    [[ "$civi_type_version" == "b" || "$civi_type_version" == "a" ]] && { echo -e ">> Montée de version vers ${GREEN}${cms_instance}:${civi_type}${NC} effectuée"; echo " "; }
    cd "$vhosts"
}