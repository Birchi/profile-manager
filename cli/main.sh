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
config_command=${__directory__}/command/config.sh
install_command=${__directory__}/command/install.sh
remove_command=${__directory__}/command/remove.sh
list_command=${__directory__}/command/list.sh
enable_command=${__directory__}/command/enable.sh
disable_command=${__directory__}/command/disable.sh
help_command=${__directory__}/command/help.sh

##
# Functions
##
function profile-manager () {
    if [ $# -eq 0 ] ; then
        ${help_command}
        return 1
    fi

    if [[ "${@:1:1}" == "install" ]] || [[ "${@:1:1}" == "add" ]] ; then
        shift 1
        ${install_command} $@
    elif [[ "${@:1:1}" = "remove" ]] || [[ "${@:1:1}" = "rm" ]] ; then
        shift 1
        ${remove_command} $@
    elif [[ "${@:1:1}" == "list" ]] || [[ "${@:1:1}" == "ls" ]] ; then
        shift 1
        ${list_command} $@
    elif [[ "${@:1:1}" == "config" ]] ; then
        shift 1
        ${config_command} $@
    elif [[ "${@:1:1}" == "enable" ]] ; then
        shift 1
        ${enable_command} $@
    elif [[ "${@:1:1}" == "disable" ]] ; then
        shift 1
        ${disable_command} $@
    elif [[ "${@:1:1}" == "version" ]] ; then
        cat ${__directory__}/VERSION
    else
        ${help_command}
    fi
}

