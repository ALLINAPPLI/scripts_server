source $CUSTOM_DIR/sources/utils.sh

### Sélection d'instance et Test CMS simple
# Fonction test qui retourne un element. Comparer cet element avec le retour de la fonction 
select_and_testCMS() {
    echo "Quelle instance choisissez vous ?"

    # Récupération de la liste des 
    listSite=($(get_sites))
    select instance in "${listSite[@]}"; do
        echo -e '\e[93m=============================================\033[0m'
        echo -e "L'instance choisie est : \e[1;32m$instance\e[0m"
        echo " "
        break;
    done
	testCMS
}

### Test CMS simple
testCMS() {
	local prev_pwd=$(pwd)
	
	cd $racine
	instance=$(find -maxdepth 2 -type d -name $instance 2> /dev/null | grep -v .rapid-scan-db | grep -v system)
	test -d httpdocs && cd httpdocs && instance="$instance/httpdocs"
	cd $instance
    test -e wp-config.php && cms_instance="wordpress"
    test -e sites/default/settings.php && cms_instance="drupal"
    test -e private/civicrm.settings.php && cms_instance="standalone"
    test -e settings.php && cms_instance="backdrop"
    cd $prev_pwd
}

fonction_test() {
    select_and_testCMS

    if [ "$cms_instance" == "wordpress" ]; then
        echo "..."
    fi

    if [ "$cms_instance" == "drupal" ]; then
        echo "..."
    fi

    if [ "$cms_instance" == "standalone" ]; then
        echo "..."
    fi
}


### Installation et activation d'une ou plusieurs extensions CiviCRM, pour les nouvelles ou les mises à jour
dll() {
    cv flush
    while [ $# -gt 0 ]
        do
            #echo "Installation et activation de l'extension "$1""
            cv ext:download "$1" --force
            cv ext:enable "$1"
            shift
    done
    cv updb;
    rep
}

### Activation d'une ou plusieurs extensions CiviCRM, déjà présentes dans l'instance
en() {
    while [ $# -gt 0 ]
        do
            #echo "Activation de l'extension "$1""
            cv ext:enable "$1"
            shift
        done
    cv updb
    rep
}

### Désactivation d'une ou plusieurs extensions CiviCRM, déjà présentes dans l'instance
dis() {
    while [ $# -gt 0 ]
        do
            #echo "Désactivation de l'extension "$1""
            cv ext:disable "$1"
            shift
        done
    cv updb
    rep
}

### Désinstallation d'une ou plusieurs extensions à la suite, avec la suppression du dossier correspondant dans le dossier extensions
un() {
    while [ $# -gt 0 ]
        do
            local extension_name=$1
            local extension_key=$(cv ext:list -L --columns=key,label | grep "$extension_name" | awk '{print $2}')
                if [ -n "$extension_key" ]; then
                    chemin_extensions=$(cv ev 'echo Civi::paths()->getPath("[civicrm.files]/ext");' -q)
                    echo -e ">> Désinstallation et suppression de $extension_key..."
                    cv ext:uninstall "$1"
		            cd $chemin_extensions
                    find -regex ".*$extension_name.*" -print0 | xargs -0 rm -rf
                else
	                echo "$extension_name non trouvée."
                fi
            shift
    done
    cv updb && cv flush && rep
}

### Vidage simple du cache de CiviCRM
cvf() {
    cv flush && rep
}

### Vidage complet du cache de CiviCRM
cvff() {
    cv flush && cv api4 System.flush && cv api4 System.flush triggers=1 && rep
}

### Script pour appliquer un patch depuis Github pour CiviCRM
cvpatch() {
	local prev_pwd=$(pwd)
    instance=$(getplesksite)
    testCMS
    echo "$instance"
    if [ -z "$instance" ]; then
    	echo -e "${RED}[ERREUR]${NC} vous n'êtes pas au sein d'une instance"
    	return 1;
    fi
   	cd $racine

    if [ "$cms_instance" == "wordpress" ]; then
        cd $instance/wp-content/plugins/civicrm/civicrm/
	fi
	        
    if [ "$cms_instance" == "drupal" ]; then
        cd $instance/sites/all/modules/civicrm/
   	fi

    if [ "$cms_instance" == "standalone" ]; then
        cd $instance/core
    fi

    if [ "$cms_instance" == "backdrop" ]; then
    	cd $instance/modules/civicrm/
    fi
    apply_p
   	cd $racine/$instance    
    cv flush && rep
    cd $prev_pwd
    #rm $file_diff
}
