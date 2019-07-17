#!/usr/bin/env bash

require "core/mssg"
require "core/dir"

declare -g -A OLD_TRAPS
declare -g USAGE
declare -gA ASSOC
declare -ga ARRAY=()

##PURE_DOC##
##PURE_HEADER:fake_cat
#fake_cat:
# Print file contents into stdout
#
# @usage <pipe> | fake_cat <file> <<< <pipe>
# @warn: ¡DOESN'T WORK FOR BINARY FILES!
##PURE_DOC_END##
fake_cat() (
    [[ -r "${1}" ]] && echo "$(<${1})" && return 0
    while IFS='' read -r line; do echo "${line}" ; done
)

##PURE_DOC##
##PURE_HEADER:fake_date
#fake_date:
# Print current date with custom date format
#
# @usage fake_date <date_format>
##PURE_DOC_END##
fake_date() (
    local IFS=' '
    printf "%($*)T\\n" "-1"
)

##PURE_DOC##
##PURE_HEADER:fake_sleep
#fake_sleep:
# Sleep for the given amount of seconds, minutes, hours or days
#
#@usage fake_sleep <time><s|m|h|d>
##PURE_DOC_END##
fake_sleep() {
        local c=${1//[A-Za-z]/''} s=${1:${#1}-1:1} i
        case $s in
            m) (( c = c * 60 ));;
            h) (( c = c * 3600 ));;
            d) (( c = c * (3600 * 24) ));;
        esac
        for ((i=0 ; i < $c ; i++)); do
            ( IFS='' read -d'' -r -t1 <> <(:) )
        done
        # IFS='' read -d'' -r -t$c -u3
        return 0
}


##PURE_DOC##
##PURE_HEADER:get_chars
#get_chars:
# Print chars of the given file
#
# @usage get_chars <file>
##PURE_DOC_END##
get_chars() {
    file_ok "$1"
    local chars
    while read -N1 c; do chars+=(${c}); done < "$1"
    ARRAY=( ${chars[@]} )
}

##PURE_DOC##
##PURE_HEADER:usage
#usage:
# Print $USAGE variable content when defined
#
# @usage usage
##PURE_DOC_END##
usage() (
    fake_cat << EOF
$USAGE
EOF
exit 0
)

##PURE_DOC##
##PURE_HEADER:clone_var
#clone_var:
# Clone variable contents into another variable. 
# Variable to be cloned must be accesible.
#
# @usage clone_var <variable_name_to_clone> <new_variable>
##PURE_DOC_END##
clone_var() {
    local IFS=\|
    test $# -eq 2 || { error "2 Variable names required <from> <to>" ; return ${ERRTBL[BAD_ARG]}; }
    [[ "$*" =~ [[:blank:]] ]] && { error "Variable names contain ilegal characters" ; return ${ERRTBL[BAD_ARG]}; }
    declare -p ${1} &> >(:) || { error "No such variable ${1}" ; return ${ERRTBL[BAD_ARG]}; }
    : "$(declare -p "${1}")"
    eval "${_/${1}/-g ${2}}"
}

##PURE_DOC##
##PURE_HEADER:pipe_to_array
#pipe_to_array:
# Pipe line by line to $ARRAY
#
# @usage pipe_to_array <<< <pipe>
##PURE_DOC_END##
pipe_to_array() {
    read -r line ; ARRAY+=("$line")
}

##PURE_DOC##
##PURE_HEADER:columns
#columns:
# Format output into columns
#
# @usage columns <string> <columns_amount> <separator>
##PURE_DOC_END##
columns() (
    [[ "${#@}" -le 3 ]] && [[ "${#@}" -gt 1 ]] || return 1
    local JUMP=$2 k=1 TABS m=8 j=2 ilen=0
    local IFS=${3:-' '} TMP=("$1") TABS MAX=()
    for i in ${TMP[*]}; do
        [[ ${#i} -gt ${MAX[$k]} ]] && MAX[$k]=${#i} && MAX[$k]=$(( -((${MAX[$k]} % 8) - 8) + ${MAX[$k]} ))
        [[ $k -ge $JUMP ]] && k=1 || k=$((k+1))
    done ; k=1
    for i in ${TMP[*]}; do
        ilen=${#i} ; j=2 ; TABS=''
        while [[ ${MAX[$k]} -gt $ilen ]] ; do ilen=$(( -(($ilen % 8) - 8) + $ilen )) ; TABS+='\t' ; ((j++)) ; done
        printf "%s${TABS}" "$i"
        [[ $k -ge $JUMP ]] && printf "\n" && k=1 || k=$((k+1))
    done
    builtin echo
)


##PURE_DOC##
##PURE_HEADER:trap_add
#trap_add:
# Add the guiven action to the already defined trap
#
# @usage trap_add <commands_to_run> <signal>
# @autor Richard Hansen
# @source https://stackoverflow.com/questions/3338030/multiple-bash-traps-for-the-same-signal#answer-7287873
# @recovered 22/02/2019
##PURE_DOC_END##
trap_add() {
    trap_add_cmd=$1; shift || fatal "${FUNCNAME} usage error" ${ERRTBL[BAD_USAGE]}
    for trap_add_name in "$@"; do
        OLD_TRAPS[${trap_add_name}]="$(trap -p ${trap_add_name})"
        trap -- "$(
            # helper fn to get existing trap command from output
            # of trap -p
            extract_trap_cmd() { printf '%s\n' "$3"; }
            # print existing trap command with newline
            eval "extract_trap_cmd $(trap -p "${trap_add_name}")"
            # print the new trap command
            printf '%s\n' "${trap_add_cmd}"
        )" "${trap_add_name}" || fatal "unable to add to trap ${trap_add_name}"
    done
}
declare -f -t trap_add

##PURE_DOC##
##PURE_HEADER:parce_file
#parce_file:
# Split each line of a file into an associative array $ASSOC
# using the given separator 
#
# @usage parce_file <separator> <file>
##PURE_DOC_END##
parce_file() {
    file_ok "${2}" || return $?
    local sep=${1:-\|} file="${2}"
    while IFS="${sep}" read -r -a array; do
        ASSOC["${array[0]}"]=${array[1]}
    done < "$file"
}

##PURE_DOC##
##PURE_HEADER:extract
#extract:
# Extract lines between two markers
# 
# @usage extract <opening_marker> <closing_marker> [< <file>|<<< <pipe>]
# @author Dylan Araps
# @author Basher SG
# @source https://github.com/dylanaraps/pure-bash-bible#extract-lines-between-two-markers
##PURE_DOC_END##
extract() {
    while IFS=$'\n' read -r line; do
        [[ $extract && $line != "$2" ]] && pipe_to_array <<< "$line"

        [[ $line == "$1" ]] && extract=1
        [[ $line == "$2" ]] && extract=
    done
}

##PURE_DOC##
##PURE_HEADER:extract.quoted
#extract.quoted:
# Extract words between two quotes
# 
# @usage extract.quoted <delimiter> [< <file>|<<< <pipe>]
##PURE_DOC_END##
extract.quoted() {
    local flag=0
    while let flag^=1 ; read -d"$1" -r words; do
        ((flag==0)) && pipe_to_array <<< "$words"
    done
}