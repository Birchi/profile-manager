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
profile_file=
profile_manager_directory=${HOME}/.profile-manager

##
# Functions
##
function usage() {
    cat << EOF
This script uninstalls profile-manager

Options:
  -d, --directory           Defines the base directory of the manager. Default value is ${profile_manager_directory}
  -h, --help                Shows the help message.

Examples:
  $(dirname $0)/uninstall.sh
EOF
}

function parse_cmd_args() {
    args=$(getopt --options d:,h \
                  --longoptions directory:,help -- "$@")
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to parse arguments!" && usage
        exit 1;
    fi

    while test $# -ge 1 ; do
        case "$1" in
            -h | --help) usage && exit 0 ;;
            -d | --directory) profile_manager_directory="$(eval echo $2)" ; shift 1 ;;
            --) ;;
             *) ;;
        esac
        shift 1
    done 
}

function detect_profile() {
    local detected_profile
    detected_profile=""

    if [ "${SHELL#*bash}" != "$SHELL" ] ; then
        if [ -f "${HOME}/.bashrc" ] ; then
            detect_profile="${HOME}/.bashrc"
        elif [ -f "${HOME}/.bash_profile" ] ; then
            detect_profile="${HOME}/.bash_profile"
        fi
    elif [ "${SHELL#*zsh}" != "$SHELL" ] ; then
        if [ -f "${HOME}/.zshrc" ] ; then
            detect_profile="${HOME}/.zshrc"
        elif [ -f "${HOME}/.zprofile" ] ; then
            detect_profile="${HOME}/.zprofile"
        fi
    fi

    if [ -z "$detect_profile" ]; then
        for {profile_file_name} in ".profile" ".bashrc" ".bash_profile" ".zprofile" ".zshrc" ; do
            if -f ${HOME}/${profile_file_name} ; then
                detect_profile=${HOME}/${profile_file_name}
            fi
        done
    fi

    echo ${detect_profile}
}

##
# Main
##
profile_file=$(detect_profile)

parse_cmd_args "$@"

sed '/# BEGIN PROFILE MANAGER/,/# END PROFILE MANAGER/d' ${profile_file} > ${profile_file}.tmp && cat ${profile_file}.tmp > ${profile_file} && rm ${profile_file}.tmp

if [ -d ${profile_manager_directory} ] ; then
    rm -rf ${profile_manager_directory}
fi
