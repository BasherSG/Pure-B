#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:cursor
# Cursor module, a proof of concept about tracking 
# and moving the cursor position based upon the 
# mouse position or a click location
# 
# @autor: Sergio Gutiérrez
# @since: 15/03/2019
##PURE_DOC##

declare -g KEY_UP='\e[A'
declare -g KEY_DOWN='\e[B'
declare -g KEY_RIGHT='\e[C'
declare -g KEY_LEFT='\e[D'

cursor_up() {
    printf "\e[${1:-1}A"
}

cursor_down() {
    printf "\e[${1:-1}B"
}

cursor_right() {
    printf "\e[${1:-1}C"
}

cursor_left() {
    printf "\e[${1:-1}D"
}

enable_mouse_tracking() {
    printf '\e[?1003h'
    printf '\e[?1015h'
    printf '\e[?1006h'
}

enable_click_tracking() {
    printf '\e[?1002h'
    printf '\e[?1015h'
    printf '\e[?1006h'
}

disable_tracking() {
    printf '\e[?1000l'
}

mouse_handler() {
    while IFS=\; read -d$'\e[' -r -a pos -u1; do
        printf "\e[${pos[2]:: -1};${pos[1]}H"
    done
}