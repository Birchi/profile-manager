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
config=
value=

##
# Functions
##
function usage() {
    cat << EOF
Usage: profile-manager enable [OPTIONS]

Options:
  -n, --name                Name of the profile.
  -c, --config              Config name of the profile.
  -v, --value               Config value of the profile.

  -h, --help                Show this help message.

Examples:
  profile-manager config set --name NAME --config CONFIG --value VALUE
  profile-manager config set -n NAME -c CONFIG -v VALUE

EOF
}

function parse_cmd_args() {
    args=$(getopt --options hn:c:v: \
                  --longoptions name:,config:,value:,help -- "$@")
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to parse arguments!" && usage
        exit 1;
    fi

    while test $# -ge 1 ; do
        case "$1" in
            -h | --help) usage && exit 0 ;;
            -n | --name) name="$(eval echo $2)" ; shift 1 ;;
            -c | --config) config="$(eval echo $2)" ; shift 1 ;;
            -v | --value) value="$(eval echo $2)" ; shift 1 ;;
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

if [ -f ${profile_manager_active_directory}/${name}/config.sh ] ; then
    if [[ $(grep -E "^export ${config}=.*" ${profile_manager_active_directory}/${name}/config.sh | wc -l) -eq 1 ]] ; then
        sed -i -e "s/^export ${config}=.*$/export ${config}=${value}/g" ${profile_manager_active_directory}/${name}/config.sh
    else
        echo "Configuration '${config}' does not exist."
    fi
else
    echo "Profile '${name}' does not have any configurations."
fi