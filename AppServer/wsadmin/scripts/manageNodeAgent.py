#==============================================================================
#
#          FILE:  configureNodeAgent.py
#         USAGE:  wsadmin.sh -lang jython -f configureNodeAgent.py nodeName
#     ARGUMENTS:  The node to be configured
#   DESCRIPTION:  Configures various properties for a nodeagent in a WebSpere cell
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

configureLogging("../config/logging.xml")
consoleLogger = logging.getLogger("console-logger")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")

lineSplit = java.lang.System.getProperty("line.separator")
serverName = "nodeagent"
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureNodeAgents(runAsUser="", runAsGroup=""):
    if (nodeList):
        for node in (nodeList):
            configureNodeAgent(node, runAsUser, runAsGroup)
        #endfor
    else:
        print("No nodes were found in the cell.")
    #endif
#enddef

def configureNodeAgent(nodeName, runAsUser="", runAsGroup=""):
    targetServer = AdminConfig.getid('/Node:' + nodeName + '/Server:' + serverName + '/')

    if (targetServer):
        print("Starting configuration for nodeagent %s on server %s...") % (nodeName, serverName)

        setProcessExec(targetServer, runAsUser, runAsGroup)
        setJVMProperties(serverName, nodeName)

        saveWorkspaceChanges()
        syncAllNodes(nodeList, targetCell)

        print("Completed configuration for deployment manager %s") % (serverName)
    else:
        print("Deployment manager not found with server name %s") % (serverName)
    #endif
#enddef

def printHelp():
    print("This script configures a deployment manager for optimal settings.")
    print("Execution: wsadmin.sh -lang jython -f configureDeploymentManager.py <runAsUser> <runAsGroup>")
    print("<runAsUser> - The operating system username to run the process as. The user must exist on the local machine. Optional, if not provided no user is configured.")
    print("<runAsGroup> - The operating system group to run the process as. The group must exist on the local machine. Optional, if not provided no group is configured.")
#enddef

##################################
# main
#################################


if (len(sys.argv) == 1):
    configureNodeAgent(sys.argv[0])
elif (len(sys.argv) == 2):
    configureDeploymentManager(sys.argv[0], sys.argv[1])
else:
    configureDeploymentManager()
#endif
