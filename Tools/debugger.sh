#!/usr/bin/env bash

declare -rg FILE="$1"
shift 1
declare -ag MAPFILE=()

source() {
    mapfile < "$@" 
    builtin source "$@"
}

show() {
    local start end
    if (( $1 >= 5 )); then start=$(($1 - 5)); else start=0; fi
    if (( $1 <= (${#MAPFILE[@]} - 5) )); then end=$(($1 + 5)); else end=${#MAPFILE[@]}; fi
    for (( i=start ; i<end ; i++)); do
        printf '\t%s' "${MAPFILE[$i]}"
    done
}

debug() {
    read -p $'\t'"$LINENO: $BASH_COMMAND"$'\n'"(bdb) "
    case $REPLY in
        'n') return 0;;
        'l') show "$LINENO" ; debug;;
    esac
}

mapfile < "$FILE"

(
trap 'debug' DEBUG
source "$FILE" $*
)
