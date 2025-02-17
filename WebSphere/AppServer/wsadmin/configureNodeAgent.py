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
import platform
import time

sys.path.append(os.path.expanduser('~') + '/lib/wasadmin/')

import includes

lineSplit = java.lang.System.getProperty("line.separator")

serverName = "nodeagent"
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureNodeAgent():
    for node in nodeList:
        targetServer = AdminConfig.getid('/Node:' + node + '/Server:' + serverName + '/')
        haManager = AdminConfig.list("HAManagerService", targetServer)
        threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
        processExec = AdminConfig.list("ProcessExecution", targetServer)
        processDef = AdminConfig.list("JavaProcessDef", targetServer)
        configSyncService = AdminConfig.list("ConfigSynchronizationService", targetServer)

        AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')

        for threadPool in threadPools:
            poolName = threadPool.split("(")[0]

            if (poolName == "HAManagerService.Pool"):
                AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
            else:
                continue
            #endif
        #endfor

        AdminConfig.modify(processExec, '[[runAsUser "<USER>"] [runAsGroup "<GROUP>"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
        AdminConfig.modify(configSyncService, '[[synchInterval "1"] [exclusions ""] [enable "true"] [synchOnServerStartup "true"] [autoSynchEnabled "true"]]')

        AdminTask.setJVMProperties('[-serverName ' + serverName + ' -nodeName ' + node + ' -verboseModeGarbageCollection false -initialHeapSize 512 -maximumHeapSize 512 -genericJvmArguments "-Xshareclasses:none -Djava.awt.headless=true"]')

    saveWorkspaceChanges()
    syncAllNodes(nodeList)

    print("Configuration complete.")
#enddef

##################################
# main
#################################
configureNodeAgent()
