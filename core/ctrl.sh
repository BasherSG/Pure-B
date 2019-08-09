#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:ctrl
# Control module; control the behavior of your scripts 
# piping numbers into a control file each number is translated
# into an action, the child process 'watcher', does all 
# the dirty work for you sending back SIGTSTP every 
# time the control file changes.
# 
# It's a great way to comunicate with a daemon
# 
# default control file actons 0='none' 1='graceful 
# exit' 2='restart script'
# 
##PURE_DOC_END##

require "core/opp"

declare -ag ACTIONS=( [1]='exit 0' [2]='restart' )
declare -g CTRL_FILE="${CTRL_FILE:-"${SELFNAME}.ctl"}"
declare -gi WATHCER=0

##PURE_DOC##
##PURE_HEADER:reset_ctrl
#reset_ctrl:
# Reset the control file back to 0
# 
# @usage reset_ctrl
##PURE_DOC_END##
reset_ctrl() (
    builtin echo 0 > "${CWD}/${CTRL_FILE}"
)

##PURE_DOC##
##PURE_HEADER:write_ctrl
#write_ctrl:
# Write number into the control file CTRL_FILE
# 
# @usage write_ctrl <number>
##PURE_DOC_END##
write_ctrl() (
    is_num ${1} || return $?
    builtin echo ${1} > "${CWD}/${CTRL_FILE}"
)

##PURE_DOC##
##PURE_HEADER:set_action
#set_action:
# Set the specified action for the desired number,
# default actions can be overwriten
# 
# @usage set_action <number> <action|function_call|command>
##PURE_DOC_END##
set_action() {
    is_num ${1} && (($1 > 0)) && shift 1 || return $?
    ACTIONS[${_}]="${*}"
}
alias sa="set_action "

##PURE_DOC##
##PURE_HEADER:push_action
#push_action:
# Push the specified action into the ACTIONS array
# 
# @usage push_action <action|function_call|command> <command_arguments>
##PURE_DOC_END##
push_action() {
    local IFS=' '
    ACTIONS+=("${*}")
}
alias pa="push_action "

##PURE_DOC##
##PURE_HEADER:restart
#restart:
# Restart the current script instance
# 
# @usage restart
##PURE_DOC_END##
restart() {
    IFS=' '
    ( "${CWD}/${SELF}" $* ) & disown $!
    exit 0
}

##PURE_DOC##
##PURE_HEADER:ctrl
#ctrl:
# Read the control file and execute action
# 
# @usage ctrl
##PURE_DOC_END##
ctrl() {
    local IFS=' ' ctrl=0
    read -r -n1 ctrl < "${CWD}/${CTRL_FILE}"
    is_num "${ctrl}" || { reset_ctrl && return 1; }
    [[ ${ctrl} -eq 0 ]] && return 0
    [[ -n ${ACTIONS[${ctrl}]} ]] || { reset_ctrl && return 1; }
    eval "${ACTIONS[${ctrl}]}"
    reset_ctrl
}

watch_me() {
    local watcher="
    #!/usr/bin/env bash

    cd /tmp

    CWD=/tmp

    source '${LWD}/pure.sh'

    require core/daemon
    require core/opp
    require core/util

    lock

    while true; do
        fake_sleep 1s
        test -e /proc/$$/comm || exit
        read -r -n1 ctrl < '${CWD}/${CTRL_FILE}'
        is_num \${ctrl} || { builtin echo 0 > '${CWD}/${CTRL_FILE}' && continue; }
        [[ \${ctrl} -eq 0 ]] && continue
        kill -'${SIGTBL[CTRL_WTCH]}' $$ || exit
    done
    "
    bash <(builtin echo "$watcher") & WATCHER=$!
    trap "ctrl" "${SIGTBL[CTRL_WTCH]}"
    unset -f watch_me
}

reset_ctrl
watch_me