#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:sigcomm
# Sigcomm module, the most unpractical, complicated way for
# process to comunicate with each other, once the languaje()
# function is called the script will listen for the signal 
# 63 for incoming messages.
# 
# The languaje chart is defined using 16 singals starting 
# on 34 (hexadecimal 0) and ending on 49 (hexadecimal f)
# each ascii character is composed of 2 hexadecimal 
# characters.
# 
# To stablish comunication the PEER variable must point 
# to the PID of the process that has the same module 
# loaded.
# 
# @autor: Sergio Gutiérrez
# @since: 15/03/2019
##PURE_DOC_END##

require "core/util"
require "core/opp"

declare -gA LANG=( [0]=34 [1]=35 [2]=36 [3]=37 [4]=38 [5]=39 [6]=40 [7]=41 [8]=42 [9]=43 [a]=44 [b]=45 [c]=46 [d]=47 [e]=48 [f]=49 )

declare -g CHAR STACK PEER LISTEN="false"

listen_trap() {
    if $1; then
        trap 'listen true; concat' 63
        trap 'listen false; translate' 64
    else 
        trap '' 63
        trap '' 64
    fi
}

##PURE_DOC##
##PURE_HEADER:languaje
#languaje:
# Function to start listening for incoming messages
# 
# @usage languaje
##PURE_DOC_END##
languaje() {
    listen_trap false

    trap "concat 0" ${LANG[0]}
    trap "concat 1" ${LANG[1]}
    trap "concat 2" ${LANG[2]}
    trap "concat 3" ${LANG[3]}
    trap "concat 4" ${LANG[4]}
    trap "concat 5" ${LANG[5]}
    trap "concat 6" ${LANG[6]}
    trap "concat 7" ${LANG[7]}
    trap "concat 8" ${LANG[8]}
    trap "concat 9" ${LANG[9]}
    trap "concat a" ${LANG[a]}
    trap "concat b" ${LANG[b]}
    trap "concat c" ${LANG[c]}
    trap "concat d" ${LANG[d]}
    trap "concat e" ${LANG[e]}
    trap "concat f" ${LANG[f]}
}

listen() { $1 2>/dev/null && LISTEN="true" || LISTEN="false"; }

concat() {
    if $LISTEN; then
        CHAR+="$1"
        [[ "${#CHAR}" -eq 2 ]] && { STACK+="$CHAR " ; unset CHAR; }
    fi
}

translate() {
    local i
    if ! $LISTEN && [[ -n "$STACK" ]]; then
        # echo "$STACK - $CHAR" #DEBUG
        listen_trap false
        for i in $STACK; do
            hchr "$i"
        done
        unset STACK CHAR
        listen_trap true
    fi
}

speak() {
    # kill -INT $PEER
    fake_sleep 0.025s 
    [[ -n "$1" ]] && { kill -n "$1" "$PEER" || return 1; }
}

##PURE_DOC##
##PURE_HEADER:send
#send:
# Send the given message to the peer process
# 
#   Note: this function does not has 
#         arguments to send a message, 
#         pipe it (echo <message> | send) 
#         or type the message by hand.
# 
# @usage send
##PURE_DOC_END##
send() {
    if [[ -n "$PEER" ]]; then
        speak 63
        while IFS= read -r -n1 char; do
            hex "$char" | while IFS= read -d\ -r -n1 hex; do
                sig="${LANG["$hex"]}"
                # echo "$hex - $sig - $PEER" #DEBUG
                speak $sig
            done
        done 
        speak 64
    fi
}

languaje