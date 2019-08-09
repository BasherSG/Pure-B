#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:proc
# Proc module, miscelaneous utilities to find, kill, 
# and gather info about process
##PURE_DOC_END##

require "core/mssg"
require "core/util"
require "core/opp"

declare -rig MAXPID="$(</proc/sys/kernel/pid_max)"

##PURE_DOC##
##PURE_HEADER:get_proc_pids
#get_proc_pids:
# Get all the pids being used by process
# 
# @usage get_proc_pids
##PURE_DOC_END##
get_proc_pids() (
    cd "/proc" || return 1
    : "$(printf '%s ' *)"
    : "${_//[[:alpha:]]/}"
    : "${_//[[:punct:]]/}"
    printf '%s\n' "$_"
)

##PURE_DOC##
##PURE_HEADER:get_all_pids
#get_all_pids:
# Get all the pids that the system can assign
# 
# @usage get_all_pids
##PURE_DOC_END##
get_all_pids() (
    eval "printf '%s ' {1..$MAXPID}"
)

##PURE_DOC##
##PURE_HEADER:get_name
#get_name:
# Get the simple name of the process
# 
# @usage get_name <pid>
##PURE_DOC_END##
proc_name() (
    local IFS=' '
    [[ -f "/proc/$1/comm" ]] && fake_cat "/proc/$1/comm"
)

##PURE_DOC##
##PURE_HEADER:get_proc_names
#get_proc_names:
# Get all the names of every process
# 
# @usage get_proc_names
##PURE_DOC_END##
get_proc_names() (
    : "$(get_proc_pids)"
    : "/proc/${_//\ /\/comm\ \/proc/}"
    fake_cat $_
)

##PURE_DOC##
##PURE_HEADER:get_status
#get_status:
# Get the main status of the given PID
# 
# @usage get_status <pid>
##PURE_DOC_END##
proc_status() (
    local stat IFS=' '
    [[ -f "/proc/$1/stat" ]] && read -r -a stat < "/proc/$1/stat" && printf "%s" "${stat[-50]}"
)

##PURE_DOC##
##PURE_HEADER:is_hidden
#is_hidden:
# Find out whether the given PID is a hidden process, if it is could be a thread
# 
# @usage is_hidden <pid>
##PURE_DOC_END##
is_hidden() {
    local IFS=' '
    cd "/proc/$1" &> <(:) || return 1
    : " $(get_proc_pids)"
    if [[ "$_" =~ ' '?$1' '? ]]; then
        return 1
    fi
    return 0
}

##PURE_DOC##
##PURE_HEADER:is_thread
#is_thread:
# Find out whether the given PID is a thread or a regular process
# 
# @usage is_thread <pid>
##PURE_DOC_END##
is_thread() (
    local IFS=' '
    parce_file ':' "/proc/$1/status" || return "${ERRTBL[BAD_FILE]}"
    ((${ASSOC[Pid]} != ${ASSOC[Tgid]})) && return 0
    return 1
) &> >(:)

##PURE_DOC##
##PURE_HEADER:pidof
#pidof:
# Get all the PIDs for the given process name
#   -s Show only the first PID found 
# 
# @usage pidof <process_name>
##PURE_DOC_END##
pidof() (
    local name i IFS=' '
    [[ -n "$*" ]] || { error 'Please supply a process name' ; return 1; }
    [[ -n "$2" ]] && name=$2 || name=$1
    for i in /proc/* ; do
    	[[ ${i//'/proc/'/''} =~ ^[0-9]+[0-9]$ ]] && [[ -f "$i/comm" ]] && [[ "$(builtin echo -n "$(<"$i/comm")")" == "$name" ]] && printf "%q " "${i//'/proc/'/''}" && [[ "$1" == '-s' ]] && break
    done
    return 0
)

##PURE_DOC##
##PURE_HEADER:proc_count
#proc_count:
# Show the amount of instances for each process name
# 
# @usage proc_count
##PURE_DOC_END##
proc_count() (
	local index IFS=$'\n' i
	declare -gA count
    for i in /proc/* ; do
		if [[ -f $i/comm ]] && [[ ${i//'/proc/'/''} =~ ^[0-9]+[0-9]$ ]]; then
			index="$(<$i/comm)"
			[[ -z ${count[$index]} ]] && count[$index]=0
	    	count[$index]=$((${count[$index]}+1))
		fi
    done
	for i in "${!count[@]}"; do
		printf "%s\t<--\t%s\n" ${count[$i]} $i
	done
)

##PURE_DOC##
##PURE_HEADER:killall
#killall:
# Kill all the process by the given name
#   -SIGNAL Send the specified signal instead the default one (SIGTERM)
# 
#   Note: To view all the available singals run `kill -l`
# 
# @usage killall <process_name>
##PURE_DOC_END##
killall() (
    local signal proc
    [[ -n "$2" ]] && [[ "$1" =~ ^- ]] && { signal="${1^^}" ; proc=$(pidof "$2"); } || proc=$(pidof "$1")
    [[ "$(kill -l)" =~ (SIG)?"${signal//'-'/''}" ]] || { error "Signal $signal not found" ; return 1; }
    [[ -n "$proc" ]] && { [[ -n "$signal" ]] && kill "$signal" $proc || kill $proc; } || builtin echo "Process not found"
)