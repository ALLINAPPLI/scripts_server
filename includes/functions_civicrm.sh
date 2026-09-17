# * Documentation : 
#  * [[ $civi_type_version == "p" || $civi_type_version == "d" ]] && commande 
#  * Si la condition '[[ $civi_type_version == "p" || $civi_type_version == "d" ]]' est validée, tout ce qui est après le '&&' est exécuté 
#  ! cd /var/www/vhosts/$civi_folder/httpdocs/sites/all/modules/civicrm.zip
# * Fin

source $CUSTOM_DIR/includes/functions.sh
source $CUSTOM_DIR/sources/utils.sh

# ============================================================================
# TODO (futur) — Mise à jour CiviCRM via Composer pour Drupal 10+
# ----------------------------------------------------------------------------
# Ce bloc de fonctions a été testé et FONCTIONNE, mais il est volontairement
# désactivé pour le moment à cause de trop nombreux cas particuliers par site :
#   - contrainte PHP du composer.json pouvant ne pas correspondre aux versions
#     PHP réellement installées sur le serveur (ex: 8.2.* demandé, absent)
#   - dépôts VCS pointant vers GitHub nécessitant un token d'authentification
#     (composer config -g github-oauth.github.com ...)
#   - hooks "post-update-cmd" définis par certaines extensions (ex:
#     civicrm/loginsecurity) qui peuvent échouer sans que ce soit bloquant
#     (site non versionné avec Git), faussant le code de sortie de Composer
#   - risque de casser vendor/ si le script est interrompu en cours de route
#
# TODO pour réactiver :
#   1. Décommenter tout le bloc ci-dessous (entre "COMPOSER_CODE_DISABLED")
#   2. Dans le script "up", supprimer/commenter le bloc "Cas Drupal 10+ :
#      mise à jour automatisée désactivée..." qui fait un "exit 0" prématuré
#   3. Dans updateCivicrm() plus bas, remplacer l'appel à
#      _civicrmDrupal10ManualNotice par un appel à _updateCivicrmComposer
#   4. Vérifier qu'un token GitHub est configuré sur le serveur au préalable
# ============================================================================

: <<'COMPOSER_CODE_DISABLED'

# Détecte si l'installation CiviCRM du site (drupal10+) est pilotée par Composer.
_civicrmIsComposerManaged(){
    local site_path="$1"
    [[ -f "$site_path/composer.json" ]] && grep -Eq '"civicrm/civicrm-(core|drupal-8)"' "$site_path/composer.json" 2>/dev/null
}

# Localise le vrai composer.phar (et non un wrapper shell qui pourrait être
# trouvé par erreur via "command -v composer").Sous Plesk, le phar officiel
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
    command -v composer.phar 2>/dev/null
}

# Détermine le binaire PHP à utiliser pour Composer. On utilise le "php" par
# défaut du shell (celui pointé par le handler Plesk actif), plutôt que de
# chercher à faire correspondre exactement la contrainte "php" du
# composer.json : ce serveur ne dispose pas forcément de la version exacte
# demandée (ex: 8.2 absent), on contourne cette contrainte via
# --ignore-platform-req=php lors des appels Composer.
_civicrmComposerPhpBinary(){
    command -v php
}

# Réactive le blocage Composer des paquets vulnérables (policy.advisories.block).
# Protégée par un flag pour ne s'exécuter qu'une seule fois, que ce soit :
#   - en fin de mise à jour normale (appel explicite)
#   - ou via le trap si le script est interrompu en cours de route
_civicrmRestoreComposerPolicy(){
    local php_bin="$1" composer_bin="$2"

    if [[ "${_civicrm_composer_policy_restored:-0}" == "1" ]]; then
        return
    fi
    _civicrm_composer_policy_restored=1

    echo -e ">> ${PURPLE}[ SECURITE ]${NC} Réactivation du blocage Composer des paquets vulnérables (policy.advisories.block) ..."
    "$php_bin" "$composer_bin" config policy.advisories.block true --no-interaction
}

