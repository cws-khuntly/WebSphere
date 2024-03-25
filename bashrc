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

## get the available log config and load it
if [[ -r "/usr/local/etc/logging.properties" ]] && [[ -s "/usr/local/etc/logging.properties" ]]; then LOGGING_PROPERTIES="/usr/local/etc/logging.properties"; fi ## if its here, use it
if [[ -r "${HOME}/etc/system/logging.properties" ]] && [[ -s "${HOME}/etc/system/logging.properties" ]]; then LOGGING_PROPERTIES="${HOME}/etc/system/logging.properties"; fi ## if its here, override the above and use it
if [[ -n "${LOGGING_PROPERTIES}" ]]; then source "${LOGGING_PROPERTIES}"; fi

## load the logger
if [[ -r "/usr/local/lib/logger.sh" ]] && [[ -s "/usr/local/lib/logger.sh" ]] && [[ -n "${LOGGING_LOADED}" ]]; then source "/usr/local/lib/logger.sh"; fi
if [[ -r "${HOME}/lib/system/logger.sh" ]] && [[ -s "${HOME}/lib/system/logger.sh" ]] && [[ -n "${LOGGING_LOADED}" ]]; then source "${HOME}/lib/system/logger.sh"; fi
if [[ -z "$(command -v "writeLogEntry")" ]] || [[ -z "${LOGGING_LOADED}" ]] || [[ "${LOGGING_LOADED}" == "false" ]]; then printf "\e[00;31m%s\e[00;32m\n" "Failed to load logging configuration. No logging available!" >&2; declare LOGGING_LOADED="${_FALSE}"; fi;

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#loadProfile";

declare -x PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:${HOME}/bin";

## load profile
for file_entry in "${HOME}"/.profile.d/*
do
    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${LINENO}" "file_entry -> ${file_entry}"; fi

    [[ -z "${file_entry}" ]] && continue;

    if [[ -d "${file_entry}" ]]; then
        for dir_entry in "${HOME}"/.profile.d/"${file_entry}"/*
        do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${LINENO}" "dir_entry -> ${dir_entry}"; fi

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
trap 'source ${HOME}/.dotfiles/functions.d/F01-userProfile; logoutUser; exit' 0;

## run tmux (we're going to finally learn it)
## support both tmux and screen, use the flag files appropriately
[[ -n "$(compgen -c | grep -E -qw ^tmux)" ]] && [[ -z "$(tmux info 2> /dev/null)" ]] && [[ -f ${HOME}/etc/run-tmux ]] && tmux attach;
[[ -n "$(compgen -c | grep -E -qw ^screen)" ]] && [[ -z "${STY}" ]] && [[ -f ${HOME}/etc/run-screen ]] && screen -RR;

## make the umask sane
umask 022;

[[ -n "${CNAME}" ]] && unset -v CNAME;
[[ -n "${FUNCTION_NAME}" ]] && unset -v FUNCTION_NAME;

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi
