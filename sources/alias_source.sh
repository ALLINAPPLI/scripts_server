###*** Liste des Aliases ***###

# Acceder au dossier scripts/
alias scripts="cd /home/scripts"
alias cmd="/root/custom_cmds/includes"

### Aliases pour lancer un des scripts
# alias clone="cd /home/scripts ; ./clonage.sh" ## Lancement du script de clonage d'instances
# alias up="cd /home/scripts ; ./civi_update.sh" ## Lancement du script civi-update.sh, pour la mise a jour de versions civicrm de l'instance que l'on souhaite # && cv upgrade:db && cv updb
# alias backup="cd /home/scripts ; ./save.sh" ## Lancement du script de sauvegarde d'instances
# alias clonebdd="cd /home/scripts ; ./clonage_bdd.sh" ## Lancement du script de clonage de base de données
# alias remp="cd /home/scripts ; ./remplacement_valeurs_bdd.sh" ## Lancement du script de remplacement de valeurs dans base de données
# alias vidage="cd /home/scripts ; ./vidage.sh" ## Lancement du script de vidage de BDD

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
alias repall="plesk repair fs -y"

### Aliases pour le placement dans le repertoire vhosts, ou pour lancer une commande rapidement
alias www="cd /var/www/vhosts"
alias cl="clear"
### Aliases pour les commandes du cli  "wp"
# function wpf()
# {
#     wp cache --allow-root flush && rep
# }

alias wpa="test -d httpdocs && cd httpdocs ; wp plugin activate "$1" --allow-root"
alias wpd="test -d httpdocs && cd httpdocs ; wp plugin deactivate "$1" --allow-root"

wpu() {
	test -d httpdocs && cd httpdocs ;
	wp plugin deactivate "$1" --allow-root;
	wp plugin uninstall "$1" --allow-root
}

alias wpf="test -d httpdocs && cd httpdocs ; wp cache --allow-root flush"
alias wpl="test -d httpdocs && cd httpdocs ; wp plugin list --allow-root"
alias wpup="test -d httpdocs && cd httpdocs ; wp plugin update "$1" --allow-root" 
alias wpi="test -d httpdocs && cd httpdocs ; wp plugin install "$1" --allow-root --activate"

### Aliases pour la modification du fichier de configuration (celui-ci)
alias bashrc="nano ~/.bashrc"
alias mbashrc="micro ~/.bashrc"
alias saverc="source ~/.bashrc"
alias aliass="format_aliases.sh $CUSTOM_DIR/includes/alias.txt"
alias m="micro"
alias maliass="cd /root/document/scripts_server && micro includes/alias.txt && ./setup.sh && cd -"

alias wpdeb="test -d httpdocs && cd httpdocs ; wp config set --raw WP_DEBUG true --allow-root && wp config set --raw WP_DEBUG_DISPLAY true --allow-root"
alias wpudeb="test -d httpdocs && cd httpdocs ; wp config set --raw WP_DEBUG false --allow-root && wp config set --raw WP_DEBUG_DISPLAY false --allow-root"
alias beef="test -d httpdocs && cd httpdocs ; bee cc all"
