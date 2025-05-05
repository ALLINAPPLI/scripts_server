_complete_vcv_option() {
    if [[ $COMP_CWORD == 1 ]]; then COMPREPLY="-g";
    else COMPREPLY=""
    fi
}

complete -F _complete_vcv_option vcv
