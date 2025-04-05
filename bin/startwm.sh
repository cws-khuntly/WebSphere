#!/usr/bin/env bash

#==============================================================================
#
#          FILE:  functions
#         USAGE:  . functions
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

# GNOME
# dbus-launch --exit-with-session /usr/bin/gnome-session

# GNOME Classic
# env GNOME_SHELL_SESSION_MODE=classic dbus-launch --exit-with-session /usr/bin/gnome-session

# KDE
dbus-launch --exit-with-session /usr/bin/startplasma-wayland

# Cinnamon
# dbus-launch --exit-with-session /usr/bin/cinnamon-session

# Budgie
# env GNOME_SHELL_SESSION_MODE=Budgie:GNOME dbus-launch --exit-with-session /usr/bin/budgie-desktop
