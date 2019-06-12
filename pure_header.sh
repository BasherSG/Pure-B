#!/usr/bin/env bash

declare -rgA ERRTBL=( ['MISS_DEPEND']=2 ['BAD_USAGE']=3 ['CANT_DO']=4 ['BAD_ARG']=5 ['NO_FILE']=6 ['NO_FOLD']=7 ['LOCK_ON']=8 ['BAD_FILE']=9 ['BAD_FOLD']=10 ['NOT_EXIST']=11 ['CANT_READ']=12 ['BAD_COLOR']=13 ['MDL_FATAL']=101 ['BAD_VERS']=254 )

test ${BASH_VERSINFO[0]} -ge 4 || { echo "Your Bash version is too old, required 4++"; exit "${ERRTBL[BAD_VERS]}"; }

declare -rgA SIGTBL=( ['CTRL_WTCH']=SIGTSTP ['DEAM_HUP']=SIGHUP ['TRCE_EXIT']=EXIT )

declare -rg PURE_VERSION='1.4.0'
declare -rg PURE_VERSINFO=( ${PURE_VERSION//\./ } 'beta' )
test -n "$CWD" || declare -g CWD="$( cd -P "$([[ -d "${0%/*}" ]] && echo "${0%/*}" || pwd)" && pwd )"

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
declare -rg MODULE_TAG="#MODULE"
declare +x -g MDL_ALIASES=${MDL_ALIASES:-false}
declare +x -ga ARGS=()
declare +x -gA MAGIC_ARGS=( )
declare -rgA DEF_ARGS=( ['cache']='--cache' ['debug']='--debug' ['mdl_alias']='--mdl_alias' ['pak']='--pak' ['reload']='--reload' )
declare -rgA DEF_ARGS_ACT=( 
    ['mdl_alias']='MDL_ALIASES=true'
    ['debug']='set -x'
)

shopt -s expand_aliases