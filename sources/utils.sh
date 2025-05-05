### Lancement de la commande plesk-repair sur l'instance où l'on est placé 
rep() {
  repair=$(getplesksite)

  if [ -n "$repair" ]; then
    plesk repair fs $repair -y 
  fi
}

### Récuperation de l'instance où l'on est placé
getplesksite() {
  local current_dir="$(pwd)"
  local vhost_dir=$racine

  if [[ "$current_dir" == *"$vhost_dir"* ]]; then
    local site_path=${current_dir#*$vhost_dir/}
    local site_name=${site_path%%/*}
    echo "$site_name"
  fi
}

apply_p() {
  echo "URL Github du patch CiviCRM :"
  read url
	  
  numero_variable=$(echo "$url" | grep -oP '(?<=/pull/).*')
  echo "Numéro du patch : $numero_variable"

  wget "$url.diff" && patch -p1 < "$numero_variable.diff" && echo -e ">> [${GREEN}RÉUSSI${NC}] Patch appliqué" 

  #$file_diff="${numero_variable}.diff"

  # Erreur à régler
  # >> [RÉUSSI] Patch installé
  # -bash: =30915.diff : commande introuvable
}
