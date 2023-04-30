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
profile_manager_active_directory=${profile_manager_base_directory}/profile/active
profile_manager_storage_directory=${profile_manager_base_directory}/profile/storage

##
# Functions
##
function usage() {
    cat << EOF
Usage: profile-manager remove [OPTIONS]

Options:
  -n, --name                Name of the profile to be removed.
  -h, --help                Show this help message.

Examples:
  profile-manager remove --name NAME
  profile-manager rm --n NAME

EOF
}

function parse_cmd_args() {
    args=$(getopt --options hn: \
                  --longoptions name:,help -- "$@")
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to parse arguments!" && usage
        exit 1;
    fi

    while test $# -ge 1 ; do
        case "$1" in
            -h | --help) usage && exit 0 ;;
            -n | --name) name="$(eval echo $2)" ; shift 1 ;;
            --) ;;
             *) ;;
        esac
        shift 1
    done 
}

##
# Main
##
name=

parse_cmd_args "$@"

if [ ! -n "${name}" ] ; then
    echo "Please, provide a profile name via --name NAME"
    exit 1
fi

profile_storage_directory=${profile_manager_storage_directory}/${name}
profile_active_link=${profile_manager_active_directory}/${name}

if [  ! -d "${profile_storage_directory}" ] ; then
    echo "No profile installed named '${name}'."
    exit 1
fi

if [  -h "${profile_active_link}" ] ; then
    rm "${profile_active_link}"
fi
rm -rf "${profile_storage_directory}"