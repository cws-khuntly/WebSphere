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

sys.path.append(os.path.expanduser('~') + '/workspace/WebSphere/AppServer/wsadmin/includes/')

import includes

lineSplit = java.lang.System.getProperty("line.separator")

targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureNodeAgent(runAsUser="", runAsGroup=""):
    serverName = "nodeagent"

    for node in (nodeList):
        targetServer = AdminConfig.getid('/Node:' + node + '/Server:' + serverName + '/')

        if (targetServer):
            print ("Starting configuration for server " + targetServer + "...")

            haManager = AdminConfig.list("HAManagerService", targetServer)
            threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
            processExec = AdminConfig.list("ProcessExecution", targetServer)
            targetTransport = AdminConfig.list("TransportChannelService", targetServer)
            targetWebContainer = AdminConfig.list("WebContainer", targetServer)
            targetCookie = AdminConfig.list("Cookie", targetServer)
            targetTuning = AdminConfig.list("TuningParams", targetServer)
            monitorPolicy = AdminConfig.list("MonitoringPolicy", targetServer)
            processExec = AdminConfig.list("ProcessExecution", targetServer)
            haManager = AdminConfig.list("HAManagerService", targetServer)
            threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
            targetTCPChannels = AdminConfig.list("TCPInboundChannel", targetServer).split(lineSplit)
            targetHTTPChannels = AdminConfig.list("HTTPInboundChannel", targetServer).split(lineSplit)
            containerChains = AdminTask.listChains(targetTransport, '[-acceptorFilter WebContainerInboundChannel]').split(lineSplit)

            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.extractHostHeaderPort"] [description ""] [value "true"] [required "false"]]')
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "trusthostheaderport"] [description ""] [value "true"] [required "false"]]')
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.invokefilterscompatibility"] [description ""] [value "true"] [required "false"]]')

            AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
            AdminConfig.modify(processExec, '[[runAsUser "' + runAsUser + '"] [runAsGroup "' + runAsUser + '"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
            AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
            AdminConfig.modify(monitorPolicy, '[[maximumStartupAttempts "3"] [pingTimeout "300"] [pingInterval "60"] [autoRestart "true"] [nodeRestartState "PREVIOUS"]]')
            AdminConfig.modify(processExec, '[[runAsUser "' + runAsUser + '"] [runAsGroup "' + runAsUser + '"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
            AdminConfig.modify(targetWebContainer, '[[sessionAffinityTimeout "0"] [enableServletCaching "true"] [disablePooling "false"] [defaultVirtualHostName "default_host"]]')
            AdminConfig.modify(targetCookie, '[[maximumAge "-1"] [name "JSESSIONID"] [domain ""] [secure "true"] [path "/"]]')
            AdminConfig.modify(targetTuning, '[[writeContents "ONLY_UPDATED_ATTRIBUTES"] [writeFrequency "END_OF_SERVLET_SERVICE"] [scheduleInvalidation "false"] [invalidationTimeout "60"]]')

            AdminTask.setJVMProperties('[-serverName ' + targetServer + ' -nodeName ' + node + ' -verboseModeGarbageCollection true -initialHeapSize 8192 -maximumHeapSize 8192 -debugMode false -genericJvmArguments "' + genericJvmArgs + '"]')

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

            if (containerChains):
                for chain in (containerChains):
                    chainName = chain.split("(")[0]

                    if (chainName == "WCInboundDefault"):
                        continue
                    elif (chainName != "WCInboudDefaultSecure"):
                        continue
                    else:
                        AdminTask.deleteChain(chain, '[-deleteChannels true]')
                    #endif
                #endfor
            #endif

            if (targetTCPChannels):
                for tcpChannel in (targetTCPChannels):
                    tcpName = tcpChannel.split("(")[0]

                    if (tcpName == "TCP_2"):
                        AdminConfig.modify(tcpChannel, '[[maxOpenConnections "50"]]')
                    else:
                        continue
                    #endif
                #endfor
            #endif

            if (targetHTTPChannels):
                for httpChannel in (targetHTTPChannels):
                    httpName = httpChannel.split("(")[0]

                    if (httpName == "HTTP_2"):
                        AdminConfig.modify(httpChannel, '[[maximumPersistentRequests "-1"] [persistentTimeout "300"] [enableLogging "true"]]')
                        AdminConfig.create('Property', httpChannel, '[[validationExpression ""] [name "RemoveServerHeader"] [description ""] [value "true"] [required "false"]]')
                    else:
                        continue
                    #endif
                #endfor
            #endif

            print ("Completed configuration for server " + targetServer + ".")
        else:
            print ("No servers were found for the provided criteria")
        #endif
    #endfor

    includes.saveWorkspaceChanges()
    includes.syncAllNodes(nodeList)
#enddef

def printHelp():
    print ("This script configures a deployment manager for optimal settings.")
    print ("Execution: wsadmin.sh -lang jython -f configureDeploymentManager.py <runAsUser> <runAsGroup>")
    print ("<runAsUser> - The operating system username to run the process as. The user must exist on the local machine. Optional, if not provided no user is configured.")
    print ("<runAsGroup> - The operating system group to run the process as. The group must exist on the local machine. Optional, if not provided no group is configured.")
#enddef

##################################
# main
#################################
if (len(sys.argv) == 1):
    configureNodeAgent(sys.argv[0])
elif (len(sys.argv) == 2):
    configureNodeAgent(sys.argv[0], sys.argv[1])
else:
    configureNodeAgent()
#endif
