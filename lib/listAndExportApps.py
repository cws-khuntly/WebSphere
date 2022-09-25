#==============================================================================
#
#          FILE:  configureDMGR.py
#         USAGE:  wsadmin.sh -lang jython -f configureDMGR.py
#     ARGUMENTS:  wasVersion
#   DESCRIPTION:  Executes an scp connection to a pre-defined server
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
#==============================================================================

import sys

def listApps():
    lineSplit = java.lang.System.getProperty("line.separator")
    appList = AdminApp.list().split(lineSplit)

    for app in appList:
        print app

        continue

def exportApp(appName):
    AdminApp.export(appName, '/var/tmp/' + appName + '.ear')

def printHelp():
    print "This script configures default values for the Deployment Manager."
    print "Format is configureDMGR wasVersion"

##################################
# main
#################################
##################################
# main
#################################
if(len(sys.argv) == 1):
    # get node name and process name from the command line
    exportApp(sys.argv[0])
else:
    listApps()
