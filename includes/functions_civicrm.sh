# * Documentation : 
#  * [[ $civi_type_version == "p" || $civi_type_version == "d" ]] && commande 
#  * Si la condition '[[ $civi_type_version == "p" || $civi_type_version == "d" ]]' est validée, tout ce qui est après le '&&' est exécuté 
#  ! cd /var/www/vhosts/$civi_folder/httpdocs/sites/all/modules/civicrm.zip
# * Fin

source $CUSTOM_DIR/includes/functions.sh
source $CUSTOM_DIR/sources/utils.sh

# Localise le vrai composer.phar (et non un wrapper shell qui pourrait être
# trouvé par erreur via "command -v composer"). Sous Plesk, le phar officiel
# est toujours à cet emplacement fixe.
_civicrmComposerPharPath(){
    local plesk_phar="/usr/local/psa/var/modules/composer/composer.phar"

    if [[ -f "$plesk_phar" ]]; then
        echo "$plesk_phar"
        return
    fi

    # Repli : si jamais ce n'est pas du Plesk, on cherche un composer.phar
    # accessible dans le PATH (mais PAS un wrapper shell comme /usr/bin/composer,
    # qui casserait l'exécution si on l'appelle via "$php_bin $composer_bin")
    local fallback
    fallback=$(command -v composer.phar 2>/dev/null)
    echo "$fallback"
}

# Détecte si l'installation CiviCRM du site (drupal10+) est pilotée par Composer.
_civicrmIsComposerManaged(){
    local site_path="$1"
    [[ -f "$site_path/composer.json" ]] && grep -Eq '"civicrm/civicrm-(core|drupal-8)"' "$site_path/composer.json" 2>/dev/null
}

# Détermine le binaire PHP à utiliser pour Composer, en fonction de la contrainte
# "php" déclarée dans le composer.json du site (ex: "8.2.*"), en cherchant le
# binaire Plesk correspondant (/opt/plesk/php/<version>/bin/php).
# Repli sur le "php" du shell si rien de trouvé.
_civicrmComposerPhpBinary(){
    local site_path="$1"
    local required major_minor candidate

    # Extrait la version PHP requise depuis le composer.json (ex: "8.2.*")
    required=$(grep -oP '"php"\s*:\s*"\K[^"]+' "$site_path/composer.json" | head -n1)
    major_minor=$(echo "$required" | grep -oP '[0-9]+\.[0-9]+' | head -n1)

    if [[ -n "$major_minor" ]]; then
        candidate="/opt/plesk/php/$major_minor/bin/php"
        if [[ -x "$candidate" ]]; then
            echo "$candidate"
            return
        fi
    fi

    # Repli : binaire PHP par défaut du shell (peut ne pas correspondre
    # à la version exigée par le site, à surveiller dans les logs)
    echo "php"
}

# Réactive le blocage Composer des paquets vulnérables (policy.advisories.block).
# Protégée par un flag pour ne s'exécuter qu'une seule fois, que ce soit :
#   - en fin de mise à jour normale (appel explicite)
#   - ou via le trap si le script est interrompu en cours de route
_civicrmRestoreComposerPolicy(){
    local php_bin="$1" composer_bin="$2"

    # Garde-fou : évite une double exécution (appel explicite + trap EXIT)
    if [[ "${_civicrm_composer_policy_restored:-0}" == "1" ]]; then
        return
    fi
    _civicrm_composer_policy_restored=1

    echo -e ">> ${PURPLE}[ SECURITE ]${NC} Réactivation du blocage Composer des paquets vulnérables (policy.advisories.block) ..."
    "$php_bin" "$composer_bin" config policy.advisories.block true --no-interaction
}

