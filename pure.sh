#!/usr/bin/env bash

# Pure framework/library
# Basher SG
# 2019

declare -rg LWD="$( cd -P "$([[ -d "${BASH_SOURCE[0]%/*}" ]] && echo "${BASH_SOURCE[0]%/*}" || pwd)" && pwd )"
declare -rg SELF_PURE="${LWD}/${BASH_SOURCE[0]##*/}"

source "${LWD}/pure_header.sh" || exit 255

version_control() {
    [[ -f "${VERSION_FILE}" ]] && local cur_version=$(<"${VERSION_FILE}")
    local cur_versinfo=( ${cur_version//\./ } )
    declare -g new_version=false

    version_case() {
        ( case ${1} in
            0) builtin echo "Updating Pure..." ; return 1;;
            [1-3]) builtin echo "Updating Pure from ${cur_version} to ${PURE_VERSION}" ; return 1;;
        esac ) || { builtin echo "${PURE_VERSION}" > "${VERSION_FILE}" ; new_version=true ; }
    }

    if [[ "${cur_version}" != "${PURE_VERSION}" ]]; then
        [[ ! -f "${VERSION_FILE}" ]] && { version_case 0; }
        for ((i = 0 ; i < ${#cur_versinfo[@]} ; i++ )); do
            ! ${new_version} && [[ "${cur_versinfo[$i]}" -lt "${PURE_VERSINFO[$i]}" ]] && { version_case $((++i)); }
        done
    fi
    unset -f version_case
}

loaded_modules() (
    echo "Currently loaded modules: $LOADED"
)

require() {
    test -n "$1" || return 1
    [[ -z "${MODULES[$1]}" ]] && builtin echo "Module: $1 does not exist" && return "${ERRTBL[NOT_EXIST]}"
    ${SOURCED["$1"]} && return 0
    test -f "$1" && source "$1" && return 0
    local IFS=':' i j
    SOURCED["$1"]=true
    ((MDL_COUNTER++))
    LOADED+=$'\n\t'"$MDL_COUNTER: ${1//\//' => '}"
    for i in ${MODULES["$1"]}; do
        source "$i" || exit "${ERRTBL[MDL_FATAL]}";
    done
    for j in ${PACKAGES["$1"]}; do 
        SOURCED["$1/$j"]=true
    done
}

map_packages() {
    local i
    for i in "${LWD}/"*; do
        [[ -d "$i" ]] || continue
        [[ ! "${PACK_FOLD}" =~ $i ]] && [[ "${i##*/}" =~ ^[a-z_/]+$ ]] && PACK_FOLD+=":$i"
    done
    declare -p PACK_FOLD > "${CACHE_FILE}"
}

map_modules() {
    local namespace label pack mdl
    local IFS=\: k i j
    for k in ${PACK_FOLD}; do
        for i in "${k}"/*.sh; do
            mdl="${i##*/}"
            [[ "${mdl}" =~ ^[a-z0-9_]+\.sh$ ]] || continue
            pack="${k##*/}"
            namespace=""
            if $MDL_ALIASES; then
                mapfile -tn 4 lines < "$i"
                for j in "${lines[@]}"; do
                    if [[ "$j" =~ ^$MODULE_TAG*.* ]]; then
                        : "${j//${MODULE_TAG}/}"
                        : "${_//[[:blank:]]/}"
                        : "${_//[[:punct:]]/}"
                        : "${_//[[:digit:]]/}"
                        : "${_,,}"
                        namespace="$_"
                        MODULES["${pack}/${namespace}"]="$i"
                        break
                    fi
                done
            fi
            test -z "$namespace" && : "${mdl}" && namespace="${pack}/${_%.*}" 
            label="${namespace##*/}"
            if [[ $label =~ [a-z_0-9]+$ ]]; then
                test -n "$namespace" || exit "${ERRTBL[MDL_FATAL]}"
                MODULES["${namespace}"]="$i"
                MAGIC_ARGS["${label}"]="--${label}"
                SOURCED["${namespace}"]=false
                MODULES["${pack}"]+="${MODULES["${pack}"]+:}$i"
                PACKAGES["${pack}"]+="${PACKAGES["${pack}"]+:}${label}"
            fi
        done
        SOURCED["${pack}"]=false
    done
    declare -p MODULES MAGIC_ARGS SOURCED PACKAGES >> "${CACHE_FILE}"
}

depend() {
    [[ -n "$1" ]] || return 1
    command -v "$1" > /dev/null || { builtin echo "No such command ${1}" ; exit "${ERRTBL[MISS_DEPEND]}"; }
    unset -f "$1"
}

eval_def_args() {
    unset -f eval_def_args
    local i
    for i in "$@"; do
        [[ -n "${DEF_ARGS_ACT[$i]}" ]] && eval "${DEF_ARGS_ACT[$i]}"
    done
    return 0
}

{
    version_control
    [[ "$*" =~ ${DEF_ARGS[cache]} ]] && CACHE_FILE="${CWD}/.${SELFNAME}.cache"
    if [[ -s "${CACHE_FILE}" ]] && [[ ! "$*" =~ ${DEF_ARGS[reload]} ]] && ! ${new_version}; then
        source "${CACHE_FILE}"
    else
        map_packages
        map_modules
    fi
    OLDIFS="$IFS"
    IFS=\| c=1
    def_pattern="${DEF_ARGS[*]}"
    pattern="${MAGIC_ARGS[*]}"
    [[ -d "${LWD}/${DEF_PACK}" ]] && pak="${DEF_PACK}"
    set -f
    for i in "$@"; do
        [[ "$i" =~ ${DEF_ARGS[args_end]} ]] && break
        : "${i//-/}"
        [[ "$i" =~ ${DEF_ARGS[pak]}\=[a-z_/]+$ ]] && eval "$_"
        [[ ! $i =~ ${def_pattern}|${pattern} ]] && ARGS[$c]="$i" && ((c++))
        if [[ -n "$pak" ]] && [[ ! $i =~ $def_pattern ]] && [[ "$i" =~ ^-- ]]; then
            require "${pak}/$_"
        fi
    done
    set +f
    IFS="$OLDIFS"
    unset OLDIFS pattern c pak i new_version
    eval_def_args "$@"
}
