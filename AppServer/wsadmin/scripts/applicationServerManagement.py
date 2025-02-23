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

import os
import sys

lineSplit = java.lang.System.getProperty("line.separator")

targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureAllServers(runAsUser="", runAsGroup=""):
    serverList = AdminTask.listServers('[-serverType APPLICATION_SERVER ]').split(lineSplit)

    print ("Starting configuration for ALL servers...")

    for server in (serverList):
        configureTargetServer(server.split("(")[0])

        print ("Configuration complete for server " + server)

        continue
    #endfor
#enddef

def configureTargetServer(serverName, runAsUser="", runAsGroup=""):
    if (nodeList):
        for node in (nodeList):
            targetServer = AdminConfig.getid('/Node:%s/Server:%s/') % (node, serverName)

            if (targetServer):
                print ("Starting configuration for server %s...") % (serverName)

                targetTransport = AdminConfig.list("TransportChannelService", targetServer)
                targetCookie = AdminConfig.list("Cookie", targetServer)
                targetTuning = AdminConfig.list("TuningParams", targetServer)
                threadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)
                targetTCPChannels = AdminConfig.list("TCPInboundChannel", targetServer).split(lineSplit)
                targetHTTPChannels = AdminConfig.list("HTTPInboundChannel", targetServer).split(lineSplit)
                containerChains = AdminTask.listChains(targetTransport, '[-acceptorFilter WebContainerInboundChannel]').split(lineSplit)

                configureAutoRestart(targetServer)
                configureWebContainer(targetServer)
                setServerTrace(targetServer)
                setProcessExec(targetServer, runAsUser, runAsGroup)

                AdminConfig.modify(targetCookie, '[[maximumAge "-1"] [name "JSESSIONID"] [domain ""] [secure "true"] [path "/"]]')
                AdminConfig.modify(targetTuning, '[[writeContents "ONLY_UPDATED_ATTRIBUTES"] [writeFrequency "END_OF_SERVLET_SERVICE"] [scheduleInvalidation "false"] [invalidationTimeout "60"]]')

                if (threadPools):
                    for threadPool in (threadPools):
                        poolName = threadPool.split("(")[0]

                        if (poolName == "server.startup"):
                            AdminConfig.modify(threadPool, '[[maximumSize "10"] [name %s] [inactivityTimeout "30000"] [minimumSize "0"] [description "This pool is used by WebSphere during server startup."] [isGrowable "false"]]') % (poolName)
                        elif (poolName == "WebContainer"):
                            AdminConfig.modify(threadPool, '[[maximumSize "75"] [name %s] [inactivityTimeout "5000"] [minimumSize "20"] [description ""] [isGrowable "false"]]') % (poolName)
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

                saveWorkspaceChanges()
                syncAllNodes(nodeList)

                print ("Completed configuration for server %s") % (serverName)
            else:
                continue
            #endif
        #endfor
    else:
        print ("No nodes were found in the cell.")
    #endif
#enddef

def configureAutoRestart(targetServer, autoRestart="PREVIOUS"):
    if (targetServer):
        print ("Starting configuration for server " + serverName + "...")

        monitorPolicy = AdminConfig.list("MonitoringPolicy", targetServer)

        if (monitorPolicy):
            AdminConfig.modify(monitorPolicy, '[[maximumStartupAttempts "3"] [pingTimeout "300"] [pingInterval "60"] [autoRestart "true"] [nodeRestartState "%s"]]') % (autoRestart)
        else:
            raise ("Error configuring the monitoring policy for server %s.") % (targetServer)
        #endif
    else:
        raise ("No server was provided to configure.")
    #endif
    #endif
#enddef

