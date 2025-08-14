### Lancement de la commande plesk-repair sur l'instance où l'on est placé 
rep() {
    if [ -d httpdocs ]; then
    	cd httpdocs
    fi
    repair=$(getplesksite)
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "$PURPLE[ATTENTION]$NC vous n'êtes pas en mode root, plesk repair skip."
        return 0
    fi
    if [ -n "$repair" ]; then
        plesk repair fs $repair -y 
    fi
}

### Récuperation de l'instance où l'on est placé
# getplesksite() {
#   local current_dir="$(pwd)"
#   local vhost_dir=$racine
# 
#   if [[ "$current_dir" == *"$vhost_dir"* ]]; then
#     local site_path=${current_dir#*$vhost_dir/}
#     local site_name=${site_path%%/*}
#     echo "$site_name"
#   fi
# }

getplesksite() {
  if [ -d httpdocs ]; then
  	cd httpdocs
  fi

  local current_dir="$(pwd)"
  local vhost_dir="${racine%/}"  # On enlève le slash final s'il y en a

  # Vérifie qu'on est bien sous /var/www/vhosts
  if [[ "$current_dir" == "$vhost_dir"* ]]; then
    # Récupère ce qui est après /var/www/vhosts/
    local site_path="${current_dir#*$vhost_dir/}"
    
    # Découpe les segments
    IFS='/' read -r -a parts <<< "$site_path"

    local sub="${parts[0]}"   # Premier dossier après vhosts
    local second="${parts[1]}"  # Deuxième, s'il existe

    if [[ "$second" == "httpdocs" || "$second" == httpdocs/* ]]; then
      echo "$sub"  # cas: /domain1/httpdocs => domain1
    elif [[ -n "$second" ]]; then
      echo "$second"  # cas: /domain1/domain2 => domain2
    else
      echo "?"  # rien de détecté
    fi
  else
    echo "Hors de la racine des vhosts"
    return 1
  fi
}

apply_p() {
  echo "URL Github du patch CiviCRM :"
  read url
	  
  numero_variable=$(echo "$url" | grep -oP '(?<=/pull/).*')
  echo "Numéro du patch : $numero_variable"

  wget "$url.diff" && patch -p1 < "$numero_variable.diff" && echo -e ">> [${GREEN}RÉUSSI${NC}] Patch appliqué"
  rm -f $numero_variable.diff

  #$file_diff="${numero_variable}.diff"

  # Erreur à régler
  # >> [RÉUSSI] Patch installé
  # -bash: =30915.diff : commande introuvable
}
