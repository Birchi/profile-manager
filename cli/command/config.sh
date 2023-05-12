#!/bin/bash
#####################################################################
#
# Copyright (c) 2023-present, Birchi (https://github.com/Birchi)
# All rights reserved.
#
# This source code is licensed under the MIT license.
#
#####################################################################
##
# Variables
##
# General
__directory__=$(cd $(dirname ${BASH_SOURCE[0]-$0}) && pwd)
# Commands
set_command=${__directory__}/config/set.sh
list_command=${__directory__}/config/list.sh
help_command=${__directory__}/config/help.sh

##
# Main
##
if [ $# -eq 0 ] ; then
    ${help_command}
    exit 1
fi


if [[ "${@:1:1}" == "list" ]] || [[ "${@:1:1}" == "ls" ]] ; then
    shift 1
    ${list_command} $@
elif [[ "${@:1:1}" == "set" ]] ; then
    shift 1
    ${set_command} $@
else
    ${help_command}
fi