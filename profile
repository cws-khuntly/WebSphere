#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  profile
#         USAGE:  . profile
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

## path
declare -x SYSTEM_PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/games";
declare -x ORACLE_PATH="/usr/lib/oracle/19.26/client64/bin";
declare -x USER_PATH="${HOME}/bin";
declare -x PATH="${PATH}:${SYSTEM_PATH}:${ORACLE_PATH}:${USER_PATH}";

## trap logout
trap 'logoutUser; exit' EXIT;

## make the umask sane
umask 022;
