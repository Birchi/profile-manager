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
show_all_profiles=0
show_disabled_profiles=0

##
# Functions
##
function usage() {
    cat << EOF
Usage: profile-manager list [OPTIONS]

Options:
  -a, --all                 Show all profiles.
  -e, --enabled             Show enabled profiles.
  -d, --disabled            Show disabled profiles.
  -h, --help                Show this help message.

Examples:
  profile-manager list --all
  profile-manager ls -a

EOF
}

function parse_cmd_args() {
    args=$(getopt --options aedh \
                  --longoptions all,enabled,disabled,help -- "$@")
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to parse arguments!" && usage
        exit 1;
    fi

    while test $# -ge 1 ; do
        case "$1" in
            -a | --all) show_all_profiles=1 ; shift 1 ;;
            -d | --disabled) show_disabled_profiles=1 ; shift 1 ;;
            -h | --help) usage && exit 0 ;;
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

profiles=
profile_state="enabled"
if [ $show_all_profiles -eq 1 ] ; then
    profiles=$(ls ${profile_manager_base_directory}/profile/storage)
elif [ $show_disabled_profiles -eq 1 ] ; then
    all_profiles=$(ls ${profile_manager_base_directory}/profile/storage)
    enabled_profiles=$(ls ${profile_manager_base_directory}/profile/active)
    profile_state="disabled"
    profiles=($(comm -3 <(printf "%s\n" "${all_profiles[@]}") <(printf "%s\n" "${enabled_profiles[@]}")))
else
    profiles=$(ls ${profile_manager_base_directory}/profile/active)
fi

if [ ${#profiles} -gt 0 ] ; then
    for profile in ${profiles} ; do
        profile_directory=${profile_manager_base_directory}/profile/storage/${profile}
        profile_version=$(cat ${profile_directory}/VERSION)
        profile_url=$(cat ${profile_directory}/URI)
        echo "$profile - $profile_version - $profile_url"
    done
else
    echo "No profiles are ${profile_state}."
fi