# Montée de version via Composer (Drupal 10+)
_updateCivicrmComposer(){
    local site_path="$vhosts/$civi_folder"
    local php_bin composer_bin composer_status confirm_full_update

    # Les versions Beta/Alpha n'ont pas de paquet packagist stable équivalent
    # -> pas d'automatisation possible, on stoppe proprement
    if [[ "$civi_type_version" != "p" && "$civi_type_version" != "d" ]]; then
        echo -e '\e[93m=======================================\033[0m'
        echo -e "${RED}[ ERREUR ]${NC} Les versions Beta/Alpha ne sont pas automatisées pour une installation Composer. Merci de faire cette montée de version manuellement."
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi

    # On détermine quel binaire PHP utiliser pour que Composer respecte
    # la contrainte "php" déclarée dans le composer.json du site
    php_bin=$(_civicrmComposerPhpBinary "$site_path")
    composer_bin=$(_civicrmComposerPharPath)

    if [[ -z "$composer_bin" || ! -f "$composer_bin" ]]; then
        echo -e "${RED}[ ERREUR ]${NC} composer.phar introuvable (ni sous Plesk, ni dans le PATH)"
        exit 1
    fi

    echo -e ">> Installation Composer détectée, montée de version vers ${GREEN}${civi_version}${NC} ..."
    echo -e ">> Binaire PHP utilisé : ${PURPLE}${php_bin}${NC}"
    cd "$site_path" || exit 1

    # Le script s'exécute en root : Composer désactive les plugins par sécurité
    # sauf si on l'autorise explicitement pour cette session.
    export COMPOSER_ALLOW_SUPERUSER=1

    # --- Filet de sécurité : réactivation garantie de policy.advisories.block ---
    # Le trap se déclenche sur EXIT (fin normale ou "exit" ailleurs dans le script),
    # INT (Ctrl+C) et TERM (kill), pour ne JAMAIS laisser le site sans cette
    # protection, même si le script est interrompu en plein milieu de l'opération.
    # NB : ne protège pas contre un "kill -9" (SIGKILL), qui ne peut pas être
    # intercepté par bash — limite technique inévitable.
    # Les valeurs sont volontairement interpolées avec des guillemets doubles
    # pour figer $php_bin/$composer_bin dès maintenant (ce sont des variables
    # "local", elles n'existeraient plus si le trap se déclenchait plus tard
    # hors de cette fonction).
    _civicrm_composer_policy_restored=0
    trap "_civicrmRestoreComposerPolicy \"$php_bin\" \"$composer_bin\"" EXIT INT TERM

    # --- Désactivation TEMPORAIRE du blocage des paquets affectés par une CVE ---
    # Sans ça, Composer refuse de résoudre les dépendances dès qu'un paquet
    # verrouillé (ex: symfony/polyfill-intl-idn via drupal/core-recommended)
    # est marqué comme vulnérable, même si on ne cherche pas à le mettre à jour.
    echo -e ">> ${PURPLE}[ SECURITE ]${NC} Désactivation temporaire du blocage Composer des paquets vulnérables (policy.advisories.block) le temps de la mise à jour de CiviCRM ..."
    "$php_bin" "$composer_bin" config policy.advisories.block false --no-interaction

    # --- Tentative n°1 : mise à jour ciblée sur CiviCRM UNIQUEMENT ---
    # Volontairement SANS --with-all-dependencies : on ne veut pas toucher
    # à Drupal core ni aux autres modules pour limiter les risques de conflit.
    echo -e ">> Tentative de mise à jour ciblée sur CiviCRM uniquement (sans toucher aux autres paquets) ..."
    "$php_bin" "$composer_bin" require \
        "civicrm/civicrm-core:$civi_version" \
        "civicrm/civicrm-drupal-8:$civi_version" \
        "civicrm/civicrm-packages:$civi_version" \
        --no-interaction
    composer_status=$?

    # --- Si ça échoue : c'est probablement parce que d'autres paquets ---
    # --- verrouillés (Drupal core, modules contrib...) bloquent la résolution ---
    if [[ $composer_status -ne 0 ]]; then
        echo -e '\e[93m=======================================\033[0m'
        echo -e "${RED}[ ATTENTION ]${NC} La mise à jour ciblée de CiviCRM seul a échoué."
        echo "Cela signifie probablement que d'autres dépendances verrouillées (Drupal core, modules contrib, etc.) doivent aussi être mises à jour pour résoudre les conflits."
        echo -e '\e[93m=======================================\033[0m'

        read -p "Voulez-vous autoriser la mise à jour de TOUS les paquets Drupal verrouillés pour débloquer la situation ? (o/N) " confirm_full_update

        if [[ "$confirm_full_update" =~ ^[oOyY]$ ]]; then
            # --- Tentative n°2 : on élargit la mise à jour à toutes les dépendances verrouillées ---
            echo -e ">> Nouvelle tentative avec mise à jour complète des dépendances verrouillées (--with-all-dependencies) ..."
            "$php_bin" "$composer_bin" require \
                "civicrm/civicrm-core:$civi_version" \
                "civicrm/civicrm-drupal-8:$civi_version" \
                "civicrm/civicrm-packages:$civi_version" \
                --with-all-dependencies --no-interaction
            composer_status=$?
        else
            echo -e ">> Mise à jour annulée par l'utilisateur : aucun paquet Drupal ne sera modifié."
        fi
    fi

    # --- Réactivation explicite du blocage de sécurité (chemin normal) ---
    # Le trap ci-dessus servira uniquement de filet de secours si jamais
    # on n'atteint pas cette ligne (interruption du script).
    _civicrmRestoreComposerPolicy "$php_bin" "$composer_bin"

    # On désarme le trap : la protection a déjà été restaurée normalement,
    # inutile de le laisser actif pour le reste de l'exécution du script "up"
    trap - EXIT INT TERM

    if [[ $composer_status -ne 0 ]]; then
        echo -e '\e[93m=======================================\033[0m'
        echo -e "${RED}[ ERREUR ]${NC} La mise à jour Composer de CiviCRM a échoué"
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