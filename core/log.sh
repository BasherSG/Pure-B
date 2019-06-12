#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:log
# Log module, simple module to easily log into the 
# default logging file 
##PURE_DOC##

require "core/util"

declare -g LOGFILE="${SELFNAME}.log"

##PURE_DOC##
##PURE_HEADER:log_mssg
#log_mssg:
# Log all the output messages defined into mssg module.
# Call once to enable
#
# @usage log_mssg
##PURE_DOC##
log_mssg() {
    alias fatal=': "FATAL" ; log'
    alias error=': "ERROR" ; log'
    alias warning=': "WARNING" ; log'
    alias info=': "INFO" ; log'
    alias fine=': "FINE" ; log'
}

##PURE_DOC##
##PURE_HEADER:log_echo
#log_echo:
# Enable echo logging 
# Call once to enable
#
# @usage log_echo
##PURE_DOC##
log_echo() {
    alias echo=': "ECHO" ; log'
}


##PURE_DOC##
##PURE_HEADER:log_stop
#log_stop:
# Stop logging functions
#
# @usage log_stop
##PURE_DOC##
log_stop() {
    unalias fatal error warning info fine echo
}

##PURE_DOC##
##PURE_HEADER:log
#log:
# Log the given message
#
# @usage log <message>
##PURE_DOC##
log() {
    local tag="$_" fatal=$( [[ "$tag" == "FATAL" ]] && true || false ) status=${2:-100}
    test -n "$1" && printf '%s - %s %s\n' "$(fake_date [%x-%T])" "$tag:" "$1 - $($fatal && printf "%s" "EXIT STATUS: $status")" >> "$CWD/$LOGFILE"
    $fatal && exit $status
}
