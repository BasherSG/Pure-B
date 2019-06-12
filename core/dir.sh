#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:dir
# Dir module, provides useful functions to test list,
# and find files
##PURE_DOC##

require "core/opp"
require "core/mssg"

##PURE_DOC##
##PURE_HEADER:exists
#exists:
# Tests whether file or folder exists
# 
# @usage exists <file|folder>
##PURE_DOC##
exists() (
    [[ ! -e "${1}" ]] && error "No such file or folder '${1}'" && return ${ERRTBL[NOT_EXIST]}
    return 0
)

##PURE_DOC##
##PURE_HEADER:can_read
#can_read:
# Tests whether file of folder can be read
# 
# @usage can_read <file|folder>
##PURE_DOC##
can_read() (
    [[ ! -r "${1}" ]] && error "Can't read file or folder '${1}'" && return ${ERRTBL[CANT_READ]}
    return 0
)

##PURE_DOC##
##PURE_HEADER:file_empty
#file_empty:
# Tests whether file is empty
# 
# @usage file_empty <file>
##PURE_DOC##
file_empty() (
    [[ ! -s "${1}" ]] && error "File is empty '${1}'" && return ${ERRTBL[BAD_FILE]}
    return 0
)

##PURE_DOC##
##PURE_HEADER:file_ok
#file_ok:
# Tests whether file exists, can be read and is a regular file
# 
# @usage file_ok <file>
##PURE_DOC##
file_ok() (
    exists "${1}" || return $?
    can_read "${1}" || return $?
    [[ ! -f "${1}" ]] && error "Is not a regular file '${1}'" && return ${ERRTBL[BAD_FILE]}
    return 0
)

##PURE_DOC##
##PURE_HEADER:folder_ok
#folder_ok:
# Tests whether folder exists, can be read and is a directory
# 
# @usage folder_ok <folder>
##PURE_DOC##
folder_ok() (
    exists "${1}" || return $?
    can_read "${1}" || return $?
    [[ ! -d "${1}" ]] && error "Is not a folder '${1}'" && return ${ERRTBL[BAD_FOLD]}
    return 0
)

##PURE_DOC##
##PURE_HEADER:real_dir
#real_dir:
# Get the real path of a folder
# 
# @usage real_dir <folder>
##PURE_DOC##
real_dir() (
    [[ -d "${1}" ]] && cd -P "${1}" && builtin echo "${PWD}" || return 1
)

##PURE_DOC##
##PURE_HEADER:basename
#basename:
# Get the basename of the given path
# 
# @usage basename <path>
##PURE_DOC##
basename() (
    sep="${2:-/}"
    builtin echo "${1##*"$sep"}"
)

##PURE_DOC##
##PURE_HEADER:dirname
#dirname:
# Get the dirname of the given path
# 
# @usage dirname <path>
##PURE_DOC##
dirname() (
    local WIN_SPRTOR='\'
    local LNX_SPRTOR='/'
    folder_ok "${1}" && real_dir "${1}" && return 0
    local DIR="${1%"$WIN_SPRTOR"*}"
    local DIR="${DIR%"$LNX_SPRTOR"*}"
    real_dir "${DIR}" || return 1
)

##PURE_DOC##
##PURE_HEADER:dir
#dir:
# List folder contents
# 
# @usage dir <folder>
##PURE_DOC##
dir() (
    folder_ok "${1:-.}" || return $?
    local dir="$(real_dir "${1}")" IFS=' '
    cd "$dir"
    printf '%s\n' * .*
)

##PURE_DOC##
##PURE_HEADER:find
#find:
# Find the given name or regex using
# 
# @usage find <starting_folder> <depth> <regex_pettern|file_name|folder_name>
##PURE_DOC##
find() (
    local work_path='.' depth=1 pattern='*' a='' matches=() i j
    test -d "$1" && work_path="$1" && shift 1
    is_num $1 && depth=$1 && shift 1 || warning "Default depth set to 1"
    test -n "$1" && pattern="$1" || warning "No search pattern specified"
    for (( i=0 ; i < $depth ; i++ )); do
        matches=("$work_path"$a/$pattern)
        for j in "${matches[@]}"; do
           [[ -e "$j" ]] && builtin echo "$j"
        done
        a+='/**'
    done
)