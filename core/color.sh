#!/usr/bin/env bash

require "core/mssg"
require "core/opp"

declare -g BOLD='0'
declare -g BACK='3'
declare -g RED="\e[${BOLD};${BACK}1m"
declare -g GREEN="\e[${BOLD};${BACK}2m"
declare -g YELLOW="\e[${BOLD};${BACK}3m"
declare -g BLUE="\e[${BOLD};${BACK}4m"
declare -g CYAN="\e[${BOLD};${BACK}5m"
declare -g AQUA="\e[${BOLD};${BACK}6m"
declare -g WHITE="\e[${BOLD};${BACK}7m"
declare -g NC="\e[${BOLD};0m"
declare -gA COLOR=( ['MAIN']="${NC}" )
declare -gA REGEX=()

echo() (
    : ''
    [[ "$1" == '-n' ]] && shift 1 && : '-n'
    if [[ -z "${REGEX[*]}" ]]; then
        builtin echo $_ -e "${COLOR[MAIN]}$*${NC}"
    else
        local buff="$*" RGX
        for RGX in "${!REGEX[@]}"; do 
            [[ "$buff" =~ $RGX ]] && buff="${buff//${BASH_REMATCH[0]}/${COLOR[$RGX]}${BASH_REMATCH[0]}${NC}}"
        done
        builtin echo -e "$buff"
    fi
)

##PURE_DOC##
##PURE_HEADER:hex_to_rgb
#hex_to_rgb:
# Convert hex color format into rgb color format
# 
# @usage hex_to_rgb <six_digit_hex_color>
# @source https://github.com/dylanaraps/pure-bash-bible#convert-a-hex-color-to-rgb
# @author Dylan Araps
##PURE_DOC_END##
hex_to_rgb() (
    #        hex_to_rgb "000000"
    : "${1/\#}"
    ((r=16#${_:0:2},g=16#${_:2:2},b=16#${_:4:2}))
    printf '%s\n' "$r $g $b"
)


##PURE_DOC##
##PURE_HEADER:rgb_to_hex
#rgb_to_hex:
# Convert rgb color format to hex color format
# 
# @usage rgb_to_hex <red_ascii_color> <green_ascii_color> <blue_ascii_color>
# @source https://github.com/dylanaraps/pure-bash-bible#convert-an-rgb-color-to-hex
# @author Dylan Araps
##PURE_DOC_END##
rgb_to_hex() (
    printf '#%02x%02x%02x\n' "$1" "$2" "$3"
)

##PURE_DOC##
##PURE_HEADER:is_hex_color
#is_hex_color:
# Validate whether the suplied string is a valid hex color or not
# 
# @usage is_hex_color <six_digit_hex_color>
# @source https://github.com/dylanaraps/pure-bash-bible#use-regex-on-a-string
# @author Dylan Araps
# @author Basher SG
##PURE_DOC_END##
is_hex_color() (
    if [[ $1 =~ ^(#?([a-fA-F0-9]{6}|[a-fA-F0-9]{3}))$ ]]; then
        return 0
    else
        error "$1 is an invalid color."
        return 1
    fi
)

##PURE_DOC##
##PURE_HEADER:color
#color:
# Apply specified color to the subsequent echo calls
# 
# @usage color <six_digit_hex_color|red_ascii_color> <green_ascii_color> <blue_ascii_color> <label>
##PURE_DOC_END##
color() {
    local label
    (($# >= 1)) || return "${ERRTBL[BAD_COLOR]}"
    local red green blue
    if (( "${#1}" == 6 )) && is_hex_color "$1" ; then
        IFS=' ' read red green blue < <(hex_to_rgb "$1")
        label="${2:-MAIN}"
    else
        red="$1"
        green="$2"
        blue="$3"
        label="${4:-MAIN}"
    fi
    IS_NUM_CAP=255
    is_num "$red" "$green" "$blue" || return "${ERRTBL[BAD_COLOR]}"
    COLOR["$label"]="\e[1m\e[38;2;${red};${green};${blue}m"
}

##PURE_DOC##
##PURE_HEADER:regex_color
#regex_color:
# Apply specified color to the specified regex pattern to subsequent echo calls
# 
# @usage regex_color <regex> <six_digit_hex_color|red_ascii_color> <green_ascii_color> <blue_ascii_color>
##PURE_DOC_END##
regex_color() {
    local IFS=' ' label="$1"
    (($# >= 2)) || return "${ERRTBL[BAD_ARG]}"
    REGEX["$label"]="$label" && shift 1
    color $* "$label"
}

no_color() {
    if [[ -z $* ]]; then
        COLOR=( ['MAIN']="${NC}" )
        REGEX=()
    else
        for i in "$@"; do
            unset "${COLOR[$i]}"
        done
    fi
}
