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
import time

lineSplit = java.lang.System.getProperty("line.separator")

targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def performNodeSync():
    print("Synchronizing all nodes...")

    for node in nodeList:
        nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

        if nodeRepo:
            AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')

        syncNode = AdminControl.completeObjectName('cell=' + targetCell + ',node=' + node + ',type=NodeSync,*')

        if syncNode:
            AdminControl.invoke(syncNode, 'sync')

        continue

##################################
# main
#################################
performNodeSync()
