#!/usr/bin/env bash

declare CWD="$( cd -P "$([[ -d "${0%/*}" ]] && echo "${0%/*}" || pwd)" && pwd )"

source "$CWD/../pure.sh"

require "core/util"

# tag_reader() {

# }

alias reset='printf "\ec"'

show_modules() {
	reset
	local i c=1 IFS=':'
	echo "Modules in package $1:" 
	for i in ${PACKAGES[$1]}; do
		printf '\t%s => %s\n' "$c" "$i" && ((c++))
	done
}

show_packages() {
	reset
	local i c=1
	echo "Packages found so far:"
	for i in "${!PACKAGES[@]}"; do
		printf '\t%s => %s\n' "$c" "$i" && ((c++))
	done
}

show_packages

# for i in 
# mapfile -C 'tag_reader' -c 1 < 
