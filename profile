#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  alias
#         USAGE:  . alias
#   DESCRIPTION:  Sets application-wide aliases
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#
#==============================================================================

## load profiles
for file_entry in ${HOME}/.profile.d/*; do
    [[ -z "${file_entry}" ]] && continue;

    if [[ -d "${file_entry}" ]]; then
        for dir_entry in ${file_entry}/*; do
            [[ -z "${dir_entry}" ]] && continue;

            profile_file="${dir_entry}";

            [[ -n "${dir_entry}" ]] && unset -v dir_entry;
        done

        [[ -n "${dir_entry}" ]] && unset -v dir_entry;
        [[ -n "${file_entry}" ]] && unset -v file_entry;
    else
        profile_file="${file_entry}"

        [[ -n "${dir_entry}" ]] && unset -v dir_entry;
        [[ -n "${file_entry}" ]] && unset -v file_entry;
    fi

    if [[ -n "${profile_file}" ]] && [[ -r "${profile_file}" ]] && [[ -s "${profile_file}" ]]; then
        source "${profile_file}";
    fi

    [[ -n "${profile_file}" ]] && unset -v profile_file;
    [[ -n "${dir_entry}" ]] && unset -v dir_entry;
    [[ -n "${file_entry}" ]] && unset -v file_entry;
done