# Lit la version CiviCRM réellement présente sur le disque (source de vérité
# finale, plus fiable que le code de sortie de Composer qui peut échouer sur
# un hook tiers non bloquant).
_civicrmInstalledVersion(){
    local site_path="$1"
    local version_file
    version_file=$(find "$site_path" -maxdepth 6 -path '*/civicrm-core/xml/version.xml' 2>/dev/null | head -n1)
    [[ -z "$version_file" ]] && return 1
    grep '<version_no>' "$version_file" | sed -E 's/.*<version_no>([^<]+)<\/version_no>.*/\1/'
}

# Montée de version via Composer (Drupal 10+)
_updateCivicrmComposer(){
    local site_path="$vhosts/$civi_folder"
    local php_bin composer_bin composer_status confirm_full_update installed_version

    # Les versions Beta/Alpha n'ont pas de paquet packagist stable équivalent
    # -> pas d'automatisation possible, on stoppe proprement
    if [[ "$civi_type_version" != "p" && "$civi_type_version" != "d" ]]; then
        echo -e '\e[93m=======================================\033[0m'
        echo -e "${RED}[ ERREUR ]${NC} Les versions Beta/Alpha ne sont pas automatisées pour une installation Composer. Merci de faire cette montée de version manuellement."
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi

    php_bin=$(_civicrmComposerPhpBinary)
    composer_bin=$(_civicrmComposerPharPath)

    if [[ -z "$php_bin" ]]; then
        echo -e "${RED}[ ERREUR ]${NC} Aucun binaire PHP trouvé dans le PATH"
        exit 1
    fi

    if [[ -z "$composer_bin" || ! -f "$composer_bin" ]]; then
        echo -e "${RED}[ ERREUR ]${NC} composer.phar introuvable (ni sous Plesk, ni dans le PATH)"
        exit 1
    fi

    echo -e ">> Installation Composer détectée, montée de version vers ${GREEN}${civi_version}${NC} ..."
    echo -e ">> Binaire PHP utilisé : ${PURPLE}${php_bin}${NC}"
    echo -e ">> composer.phar utilisé : ${PURPLE}${composer_bin}${NC}"
    cd "$site_path" || exit 1

    # Le script s'exécute en root : Composer désactive les plugins par sécurité
    # sauf si on l'autorise explicitement pour cette session.
    export COMPOSER_ALLOW_SUPERUSER=1

    # --- Filet de sécurité : réactivation garantie de policy.advisories.block ---
    # Se déclenche sur EXIT (fin normale ou "exit" ailleurs), INT (Ctrl+C) et
    # TERM (kill), pour ne JAMAIS laisser le site sans cette protection.
    # NB : ne protège pas contre un "kill -9" (SIGKILL), limite technique
    # inévitable en bash.
    _civicrm_composer_policy_restored=0
    trap "_civicrmRestoreComposerPolicy \"$php_bin\" \"$composer_bin\"" EXIT INT TERM

    # --- Désactivation TEMPORAIRE du blocage des paquets affectés par une CVE ---
    echo -e ">> ${PURPLE}[ SECURITE ]${NC} Désactivation temporaire du blocage Composer des paquets vulnérables (policy.advisories.block) le temps de la mise à jour de CiviCRM ..."
    "$php_bin" "$composer_bin" config policy.advisories.block false --no-interaction

    # --- Tentative n°1 : mise à jour ciblée sur CiviCRM UNIQUEMENT ---
    # --ignore-platform-req=php : ce serveur ne dispose pas forcément de la
    # version PHP exacte déclarée dans le composer.json du site (ex: 8.2.*
    # alors que seuls 8.0/8.3/8.4/8.5 sont installés) ; on ignore cette
    # contrainte plutôt que de bloquer la mise à jour dessus.
    echo -e ">> Tentative de mise à jour ciblée sur CiviCRM uniquement (sans toucher aux autres paquets) ..."
    "$php_bin" "$composer_bin" require \
        "civicrm/civicrm-core:$civi_version" \
        "civicrm/civicrm-drupal-8:$civi_version" \
        "civicrm/civicrm-packages:$civi_version" \
        --ignore-platform-req=php \
        --no-interaction
    composer_status=$?

    if [[ $composer_status -ne 0 ]]; then
        echo -e '\e[93m=======================================\033[0m'
        echo -e "${RED}[ ATTENTION ]${NC} La mise à jour ciblée de CiviCRM seul a échoué."
        echo "Cela signifie probablement que d'autres dépendances verrouillées (Drupal core, modules contrib, etc.) doivent aussi être mises à jour pour résoudre les conflits."
        echo "Vérifie aussi qu'un token GitHub est configuré (composer config -g github-oauth.github.com ...) si l'erreur mentionne l'authentification GitHub."
        echo -e '\e[93m=======================================\033[0m'

        read -p "Voulez-vous autoriser la mise à jour de TOUS les paquets Drupal verrouillés pour débloquer la situation ? (o/N) " confirm_full_update

        if [[ "$confirm_full_update" =~ ^[oOyY]$ ]]; then
            echo -e ">> Nouvelle tentative avec mise à jour complète des dépendances verrouillées (--with-all-dependencies) ..."
            "$php_bin" "$composer_bin" require \
                "civicrm/civicrm-core:$civi_version" \
                "civicrm/civicrm-drupal-8:$civi_version" \
                "civicrm/civicrm-packages:$civi_version" \
                --with-all-dependencies \
                --ignore-platform-req=php \
                --no-interaction
            composer_status=$?
        else
            echo -e ">> Mise à jour annulée par l'utilisateur : aucun paquet Drupal ne sera modifié."
        fi

        # --- FILET DE SÉCURITÉ ---
        # Composer a pu supprimer physiquement des paquets patchés (ex: via
        # cweagans/composer-patches) avant d'échouer, sans les avoir
        # réinstallés. Le "revert" ne restaure que composer.json/lock, PAS
        # vendor/. On force donc une resynchronisation pour ne jamais laisser
        # le site cassé.
        if [[ $composer_status -ne 0 ]]; then
            echo -e ">> ${PURPLE}[ SECURITE ]${NC} Resynchronisation de vendor/ avec composer.lock (composer install) pour éviter de laisser le site dans un état cassé ..."
            "$php_bin" "$composer_bin" install --ignore-platform-req=php --no-interaction
            composer_status=$?
        fi
    fi

    # --- Réactivation explicite du blocage de sécurité (chemin normal) ---
    _civicrmRestoreComposerPolicy "$php_bin" "$composer_bin"
    trap - EXIT INT TERM

    installed_version=$(_civicrmInstalledVersion "$site_path")

    if [[ "$installed_version" == "$civi_version" ]]; then
        echo -e ">> Version CiviCRM effectivement installée sur le disque : ${GREEN}${installed_version}${NC}"
        composer_status=0
    else
        echo -e '\e[93m=======================================\033[0m'
        echo -e "${RED}[ ERREUR ]${NC} Version installée sur le disque (${installed_version:-inconnue}) différente de la version demandée (${civi_version})"
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi

    echo -e ">> Montée de version Composer vers ${GREEN}${civi_version}${NC} effectuée"
}

