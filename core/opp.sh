#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:opp
# Opp module; Aritmetical, logical, conversion 
# functions
##PURE_DOC_END##

require "core/mssg"

declare -g BIN_256=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
declare -g HEX_256=({{0..9},{A..F}}{{0..9},{A..F}})
declare -ga GALOIS_GEN=(
    [3]=3 [5]=5 [6]=6 [9]=9 
    [11]=11 [14]=14 [17]=17 [18]=18 
    [19]=19 [20]=20 [23]=23 [24]=24 
    [25]=25 [26]=26 [28]=28 [30]=30 
    [31]=31 [33]=33 [34]=34 [35]=35 
    [39]=39 [40]=40 [42]=42 [44]=44 
    [48]=48 [49]=49 [60]=60 [62]=62 
    [63]=63 [65]=65 [69]=69 [70]=70 
    [71]=71 [72]=72 [73]=73 [75]=75 
    [76]=76 [78]=78 [79]=79 [82]=82 
    [84]=84 [86]=86 [87]=87 [88]=88 
    [89]=89 [90]=90 [91]=91 [95]=95 
    [100]=100 [101]=101 [104]=104 [105]=105 
    [109]=109 [110]=110 [112]=112 [113]=113 
    [118]=118 [119]=119 [121]=121 [122]=122 
    [123]=123 [126]=126 [129]=129 [132]=132 
    [134]=134 [135]=135 [136]=136 [138]=138 
    [142]=142 [143]=143 [144]=144 [147]=147 
    [149]=149 [150]=150 [152]=152 [153]=153 
    [155]=155 [157]=157 [160]=160 [164]=164 
    [165]=165 [166]=166 [167]=167 [169]=169 
    [170]=170 [172]=172 [173]=173 [178]=178 
    [180]=180 [183]=183 [184]=184 [185]=185 
    [186]=186 [190]=190 [191]=191 [192]=192 
    [193]=193 [196]=196 [200]=200 [201]=201 
    [206]=206 [207]=207 [208]=208 [214]=214 
    [215]=215 [218]=218 [220]=220 [221]=221 
    [222]=222 [226]=226 [227]=227 [229]=229 
    [230]=230 [231]=231 [233]=233 [234]=234 
    [235]=235 [238]=238 [240]=240 [241]=241 
    [244]=244 [245]=245 [246]=246 [248]=248 
    [251]=251 [253]=253 [254]=254 [255]=255
)
declare -g -a LOG_TBL=()
declare -g -a ALOG_TBL=()
declare -g -i IS_NUM_CAP=0                  

