#==============================================================================
#
#          FILE:  installApp.py
#         USAGE:  wsadmin.sh -lang jython -f installApp.py
#     ARGUMENTS:  appName, appPath, appTarget, appWarName, appWarFile, targetCell, targetCluster
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

def performAppInstallation(clusterName, appName, appPath):
    lineSplit = java.lang.System.getProperty("line.separator")
    targetCell = AdminControl.getCell()
    nodeList = AdminTask.listManagedNodes().split(lineSplit)

    print "Installing application .."
    AdminApplication.installAppWithClusterOption('' + appName + '','' + appPath + '','' + clusterName + '')

    print "Saving configuration.."

    AdminConfig.save()

    for node in nodeList:
        nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

        if nodeRepo:
            AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')

        syncNode = AdminControl.completeObjectName('cell=' + targetCell + ',node=' + node + ',type=NodeSync,*')

        if syncNode:
            AdminControl.invoke(syncNode, 'sync')

        continue

    print "Performing ripple start.."

    AdminControl.invoke(cluster, 'rippleStart')

    print
    print "Executing getDeployStatus()"
    print AdminApp.getDeployStatus(appName)

    print
    print "Executing isAppReady()"
    print AdminApp.isAppReady(appName)

def printHelp():
    print "This script disables the HA Manager on a specific process"
    print "Format is disableHamOnProcess nodeName processName"

##################################
# main
#################################
if(len(sys.argv) == 3):
    performAppInstallation(sys.argv[0],sys.argv[1],sys.argv[2])
else:
    printHelp()
