#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  bash_profile
#         USAGE:  . bash_profile
#   DESCRIPTION:  Sets application-wide functions
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

[[ "$-" != *i* ]] || [ -z "${PS1}" ] && return;

## load the logger
if [[ -r "${HOME}/lib/system/logger.sh" ]] && [[ -s "${HOME}/lib/system/logger.sh" ]] && [[ -z "${LOGGING_LOADED}" ]]; then source "${HOME}/lib/system/logger.sh"; fi
if [[ -z "$(command -v "writeLogEntryToFile")" ]]; then printf "\e[00;31m%s\033[0m\n" "Failed to load logging configuration. No logging available!" >&2; declare LOGGING_LOADED="${_FALSE}"; fi;

declare -x PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:${HOME}/bin";

## load profile
for file_entry in "${HOME}"/.profile.d/*; do
    [[ -z "${file_entry}" ]] && continue;

    if [[ -d "${file_entry}" ]]; then
        for dir_entry in "${file_entry}"/*; do
            [[ -z "${dir_entry}" ]] && continue;

            if [[ -r "${dir_entry}" ]] && [[ -s "${dir_entry}" ]]; then source "${dir_entry}"; fi

            [[ -n "${dir_entry}" ]] && unset -v dir_entry;
        done

        [[ -n "${dir_entry}" ]] && unset -v dir_entry;
        [[ -n "${file_entry}" ]] && unset -v file_entry;
    fi

    if [[ -r "${file_entry}" ]] && [[ -s "${file_entry}" ]]; then source "${file_entry}"; fi

    [[ -n "${dir_entry}" ]] && unset -v dir_entry;
    [[ -n "${file_entry}" ]] && unset -v file_entry;
done

[[ -n "${dir_entry}" ]] && unset -v dir_entry;
[[ -n "${file_entry}" ]] && unset -v file_entry;

source "${HOME}"/.alias;
source "${HOME}"/.functions;

showHostInfo;

## trap logout
trap 'logoutUser; exit' 0;

## make the umask sane
umask 022;
