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
#        AUTHOR:  Kevin Huntly <kevin.huntly@bcbsma.com>
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

serverName = "dmgr"
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureDMGR():
    for node in nodeList:
        targetServer = AdminConfig.getid('/Node:' + node + '/Server:' + serverName + '/')

        if (targetServer):
            haManager = AdminConfig.list("HAManagerService", targetServer)
            threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
            processExec = AdminConfig.list("ProcessExecution", targetServer)

            AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
            AdminConfig.modify(processExec, '[[runAsUser "<USER>"] [runAsGroup "<GROUP>"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')

            for threadPool in threadPools:
                poolName = threadPool.split("(")[0]

                if (poolName == "HAManagerService.Pool"):
                    AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
                else:
                    continue
                #endif
            #endfor

            AdminTask.setJVMProperties('[-serverName ' + serverName + ' -nodeName ' + nodeName + ' -verboseModeGarbageCollection true -initialHeapSize 512 -maximumHeapSize 512 -genericJvmArguments "-Xshareclasses:none"]')

            saveWorkspaceChanges()
            syncAllNodes(nodeList)
        continue
    #endfor

    print("Configuration complete.")
#enddef

##################################
# main
#################################
configureDMGR()
