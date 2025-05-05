# Scripts de l'agence

### Voici tous les scripts shell :
- `clonage.sh` (clonage d'instance)
- `clonage_bdd.sh`(clonage d'une base de données seule)
- `remplacement_valeurs_bdd.sh` (remplacement d'occurences dans une BDD)
- `save.sh` (sauvegarde d'instance)
- `vidage_bdd.sh` (vidage d'une base données)
- `bdd_instance.sh` (affichage du nom de la BDD d'une instance)
- `civi_update.sh` (changement de version CiviCRM d'instance)

#### Tous ces scripts sont liés à ces fichiers de fonction :
- `functions.sh` 

### A l'exception du script `civi_update.sh`, qui lui est lié au fichier :
- `functions_civicrm.sh` (fonction du script civi_update.sh)

### Attention /!\
La base de données et son utilisateur ne doivent pas avoir le même nom.
Pour le bon déroulement de certains scripts, le mot de passe de la base de données des instances ne doit pas contenir un de ces caractères spéciaux :
- `$`
- `&`
- `#`

Si le mot de passe contient un des trois caractères spéciaux ci-dessus : 
1. Modifiez le mot de passe depuis Plesk en omettant les caractères spéciaux
2. Reportez ce dernier dans les fichiers :
    - `wp-config.php` et `civicrm-settings.php` pour **Wordpress**
    - `settings.php`  et `civicrm-settings.php` pour **Drupal**
    - `civicrm-settings.php` pour **Standalone**
