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

    print
    print "Executing getDeployStatus()"
    print AdminApp.getDeployStatus(appName)

    print
    print "Executing isAppReady()"
    print AdminApp.isAppReady(appName)

def advancedInstallApp(appPath, appName, appModule, warName, clusterName):
    lineSplit = java.lang.System.getProperty("line.separator")
    nodeList = AdminTask.listManagedNodes().split(lineSplit)
    targetCell = AdminControl.getCell()

    AdminApp.install('' + appPath + '', '[ -distributeApp -appname ' + appName + ' -MapModulesToServers [[ ' + appModule + ' ' + warName + ',WEB-INF/web.xml WebSphere:cell=' + targetCell + ',cluster=' + clusterName + '+WebSphere:cell=dmgrCell01,node=pv-web-dv-dx-srv-01Node,server=HTTPServer]]]' )
    AdminConfig.save()

    for node in nodeList:
        nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

        if nodeRepo:
            AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')

        syncNode = AdminControl.completeObjectName('cell=' + targetCell + ',node=' + node + ',type=NodeSync,*')

        if syncNode:
            AdminControl.invoke(syncNode, 'sync')

        continue

def updateInstalledApp(appName, appModule, warName, clusterName):
    lineSplit = java.lang.System.getProperty("line.separator")
    nodeList = AdminTask.listManagedNodes().split(lineSplit)
    targetCell = AdminControl.getCell()

    AdminApp.edit('' + appName + '', '[ -MapModulesToServers [[ ' + appModule + ' ' + warName + ',WEB-INF/web.xml WebSphere:cell=' + targetCell + ',cluster=' + clusterName + '+WebSphere:cell=dmgrCell01,node=pv-web-dv-dx-srv-01Node,server=HTTPServer ]]]' )
    AdminConfig.save()

    for node in nodeList:
        nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

        if nodeRepo:
            AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')

        syncNode = AdminControl.completeObjectName('cell=' + targetCell + ',node=' + node + ',type=NodeSync,*')

        if syncNode:
            AdminControl.invoke(syncNode, 'sync')

        continue

def printHelp():
    print "This script disables the HA Manager on a specific process"
    print "Format is disableHamOnProcess nodeName processName"

##################################
# main
#################################
if(len(sys.argv) == 3):
    performAppInstallation(sys.argv[0], sys.argv[1], sys.argv[2])
elif(len(sys.argv) == 4):
    updateInstalledApp(sys.argv[0], sys.argv[1], sys.argv[2], sys.argv[3])
elif(len(sys.argv) == 5):
    advancedInstallApp(sys.argv[0], sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
else:
    printHelp()
