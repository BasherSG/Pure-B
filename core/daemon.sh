#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:daemon
# Daemon module, intended to easily run scripts as daemons,
# making them unique instances, so the script won't be 
# allowed to run multiple times at the same time
##PURE_DOC_END##

require "core/util"
require "core/mssg"

declare -g PIDFILE="${PIDFILE:-"/tmp/${SELFNAME}.pid"}"

##PURE_DOC##
##PURE_HEADER:lock
#lock:
# Locks the current instance of the script, using the 
# default PIDFILE
#
#@usage lock
##PURE_DOC_END##
lock() { (
        if [[ -e "$PIDFILE" ]]; then
            test -f "$PIDFILE" || fatal "$PIDFILE is not a regular file" ${ERRTBL[BAD_FILE]}
            test -r "$PIDFILE" || fatal "Can't read file $PIDFILE" ${ERRTBL[CANT_READ]}
            if [[ -s "$PIDFILE" ]] ; then
                local pid="$(builtin echo $(<$PIDFILE))"
                if [[ -d /proc/$pid ]]; then
                    test -r /proc/$pid/comm || fatal "Can't establish which process is using the pid: $pid" ${ERRTBL[CANT_READ]}
                    local process="$(builtin echo $(</proc/$pid/comm))"
                    [[ "$SELF" == "$process" ]] && fatal "Process $SELF is already running" ${ERRTBL[LOCK_ON]}
                fi
            fi
        fi
        umask 000
        builtin echo "$$" > "$PIDFILE"
    ) || exit $?
    trap_add 'release' EXIT
}

##PURE_DOC##
##PURE_HEADER:release
#release:
# Release the current lock
# 
#@usage release
##PURE_DOC_END##
release() {
    : > "$PIDFILE"
}

##PURE_DOC##
##PURE_HEADER:daemonize
#daemonize:
# Daemonize the current script instance, if
# it's attached to a terminal detach it
#
#@usage daemonize
#@warn Implies lock
##PURE_DOC_END##
daemonize() {
    lock
    set -m
    trap '' HUP
    [[ -t 0 ]] && info 'Please run "bg" to detach the process from the current terminal' && suspend -f
}

##PURE_DOC##
##PURE_HEADER:forever_sleep
#forever_sleep:
# Sleeps forever, useless unless used with 
# ctrl module and custom actions 
#
#@usage forever_sleep
##PURE_DOC_END##
forever_sleep() {
    while :; do fake_sleep 1h ; done
}