#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:string
# String utilities module, miscellaneous utilities to transform, trim, cut, and
# find strings
##PURE_DOC_END##

require "core/opp"
require "core/util"

##PURE_DOC##
##PURE_HEADER:cycle
#cycle:
# Cycle through each string element
# 
# @usage cycle <string>
# @author Dylan Araps
# @author Basher SG
# @source https://github.com/dylanaraps/pure-bash-bible#cycle-through-an-array
##PURE_DOC_END##
cycle() {
    printf '%s' "${1:${i:=0}:1}"
    ((i=i>=${#1}-1?0:++i))
}

##PURE_DOC##
##PURE_HEADER:hstring
#hstring:
# Convert hex string to ascii string
# 
# @usage hstring <hex_string>
##PURE_DOC_END##
hstring() {
	while read -N2 -r hex; do
		hchr "$hex"
	done <<< "${@}"
}

##PURE_DOC##
##PURE_HEADER:stringh
#stringh:
# Convert ascii string to hex string
# 
# @usage stringh <string>
##PURE_DOC_END##
stringh() {
	local IFS=' '
	while read -N1 -r char; do
		hex "$char"
	done < <(printf "%s" "${@}")
}

##PURE_DOC##
##PURE_HEADER:hamming_dist
#hamming_dist:
# Calculate the hamming distance between two strings
# 
# @usage hamming_dist <string> <string>
##PURE_DOC_END##
hamming_dist() {
	local dist=0
	local d1 d2
	while read -N1 -r -u4 char1 && read -N1 -r -u5 char2; do
		d1=$(ord "$char1")
		d2=$(ord "$char2")
		for ((val=($d1^$d2) ; val>0 ; val/=2)); do
			((val&1)) && ((dist++))
		done
	done 4<<< "${1}" 5<<< "${2}"
	printf "%s" "$dist"
}

##PURE_DOC##
##PURE_HEADER:enxor
#enxor:
# Xor the guiven string using the key string
# 
# @usage enxor <string> <key>
##PURE_DOC_END##
enxor() {
	local string="${1}" i=0
	local key="${2}" 
	declare -ri key_len=${#key}
	[[ -n "$string" ]] && [[ -n "$key" ]] || return 1
	while read -N1 -r char; do
		dhex $(xor "$(ord "$char")" "$(ord "${key:${i:=0}:1}")")
		((i=i>=key_len-1?0:++i))
	done < <(printf '%s' "${string}")
}

##PURE_DOC##
##PURE_HEADER:dexor
#dexor:
# Un-xor the guiven string using the key string
# 
# @usage dexor <hex_string> <key>
##PURE_DOC_END##
dexor() {
	local hstring="${1}" i=0
	local key="${2}" 
	declare -ri key_len=${#key}
	[[ -n "$hstring" ]] && [[ -n "$key" ]] || return 1
	while read -N2 -r hex; do
		chr $(xor "$(hdec "$hex")" "$(ord "${key:${i:=0}:1}")")
		((i=i>=key_len-1?0:++i))
	done <<< "${hstring}"
}