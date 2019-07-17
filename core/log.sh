#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:log
# Log module, simple module to easily log into the
# default logging file
##PURE_DOC_END##

require "core/util"

declare -g LOGFILE="${LOGFILE:-"${SELFNAME}.log"}"
declare -gA LOG_FUNCTION_CACHE=()

##PURE_DOC##
##PURE_HEADER:log_mssg
#log_mssg:
# Log all the output messages defined into mssg module.
# Call once to enable
#
# @usage log_mssg
##PURE_DOC_END##
log_mssg() {
    LOG_FUNCTION_CACHE+=(
        ['fatal']="$(declare -f fatal)"
        ['error']="$(declare -f error)"
        ['warning']="$(declare -f warning)"
        ['info']="$(declare -f info)"
        ['fine']="$(declare -f fine)" )
    unset -f fatal error warning info fine
    fatal() { : "FATAL" ; log "$1" "$2"; }
    error() { : "ERROR" ; log "$1"; }
    warning() { : "WARNING" ; log "$1"; }
    info() { : "INFO" ; log "$1"; }
    fine() { : "FINE" ; log "$1"; }
}

##PURE_DOC##
##PURE_HEADER:log_echo
#log_echo:
# Enable echo logging
# Call once to enable
#
# @usage log_echo
##PURE_DOC_END##
log_echo() {
    LOG_FUNCTION_CACHE+=( ['echo']="$(declare -f echo)" )
    unset -f echo
    echo() { : "ECHO" ; log "$1"; }
}

##PURE_DOC##
##PURE_HEADER:log_stop
#log_stop:
# Stop logging functions
#
# @usage log_stop
##PURE_DOC_END##
log_stop() {
    for i in "${!LOG_FUNCTION_CACHE[@]}"; do 
        unset -f "$i"
        eval "${LOG_FUNCTION_CACHE[$i]}"
    done    
}

##PURE_DOC##
##PURE_HEADER:log
#log:
# Log the given message
#
# @usage log <message>
##PURE_DOC_END##
log() {
    local tag="$_" fatal status=${2:--1}
    [[ "$tag" == 'FATAL' ]] ; fatal=$?
    test -n "$1" && printf '%s - %s %s\n' "$(fake_date [%x-%T])" "$tag:" "$1 $( ((status>=0)) && printf "%s" "- EXIT STATUS: $status" )" >> "$CWD/$LOGFILE"
    ((fatal==0)) && exit $status
    return 0
}

: "START" ; log "New log entry pid:$$ comm:$SELF" 0
trap_add 'last=$?' EXIT
trap_add ': "END" ; log "End of log entry pid:$$ comm:$SELF" $last' EXIT