def configureWebContainer(targetServer, defaultVhostName="default_host"):
    if (targetServer):
        print ("Starting configuration for server " + serverName + "...")

        targetWebContainer = AdminConfig.list("WebContainer", targetServer)

        if (targetWebContainer):
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.extractHostHeaderPort"] [description ""] [value "true"] [required "false"]]')
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "trusthostheaderport"] [description ""] [value "true"] [required "false"]]')
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.invokefilterscompatibility"] [description ""] [value "true"] [required "false"]]')

            AdminConfig.modify(targetWebContainer, '[[defaultVirtualHostName %s]]') % (defaultVhostName)

            setServletCaching(targetServer)
            setPortletCaching(targetServer)
        else:
            raise ("Error configuring the web container for server %s.") % (targetServer)
        #endif
    else:
        raise ("No server was provided to configure.")
    #endif
#enddef

def configureHAManager(targetServer):
    if (targetServer):
        print ("Starting configuration for server " + serverName + "...")

        haManager = AdminConfig.list("HAManagerService", targetServer)

        if (targetWebContainer):
            AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
        else:
            raise ("Error configuring HAManager for server %s.") % (targetServer)
        #endif
    else:
        raise ("No server was provided to configure.")
    #endif
#enddef

def setServletCaching(targetServer, isServletCachingEnabled=False):
    if (targetServer):
        print ("Starting configuration for server " + serverName + "...")

        targetWebContainer = AdminConfig.list("WebContainer", targetServer)

        if (targetWebContainer):
            AdminConfig.modify(targetWebContainer, '[[enableServletCaching %s]]') % (isServletCachingEnabled)
        else:
            raise ("Error configuring the web container for server %s.") % (targetServer)
        #endif
    else:
        raise ("No server was provided to configure.")
    #endif
#enddef

def setPortletCaching(targetServer, isPortletCachingEnabled=False):
    if (targetServer):
        print ("Starting configuration for server " + serverName + "...")

        targetPortletContainer = AdminConfig.list("PortletContainer", targetServer)

        if (targetPortletContainer):
            AdminConfig.modify(targetPortletContainer, '[[enablePortletCaching %s]]') % (isPortletCachingEnabled)
        else:
            raise ("Error configuring portlet caching for server %s.") % (targetServer)
        #endif
    else:
        raise ("No server was provided to configure.")
    #endif
#enddef

def setServerTrace(targetServer, traceSpec="*=info", outputType="SPECIFIED_FILE", maxBackupFiles=50, rolloverSize=50, traceFilename='$' + ' {LOG_ROOT}/' + '$' + '{SERVER}/trace.log'):
    if (targetServer):
        print ("Starting configuration for server " + serverName + "...")

        targetTraceService = AdminConfig.list("TraceService", targetServer)

        if (targetTraceService):
            AdminConfig.modify(targetTraceService, [['startupTraceSpecification', traceSpec]] )
            AdminConfig.modify(targetTraceService, [['traceOutputType', outputType]] )
            AdminConfig.modify(targetTraceService, [['traceLog', [['fileName', traceFilename], ['maxNumberOfBackupFiles', '%d' % maxBackupFiles], ['rolloverSize', '%d' % rolloverSize ]]]] )
        else:
            raise "Error configuring the web container for server " + serverName + "."
        #endif
    else:
        raise "No server was found with the provided name: " + serverName + "."
    #endif
#enddef