##PURE_DOC##
##PURE_HEADER:is_num
#is_num:
# Tests whether all the suplied params are numbers
# if not, the return status is the numerical position 
# of the offending arg
# 
# @usage is_num <number1> <number2> ... <numberN>
##PURE_DOC_END##
is_num() (
    trap "IS_NUM_CAP=0" RETURN
    [[ -z "${*}" ]] && return 1
    local TMP=( ${@} ) i
    for ((i=0 ; i<${#TMP[@]} ; i++)) ; do
        [[ ${TMP[$i]} =~ ^-?[0-9]+([.][0-9]+)?$ ]] || return $((++i))
        (( IS_NUM_CAP > 0 )) && ((${TMP[$i]} > IS_NUM_CAP )) && return $((++i))
    done
    return 0
)

##PURE_DOC##
##PURE_HEADER:min
#min:
# Find the minimum number
# 
# @usage min <number1> <number2> ... <numberN>
##PURE_DOC_END##
min() (
    : $1
    for i in "${@}"; do
        [[ ${i} =~ ^-?[0-9]+$ ]] || return 1
        ((i<_)) && : $i || : $_
    done
    printf '%s' $_
)

##PURE_DOC##
##PURE_HEADER:max
#max:
# Find the maximum number
# 
# @usage max <number1> <number2> ... <numberN>
##PURE_DOC_END##
max() (
    : $1
    for i in "${@}"; do
        [[ ${i} =~ ^-?[0-9]+$ ]] || return 1
        let i>_ && : $i || : $_
    done
    printf '%s' $_
)

##PURE_DOC##
##PURE_HEADER:get_sign
#get_sign:
# Return true if the given number is positive or 1
# if negative
# 
# @usage get_sign <number>
##PURE_DOC_END##
get_sign() (
    is_num $1 || return 2
    [[ $1 -gt 0 ]] && return 0 || return 1
)

##PURE_DOC##
##PURE_HEADER:ord
#ord:
# Convert given character to decimal ascii value
# 
# @usage ord <character>
##PURE_DOC_END##
ord() (
    printf '%d' "'$1"
)

##PURE_DOC##
##PURE_HEADER:ucod
#ucod:
# Print the corresponding unicode format for the given character
# 
# @usage ucod <character>
##PURE_DOC_END##
ucod() (
    printf '\\u%04x' "'$1"
)

##PURE_DOC##
##PURE_HEADER:chr
#chr:
# Convert given decimal ascii number to character
# 
# @usage chr <ascii_decimal>
##PURE_DOC_END##
chr() (
	[[ "$1" -gt 0 ]] && [[ "$1" -lt 256 ]] || return 1
	printf "\x$(printf %x "$1")"
)

##PURE_DOC##
##PURE_HEADER:hchr
#hchr:
# Convert given hexadecimal ascii number to character
# 
# @usage hchr <ascii_hexadecimal>
##PURE_DOC_END##
hchr() (
	[[ "$(printf '%d' "0x$1")" -lt 256 ]] || return 1
	printf "\x$(printf %x 0x$1)"
)

##PURE_DOC##
##PURE_HEADER:hex
#hex:
# Convert given character to hexadecimal ascii value
# 
# @usage hex <character>
##PURE_DOC_END##
hex() (
	printf '%02x' "'$1"
)

##PURE_DOC##
##PURE_HEADER:hdec
#hdec:
# Convert given hexadecimal value to decimal
# 
# @usage hdec <hexadecimal_value>
##PURE_DOC_END##
hdec() (
	printf '%d' "0x$1"
)

##PURE_DOC##
##PURE_HEADER:dhex
#dhex:
# Convert given decimal value to hexadecimal
# 
# @usage dhex <decimal_value>
##PURE_DOC_END##
dhex() (
	printf '%02x' "$1"
)

##PURE_DOC##
##PURE_HEADER:and
#and:
# Perform the and operation between the two given args
# 
# @usage and <args1> <args2>
##PURE_DOC_END##
and() (
    printf '%s' $(($1 & $2))
)

##PURE_DOC##
##PURE_HEADER:or
#or:
# Perform the or operation between the two given args
# 
# @usage or <args1> <args2>
##PURE_DOC_END##
or() (
    printf '%s' $(($1 | $2))
)

##PURE_DOC##
##PURE_HEADER:xor
#xor:
# Perform the xor operation between the two given args
# 
# @usage xor <args1> <args2>
##PURE_DOC_END##
xor() (
    printf '%s' $(($1 ^ $2))
)

##PURE_DOC##
##PURE_HEADER:bshift_l
#bshift_l:
# Perform the bit shift left operation between the two given args
# 
# @usage bshift_l <args1> <args2>
##PURE_DOC_END##
bshift_l() (
    printf '%s' $(($1 << $2))
)

##PURE_DOC##
##PURE_HEADER:bshift_r
#bshift_r:
# Perform the bit shift right operation between the two given args
# 
# @usage bshift_r <args1> <args2>
##PURE_DOC_END##
bshift_r() (
    printf '%s' $(($1 >> $2))
)

##PURE_DOC##
##PURE_HEADER:finite_field_mult
#finite_field_mult:
# Perform the finite field multiplication operation between the two given args
# 
# @usage finite_field_mult <args1> <args2>
##PURE_DOC_END##
finite_field_mult() (
    local aa=$1 bb=$2 r=0
    while ((aa && bb)); do
        (($bb & 1)) && r=$(($r ^ $aa))
        (($aa & 0x80)) && aa=$((($aa << 1 ) ^ 0x11b)) || aa=$(($aa << 1))
        bb=$(($bb >> 1))
    done
    printf '%s' $r
)

##PURE_DOC##
##PURE_HEADER:finite_field_gen
#finite_field_gen:
# Generate the ATABLE and the LOG_TBL for the given galois generator seed
# 
# @usage finite_field_gen <seed>
##PURE_DOC_END##
finite_field_gen() {
    local c a=1 d g=$1 i
    [[ -n ${GALOIS_GEN[*]} ]] || return 1
    [[ -n $g ]] && [[ -n "${GALOIS_GEN[$g]}" ]] || { error "Galois generator $g not found using 3"$'\n' ; builtin echo "Available generators: ${GALOIS_GEN[*]}" ; g=3 ; }
    for i in {0..255}; do
        ALOG_TBL[$i]=$a
        a=$(finite_field_mult $g $a)
        LOG_TBL[${ALOG_TBL[$i]}]=$i
    done
    ALOG_TBL[255]=${ALOG_TBL[0]}
    LOG_TBL[0]=0
}