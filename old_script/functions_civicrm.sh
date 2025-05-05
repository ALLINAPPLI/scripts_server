# * Documentation : 
#  * Si la condition '[ $civi_type_version == "p" ]' est validée, tout ce qui est après le '&&' est exécuté 
#  * [ $civi_type_version == "p" ] && commande 
# * Fin

updateCivicrm(){ 
  # cd /var/www/vhosts/$civi_folder/httpdocs/sites/all/modules/civicrm.zip

  cd $vhosts/$civi_folder/httpdocs

  civicrm="civicrm"
  un="1"

  #! Condition d'existence ou non du plugin CiviCRM dans l'instance choisie
  [ $cms_instance == "wordpress" ] && cd $chemin_plugins_wordpress && [ ! -d "civicrm" ] && echo "Le plugin CiviCRM n'est pas installé, fin du script" && exit 0
  [ $cms_instance == "drupal" ] && cd $chemin_plugins_drupal && [ ! -d "civicrm" ] && echo "Le plugin CiviCRM n'est pas installé, fin du script" && exit 0
  [ $cms_instance == "standalone" ] && cd $chemin_plugins_standalone 

  #! Condition pour se placer dans le bon dossier contenant les plugins, et affectation de valeurs pour toutes les variables
  [ $cms_instance == "wordpress" ] && cd $chemin_plugins_wordpress && extension="zip" && [[ -e $civicrm && -n "$(ls -A $civicrm)" ]] && echo " " 
  [ $cms_instance == "drupal" ] && cd $chemin_plugins_drupal && extension="tar.gz" && [[ -e $civicrm && -n "$(ls -A $civicrm)" ]] && echo " " 
  [ $cms_instance == "standalone" ] && cd $chemin_plugins_standalone && extension="tar.gz" && echo " " #&& [[ -e $civicrm && -n "$(ls -A $civicrm)" ]] && echo " " 

  #! Condition selon le CMS et le choix de version choisie (Prod - Beta - Alpha), affectation de la variable $download_link 
  [[ $cms_instance == "wordpress" || $cms_instance == "drupal" ]] && [ $civi_type_version == "p" ] && rm -rf civicrm && download_link="https://download.civicrm.org/civicrm-$civi_version-$cms_instance.$extension" 
  [[ $cms_instance == "wordpress" || $cms_instance == "drupal" ]] && [ $civi_type_version == "b" ] && rm -rf civicrm && version_type="RC" && download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension" && civi_type="Beta"  
  [[ $cms_instance == "wordpress" || $cms_instance == "drupal" ]] && [ $civi_type_version == "a" ] && rm -rf civicrm && version_type="NIGHTLY" && download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension" && civi_type="Alpha"

  [ $cms_instance == "standalone" ] && [ $civi_type_version == "p" ] && download_link="https://download.civicrm.org/civicrm-$civi_version-$cms_instance.$extension" && mkdir temp_civi_standalone && cd temp_civi_standalone
  [ $cms_instance == "standalone" ] && [ $civi_type_version == "b" ] && version_type="RC" && download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension" && civi_type="Beta" && mkdir temp_civi_standalone  && cd temp_civi_standalone
  [ $cms_instance == "standalone" ] && [ $civi_type_version == "a" ] && version_type="NIGHTLY" && download_link="https://download.civicrm.org/latest/civicrm-$version_type-$cms_instance.$extension" && civi_type="Alpha" && mkdir temp_civi_standalone && cd temp_civi_standalone

  # Déclaration des variables
  civi_download_prod=$civicrm-$civi_version-$cms_instance.$extension
  civi_download_beta_alpha=$civicrm-$version_type-$cms_instance.$extension

  if wget -q $download_link
    then
      wget $download_link
  else
    echo -e '\e[93m=======================================\033[0m'
    echo -e '\e[93m\033[31m Aucune version de Civicrm trouvée\033[31m'
    echo -e '\e[93m=======================================\033[0m'
    exit 1
  fi

  # Dezip la nouvelle version installée - Wordpress
  [ $cms_instance == "wordpress" ] && [ $civi_type_version == "p" ] && echo "Version Prod : $civi_download_prod" && unzip $civi_download_prod && cd $chemin_plugins_wordpress && echo "Archive décompressée dans le dossier $chemin_plugins_wordpress"
  [ $cms_instance == "wordpress" ] && [[ $civi_type_version == "b" || $civi_type_version == "a" ]] && echo "Version Beta : $civi_download_beta_alpha" && unzip $civi_download_beta_alpha && cd $chemin_plugins_wordpress && echo "Archive décompressée dans le dossier $chemin_plugins_wordpress" 

  # Dezip la nouvelle version installée - Drupal
  [ $cms_instance == "drupal" ] && [ $civi_type_version == "p" ] && echo "Version Prod : $civi_download_prod" && tar -xzf $civi_download_prod && rm $civi_download_prod || $civi_download_prod.$un 2> /dev/null && cd $chemin_plugins_drupal && echo "Archive décompressée dans le dossier $chemin_plugins_drupal"
  [ $cms_instance == "drupal" ] && [[ $civi_type_version == "b" || $civi_type_version == "a" ]] && echo "Version Beta : $civi_download_beta_alpha" && tar -xzf $civi_download_beta_alpha && rm $civi_download_beta_alpha || rm $civi_download_beta_alpha.$un 2> /dev/null && cd $chemin_plugins_drupal && echo "Archive décompressée dans le dossier $chemin_plugins_drupal"

  # Dezip la nouvelle version installée - Standalone
  [ $cms_instance == "standalone" ] && [ $civi_type_version == "p" ] && echo "Version Prod : $civi_download_prod" && tar -xzf $civi_download_prod && rm $civi_download_prod || $civi_download_prod.$un 2> /dev/null && cd $chemin_plugins_standalone && echo "Archive décompressée dans le dossier $chemin_plugins_standalone"
  [ $cms_instance == "standalone" ] && [[ $civi_type_version == "b" || $civi_type_version == "a" ]] && echo "Version Beta : $civi_download_beta_alpha" && tar -xzf $civi_download_beta_alpha && rm $civi_download_beta_alpha || rm $civi_download_beta_alpha.$un 2> /dev/null && cd $chemin_plugins_standalone && echo "Archive décompressée dans le dossier $chemin_plugins_standalone"
  [ $cms_instance == "standalone" ] && rm -rf core && mv temp_civi_standalone/civicrm-standalone/core $vhosts/$civi_folder/httpdocs && rm -rf temp_civi_standalone

  echo -e '\e[93m================================================\033[0m'

  # Suppression de l'archive zippée de la nouvelle version CiviCRM
  [ $cms_instance == "wordpress" ] && cd $chemin_plugins_wordpress && rm $civi_download_prod 2> /dev/null || rm $civi_download_prod.$un 2> /dev/null || rm $civi_download_beta_alpha 2> /dev/null || rm $civi_download_beta_alpha.$un 2> /dev/null 
  [ $cms_instance == "drupal" ] && cd $chemin_plugins_drupal && rm $civi_download_prod 2> /dev/null || rm $civi_download_prod.$un 2> /dev/null || rm $civi_download_beta_alpha 2> /dev/null || rm $civi_download_beta_alpha.$un 2> /dev/null 
  [ $cms_instance == "standalone" ] && cd $chemin_plugins_standalone && rm $civi_download_prod 2> /dev/null || rm $civi_download_prod.$un 2> /dev/null || rm $civi_download_beta_alpha 2> /dev/null || rm $civi_download_beta_alpha.$un 2> /dev/null 

  #! Condition d'existence ou non du ficheir .zip de la version PROD de CiviCRM
  # [ -f "$civi_download_prod" ] && rm $civi_download_prod || $civi_download_prod.$un && echo "ZIP de la nouvelle version CiviCRM bien supprimée"

  cd $vhosts/$civi_folder/httpdocs

  # upgrade bundled extensions & upgrade db & clear civi cache
  # cv ext:upgrade-db && echo ">> MàJ des extensions faite"
  # [ $cms_instance == "drupal" ] && drush pm-updatestatus civicrm && drush cc all # Check plugin status
  cv updb && echo -e ">> [${GREEN}REUSSI${NC}] MàJ DB faite"
  cv flush && echo -e ">> [${GREEN}REUSSI${NC}] Cache de l'instance vidé"
  plesk repair fs $civi_folder -y && echo -e ">> [${GREEN}REUSSI${NC}] Plesk repair effectué"
  echo -e ">> [${GREEN}REUSSI${NC}] Montée de version $civi_version effectuée" ; echo " "
}
