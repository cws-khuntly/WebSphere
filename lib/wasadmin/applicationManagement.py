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
import logging

from pathlib import Path

global logger = logging.getlog(__name__)
global lineSplit = java.lang.System.getProperty("line.separator")

global appList = AdminApp.list().split(lineSplit)

def listApps():
    for app in appList:
        print(app)
 
        continue

def remapApplication():
    for app in appList:
        moduleName = AdminApp.listModules("" + app + "", '-server').split("#")[1].split("+")[0]

        AdminApp.edit('' + app + '', '[ -MapModulesToServers [[ \"' + app + '\" ' + moduleName + ',WEB-INF/web.xml WebSphere:cell=dmgrCell01,cluster=TestCluster ]]]')

        continue

    AdminConfig.save()
    AdminNodeManagement.syncActiveNodes()

def exportApp(appName):
    Path("Path.home() '/workspace/WebSphere/files/").mkdir(parents=True, exist_ok=True)

    AdminApp.export(appName, Path.home() '/workspace/WebSphere/files/' + appName + '.ear')

def performAppInstallation(appName, appPath, clusterName):
    print("Installing application " + appName + "..")

    AdminApplication.installAppWithClusterOption('' + appName + '','' + appPath + '','' + clusterName + '')

    print("Saving configuration..")

    AdminConfig.save()

    for node in nodeList:
        nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

        if nodeRepo:
            AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')

        syncNode = AdminControl.completeObjectName('cell=' + targetCell + ',node=' + node + ',type=NodeSync,*')

        if syncNode:
            AdminControl.invoke(syncNode, 'sync')

        continue

def performAppUninstall(appName):
    print("Removing application " + appName + "..")

    AdminApplication.uninstall('' + appName + '')

    print("Saving configuration..")

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
    print("This script performs an application management.")
    print("Execution: wsadmin.sh -lang jython -f /path/to/clusterInstallApp.py <option> <appname> <binary path> <cluster name>")
    print("<option> is one of install or uninstall.")
    print("<appname> is the application name to be installed or removed. Required for both available options.")
    print("<binary path> is the full path to the binaries for the application to be installed. Required if <option> install.")
    print("<cluster name> is the WebSphere cluster to install the application into. Required if <option> install.")

##################################
# main
#################################
if(len(sys.argv) == 1):
    # get node name and process name from the command line
    exportApp(sys.argv[0])
else:
    listApps()
