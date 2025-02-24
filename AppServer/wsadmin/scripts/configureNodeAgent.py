#==============================================================================
#
#          FILE:  configureNodeAgent.py
#         USAGE:  wsadmin.sh -lang jython -f configureNodeAgent.py
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

lineSplit = java.lang.System.getProperty("line.separator")

serverName = "nodeagent"
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureNodeAgents(runAsUser="", runAsGroup=""):
    if (nodeList):
        for node in (nodeList):
            targetServer = AdminConfig.getid('/Node:' + node + '/Server:' + serverName + '/')

            if (targetServer):
                print ("Starting nodeagent configuration for node " + node + "...")

                haManager = AdminConfig.list("HAManagerService", targetServer)
                threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
                processExec = AdminConfig.list("ProcessExecution", targetServer)
                configSyncService = AdminConfig.list("ConfigSynchronizationService", targetServer)

                AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
                AdminConfig.modify(configSyncService, '[[synchInterval "1"] [exclusions ""] [enable "true"] [synchOnServerStartup "true"] [autoSynchEnabled "true"]]')

                if ((runAsUser) and (runAsGroup)):
                    AdminConfig.modify(processExec, '[[runAsUser "' + runAsUser + '"] [runAsGroup "' + runAsGroup + '"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
                elif (runAsUser):
                    AdminConfig.modify(processExec, '[[runAsUser "' + runAsUser + '"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
                else:
                    AdminConfig.modify(processExec, '[[runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
                #end if

                AdminTask.setJVMProperties('[-serverName ' + serverName + ' -nodeName ' + node + ' -verboseModeGarbageCollection false -initialHeapSize 2048 -maximumHeapSize 2048 -genericJvmArguments "-Xshareclasses:none -Djava.awt.headless=true"]')

                if (threadPools):
                    for threadPool in (threadPools):
                        poolName = threadPool.split("(")[0]

                        if (poolName == "server.startup"):
                            AdminConfig.modify(threadPool, '[[maximumSize "10"] [name "' + poolName + '"] [inactivityTimeout "30000"] [minimumSize "0"] [description "This pool is used by WebSphere during server startup."] [isGrowable "false"]]')
                        elif (poolName == "WebContainer"):
                            AdminConfig.modify(threadPool, '[[maximumSize "75"] [name "' + poolName + '"] [inactivityTimeout "5000"] [minimumSize "20"] [description ""] [isGrowable "false"]]')
                        elif (poolName == "HAManagerService.Pool"):
                            AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
                        else:
                            continue
                        #endif
                    #endfor
                #endif

                saveWorkspaceChanges()
                syncAllNodes(nodeList)

                print ("Completed configuration for node " + node + ".")
            else:
                print ("No servers were found for the provided criteria.")
            #endif
        #endfor
    else:
        print ("No nodes were found in the cell.")
    #endif
#enddef

def configureNodeAgent(nodeName, runAsUser="", runAsGroup=""):
    targetServer = AdminConfig.getid('/Node:' + nodeName + '/Server:' + serverName + '/')

    if (targetServer):
        print ("Starting nodeagent configuration for node " + nodeName + "...")

        haManager = AdminConfig.list("HAManagerService", targetServer)
        threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
        processExec = AdminConfig.list("ProcessExecution", targetServer)
        configSyncService = AdminConfig.list("ConfigSynchronizationService", targetServer)

        AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
        AdminConfig.modify(configSyncService, '[[synchInterval "1"] [exclusions ""] [enable "true"] [synchOnServerStartup "true"] [autoSynchEnabled "false"]]')

        if ((runAsUser) and (runAsGroup)):
            AdminConfig.modify(processExec, '[[runAsUser "' + runAsUser + '"] [runAsGroup "' + runAsGroup + '"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
        elif (runAsUser):
            AdminConfig.modify(processExec, '[[runAsUser "' + runAsUser + '"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
        else:
            AdminConfig.modify(processExec, '[[runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
        #end if

        AdminTask.setJVMProperties('[-serverName ' + serverName + ' -nodeName ' + nodeName + ' -verboseModeGarbageCollection false -initialHeapSize 2048 -maximumHeapSize 2048 -genericJvmArguments "-Xshareclasses:none -Djava.awt.headless=true"]')

        if (threadPools):
            for threadPool in (threadPools):
                poolName = threadPool.split("(")[0]

                if (poolName == "server.startup"):
                    AdminConfig.modify(threadPool, '[[maximumSize "10"] [name "' + poolName + '"] [inactivityTimeout "30000"] [minimumSize "0"] [description "This pool is used by WebSphere during server startup."] [isGrowable "false"]]')
                elif (poolName == "WebContainer"):
                    AdminConfig.modify(threadPool, '[[maximumSize "75"] [name "' + poolName + '"] [inactivityTimeout "5000"] [minimumSize "20"] [description ""] [isGrowable "false"]]')
                elif (poolName == "HAManagerService.Pool"):
                    AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
                else:
                    continue
                #endif
            #endfor
        #endif

        print ("Completed configuration for node " + nodeName + ".")
    else:
        print ("No servers were found for the provided criteria.")
    #endif

    saveWorkspaceChanges()
    syncAllNodes(nodeList)
#enddef

def printHelp():
    print ("This script configures a deployment manager for optimal settings.")
    print ("Execution: wsadmin.sh -lang jython -f configureDeploymentManager.py <nodeName> <runAsUser> <runAsGroup>")
    print ("<nodeName> - The node name the nodeagent is running against. One of \"all\" or a node name known to the deployment manager.")
    print ("<runAsUser> - The operating system username to run the process as. The user must exist on the local machine. Optional, if not provided no user is configured.")
    print ("<runAsGroup> - The operating system group to run the process as. The group must exist on the local machine. Optional, if not provided no group is configured.")
#enddef

##################################
# main
#################################
if (sys.argv[0] == "all"):
    if (len(sys.argv) == 1):
        configureNodeAgents()
    elif (len(sys.argv) == 2):
        configureNodeAgents(sys.argv[1])
    elif (len(sys.argv) == 3):
        configureNodeAgents(sys.argv[1], sys.argv[2])
    #endif
else:
    if (len(sys.argv) == 1):
        configureNodeAgent(sys.argv[0])
    elif (len(sys.argv) == 2):
        configureNodeAgent(sys.argv[0], sys.argv[1])
    elif (len(sys.argv) == 3):
        configureNodeAgents(sys.argv[0], sys.argv[1], sys.argv[2])
    #endif
#endif
