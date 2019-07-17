#!/usr/bin/env bash

##PURE_DOC##
##PURE_MODULE:base64
# Base64 module, turn text into base64 formated strings
# and backward
##PURE_DOC_END##

require "core/opp"

declare -g -r b64=( {A..Z} {a..z} {0..9} {+,/} )

##PURE_DOC##
##PURE_HEADER:b64_decode
#b64_decode:
# Decode a base64 string into plain text
# 
# @usage b64_decode <base64_string>
##PURE_DOC_END##
b64_decode() (
    decodeblock() {
        local in=( $* ) out index i
        out[0]=$(( ${in[0]} << 2 | ${in[1]} >> 4 ))
        case ${#in[@]} in
            3)  out[1]=$(( ((${in[1]} & 0x0f) << 4) | ${in[2]} >> 2 ))
                out[2]=$(( ((${in[2]} & 0x03) << 6) ));;
            4)  out[1]=$(( ((${in[1]} & 0x0f) << 4) | ${in[2]} >> 2 ))
                out[2]=$(( ((${in[2]} & 0x03) << 6) | ${in[3]} ));;
        esac
        for i in "${out[@]}"; do
            chr "$i"
        done
    }

    local i=0 phase=0 block p b64src="$1"
    while read -r -n1 c; do
        [[ "$c" == '=' ]] && decodeblock "${b64src[@]}" && break
        p="${b64[@]}"
        p="${p//' '/''}"
        p="${p%%$c*}"
        if [[ ${#p} -ge 0 ]]; then
            b64src[$phase]=${#p}
            phase=$(( ($phase + 1) % 4 ))
            if [[ $phase -eq 0 ]]; then
                decodeblock "${b64src[@]}"
                b64src=()
            fi
        fi
        ((i++))
    done < <(printf "%s" "$b64src")
)

##PURE_DOC##
##PURE_HEADER:b64_encode
#b64_encode:
# Encode plain text into base64 string
# 
# @usage b64_encode <plain_text>
##PURE_DOC_END##
b64_encode() (
    encodeblock() {
        local len=$1 && shift
        local in=( $* ) out index
        index=$(( ${in[0]} >> 2 ))
        out[0]=${b64[$index]}
        index=$(( ((${in[0]} & 0x03) << 4) | ((${in[1]} & 0xf0) >> 4) ))
        out[1]=${b64[$index]}
        index=$(( ((${in[1]} & 0x0f) << 2) | ((${in[2]} & 0xc0) >> 6) ))
        out[2]=$( (($len > 1)) && builtin echo -n ${b64[$index]} || builtin echo -n '=' )
        index=$(( ${in[2]} & 0x3f ))
        out[3]=$( (($len > 2)) && builtin echo -n ${b64[$index]} || builtin echo -n '=' )
        printf "%s" "${out[@]}"
    }

    local block j=0 len clrstr="$*" i
    while [[ -n "${clrstr:$j:1}" ]]; do
        len=0
        for (( i = 0 ; i < 3 ; i++ )); do
            block[$i]="$(ord "${clrstr:$j:1}")"
            [[ -n "${clrstr:$j:1}" ]] && { ((len++)) ; ((j++)); }
        done
        [[ -n $len ]] && encodeblock $len ${block[*]}
        block=() ; len=0
    done
)