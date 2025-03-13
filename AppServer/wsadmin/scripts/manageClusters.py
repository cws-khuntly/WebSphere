#==============================================================================
#
#          FILE:  manageClusters.py
#         USAGE:  wsadmin.sh -lang jython -f restartCluster.py
#     ARGUMENTS:  (clusterName)
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

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")
consoleInfoLogger = logging.getLogger("console-out")
consoleErrorLogger = logging.getLogger("console-err")

targetCell = AdminControl.getCell()
lineSplit = java.lang.System.getProperty("line.separator")
clusterList = AdminConfig.list("ServerCluster").split(lineSplit)

def buildServerCluster():
#enddef

def buildServerInCluster():
#enddef

def addClusterConfiguration():
#enddef

def rippleStartCluster():
#enddef

def printHelp():
    print("This script performs server management tasks.")
    print("Execution: wsadmin.sh -lang jython -f serverManagement.py <option> <configuration file>")
    print("Options are: ")

    print("    create-server-cluster: Creates an empty WebSphere Application Server cluster.")
    print("        <configuration file>: The configuration file containing the information necessary to create the cluster.")
    print("            The provided configuration file must contain the following sections:")
    print("                [cluster-information]")
    print("                    This section must contain a value indicating the cluster name.")

    print("    create-server-in-cluster: Creates a new Application Server instance on a provided node in an existing cluster.")
    print("        <configuration file>: The configuration file containing the information necessary to create the server.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain a value indicating the server name.")
    print("                    This section must contain a value indicating the node name.")
    print("                [cluster-information]")
    print("                    This section must contain a value indicating the cluster name.")

    print("    add-cluster-configuration: Adds configuration entries for a provided cluster.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [cluster-information]")
    print("                    This section must contain a value indicating the cluster name.")

    print("    restart-cluster: Restarts all servers in a provided cluster.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [cluster-information]")
    print("                    This section must contain a value indicating the cluster name.")
#enddef

##################################
# main
#################################
if (len(sys.argv) == 0):
    printHelp()
else:
    configFile = str(sys.argv[1])

    if (os.path.exists(configFile)) and (os.access(configFile, os.R_OK)):
        if (sys.argv[0] == "create-server-cluster"):
            buildServerCluster()
        elif (sys.argv[0] == "create-server-in-cluster"):
            buildServerInCluster()
        elif (sys.argv[0] == "add-cluster-configuration"):
            addClusterConfiguration()
        elif (sys.argv[0] == "restart-cluster"):
            rippleStartCluster()
        else:
            printHelp()
        #endif
    else:
        print("The provided configuration file either does not exist or cannot be read.")
    #endif
#endif
