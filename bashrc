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

[[ -f ${HOME}/.profile ]] && source ${HOME}/.profile;

## load the logger
if [[ -r "${SCRIPT_ROOT}/lib/system/logger.sh" ]] && [[ -s "${SCRIPT_ROOT}/lib/system/logger.sh" ]]; then
    source "${SCRIPT_ROOT}/lib/system/logger.sh"; ## if its here, override the above and use it
elif [[ -r "${HOME}/lib/system/logger.sh" ]] && [[ -s "${HOME}/lib/system/logger.sh" ]]; then
    source "${HOME}/lib/system/logger.sh"; ## if its here, override the above and use it
elif [[ -r "/usr/local/bin/logger.sh" ]] && [[ -s "/usr/local/bin/logger.sh" ]]; then
    source "/usr/local/bin/logger.sh"; ## if its here, use it
else
    printf "\e[00;31m%s\e[00;32m\n" "Unable to load logger. No logging enabled!" >&2;
fi

if [[ -z "$(command -v "writeLogEntryToFile")" ]]; then printf "\e[00;31m%s\033[0m\n" "Failed to load logging configuration. No logging available!" >&2; declare LOGGING_LOADED="${_FALSE}"; fi;

source "${HOME}/.profiles";
source "${HOME}/.alias";
source "${HOME}/.functions";

if [[ -z "${isReloadRequest}" ]] || [[ "${isReloadRequest}" == "${_FALSE}" ]]; then
    showHostInfo;
    runLoginCommands;
fi

## trap logout
trap 'logoutUser; exit' EXIT;

## make the umask sane
umask 022;
