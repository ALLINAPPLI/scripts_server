
display_db_size()
{
    if [ $# -lt 1 ]; then
        echo "No data base given"
        return 1;
    fi
    echo " ";
    echo -e "Taille de ${GREEN}$1${NC}";
    plesk db "SELECT CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' Mo') AS 'Taille de la base' FROM information_schema.TABLES WHERE table_schema = '$1';"
    echo " ";
    return 0;
}

print_clone_bdd_resume()
{
    echo " ";
    echo -e "${GREEN}Identifiants $1 : ${NC}";
    echo "BDD  : $2";
    echo "USER : $3";
    echo "MDP  : $4";
    echo " ";
}

vidage_bdd() {
    table_count=$(mysql -u "$2" -p"$3" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$1';" -s -N)

    if [ -z "$table_count" ] | [ "$table_count" -eq 0 ]; then
        echo -e "${RED}[ ERREUR ]${NC} table_count = $table_count; parameters: 2: '$2' 3: '$3' 1: '$1'"
        echo -e "${RED}[ ERREUR ]${NC} bdd déjà vide ?"
        return 0;
    fi
    # Tentative de connexion et dump des tables sans données
    echo "SET FOREIGN_KEY_CHECKS = 0;" > ./temp_vidage.sql 
    echo -e ">> Vidage de la base de données ${GREEN}$1${NC} ..."
    sudo mysqldump --lock-tables=false --add-drop-table --no-data -u "$2" -p"$3" "$1" | grep 'DROP TABLE' >> ./temp_vidage.sql
    echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./temp_vidage.sql 
    sudo mysql -u $2 -p$3 $1 < ./temp_vidage.sql
    rm temp_vidage.sql ; echo " "
}

get_bdd_from_instance() {
    echo -e "${BLUE}[ INFO ]${NC} Récupération de la base de données ${GREEN}$1${NC}...";

    if [ "$4" = "--skip-triggers" ]; then
        sudo mysqldump --skip-triggers --user="$2" --password="$3" "$1" > "$1.sql"
    else 
        sudo mysqldump --user="$2" --password="$3" "$1" > "$1.sql"
    fi
}

set_bdd_in_instance() {
    echo -e "${BLUE}[ INFO ]${NC} Mise à jour de la bdd ${GREEN}$1${NC} depuis le ficher ${GREEN}$4${NC}..."
    sudo mysql --user="$2" --password="$3" "$1" < "$4"   
}

get_instance_cms ()
{
    if [ $# -lt 1 ]; then
        echo -e "${RED}[ ERREUR ]${NC} Vous devez donner une instance en parametre" >&2;
        exit 1
    fi
    cms_instance=''
    mysql_database=''
    mysql_user=''
    test -e $racine/$1/httpdocs/wp-config.php && cms_instance="wordpress";
    test -e $racine/$1/httpdocs/sites/default/settings.php && cms_instance="drupal";
    test -e $racine/$1/httpdocs/private/civicrm.settings.php && cms_instance="standalone";
    test -e $racine/$1/httpdocs/settings.php && cms_instance="backdrop"

    case "$cms_instance" in
        wordpress) {
            cd $racine/$1/httpdocs/;
            mysql_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php`;
            mysql_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`;
            mysql_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`;
        };;
        drupal) {
            cd $racine/$1/httpdocs/sites/default/;
            mysql_database=$(sed -n "s/^[[:space:]]*'database' => '\([^']*\)',/\1/p" settings.php | head -n 1);
            mysql_user=$(sed -n "s/^[[:space:]]*'username' => '\([^']*\)',/\1/p" settings.php | head -n 1);
            mysql_mdp=$(sed -n "s/^[[:space:]]*'password' => '\([^']*\)',/\1/p" settings.php | head -n 1);
        };;
        standalone){
            cd $racine/$1/httpdocs/private/
            line=$(cat civicrm.settings.php | grep "define('CIVICRM_DSN', 'mysql" | tail -n 1)
            echo -e "${BLUE}[ INFO ]${NC} line grep: $line" >&2
            [[ $line =~ mysql://([^:]+):([^@]+)@([^/]+)/([^?]+) ]] && \
                mysql_user="${BASH_REMATCH[1]}" && \
                mysql_mdp="${BASH_REMATCH[2]}" && \
                mysql_database="${BASH_REMATCH[4]}"
        };;
        backdrop){
        	cd $racine/$1/httpdocs
        	credentials_and_db="${url#mysql://}"; creds="${credentials_and_db%@*}"
        	# Extraire la partie après @ (host/bdd), puis juste le bdd
        	bdd="${credentials_and_db#*@}"; bdd="${bdd#*/}"
        	# Séparer user et mdp
        	user="${creds%%:*}"; mdp="${creds#*:}"
        };;
        *)
            echo "No CMS !" >&2;
            return 1
        ;;
    esac
    echo "$cms_instance" "$mysql_database" "$mysql_user" "$mysql_mdp"
    return 0
}