def setProcessExec(targetServer, runAsUser, runAsGroup):
    if ((targetServer)):
        processExec = AdminConfig.list("ProcessExecution", targetServer)

        if ((runAsUser) and (runAsGroup)):
            AdminConfig.modify(processExec, '[[runAsUser %s] [runAsGroup %s] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]') % (runAsUser, runAsGroup)
        elif (runAsUser):
            AdminConfig.modify(processExec, '[[runAsUser %s] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]') % (runAsUser)
        else:
            AdminConfig.modify(processExec, '[[runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
        #end if
    else:
        raise "No server was found with the provided name: " + serverName + "."
    #endif
#enddef

def setJVMProperties(serverName, nodeName, initialHeapSize=4096, maxHeapSize=4096):
    genericJvmArgs = ("${WPS_JVM_ARGUMENTS_EXT} -Dibm.stream.nio=true -Djava.io.tmpdir=${WAS_TEMP_DIR} -Xdump:stack:events=allocation,filter=#10m -Xgcpolicy:gencon "
        "-verbose:gc -Xverbosegclog:${SERVER_LOG_ROOT}/verbosegc.%Y%m%d.%H%M%S.%pid.txt,20,10000 -Dcom.ibm.websphere.alarmthreadmonitor.threshold.millis=40000 "
        "-Xmns1536M -Xmnx1536M -XX:MaxDirectMemorySize=256000000 -Xscmx512m -Xshareclasses:none -Dsun.reflect.inflationThreshold=0 -Djava.security.egd=file:/dev/./urandom "
        "-Dcom.sun.jndi.ldap.connect.pool.maxsize=200 -Dcom.sun.jndi.ldap.connect.pool.prefsize=200 -Dcom.sun.jndi.ldap.connect.pool.timeout=3000 "
        "-Djava.net.preferIPv4Stack=true -Dsun.net.inetaddr.ttl=600 -DdisableWSAddressCaching=true "
        "-Dcom.ibm.websphere.webservices.http.connectionKeepAlive=true -Dcom.ibm.websphere.webservices.http.maxConnection=1200 "
        "-Dcom.ibm.websphere.webservices.http.connectionIdleTimeout=6000 -Dcom.ibm.websphere.webservices.http.connectionPoolCleanUpTime=6000 "
        "-Dcom.ibm.websphere.webservices.http.connectionTimeout=0 -Dlog4j2.formatMsgNoLookups=true -Dderby.system.home=${USER_INSTALL_ROOT}/PortalServer/derby "
        "-Dephox.config.file=/opt/ephox/application.conf -Xjit:iprofilerMemoryConsumptionLimit=67108864 -Xcodecache20m")

    if ((serverName) and (nodeName)):
        AdminTask.setJVMProperties('[-serverName %s -nodeName %s -verboseModeGarbageCollection true -initialHeapSize %s -maximumHeapSize + %s -debugMode false -genericJvmArguments %s]') \
            % (serverName, nodeName, initialHeapSize, maxHeapSize)
    else:
        raise "No server was found with the provided name: " + serverName + "."
    #endif
#enddef

def serverStatus(nodeName, serverName):
    targetServer = AdminConfig.getid('/Node:' + nodeName + '/Server:' + serverName + '/')

    if (targetServer):
        print (AdminControl.getAttribute(targetServer, 'state'))
    else:
        print ("No server was provided.")
    #endif
#enddef

def startServer(nodeName, serverName, startWaitTime=10):
    if ((nodeName) and (serverName)):
        try:
            AdminControl.startServer(nodename, servername, startWaitTime)
        except:
            (exception, parms, tback) = sys.exc_info()

            if (-1 != repr( parms ).find("already running")):
                return
            else:
                # Some other error? scream and shout
                raise Exception("EXCEPTION STARTING SERVER %s: %s %s" % (serverName, str(exception),str(parms)))
            #endif
        #endtry
    else:
        raise Exception("EXCEPTION STARTING SERVER %s: %s %s" % (serverName, str(exception),str(parms)))
    #endif
#enddef

def stopServer(nodeName, serverName, immediate=False, terminate=False):
    if ((nodeName) and (serverName)):
        try:
            if (terminate):
                AdminControl.stopServer(nodename, servername, 'terminate' )
            elif (immediate):
                AdminControl.stopServer(nodename, servername, 'immediate' )
            else:
                AdminControl.stopServer(nodename, servername)
            #endif
        except:
            (exception, parms, tback) = sys.exc_info()

            if (-1 != repr( parms ).find("already running")):
                return
            else:
                # Some other error? scream and shout
                raise Exception("An error occurred stopping server %s: %s %s" % (targetServer, str(exception),str(parms)))
            #endif
        #endtry
    else:
        raise Exception("No node/server information was provided.")
    #endif
#enddef

def restartServer(nodeName, serverName, restartTimeout=300):
    if ((nodeName) and (serverName)):
        if (serverStatus(nodeName, serverName) == "RUNNING"):
            raise Exception("Server %s is already running on node %s %s" % (serverName, nodeName))
        else:
            targetServer = AdminControl.completeObjectName('type=Server,node=%s,process=%s,*' % (nodeName, serverName))

            if (targetServer):
                try:
                    AdminControl.invoke(serverObjectName, 'restart')

                    elapsedTime = 0

                    if (restartTimeout > 0):
                        sleepTime = 5
                        isRunning = serverStatus(nodeName, serverName)

                        while ((isRunning) and (elapsedTime < restartTimeout)):
                            time.sleep(sleepTime)

                            elapsedTime = elapsedTime + sleepTime
                            isRunning = serverStatus(nodeName, serverName)
                        #endwhile

                        # Phase 2 - Wait for server to start (This can take another minute)
                        while not isRunning and elapsedtimeseconds < maxwaitseconds:
                            sop(m,"Waiting %d of %d seconds for %s to restart. isRunning=%s" % ( elapsedtimeseconds, maxwaitseconds, servername, isRunning, ))
                            time.sleep( sleeptimeseconds )
                            elapsedtimeseconds = elapsedtimeseconds + sleeptimeseconds
                            isRunning = isServerRunning( nodename, servername )
                        #endwhile

                    isRunning = isServerRunning( nodename, servername )
                    sop(m,"Exit. nodename=%s servername=%s maxwaitseconds=%d elapsedtimeseconds=%d Returning isRunning=%s" % (nodename, servername, maxwaitseconds, elapsedtimeseconds, isRunning ))
                    return isRunning
                except:
                    (exception, parms, tback) = sys.exc_info()

                    if (-1 != repr( parms ).find("already running")):
                        return
                    else:
                        # Some other error? scream and shout
                        raise Exception("An error occurred restarting server %s: %s %s" % (targetServer, str(exception),str(parms)))
                    #endif
                #endtry
            else:
                raise Exception("A server with name %s on node %s could not be found." % (serverName, nodeName))
            #endif
        #endif
    else:
        raise Exception("No node/server information was provided.")
    #endif
#enddf

def printHelp():
    print("This script configures default values for the provided jvm.")
    print("Format is configureTargetServer serverName")
#enddef

def printHelp():
    print ("This script configures aan application server (or servers) for optimal settings.")
    print ("Execution: wsadmin.sh -lang jython -f configureApplicationServer.py <target server> <runAsUser> <runAsGroup>")
    print ("<target server> - The target server to apply configuration to. One of \"all\" or the server name to configure. Required.")
    print ("<runAsUser> - The operating system username to run the process as. The user must exist on the local machine. Optional, if not provided no user is configured.")
    print ("<runAsGroup> - The operating system group to run the process as. The group must exist on the local machine. Optional, if not provided no group is configured.")
#enddef

##################################
# main
#################################
if (sys.argv[0] == "all"):
    if (len(sys.argv) == 1):
        configureAllServers()
    elif (len(sys.argv) == 2):
        configureAllServers(sys.argv[1], sys.argv[2])
    elif (len(sys.argv) == 3):
        configureAllServers(sys.argv[1], sys.argv[2], sys.argv[3])
    else:
        printHelp()
    #endif
else:
    if (len(sys.argv) == 1):
        configureTargetServer(sys.argv[0])
    elif (len(sys.argv) == 2):
        configureTargetServer(sys.argv[0], sys.argv[1])
    elif (len(sys.argv) == 3):
        configureTargetServer(sys.argv[0], sys.argv[1], sys.argv[2])
    else:
        printHelp()
    #endif
#endif
