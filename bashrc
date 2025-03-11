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
if [[ -r "${HOME}/lib/system/logger.sh" ]] && [[ -s "${HOME}/lib/system/logger.sh" ]] && [[ -z "${LOGGING_LOADED}" ]]; then source "${HOME}/lib/system/logger.sh"; fi
if [[ -z "$(command -v "writeLogEntryToFile")" ]]; then printf "\e[00;31m%s\033[0m\n" "Failed to load logging configuration. No logging available!" >&2; declare LOGGING_LOADED="${_FALSE}"; fi;

source "${HOME}/.profiles";
source "${HOME}/.alias";
source "${HOME}/.functions";

showHostInfo;

## trap logout
trap 'logoutUser; exit' EXIT;

## make the umask sane
umask 022;
