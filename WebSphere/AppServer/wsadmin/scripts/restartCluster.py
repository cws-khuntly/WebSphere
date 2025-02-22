#==============================================================================
#
#          FILE:  restartCluster.py
#         USAGE:  wsadmin.sh -lang jython -f restartCluster.py
#     ARGUMENTS:  (clusterName)
#   DESCRIPTION:  Executes an scp connection to a pre-defined server
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kevin Huntly <kevin.huntly@bcbsma.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

import os
import sys

lineSplit = java.lang.System.getProperty("line.separator")

targetCell = AdminControl.getCell()
clusterList = AdminConfig.list('ServerCluster').split(lineSplit)

def restartClusters():
    print ("Restarting all found clusters...")

    for cluster in (clusterList):
        clusterName = AdminControl.completeObjectName('cell=' + targetCell + ',type=Cluster,name=' + cluster.split("(")[0] + ',*')

        print ("Restarting cluster " + cluster + "...")
        print ("Cluster " + cluster.split("(")[0] + " is currently: " + AdminControl.getAttribute(clusterName, "state" ).split(".")[2])
        
        AdminControl.invoke(clusterName, "stop")
        
        time.sleep(900)
        
        if (AdminControl.getAttribute(clusterName, "state" ).split(".")[2] == "stopped"):
            AdminControl.invoke(clusterName, "rippleStart")

            continue
        #endif
    #endfor
#enddef

def restartCluster(clusterName):
    for cluster in (clusterList):
        if (clusterName == cluster.split("(")[0]):
            for cluster in (clusterList):
                clusterName = AdminControl.completeObjectName('cell=' + targetCell + ',type=Cluster,name=' + cluster.split("(")[0] + ',*')

                print ("Restarting cluster " + clusterName + "...")
                print ("Cluster " + cluster.split("(")[0] + " is currently: " + AdminControl.getAttribute(clusterName, "state" ).split(".")[2])
                
                AdminControl.invoke(clusterName, "stop")
                
                time.sleep(900)
                
                if (AdminControl.getAttribute(clusterName, "state" ).split(".")[2] == "stopped"):
                    AdminControl.invoke(clusterName, "rippleStart")

                    continue
                #endif
            #endfor
        else:
            print("The provided cluster is not available on this system.")

            sys.exit(1)
        #endif
    #endfor
#enddef    

def printHelp():
    print ("This script performs an application management.")
    print ("Execution: wsadmin.sh -lang jython -f /path/to/clusterInstallApp.py <option> <appname> <binary path> <cluster name>")
    print ("<option> - One of list, install, update, uninstall, change-weight, export.")
    print ("<app path> - The path to the application to install or modify.")
    print ("<cluster name> - The cluster to install or update the application into. Required if option is install or update.")
    print ("<webserver node name> - The webserver node name as defined in the deployment manager for mapping. Required if option is install or update.")
    print ("<webserver name> - The webserver name as defined in the deployment manager for mapping. Required if option is install or update.")
    print ("<start weight> - Only required if option is change-weight.")
#enddef

##################################
# main
#################################
if ((len(sys.argv) == 1) and (sys.argv[0] == "list")):
    listApps()
else:
    if (sys.argv[0] == "install"):
        if (len(sys.argv) == 5):
            installSingleModule(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
        else:
            printHelp()
        #endif
    if (sys.argv[0] == "update"):
        if (len(sys.argv) == 5):
            updateSingleModule(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
        else:
            printHelp()
        #endif
    elif (sys.argv[0] == "uninstall"):
        if (len(sys.argv) == 2):
            performAppUninstall(sys.argv[1])
        else:
            printHelp()
        #endif
    elif (sys.argv[0] == "export"):
        if (len(sys.argv) == 1):
            exportApp(sys.argv[1])
        else:
            printHelp()
        #endif
    elif (sys.argv[0] == "change-weight"):
        if (len(sys.argv) == 2):
            modifyStartupWeightForApplication(sys.argv[1], sys.argv[2])
        else:
            printHelp()
        #endif
    #endif
#endif
