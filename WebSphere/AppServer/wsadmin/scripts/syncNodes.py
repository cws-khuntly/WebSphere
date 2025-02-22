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

import os
import sys

sys.path.append(os.path.expanduser('~') + '/workspace/WebSphere/AppServer/wsadmin/includes/')

import includes

lineSplit = java.lang.System.getProperty("line.separator")

nodeList = AdminTask.listManagedNodes().split(lineSplit)

def performNodeSync():
    includes.saveWorkspaceChanges()
    includes.syncAllNodes(nodeList)
#enddef

##################################
# main
#################################
performNodeSync()
