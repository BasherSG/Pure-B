#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:conf
# Module to manage a simple configuration file
# composed of pairs name=value per line
# each line will be translated into an entry
# into the associative array CONFIG_VALS
##PURE_DOC##

require "core/mssg"
require "core/util"

declare -g CONFILE="${SELFNAME}.conf"
declare -g -A CONFIG_VALS
declare -g CONFIG_SEP='='

##PURE_DOC##
##PURE_HEADER:config_write
#config_write:
# Write the associative array CONFIG_VALS into the 
# default configuration file CONFILE
# 
# @usage config_write
##PURE_DOC##
config_write() {
    local i
    for i in "${!CONFIG_VALS[@]}"; do
        builtin echo "${i}${CONFIG_SEP}${CONFIG_VALS[${i}]}"
    done > "$CWD/$CONFILE"
}

##PURE_DOC##
##PURE_HEADER:config_read
#config_read:
# Read the default configuration file and dump 
# the contents into the associative array CONFIG_VALS
#
# @usage config_read
##PURE_DOC##
config_read() {
    parce_file "$CONFIG_SEP" "$CWD/$CONFILE" || return $?
    clone_var ASSOC CONFIG_VALS
}