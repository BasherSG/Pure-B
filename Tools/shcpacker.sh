#!/usr/bin/env bash

declare CWD="$( cd -P "$([[ -d "${0%/*}" ]] && echo "${0%/*}" || pwd)" && pwd )"

source "$CWD/../pure.sh"

require "core/util"

declare -g MAIN_FILE="${ARGS[1]}" 
test -n "$MAIN_FILE" || fatal "Please provide an input file" "${ERRTBL[NO_FILE]}"
declare -g OUTPUT_FILE="${ARGS[2]:-${MAIN_FILE}.o}"
: > "$OUTPUT_FILE"
declare -gA TO_DUMP=()

find_requires() {
	local i match
	if [[ "$2" =~ require\ [\'\"]?([_a-z]+\/?[_a-z]+)[\'\"]?\ ?\;? ]]; then
		match="${BASH_REMATCH[1]}"
		if [[ -n "${PACKAGES["$match"]}" ]]; then
			local IFS=':'
			for i in ${PACKAGES[$match]}; do 
				[[ -n "${MODULES[$match/$i]}" ]] && TO_DUMP["$match/$i"]="${MODULES[$match/$i]}"
			done
		else
			[[ -n "${MODULES[$match]}" ]] && TO_DUMP[$match]="${MODULES[$match]}"
		fi
	fi
}

dump() {
	if [[ ! "$2" =~ require\ [\'\"]?([_a-z]+\/?[_a-z]+)[\'\"]?\ ?\;? ]] && \
	[[ ! "$2" =~ source\ *.*${SELF_PURE##*/} ]] && \
	[[ ! "$2" =~ ^\# ]]; then
		builtin echo -n "$2" >> "$OUTPUT_FILE"
	fi
}

mapfile -C 'find_requires' -c 1 < "$MAIN_FILE"
for i in "${TO_DUMP[@]}"; do
	mapfile -C 'find_requires' -c 1 < "$i"
done

builtin echo '#!'"$(command -v bash)"'

declare -rg SELF="${0##*/}"
declare -rg SELFNAME="${SELF%.*}"

for i in "$@"; do
	: "${i//-/}"
	if [[ ! "$i" =~ "--debug" ]]; then ARGS[$c]="$i" && ((c++)) ; else set -x ; fi
done

depend() {
    [[ -n "$1" ]] || return 1
    command -v "$1" > /dev/null || { builtin echo "No such command ${1}" ; exit "${ERRTBL[MISS_DEPEND]}"; }
    unset -f "$1"
}' >> "$OUTPUT_FILE"

for i in "${TO_DUMP[@]}"; do
	mapfile -C 'dump' -c 1 < "$i"
	builtin echo >> "$OUTPUT_FILE"
done

mapfile -C 'dump' -c 1 < "$MAIN_FILE"