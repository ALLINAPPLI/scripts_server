source $CUSTOM_DIR/includes/utils.sh

### Aliases pour git clone de l'extension de Wordpress et activation
wpgc() {
  instance=$(getplesksite)
  
  extension=$(echo "$1" | awk -F'/' '{print $NF}' | sed 's/\.git$//')
  extracted_string=$(echo "$extension" | awk -F '.' '{print $NF}')

  echo ">> Clonage de l'extension : $extracted_string"
  cd $racine/$instance/httpdocs/wp-content/plugins

  git clone "$1" && wp plugin activate "$extracted_string" --allow-root
  cd $racine/$instance/httpdocs
  rep
}	

### Alias pour git pull à transformer en fonction 
### A FINALISER
wpgp() {
  instance=$(getplesksite)
  
  extension=$(echo "$1" | awk -F'/' '{print $NF}' | sed 's/\.git$//')
  extracted_string=$(echo "$extension" | awk -F '.' '{print $NF}')

  echo "Mise à jour de l'extension : $extracted_string"
  cd $racine/$instance/httpdocs/wp-content/plugins/$extracted_string

  git pull "$1"
  cd $racine/$instance/httpdocs
  rep
}
