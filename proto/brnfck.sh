#!/usr/bin/env bash

# require "core/mssg"
require "core/dir"
# require "core/opp"
require "core/util"

declare -gr BF_VAR='VAR'
declare -gi BF_VARS_INDEX=0
declare -gA BF_VARS=( [${BF_VAR}${BF_VARS_INDEX}]=0 )
declare -gi CHR_POINT=0

# bf() {
#     local file=${1?'Please provide a brainfuck file to read'}
#     bftranslate() {
        
#         return 0
#     }
#     unset -f bftranslate
#     # flush_buffers() {

#     # }
#     unset -f flush_buffers
#     load_buffer() {
#         local level=0
#         while IFS= read -N1 -r c ; do
#             # (( loop != level )) && BF_BUFF+="${c//[\[\]]/}"
#             # (( loop == level )) && [[ "$c" == '[' ]] && loop+=1 && index=${BF_VARS_INDEX}
#             # if [[ "$c" == ']' ]]; then
#             #     end+=1
#             #     ((end == level)) && [[ ${BF_VARS[${BF_VAR}${index}]} -gt 0 ]] && sleep 10s && bf <(echo "$BF_BUFF") $index $((++level))
#             #     loop=false
#             # fi
#             # (( loop == level )) && { bftranslate "$c" || return 1; }
#             if [[ "$c" == '[' ]]; then 
#                 BF_BUFF[$BF_BUFF_INDEX]+=$((BF_BUFF_INDEX+1)) 
#                 ((BF_BUFF_INDEX++))
#                 ((level++))
#                 continue
#             fi
#             if ((level == $BF_BUFF_INDEX)) && [[ "$c" == ']' ]]; then
#                 BF_BUFF[$BF_BUFF_INDEX]+=$((BF_BUFF_INDEX-1)) 
#                 ((BF_BUFF_INDEX--))
#                 ((level--))
#                 continue
#             fi
#             BF_BUFF[$BF_BUFF_INDEX]+="$c"
#         done < "$file"
#     }
#     load_buffer
#     unset -f load_buffer
#     # local index=${2:-0} level=${3:-0} loop=$level end=$level

#     declare -p BF_BUFF

#     # bftranslate "$c"
# }

bf() {
    local c
    file_ok "$1"
    eval "$(get_chars "$1")"
    while (( $CHR_POINT < ${#chars[@]} )); do
        case "${chars[$CHR_POINT]}" in
            +) let BF_VARS[${BF_VAR}${BF_VARS_INDEX}]++ ;;
            -) let BF_VARS[${BF_VAR}${BF_VARS_INDEX}]-- ;;
            \>) ((BF_VARS_INDEX++)) ;;
            \<) [[ ${BF_VARS_INDEX} -gt 0 ]] && ((BF_VARS_INDEX--)) ;;
            \.) chr "${BF_VARS[${BF_VAR}${BF_VARS_INDEX}]}" ;;
            \,) 
                if [[ -t 0 ]]; then
                    read -r -n1 p
                    BF_VARS[${BF_VAR}${BF_VARS_INDEX}]=$(ord "$p")
                else
                    {  error 'The , operator requires an interactive terminal to be used' ; return 1; }
                fi;;
            \[) 
                if (( BF_VARS[${BF_VAR}${BF_VARS_INDEX}] == 0 )); then
                    local j=1 c2
                    while (( j > 0 )); do
                        c2=${chars[$((++CHR_POINT))]}
                        [[ "$c2" == '[' ]] && ((j++))
                        [[ "$c2" == ']' ]] && ((j--))
                    done
                fi
            ;;
            \])
                local j=1 c2
                while (( j > 0 )); do
                    c2=${chars[$((--CHR_POINT))]}
                    [[ "$c2" == '[' ]] && ((j--))
                    [[ "$c2" == ']' ]] && ((j++))
                done
            ;;
        esac
        ((CHR_POINT++))
    done
}
