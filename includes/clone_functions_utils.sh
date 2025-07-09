source $CUSTOM_DIR/includes/functions.sh

display_db_size()
{
    if [ $# -lt 1 ]; then
        echo "No data base given"
        return 1;
    fi
    echo " ";
    echo -e "Taille de ${GREEN}$1${NC}";
    echo "SELECT CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' Mo') AS 'Taille de la base' FROM information_schema.TABLES;" | sql
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
	cd $HOME
    table_count=$(mysql -u "$2" -p"$3" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$1';" -s -N)

    if [ -z "$table_count" ] | [ "$table_count" -eq 0 ]; then
        echo -e "${RED}[ ERREUR ]${NC} table_count = $table_count; parameters: 2: '$2' 3: '$3' 1: '$1'"
        echo -e "${RED}[ ERREUR ]${NC} bdd déjà vide ?"
        return 0;
    fi
    echo "SET FOREIGN_KEY_CHECKS = 0;" > ./temp_vidage.sql 
    echo -e ">> Vidage de la base de données ${GREEN}$1${NC} ..."
    mysqldump --lock-tables=false --add-drop-table --no-data -u "$2" -p"$3" "$1" | grep 'DROP TABLE' >> ./temp_vidage.sql
    echo "SET FOREIGN_KEY_CHECKS = 1;" >> ./temp_vidage.sql 
    mysql -u $2 -p$3 $1 < ./temp_vidage.sql
    rm temp_vidage.sql ; echo " "
    cd $OLDPWD
}

get_bdd_from_instance() {
    echo -e "${BLUE}[ INFO ]${NC} Récupération de la base de données ${GREEN}$1${NC}...";

    if [ "$4" = "--skip-triggers" ]; then
        mysqldump --skip-triggers --user="$2" --password="$3" "$1" > "$1.sql"
    else 
        mysqldump --user="$2" --password="$3" "$1" > "$1.sql"
    fi
}

set_bdd_in_instance() {
    echo -e "${BLUE}[ INFO ]${NC} Mise à jour de la bdd ${GREEN}$1${NC} depuis le ficher ${GREEN}$4${NC}..."
    mysql --user="$2" --password="$3" "$1" < "$4"   
}

get_instance_cms ()
{
    if [ $# -lt 1 ]; then
        echo -e "${RED}[ ERREUR ]${NC} Vous devez donner une instance en parametre" >&2;
        exit 1
    fi
    local cms_instance=''
    local mysql_database=''
    local mysql_user=''

    cd $racine
	local root_domain=$(get_site_root $1)
	cd "$root_domain"

    test -e wp-config.php && cms_instance="wordpress";
    test -e sites/default/settings.php && cms_instance="drupal";
    test -e private/civicrm.settings.php && cms_instance="standalone";
    test -e settings.php && cms_instance="backdrop"


    case "$cms_instance" in
        wordpress) {
            mysql_database=`grep -oP "(?<=DB_NAME', ').*(?=')" wp-config.php`;
            mysql_user=`grep -oP "(?<=DB_USER', ').*(?=')" wp-config.php`;
            mysql_mdp=`grep -oP "(?<=DB_PASSWORD', ').*(?=')" wp-config.php`;
        };;
        drupal) {
            cd sites/default/;
            mysql_database=$(sed -n "s/^[[:space:]]*'database' => '\([^']*\)',/\1/p" settings.php | head -n 1);
            mysql_user=$(sed -n "s/^[[:space:]]*'username' => '\([^']*\)',/\1/p" settings.php | head -n 1);
            mysql_mdp=$(sed -n "s/^[[:space:]]*'password' => '\([^']*\)',/\1/p" settings.php | head -n 1);
        };;
        standalone){
            cd private/
            line=$(cat civicrm.settings.php | grep "define('CIVICRM_DSN', 'mysql" | tail -n 1)
            [[ $line =~ mysql://([^:]+):([^@]+)@([^/]+)/([^?]+) ]] && \
                mysql_user="${BASH_REMATCH[1]}" && \
                mysql_mdp="${BASH_REMATCH[2]}" && \
                mysql_database="${BASH_REMATCH[4]}"
        };;
        backdrop){
        	url=$(cat settings.php | grep "mysql://")
        	if [ $? = 0 ]; then
        		url=$(echo "$url" | sed -E "s/.*'([^']+)'.*/\1/")
        		mysql_user=$(echo "$url" | sed -E 's#mysql://([^:]+):.*@\S+/.*#\1#')
        		mysql_mdp=$(echo "$url" | sed -E 's#mysql://[^:]+:([^@]+)@\S+/.*#\1#')
        		mysql_database=$(echo "$url" | sed -E 's#.*/([^/?]+).*#\1#')
        	else
        		mysql_database=$(sed -n "s/^[[:space:]]*'database' => '\([^']*\)',/\1/p" settings.php | head -n 1);
  		        mysql_user=$(sed -n "s/^[[:space:]]*'username' => '\([^']*\)',/\1/p" settings.php | head -n 1);
        		mysql_mdp=$(sed -n "s/^[[:space:]]*'password' => '\([^']*\)',/\1/p" settings.php | head -n 1);
        	fi
        };;
        *)
            echo "No CMS !" >&2;
            return 1
        ;;
    esac
    echo "$cms_instance" "$mysql_database" "$mysql_user" "$mysql_mdp"
    return 0
}
