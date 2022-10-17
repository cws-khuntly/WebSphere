#==============================================================================
#
#          FILE:  configureTargetServer.py
#         USAGE:  wsadmin.sh -lang jython -f configureTargetServer.py
#     ARGUMENTS:  wasVersion serverName clusterName vHostName (vHostAliases) (serverLogRoot)
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

targetCell = AdminControl.getCell()
lineSplit = java.lang.System.getProperty("line.separator")
genericJvmArgs = ("${WPS_JVM_ARGUMENTS_EXT} -Dibm.stream.nio=true -Djava.io.tmpdir=${WAS_TEMP_DIR} -Xdump:stack:events=allocation,filter=#10m -Xgcpolicy:gencon -verbose:gc -Xverbosegclog:${SERVER_LOG_ROOT}/verbosegc.%Y%m%d.%H%M%S.%pid.txt,20,10000 "
                "-Dcom.ibm.websphere.alarmthreadmonitor.threshold.millis=40000 -Xmn1024M -XX:MaxDirectMemorySize=256000000 -Xscmx150m -Xshareclasses:none -Dsun.reflect.inflationThreshold=0 -Djava.security.egd=file:/dev/./urandom "
                "-Dcom.sun.jndi.ldap.connect.pool.maxsize=200 -Dcom.sun.jndi.ldap.connect.pool.prefsize=200 -Dcom.sun.jndi.ldap.connect.pool.timeout=3000 -Djava.net.preferIPv4Stack=true -Dsun.net.inetaddr.ttl=600 -DdisableWSAddressCaching=true "
                "-Dcom.ibm.websphere.webservices.http.connectionKeepAlive=true -Dcom.ibm.websphere.webservices.http.maxConnection=1200 -Dcom.ibm.websphere.webservices.http.connectionIdleTimeout=6000 "
                "-Dcom.ibm.websphere.webservices.http.connectionPoolCleanUpTime=6000 -Dcom.ibm.websphere.webservices.http.connectionTimeout=0")

def configureAllServers():
    serverList = AdminTask.listServers('[-serverType APPLICATION_SERVER ]').split(lineSplit)

    for server in serverList:
        configureTargetServer(server.split("(")[0])

