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
import platform
import time

lineSplit = java.lang.System.getProperty("line.separator")

serverName = "dmgr"
targetCell = AdminControl.getCell()

def configureDMGR():
    nodeList = AdminTask.listManagedNodes().split(lineSplit)

    for node in nodeList:
        targetServer = AdminConfig.getid('/Node:' + node + '/Server:' + serverName + '/')

        if targetServer:
            haManager = AdminConfig.list("HAManagerService", targetServer)
            threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
            processExec = AdminConfig.list("ProcessExecution", targetServer)

            AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
            AdminConfig.modify(processExec, '[[runAsUser "wasadm"] [runAsGroup "wasgrp"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')

            for threadPool in threadPools:
                poolName = threadPool.split("(")[0]

                if (poolName == "HAManagerService.Pool"):
                    AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
                else:
                    continue

            AdminTask.setJVMProperties('[-serverName ' + serverName + ' -nodeName ' + nodeName + ' -verboseModeGarbageCollection true -initialHeapSize 512 -maximumHeapSize 512 -genericJvmArguments "-Xshareclasses:none"]')

            AdminConfig.save()

            nodeList = AdminTask.listManagedNodes().split(lineSplit)

            for node in nodeList:
                nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

                if nodeRepo:
                    AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')

                syncNode = AdminControl.completeObjectName('cell=' + targetCell + ',node=' + node + ',type=NodeSync,*')

                if syncNode:
                    AdminControl.invoke(syncNode, 'sync')

                continue
        continue

    print("Configuration complete.")

##################################
# main
#################################
configureDMGR()
