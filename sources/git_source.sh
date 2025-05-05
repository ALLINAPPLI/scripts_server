## RiverLea
gcrl() {
    echo -e ">> Installation de l'extension ${GREEN}$ext1${NC}..."
    instance=$(getplesksite)
    rl="https://lab.civicrm.org/extensions/riverlea.git"
    ext1="riverlea"
    
    cd httpdocs
    chemin_extensions=$(cv ev 'echo Civi::paths()->getPath("[civicrm.files]/ext");')
    cd $chemin_extensions

    git clone "$rl" && cv en "$ext1" && cv updb && cv flush && rep

    cd $racine/$instance/httpdocs/
}

gprl() {
    echo -e ">> Mise à jour de l'extension ${GREEN}$ext1${NC}..."
    instance=$(getplesksite)
    ext1="riverlea"
    rl="https://lab.civicrm.org/extensions/riverlea.git"

    cd httpdocs
    chemin_extensions=$(cv ev 'echo Civi::paths()->getPath("[civicrm.files]/ext");')
    cd $chemin_extensions/$ext1 

    git pull "$rl" && cv updb && cv flush && rep

    cd $racine/$instance/httpdocs/
}

### Git commit
committ() {
    git add .
    read -p "Votre message du commit : " message
    git commit -m "$message"
    git push
    echo "Votre repo s'est bien mis à jour !"
}
