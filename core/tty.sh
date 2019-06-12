#!/usr/bin/env bash

require "core/opp"

##PURE_DOC##
##PURE_HEADER:get_all_tty
#get_all_tty:
# Get all tty being used
# 
# @usage get_all_tty
##PURE_DOC##
get_all_tty() (
    for i in $(printf "%s\n" /proc/*); do
    		for j in $(printf "%s\n" /dev/pts/* /dev/tty*); do 
        		test $i/fd/0 -ef $j && builtin echo "$i - $(<$i/comm) - $j"
    		done
	done
)

##PURE_DOC##
##PURE_HEADER:get_tty
#get_tty
# Get tty currently being used
# 
# @usage get_tty
##PURE_DOC##
get_tty() (
    is_num ${1} || return ${ERRTBL[BAD_ARG]}
    for i in $(printf "%s\n" /dev/pts/* /dev/tty*); do 
    		test "/proc/$1/fd/0" -ef $i && builtin echo "$i" && break
	done
)