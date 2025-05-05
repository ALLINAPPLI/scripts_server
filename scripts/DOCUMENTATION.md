# Scripts de l'agence

### Voici tous les scripts shell :
- `clone` (clonage d'instances web)
- `clonebdd`(clonage d'une base de données seule)
- `remp` (remplacement d'occurences dans une base de données)
- `backup` (sauvegarde d'instance web)
- `vidage` (vidage d'une base données)
- `bdd_instance.sh` (affichage du nom de la base de données d'une instance)
- `up` (changement de version CiviCRM d'une instance web)

#### Tous ces scripts sont liés à ce fichiers de fonction :
- `functions.sh` 

### A l'exception du script `civi_update.sh`, qui lui est lié au fichier :
- `functions_civicrm.sh` (fonctions relatifs au script `civi_update.sh`)

### Attention /!\
La base de données et son utilisateur ne doivent pas avoir le même nom.
Pour le bon déroulement de certains scripts, le mot de passe de la base de données des instances ne doit pas contenir un de ces caractères spéciaux :
- `$`
- `&`
- `#`

### Condition
- Nom de l'instance pas égal a la base de données

Si le mot de passe contient un des trois caractères spéciaux ci-dessus : 
1. Modifiez le mot de passe depuis **Plesk** en omettant les caractères spéciaux.
2. Reportez ce dernier dans les fichiers :
    - `wp-config.php` et `civicrm-settings.php` pour une instance **Wordpress**
    - `settings.php`  et `civicrm-settings.php` pour une instance **Drupal**
    - `civicrm-settings.php` pour une instance **Standalone**

I. Reste a faire
## sed -i 's/\BDES\b/DESE/g' bdese.sql # Modifier les valeurs, pour le cas de l'instance BDESE
# POINT DE CONTROLE MDP (CARACTERES SPECIAUX dans le readme)
