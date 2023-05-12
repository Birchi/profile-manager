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
name=

##
# Functions
##
function usage() {
    cat << EOF
Usage: profile-manager config list [OPTIONS]

Options:
  -n, --name                Name of the profile.
  -h, --help                Show this help message.

Examples:
  profile-manager config list --name NAME
  profile-manager config list -n NAME

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

parse_cmd_args "$@"

if [[ "${name}" == "" ]] ; then
    echo "Please, specify the profile via --name NAME"
    exit 1
fi

if [ -f ${profile_manager_active_directory}/${name}/config.sh ] ; then
    grep -E "^export .*" ${profile_manager_active_directory}/${name}/config.sh | sed 's/^export \([A-Z0-9\_]*\)=\(.*\)$/\1=\2/g'
else
    echo "Profile '${name}' does not have any configurations."
fi