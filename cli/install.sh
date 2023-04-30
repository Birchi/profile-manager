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
name=
uri=
file_extension=
force_install=0
profile_manager_base_directory=${PROFILE_MANAGER_DIRECTORY:-~/.profile-manager}
profile_manager_active_directory=${profile_manager_base_directory}/profile/active
profile_manager_storage_directory=${profile_manager_base_directory}/profile/storage

##
# Functions
##
function usage() {
    cat << EOF
Usage: profile-manager install [OPTIONS]

Options:
  -n, --name                Local name of profile.
  -u, --uri                 URI of the profile.
  -f, --force               Overwrites an profile, if it exists.
  -e, --file-extension      Defines the format of the URI. This is useful, if it cannot be auto detected.
  -h, --help                Show this help message.

EOF
}

function parse_cmd_args() {
    args=$(getopt --options hfu:n:e: \
                  --longoptions uri:,file-extension,name:,force,help -- "$@")
    
    if [[ $? -ne 0 ]]; then
        echo "Failed to parse arguments!" && usage
        exit 1;
    fi

    while test $# -ge 1 ; do
        case "$1" in
            -n | --name) name="$(eval echo $2)" ; shift 1 ;;
            -u | --uri) uri="$(eval echo $2)" ; shift 1 ;;
            -e | --file-extension) file_extension="$(eval echo $2)" ; shift 1 ;;
            -f | --force) force_install=1 ;;
            -h | --help) usage && exit 0 ;;
            --) ;;
             *) ;;
        esac
        shift 1
    done 
}

function get_file_extension() {
    local f_name
    f_name=$(basename $1 | sed -e 's/\(.*\)/\L\1/')
    local f_extension
    f_extension="unknown"

    if [[ "${file_extension}" == "" ]] ; then
        if [[ ${f_name#*.} == *zip ]] ; then
            f_extension="zip"
        elif [[ ${f_name#*.} == *tar.bz2 ]] ; then
            f_extension="tar.bz2"
        elif [[ ${f_name#*.} == *tar.gz ]] ; then
            f_extension="tar.gz"
        elif [[ ${f_name#*.} == *tar.xz ]] ; then
            f_extension="tar.xz"
        elif [[ ${f_name#*.} == *tar ]] ; then
            f_extension="tar"
        fi
    else
        f_extension="$( echo ${file_format} | sed -e 's/\(.*\)/\L\1/')"
    fi
    echo ${f_extension}
}

function detect_uri_protocol() {
    local protocol
    protocol="file"
    if [[ $1 == http://* ]] || [[ $1 == https://* ]] ; then
        protocol="remote"
    fi
    echo "${protocol}"
}

##
# Main
##

parse_cmd_args "$@"

if [ ! -n "${name}" ] ; then
    echo "Please, provide a profile name via --name NAME"
    exit 1
fi

if [ ! -n "${uri}" ] ; then
    echo "Please, provide a uri via --uri URL"
    exit 1
fi

profile_manager_tmp_directory=${profile_manager_base_directory}/tmp/${name}
profile_storage_directory=${profile_manager_storage_directory}/${name}
profile_active_link=${profile_manager_active_directory}/${name}
file_name=$(basename ${uri})
uri_protocol=$(detect_uri_protocol ${uri})
file_extension=$(get_file_extension ${uri})

if [[ "${file_extension}" == "unknown" ]] ; then
    echo "Cannot detect file extension."
    exit 1
fi

if [[ "${file_extension}" != "zip" ]] && [[ "${file_extension}" != "tar.gz" ]] \
   && [[ "${file_extension}" != "tar" ]] && [[ "${file_extension}" != "tar.bz2" ]] \
   && [[ "${file_extension}" != "tar.xz" ]]  ; then
    echo "File extension is not supported yet."
    exit 1
fi

if [[ "${force_install}" -eq 1 ]] ; then
    if [ -d "${profile_storage_directory}" ] ; then
        rm -rf "${profile_storage_directory}"
    fi
    if [ -h "${profile_active_link}" ] ; then
        rm ${profile_active_link}
    fi
fi

if [ -d ${profile_storage_directory} ] ; then
    echo "Profile '${name}' already exists."
    exit 1
fi

if [ -d ${profile_manager_tmp_directory} ] ; then
    rm -rf "${profile_manager_tmp_directory}"
fi
mkdir -p ${profile_manager_tmp_directory}

if [[ "${uri_protocol}" == "remote" ]] ; then
    curl -s -L --insecure $uri --output ${profile_manager_tmp_directory}/$(basename $uri) > /dev/null
elif [[ "${uri_protocol}" == "file" ]] ; then
    cp $uri ${profile_manager_tmp_directory}/$(basename $uri)
fi

if [[ "${file_extension}" == "zip" ]] ; then
    unzip -qo ${profile_manager_tmp_directory}/$(basename $uri) -d ${profile_manager_tmp_directory}
elif [[ "${file_extension}" == "tar.gz" ]] ; then
    tar -zxf ${profile_manager_tmp_directory}/$(basename $uri) -C ${profile_manager_tmp_directory}/.
elif [[ "${file_extension}" == "tar.xz" ]] ; then
    tar -Jxf ${profile_manager_tmp_directory}/$(basename $uri) -C ${profile_manager_tmp_directory}/.
elif [[ "${file_extension}" == "tar.bz2" ]] ; then
    tar -jxf ${profile_manager_tmp_directory}/$(basename $uri) -C ${profile_manager_tmp_directory}/.
elif [[ "${file_extension}" == "tar" ]] ; then
    tar -xf ${profile_manager_tmp_directory}/$(basename $uri) -C ${profile_manager_tmp_directory}/.
fi

main_file=$(find ${profile_manager_tmp_directory}/* -name main.sh -type f)
if [[ "${main_file}" == "" ]] ; then
    echo "Cannot find main.sh file. Please, make sure there is a main.sh file in the folder."
    exit 1
fi

main_directory=$(dirname ${main_file})
cp -r ${main_directory} ${profile_storage_directory}

echo "${uri}" > ${profile_storage_directory}/URI
ln -s "${profile_storage_directory}" "${profile_active_link}"

rm -rf ${profile_manager_tmp_directory}