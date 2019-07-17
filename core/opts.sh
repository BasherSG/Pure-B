#!/usr/bin/env bash

##PURE_DOC##
##PURE_HEADER:magicase
#magicase:
# Case generator function
# 	-Separator1: Parameter used to split the Options.
# 	-Options:    Options to be triggered when the case is called.
# 	-Separator2: Parameter used to split the Actions to be performed.
# 	-Actions:    Actions to be performed by the options.
# 	-Param:      Variable name to be evaluated by the case
# 
# @usage magicase <Separator1> <Option1Separator1OptionN> <Separator2> <Action1Separato2ActionN> <Param>
##PURE_DOC_END##
function magicase() {
    [[ ${#@} -eq 5 ]] || return 1
    local opts works param="$5"
    IFS="$1" read -a opts <<< "$2"
    IFS="$3" read -a actions <<< "$4"
    printf "%s\n" "case $"$param" in"
    while true; do
        read -r -u3 opt || break
        read -r -u4 action || break
        opt="$(is_number $opt && echo -n "$opt) $action;;" || echo -n "'$opt') $action;;")"
        printf "\t%s\n" "$opt"
    done 3< <(printf "%s\n" "${opts[@]}") 4< <(printf "%s\n" "${actions[@]}")
    printf "%s\n" 'esac'
}

##PURE_DOC##
##PURE_HEADER:magicopts
#magicopts
# Option generator function
# 	-Separator1: Parameter used to split the Options.
# 	-Options:    Options to be triggered when the case is called.
# 	-Separator2: Parameter used to split the Actions to be performed.
# 	-Actions:    Actions to be performed by the options.
# 	-Param:      Variable name to be evaluated by the case
# 
# @usage magicopts <Separator1> <Option1Separator1OptionN> <Separator2> <Action1Separato2ActionN> <Param>
##PURE_DOC_END##
function magicopts() {
    [[ ${#@} -eq 5 ]] || return 1
    local delim1="$1" delim2="$3"
    local case=$(magicase "$delim1" "${2//':'/''}" "$delim2" "$4" "$5")
    local opts="${2//"$delim1"/''}" param="$5"
    while getopts "$opts" "$param"; do
        eval "$case"
    done
}