def configureTargetServer(serverName):
    nodeList = AdminTask.listManagedNodes().split(lineSplit)

    for node in nodeList:
        targetServer = AdminConfig.getid('/Node:' + node + '/Server:' + serverName + '/')

        if targetServer:
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

            AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
            AdminConfig.modify(monitorPolicy, '[[maximumStartupAttempts "3"] [pingTimeout "300"] [pingInterval "60"] [autoRestart "true"] [nodeRestartState "PREVIOUS"]]')
            AdminConfig.modify(processExec, '[[runAsUser "wasadm"] [runAsGroup "wasgrp"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
            AdminConfig.modify(targetWebContainer, '[[sessionAffinityTimeout "0"] [enableServletCaching "true"] [disablePooling "false"] [defaultVirtualHostName "default_host"]]')
            AdminConfig.modify(targetCookie, '[[maximumAge "-1"] [name "JSESSIONID"] [domain ""] [secure "false"] [path "/"]]')
            AdminConfig.modify(targetTuning, '[[writeContents "ONLY_UPDATED_ATTRIBUTES"] [writeFrequency "END_OF_SERVLET_SERVICE"] [scheduleInvalidation "false"] [invalidationTimeout "15"]]')

            for threadPool in threadPools:
                poolName = threadPool.split("(")[0]

                if (poolName == "server.startup"):
                    AdminConfig.modify(threadPool, '[[maximumSize "10"] [name "' + poolName + '"] [inactivityTimeout "30000"] [minimumSize "0"] [description "This pool is used by WebSphere during server startup."] [isGrowable "false"]]')
                elif (poolName == "WebContainer"):
                    AdminConfig.modify(threadPool, '[[maximumSize "75"] [name "' + poolName + '"] [inactivityTimeout "5000"] [minimumSize "20"] [description ""] [isGrowable "false"]]')
                elif (poolName == "HAManagerService.Pool"):
                    AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
                else:
                    continue

            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.extractHostHeaderPort"] [description ""] [value "true"] [required "false"]]')
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "trusthostheaderport"] [description ""] [value "true"] [required "false"]]')
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.invokefilterscompatibility"] [description ""] [value "true"] [required "false"]]')

            AdminTask.setJVMProperties('[-serverName ' + serverName + ' -nodeName ' + node + ' -verboseModeGarbageCollection true -initialHeapSize 12288 -maximumHeapSize 12288 -debugMode true -genericJvmArguments "' + genericJvmArgs + '"]')

            containerChains = AdminTask.listChains(targetTransport, '[-acceptorFilter WebContainerInboundChannel]').split(lineSplit)

            for chain in containerChains:
                chainName = chain.split("(")[0]

                if (chainName != "WCInboundDefault"):
                    AdminTask.deleteChain(chain, '[-deleteChannels true]')
                else:
                    continue

            for tcpChannel in targetTCPChannels:
                tcpName = tcpChannel.split("(")[0]

                if tcpName == "TCP_2":
                    AdminConfig.modify(tcpChannel, '[[maxOpenConnections "50"]]')
                else:
                    continue

            for httpChannel in targetHTTPChannels:
                httpName = httpChannel.split("(")[0]

                if httpName == "HTTP_2":
                    AdminConfig.modify(httpChannel, '[[maximumPersistentRequests "-1"] [persistentTimeout "300"] [enableLogging "true"]]')
                    AdminConfig.create('Property', httpChannel, '[[validationExpression ""] [name "RemoveServerHeader"] [description ""] [value "true"] [required "false"]]')
                else:
                    continue
        else:
            continue

    AdminConfig.save()

    for node in nodeList:
        nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

        if nodeRepo:
            AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')

        syncNode = AdminControl.completeObjectName('cell=' + targetCell + ',node=' + node + ',type=NodeSync,*')

        if syncNode:
            AdminControl.invoke(syncNode, 'sync')

        continue

    print "Configuration complete."

def installSampleApp(wasVersion, targetServer, targetCluster, vHostName):
    lineSplit = java.lang.System.getProperty("line.separator")
    nodeList = AdminTask.listManagedNodes().split(lineSplit)
    targetCell = AdminControl.getCell()

    targetServer = targetServer.upper()
    targetAppName = targetCluster.lower()
    cluster = AdminControl.completeObjectName('cell=' + AdminControl.getCell()  + ',type=Cluster,name=' + targetCluster + ',*')

    print "Installing sample application .."

    if (wasVersion == "61"):
        AdminApp.install('/home/wasadm/etc/Initial_Deployment.ear', '[ -installed.ear.destination /appvol/WAS61/' + targetServer + ' -appname ' + targetAppName + ' -MapModulesToServers [[ Initial_Deployment Initial_Deployment.war,WEB-INF/web.xml WebSphere:cell=' + targetCell + ',cluster=' + targetCluster + ' ]] -MapWebModToVH [[ Initial_Deployment Initial_Deployment.war,WEB-INF/web.xml ' + vHostName + ' ]]]')
    elif (wasVersion == "70"):
        AdminApp.install('/home/wasadm/etc/Initial_Deployment.ear', '[ -installed.ear.destination /appvol/WAS70/' + targetServer + ' -appname ' + targetAppName + ' -MapModulesToServers [[ Initial_Deployment Initial_Deployment.war,WEB-INF/web.xml WebSphere:cell=' + targetCell + ',cluster=' + targetCluster + ' ]] -MapWebModToVH [[ Initial_Deployment Initial_Deployment.war,WEB-INF/web.xml ' + vHostName + ' ]]]')

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

    print "Installation complete."

def printHelp():
    print "This script configures default values for the provided jvm."
    print "Format is configureTargetServer serverName"

##################################
# main
#################################
if(len(sys.argv) == 1):
    # get node name and process name from the command line
    if (sys.argv[0] == "all"):
        configureAllServers()
    else:
        configureTargetServer(sys.argv[0])
else:
    printHelp()
