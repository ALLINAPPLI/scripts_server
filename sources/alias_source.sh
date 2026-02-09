###*** Liste des Aliases ***###

### Accéder au dossier scripts/
alias scripts="cd /etc/my_common/scripts_server"
alias cmd="cd /etc/my_common/scripts_server/includes"

### Aliases pour les commandes "cv"
alias cvup="test -d httpdocs && cd httpdocs ; cv updb && rep"
alias list="test -d httpdocs && cd httpdocs ; cv ext:list -L --columns=key,label,version,status" 
alias listi="test -d httpdocs && cd httpdocs ; cv ext:list -L --columns=key,label,version,status,upgrade,upgradeVersion --statuses=installed"
alias listu="test -d httpdocs && cd httpdocs ; cv ext:list -L --columns=key,label,version,status --statuses=uninstalled"
alias listd="test -d httpdocs && cd httpdocs ; cv ext:list -L --columns=key,label,version,status --statuses=disabled"
alias listup="test -d httpdocs && cd httpdocs ; cv ext:list -L --columns=key,label,version,status,upgrade,upgradeVersion --statuses=installed --upgrade=available"
alias cvs="test -d httpdocs && cd httpdocs ; cv status"
 
### Alias pour snpnc-impots
function impots()
{
    cd $racine
    cd sandbox.snpnc.org/httpdocs/snpnc-impots
}

alias deploydev="pnpm run build && pnpm run deploy:dev"
alias deployprod="pnpm run build && pnpm run deploy:prod"

### Alias pour réparer les droits sur toutes les instances
#alias repall="plesk repair fs -y"

### Aliases pour le placement dans le repertoire vhosts, ou pour lancer une commande rapidement
alias www="cd /var/www/vhosts"
alias cl="clear"

### Aliases pour les commandes du cli  "wp"
alias wpa="test -d httpdocs && cd httpdocs ; wp plugin activate "$1" --allow-root"
alias wpd="test -d httpdocs && cd httpdocs ; wp plugin deactivate "$1" --allow-root"

wpu() {
	test -d httpdocs && cd httpdocs ;
	wp plugin deactivate "$1" --allow-root;
	wp plugin uninstall "$1" --allow-root
}
alias wpc="test -d httpdocs && cd httpdocs ; wp --allow-root"
alias wpf="test -d httpdocs && cd httpdocs ; wp cache --allow-root flush"
alias wpl="test -d httpdocs && cd httpdocs ; wp plugin list --allow-root"
alias wpup="test -d httpdocs && cd httpdocs ; wp plugin update "$1" --allow-root" 
alias wpi="test -d httpdocs && cd httpdocs ; wp plugin install "$1" --allow-root --activate"
alias wpdeb="test -d httpdocs && cd httpdocs ; wp config set --raw WP_DEBUG true --allow-root && wp config set --raw WP_DEBUG_DISPLAY true --allow-root"
alias wpudeb="test -d httpdocs && cd httpdocs ; wp config set --raw WP_DEBUG false --allow-root && wp config set --raw WP_DEBUG_DISPLAY false --allow-root"
alias wpm="test -d httpdocs && cd httpdocs ; wp maintenance-mode activate --allow-root"
alias wpum="test -d httpdocs && cd httpdocs ;  wp maintenance-mode deactivate --allow-root"

### Aliases pour la modification du fichier de configuration (celui-ci)
alias bashrc="nano ~/.bashrc"
alias mbashrc="micro ~/.bashrc"
alias saverc="source ~/.bashrc"
alias aliass="format_aliases.sh $CUSTOM_DIR/includes/alias.txt"
alias m="micro"
alias malias="cd /etc/my_common/scripts_server/sources && micro alias_source.sh"
#alias maliass="cd /etc/my_common/scripts_server/sources && micro includes/alias.txt && ./setup.sh && cd -"

alias beef="test -d httpdocs && cd httpdocs ; bee cc all"

### Alias pour gérér la maintenance sur Drupal
alias dm="test -d httpdocs && cd httpdocs ; drush vset site_offline 1 && drush cache-clear all"
alias dum="test -d httpdocs && cd httpdocs ; drush vset site_offline 0 && drush cache-clear all"
