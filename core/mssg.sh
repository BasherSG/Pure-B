#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:log
# Mssg module, provides UI functions.
# Show warnings, information and errors
##PURE_DOC_END##

require "core/color"

##PURE_DOC##
##PURE_HEADER:fatal
#fatal:
# Display a fatal error message and exit with the given exit status
# 
# @usage fatal <message> <exit_status>
##PURE_DOC_END##
fatal() {
    color 255 0 0
    \echo "[:FATAL:]" "$1" 1>&2
    exit ${2:-100}
}

##PURE_DOC##
##PURE_HEADER:error
#error:
# Display an error message
# 
# @usage error <message>
##PURE_DOC_END##
error() (
    regex_color ':ERROR:' 255 0 0
    \echo "[:ERROR:]" "$1" 1>&2
)

##PURE_DOC##
##PURE_HEADER:warning
#warning:
# Display a warning message
# 
# @usage warning <message>
##PURE_DOC_END##
warning() (
    regex_color ':WARNING:' 230 230 0
    \echo "[:WARNING:]" "$1" 1>&2
)

##PURE_DOC##
##PURE_HEADER:info
#info:
# Display an informative message
# 
# @usage info <message>
##PURE_DOC_END##
info() (
    regex_color ':INFO:' 100 100 255
    \echo "[:INFO:]" "$1"
)

##PURE_DOC##
##PURE_HEADER:fine
#fine:
# Display an all ok message
# 
# @usage fine <message>
##PURE_DOC_END##
fine() (
    regex_color ':OK:' 0 255 0
    \echo "[:OK:]" "$1"
)

##PURE_DOC##
##PURE_HEADER:status
: << DEPRECATED
#status:
# Display a status based uppon the last exit status
# 0 - OK
# 1 - NOK
# 2 - INF
# 3 - WRN   
# 
# @usage status <message> <status>
DEPRECATED
##PURE_DOC_END##
status() (
    local IFS=| var=( ${1} )
    case $? in
        0) printf "[${GREEN}%s${NC}] - %s" 'OK' "${var[0]}";;
        1) printf "[${RED}%s${NC}] - %s" 'NOK' "${var[1]}";;
        2) printf "[${BLUE}%s${NC}] - %s" 'INF' "${var[2]}";;
        3) printf "[${YELLOW}%s${NC}] - %s" 'WRN' "${var[3]}";;
        *) printf '\r'
    esac
)

##PURE_DOC##
##PURE_HEADER:prompt
#prompt:
# Display a simple yes/no prompt
# 
# @usage prompt <message>
##PURE_DOC_END##
prompt() (
    read -r -p "$1 (Y/N)"
    [[ "$REPLY" =~ [Yy] ]] || return 1 
)
