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
profile_manager_base_directory=${PROFILE_MANAGER_DIRECTORY:-~/.profile-manager}
profile_manager_cli_directory=${profile_manager_base_directory}/cli

##
# Functions
##
function profile-manager () {
    if [ $# -eq 0 ] ; then
        ${profile_manager_cli_directory}/help.sh
        exit 1
    fi

    if [[ "${@[1]}" == "install" ]] || [[ "${@[1]}" == "add" ]] ; then
        shift 1
        ${profile_manager_cli_directory}/install.sh $@
    elif [[ "${@[1]}" = "remove" ]] || [[ "${@[1]}" = "rm" ]] ; then
        shift 1
        ${profile_manager_cli_directory}/remove.sh $@
    elif [[ "${@[1]}" == "list" ]] || [[ "${@[1]}" == "ls" ]] ; then
        shift 1
        ${profile_manager_cli_directory}/list.sh $@
    elif [[ "${@[1]}" == "enable" ]] ; then
        shift 1
        ${profile_manager_cli_directory}/enable.sh $@
    elif [[ "${@[1]}" == "disable" ]] ; then
        shift 1
        ${profile_manager_cli_directory}/disable.sh $@
    elif [[ "${@[1]}" == "version" ]] ; then
        cat ${profile_manager_cli_directory}/VERSION
    else
        ${profile_manager_cli_directory}/help.sh
    fi
}
