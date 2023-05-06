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
profile_manager_directory=~/.profile-manager
is_offline=0

##
# Functions
##
function usage() {
    cat << EOF
This script installs profile-manager

Options:
  -d, --directory           Defines the base directory of the manager. Default value is ${profile_manager_directory}
  -o, --offline             Enables the offline installation. Normally used for development environments.
  -h, --help                Shows the help message.

Examples:
  $(dirname $0)/install.sh
EOF
}

function parse_cmd_args() {
    args=$(getopt --options d:oh \
                  --longoptions directory:,offline,help -- "$@")
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to parse arguments!" && usage
        exit 1;
    fi

    while test $# -ge 1 ; do
        case "$1" in
            -h | --help) usage && exit 0 ;;
            -d | --directory) profile_manager_directory="$(eval echo $2)" ; shift 1 ;;
            -o | --offline) is_offline=1 ;;
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

# Create folder structure
mkdir -p ${profile_manager_directory}
mkdir -p ${profile_manager_directory}/cli
mkdir -p ${profile_manager_directory}/profile
mkdir -p ${profile_manager_directory}/profile/active
mkdir -p ${profile_manager_directory}/profile/storage
mkdir -p ${profile_manager_directory}/tmp

if [ ${is_offline} -eq 1 ] ; then
    rm -rf ${profile_manager_directory}/cli
    cp -r $(dirname $0)/cli ${profile_manager_directory}/cli
else
    rm -rf ${profile_manager_directory}/cli
    mkdir -p ${profile_manager_directory}/cli
    for file_to_download in "disable.sh" "enable.sh" "help.sh" "install.sh" "list.sh" "main.sh" "remove.sh" "VERSION" ; do 
        curl -s -L --insecure "https://raw.githubusercontent.com/Birchi/profile-manager/main/cli/${file_to_download}" --output ${profile_manager_directory}/cli/${file_to_download} > /dev/null
    done
    chmod 744 ${profile_manager_directory}/cli/*.sh
fi

sed '/# BEGIN PROFILE MANAGER/,/# END PROFILE MANAGER/d' ${profile_file} > ${profile_file}.tmp && cat ${profile_file}.tmp > ${profile_file} && rm ${profile_file}.tmp

cat << EOF >> ${profile_file}

# BEGIN PROFILE MANAGER
export PROFILE_MANAGER_DIRECTORY=${profile_manager_directory}
if [ -d \${PROFILE_MANAGER_DIRECTORY} ] ; then
    active_profile_directory=\${PROFILE_MANAGER_DIRECTORY}/profile/active
    for profile in \$(ls \${active_profile_directory}) ; do
        source \${active_profile_directory}/\${profile}/main.sh
    done

    if [ -f \${PROFILE_MANAGER_DIRECTORY}/cli/main.sh ] ; then
        source \${PROFILE_MANAGER_DIRECTORY}/cli/main.sh
    fi
fi
# END PROFILE MANAGER
EOF
