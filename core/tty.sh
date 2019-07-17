#!/usr/bin/env bash

require "core/opp"

declare -gA ACTIVE_TTYS=()
declare -gA ACTIVE_PTSS=()

##PURE_DOC##
##PURE_HEADER:get_all_tty
#get_all_tty:
# Get all tty and pts being used
# 
# @usage get_all_tty
##PURE_DOC_END##
get_all_tty() {
	local comm
    for i in /proc/*; do
    		for j in /dev/tty*; do 
        		test $i/fd/0 -ef "$j" && comm="$(<"$i"/comm)" && builtin echo "$i - $comm - $j" && ACTIVE_TTYS+=( [$j]="$comm" )
    		done
    		for j in /dev/pts/*; do 
        		test $i/fd/0 -ef "$j" && comm="$(<"$i"/comm)" && builtin echo "$i - $comm - $j" && ACTIVE_PTSS+=( [$j]="$comm" )
    		done
	done
}

##PURE_DOC##
##PURE_HEADER:get_tty
#get_tty
# Get tty or pts currently being used
# 
# @usage get_tty
##PURE_DOC_END##
get_tty() (
    is_num ${1} || return ${ERRTBL[BAD_ARG]}
    for i in /dev/pts/* /dev/tty*; do 
    		test "/proc/$1/fd/0" -ef $i && builtin echo "$i" && break
	done
)

##PURE_DOC##
##PURE_HEADER:broadcast_pts
#broadcast_pts
# Send to all active pts the given message
# Note: get_all_tty must be called to fill all the active pts
# 
# @usage broadcast_pts <message>
##PURE_DOC_END##
broadcast_pts() (
	[[ -n "$1" ]] || return ${ERRTBL[BAD_ARG]}
	for i in "${!ACTIVE_PTSS[@]}"; do
		builtin echo "$1" > "$i"
	done
)

##PURE_DOC##
##PURE_HEADER:broadcast_tty
#broadcast_tty
# Send to all active tty the given message
# Note: get_all_tty must be called to fill all the active tty
# 
# @usage broadcast_tty <message>
##PURE_DOC_END##
broadcast_tty() (
	[[ -n "$1" ]] || return ${ERRTBL[BAD_ARG]}
	for i in "${!ACTIVE_TTYS[@]}"; do
		builtin echo "$1" > "$i"
	done
)

##PURE_DOC##
##PURE_HEADER:send_to_pts
#send_to_pts
# Send message to the given pts
# Note: get_all_tty must be called to fill all the active pts
# 
# @usage send_to_pts <message> <pts_number>
##PURE_DOC_END##
send_to_pts() (
	is_num ${2} || return ${ERRTBL[BAD_ARG]}
	[[ -n "${ACTIVE_PTSS[/dev/pts/$2]}" ]] || { error "No such pts /dev/pts/$2" ; return "${ERRTBL[NO_FILE]}"; }
	builtin echo "${1}" > "/dev/pts/$2"
)

##PURE_DOC##
##PURE_HEADER:send_to_tty
#send_to_tty
# Send message to the given tty
# Note: get_all_tty must be called to fill all the active tty
# 
# @usage send_to_tty <message> <tty_number>
##PURE_DOC_END##
send_to_tty() (
	is_num ${2} || return ${ERRTBL[BAD_ARG]}
	[[ -n "${ACTIVE_PTSS[/dev/tty$2]}" ]] || { error "No such pts /dev/tty$2" ; return "${ERRTBL[NO_FILE]}"; }
	builtin echo "${1}" > "/dev/tty$2"
)