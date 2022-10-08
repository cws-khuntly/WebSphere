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

import sys

def configureNodeAgent():
    serverName = "nodeagent"
    lineSplit = java.lang.System.getProperty("line.separator")
    targetCell = AdminControl.getCell()
    nodeList = AdminTask.listManagedNodes().split(lineSplit)
    syncList = AdminConfig.list("ConfigSynchronizationService").split("\n")

    for node in nodeList:
        targetServer = AdminConfig.getid('/Node:' + node + '/Server:' + serverName + '/')
        haManager = AdminConfig.list("HAManagerService", targetServer)
        threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
        processExec = AdminConfig.list("ProcessExecution", targetServer)
        processDef = AdminConfig.list("JavaProcessDef", targetServer)

        print "Disabling HAManager .."

        AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')

        for threadPool in threadPools:
            poolName = threadPool.split("(")[0]

            if (poolName == "HAManagerService.Pool"):
                AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
            else:
                continue

        print "Modifying JVM .."

        AdminConfig.modify(processExec, '[[runAsUser "wasadm"] [runAsGroup "wasgrp"]]')

        AdminTask.setJVMProperties('[-serverName ' + serverName + ' -nodeName ' + node + ' -verboseModeGarbageCollection true -initialHeapSize 2048 -maximumHeapSize 2048 -genericJvmArguments "-Xshareclasses:none"]')

    print "Saving configuration.."

    AdminConfig.save()

    print "Configuration saved .."

    for node in nodeList:
        nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

        if nodeRepo:
            AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')

        syncNode = AdminControl.completeObjectName('cell=' + targetCell + ',node=' + node + ',type=NodeSync,*')

        if syncNode:
            AdminControl.invoke(syncNode, 'sync')

        continue

##################################
# main
#################################
configureNodeAgent()