COMPOSER_CODE_DISABLED

# ============================================================================
# Fin du bloc Composer désactivé
# ============================================================================

updateCivicrm(){ 

    cd "$vhosts/$civi_folder"

    civicrm="civicrm"
    un="1"

    # Condition d'existence ou non du plugin CiviCRM dans l'instance choisie
    [ "$cms_instance" == "wordpress" ] && cd "$chemin_plugins" && [ ! -d "civicrm" ] && echo "Le plugin CiviCRM n'est pas installé, fin du script" && exit 0
    [ "$cms_instance" == "drupal" ] && cd "$chemin_plugins" && [ ! -d "civicrm" ] && echo "Le plugin CiviCRM n'est pas installé, fin du script" && exit 0
    [ "$cms_instance" == "backdrop" ] && cd "$chemin_plugins" && [ ! -d "civicrm" ] && echo "Le plugin CiviCRM n'est pas installé, fin du script" && exit 0

    # Condition pour se placer dans le bon dossier contenant les plugins, et affectation de valeurs pour toutes les variables
    [ "$cms_instance" == "wordpress" ] && cd "$chemin_plugins" && extension="zip" && [[ -e "$civicrm" && -n "$(ls -A "$civicrm")" ]] && echo " "
    [ "$cms_instance" == "drupal" ] && cd "$chemin_plugins" && extension="tar.gz" && [[ -e "$civicrm" && -n "$(ls -A "$civicrm")" ]] && echo " "
    [ "$cms_instance" == "standalone" ] && cd "$chemin_plugins" && extension="tar.gz" && echo " "
    [ "$cms_instance" == "backdrop" ] && cd "$chemin_plugins" && extension="tar.gz" && [[ -e "$civicrm" && -n "$(ls -A "$civicrm")" ]] && echo " "

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
        [[ "$cms_instance" == "wordpress" || "$cms_instance" == "drupal" || "$cms_instance" == "backdrop" ]] && echo -e ">> Suppression du dossier de CiviCRM ..." && rm -rf civicrm
        [ "$cms_instance" == "standalone" ] && echo -e ">> Vidage du contenu du dossier core/* ..." && rm -rf core/*
    else
        echo -e '\e[93m=======================================\033[0m'
        echo -e '\e[93m\033[31m Aucune version de Civicrm trouvée\033[31m'
        echo -e '\e[93m=======================================\033[0m'
        exit 1
    fi

    # Déclaration des variables
    echo -e ">> Téléchargement de la version ${GREEN}${civi_version:-${civi_type}}${NC} de CiviCRM ..."
    echo -e '\e[93m================================================\033[0m' ; echo " "
    wget "$download_link" -q
    echo -e '\e[93m================================================\033[0m' ; echo " "

    # Conditions sur le CMS
    if [ "$cms_instance" == "wordpress" ]; then
        echo ">> Décompression de l'archive dans le dossier $chemin_plugins ..."
        cd "$chemin_plugins" && unzip -qq "$civi_download" || unzip -qq "$civi_download.$un"

    elif [ "$cms_instance" == "drupal" ]; then
        echo ">> Décompression de l'archive dans le dossier $chemin_plugins ..."
        cd "$chemin_plugins" && tar -xzf "$civi_download" || tar -xzf "$civi_download.$un"

    elif [ "$cms_instance" == "backdrop" ]; then
        echo ">> Décompression de l'archive dans le dossier $chemin_plugins ..."
        cd "$chemin_plugins" && tar -xzf "$civi_download" || tar -xzf "$civi_download.$un"

    elif [ "$cms_instance" == "standalone" ]; then
        echo ">> Décompression de l'archive dans le dossier $chemin_plugins ..."
        cd "$chemin_plugins" && tar -xzf "$civi_download" || tar -xzf "$civi_download.$un"
        mv "$vhosts/$civi_folder/civicrm-standalone/core/"* "$vhosts/$civi_folder/core" && rm -rf civicrm-standalone
    else
        echo "Pas de CMS trouvé, fin du script" && exit 0
    fi

    echo -e ">> Suppression de l'archive ..." && rm "$civi_download" 2>/dev/null

    [[ "$civi_type_version" == "p" || "$civi_type_version" == "d" ]] && echo -e ">> Installation de la version ${GREEN}$civi_version${NC} ..."
    [[ "$civi_type_version" == "b" || "$civi_type_version" == "a" ]] && echo -e ">> Installation de la version ${GREEN}$civi_type${NC} ..."

    cd "$vhosts/$civi_folder"

    [[ "$civi_type_version" == "p" || "$civi_type_version" == "d" ]] && echo -e ">> Montée de version vers ${GREEN}${cms_instance}:${civi_version}${NC} effectuée" ; echo " "
    [[ "$civi_type_version" == "b" || "$civi_type_version" == "a" ]] && echo -e ">> Montée de version vers ${GREEN}${cms_instance}:${civi_type}${NC} effectuée" ; echo " "
    cd "$vhosts"
}