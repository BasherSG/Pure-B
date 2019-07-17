#!/usr/bin/env bash

require "core/util"

declare -g -a STACK

trap_add "get_stack ; print_trace" EXIT

##PURE_DOC##
##PURE_HEADER:get_stack
#get_stack:
# Get the call stack
#
# @usage get_stack
# @author codeforester
# @author akostadinov
# @source https://stackoverflow.com/questions/685435/trace-of-executed-programs-called-by-a-bash-script#answer-18873979
# @recovered 12/03/2019
##PURE_DOC_END##
get_stack() {
   STACK=""
   # to avoid noise we start with 1 to skip get_stack caller
   local i
   local stack_size=${#FUNCNAME[@]}
   for (( i=1; i<$stack_size ; i++ )); do
      local func="${FUNCNAME[$i]}"
      [ x$func = x ] && func=MAIN
      local linen="${BASH_LINENO[(( i - 1 ))]}"
      local src="${BASH_SOURCE[$i]}"
      [ x"$src" = x ] && src=non_file_source

      STACK[$i]=$'\t'"$func:|$src|$linen"
   done
}

##PURE_DOC##
##PURE_HEADER:print_trace
#print_trace:
# Call trace
#
# @usage print_trace
##PURE_DOC_END##
print_trace() (
    local IFS=\|
    printf "%s\n" "TRACE:"
    columns $'\t'"FUNCTION|SOURCE|LINE${STACK[*]}" 3 '|'
)
