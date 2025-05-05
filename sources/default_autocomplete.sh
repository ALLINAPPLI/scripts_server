_autocomplete()
{
    local cur=${COMP_WORDS[COMP_CWORD]}
    local fct_lister=$1
    local cache_file=$2
    local cache_ttl=$3  # en secondes

    # Regénère si le fichier n'existe pas ou est trop vieux
    if [[ ! -f "$cache_file" || $(($(date +%s) - $(stat -c %Y "$cache_file"))) -gt $cache_ttl ]]; then
        $fct_lister > "$cache_file" 2> /dev/null
        if [ $? -ne 0 ]; then
            return
        fi
    fi

    # Lire toutes les options déjà tapées sauf la commande elle-même
    local already_used=()
    for word in "${COMP_WORDS[@]:1}"; do
        # Ignore les options (commencent par -)
        [[ "$word" != -* ]] && already_used+=("$word")
    done

    # Filtrer la liste pour enlever les déjà utilisées
    local filtered_list=()
    while IFS= read -r item; do
        local skip=false
        for used in "${already_used[@]}"; do
            if [[ "$item" == "$used" ]]; then
                skip=true
                break
            fi
        done
        $skip || filtered_list+=("$item")
    done < "$cache_file"

    COMPREPLY=( $(compgen -W "${filtered_list[*]}" -- "$cur") )
}

_dll_lister()
{
    cv ext:list --local --columns=key --statuses=installed --upgrade=available 2> /dev/null \
        | grep '|' \
        | awk '{print $2}' \
        | grep -v '^key$' \
        | grep -v '^+$'
}

_autocomplete_dll()
{
    _autocomplete "_dll_lister" "dll_cache" "60"
}

_en_lister()
{
    cv ext:list --local --columns=key --statuses=disabled 2> /dev/null \
        | grep '|' \
        | awk '{print $2}' \
        | grep -v '^key$' \
        | grep -v '^+$'
}

_autocomplete_en()
{
    _autocomplete "_en_lister" "en_cache" "30"
}

_dis_lister()
{
    cv ext:list --local --columns=key --statuses=installed 2> /dev/null \
        | grep '|' \
        | awk '{print $2}' \
        | grep -v '^key$' \
        | grep -v '^+$'
}

_autocomplete_dis()
{
    _autocomplete "_dis_lister" "dis_cache" "30"
}

_un_lister()
{
    cv ext:list --local --columns=key 2> /dev/null \
        | grep '|' \
        | awk '{print $2}' \
        | grep -v '^key$' \
        | grep -v '^+$'
}

_autocomplete_un()
{
    _autocomplete "_un_lister" "un_cache" "30"
}

_wpa_lister()
{
    wp --allow-root plugin list --status=inactive --field=name
}

_autocomplete_wpa()
{
    _autocomplete "_wpa_lister" "wpa_cache" "30"
}

_wpd_lister()
{
    wp --allow-root plugin list --status=active --field=name
}

_autocomplete_wpd()
{
    _autocomplete "_wpd_lister" "wpd_cache" "30"
}

_wpu_lister()
{
    wp --allow-root plugin list --field=name
}

_autocomplete_wpu()
{
    _autocomplete "_wpu_lister" "wpu_cache" "30"
}

_wpup_lister()
{
    wp --allow-root plugin list --update=available --field=name
}

_autocomplete_wpup()
{
    _autocomplete "_wpup_lister" "wpup_cache" "30"
}


complete -F _autocomplete_wpup wpup
complete -F _autocomplete_wpu wpu
complete -F _autocomplete_wpd wpd
complete -F _autocomplete_wpa wpa
complete -F _autocomplete_un un
complete -F _autocomplete_dis dis
complete -F _autocomplete_dll dll
complete -F _autocomplete_en en
