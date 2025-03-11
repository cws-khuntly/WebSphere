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

declare -x PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:${HOME}/bin";

## trap logout
trap 'logoutUser; exit' EXIT;

## make the umask sane
umask 022;
