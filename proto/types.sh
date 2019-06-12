#!/usr/bin/env bash

require "core/mssg"

alias global=": -g ; type_def"
alias final=": -r ; type_def"
alias int=": -i ; type_def"
alias string=": -- ; type_def"
alias array=": -a ; type_def"
alias assoc=": -a ; type_def"
alias env=": -x ; type_def"

type_def() {
    type_stack+="$_ "
    eval "$@" && eval "declare ${type_stack}$_" && unset type_stack && return 1
}