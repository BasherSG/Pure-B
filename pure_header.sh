#!/usr/bin/env bash


source "$LWD/errtbl.sh" 

test ${BASH_VERSINFO[0]} -ge 4 || { echo "Your Bash version is too old, required 4++"; exit "${ERRTBL[BAD_VERS]}"; }

declare -rgA SIGTBL=( ['CTRL_WTCH']=SIGTSTP ['DEAM_HUP']=SIGHUP ['TRCE_EXIT']=EXIT )
test -n "$CWD" || declare -g CWD="$( cd -P "$([[ -d "${0%/*}" ]] && echo "${0%/*}" || pwd)" && pwd )"

declare -rg PURE_VERSION='1.4.2'
declare -rg PURE_VERSINFO=( ${PURE_VERSION//\./ } 'beta' )

declare -rg SELF_HEADER="${LWD}/${BASH_SOURCE[0]##*/}"
declare -rg SELF="${0##*/}"
declare -rg SELFNAME="${SELF%.*}"
declare -g DEF_PACK="${DEF_PACK:-core}"
declare +x -gA PACKAGES=( )
declare +x -g PACK_FOLD+="${PACK_FOLD+:}${LWD}/${DEF_PACK}"
declare +x -g CACHE_FILE="${CACHE_FILE:-${LWD}/.pure.cache}"
declare +x -gA MODULES=()
declare +x -gA SOURCED=()
declare +x -g LOADED
declare +x -gi MDL_COUNTER=0
declare -rg MODULE_TAG="${MODULE_TAG:-"#MODULE"}"
declare +x -g MDL_ALIASES=${MDL_ALIASES:-false}
declare -g RETURN
declare +x -ga ARGS=()
declare +x -gA MAGIC_ARGS=( )
declare -rgA DEF_ARGS=( ['cache']='--cache' ['debug']='--debug' ['mdl_alias']='--mdl_alias' ['pak']='--pak' ['reload']='--reload' ['args_end']='--$' )
declare -rgA DEF_ARGS_ACT=(
    [${DEF_ARGS[args_end]}]='break'
    [${DEF_ARGS[mdl_alias]}]='MDL_ALIASES=true'
    [${DEF_ARGS[debug]}]='set -x'
)

set -o functrace &> >(:)
trap '(("${#return[@]}">0)) && printf "${ret_format:-%s}" "${return[@]}" && RETURN="${return[@]}" && unset return' RETURN

shopt -s expand_aliases