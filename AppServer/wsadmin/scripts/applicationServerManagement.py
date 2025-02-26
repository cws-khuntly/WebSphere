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
import time
import logging

configureLogging("../config/logging.xml")
logger = logging.getLogger(__name__)

global configFile

lineSplit = java.lang.System.getProperty("line.separator")
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

## TODO
def configureAllServers():
    serverList = AdminTask.listServers('[-serverType APPLICATION_SERVER ]').split(lineSplit)

    logger.debug(serverList)

    if (len(serverList) != 0):
        logger.info("Starting configuration for all servers in cell %s..") % (targetCell)
        print("Starting configuration for all servers in cell %s..") % (targetCell)

        for server in (serverList):
            logger.debug(server)

            if (len(server) != 0):
                logger.info("Starting configuration for all servers in cell %s..") % (targetCell)
                print("Starting configuration for server %s..") % (server)

                try:
                    logger.debug("Calling configureTargetServer()..")

                    configureTargetServer()

                    logger.info("Configuration complete for server %s") % (targetCell)
                    print("Configuration complete for server %s") % (server)
                except:
                    logger.info("Configuration complete for server %s") % (targetCell)
                    print("An error occurred configuring the server %s. Please review logs.") % (server)

                    continue
                #endtry
            #endtry

            continue
        #endfor
    else:
        logger.error("No servers were found in the cell %s.") % (targetCell)
        print("No servers were found in the cell %s.") % (targetCell)
    #endif
#enddef

def configureTargetServer():
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        logger.debug(properties)

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            logger.debug(nodeName)
            logger.debug(serverName)

            if ((len(nodeName) != 0) and (len(serverName) != 0)):
                targetServer = AdminConfig.getid('/Node:%s/Server:%s/') % (nodeName, serverName)

                logger.debug(targetServer)

                if (len(targetServer) != 0):
                    logger.info("Starting configuration for server %s..") % (serverName)
                    print("Starting configuration for server %s..") % (serverName)

                    try:
                        configureAutoRestart(configFile, targetServer)
                        configureWebContainer(targetServer)
                        setServerTrace(targetServer)
                        setProcessExec(targetServer)
                        configureThreadPools(targetServer)
                        setServletCaching(targetServer)
                        setPortletCaching(targetServer)

                        logger.info("Completed configuration for server %s.") % (serverName)
                        print("Completed configuration for server %s.") % (serverName)
                    except:
                        logger.error("An error occurred performing configuration steps for server %s. Please review logs.")
                        print("An error occurred performing configuration steps for server %s. Please review logs.")
                    finally:
                        logger.debug("Saving workspace changes and synchronizing the cell..")

                        saveWorkspaceChanges()
                        syncAllNodes(nodeList, targetCell)
                    #endfor
                else:
                    logger.error("No server was found with node name %s and server name %s.") % (nodeName, serverName)
                    print("No server was found with node name %s and server name %s.") % (nodeName, serverName)
                #endif
            else:
                logger.error("No node/server information was found in the provided configuration file.")
                print("No node/server information was found in the provided configuration file.")
            #endif
        else:
            logger.error("No server information section was found in the provided configuration file.")
            print("No server information section was found in the provided configuration file.")
        #endif
    else:
        logger.error("No configuration file was provided.")
        print("No configuration file was provided.")
    #endif
#enddef

def configureAutoRestart(targetServer, autoRestart = "STOPPED"):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-auto-restart")

        if (len(properties) != 0):
            setRestartValue = properties["restart-policy"] or autoRestart

            if (len(targetServer) != 0):
                monitorPolicy = AdminConfig.list('MonitoringPolicy', targetServer)

                if (len(monitorPolicy) != 0):
                    try:
                        AdminConfig.modify(monitorPolicy, '[[maximumStartupAttempts "3"] [pingTimeout "300"] [pingInterval "60"] [autoRestart "true"] [nodeRestartState "%s"]]') % (setRestartValue)
                    except:
                        raise Exception ("An error occurred updating the monitoring policy for the provided server. Please review logs.")
                    #endtry
                else:
                    raise Exception ("No monitoring policy was found for the provided server.")
                #endif
            else:
                raise Exception ("No monitoring policy value was found in the provided configuration file.")
            #endif
        else:
            raise Exception ("No monitoring policy information section was found in the provided configuration file.")
        #endif
    else:
        raise Exception ("No configuration file was provided.")
    #endif
#enddef

def configureWebContainer(targetServer, defaultVHost = "default_host"):
    if ("configFile" != ""):
        properties = readConfigurationFileSection(configFile, "server-default-vhost")

        if (len(properties) != 0):
            setDefaultHost = properties["virtual-host"] or defaultVHost

            if (len(targetServer) != 0):
                targetWebContainer = AdminConfig.list('WebContainer', targetServer)

                if (len(targetWebContainer) != 0):
                    try:
                        AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.extractHostHeaderPort"] [description ""] [value "true"] [required "false"]]')
                        AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "trusthostheaderport"] [description ""] [value "true"] [required "false"]]')
                        AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.invokefilterscompatibility"] [description ""] [value "true"] [required "false"]]')

                        AdminConfig.modify(targetWebContainer, '[[defaultVirtualHostName %s]]') % (setDefaultHost)
                    except:
                        raise Exception ("An error occurred while modifying the web container. Please review logs.")
                    #endtry
                else:
                    raise Exception ("No web container was found for the provided server.")
                #endif
            else:
                raise Exception ("No server was provided to configure.")
            #endif
        else:
            raise Exception ("No virtual host information section was found in the provided configuration file.")
        #endif
    else:
        raise Exception ("No configuration file was provided.")
    #endif
#enddef

def configureHAManager(targetServer, isEnabled = "false"):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-hamanager")

        if (len(properties) != 0):
            isHAEnabled = properties["enabled"] or isEnabled

            if (len(targetServer) != 0):
                haManager = AdminConfig.list('HAManagerService', targetServer)

                if (len(haManager) != 0):
                    try:
                        AdminConfig.modify(haManager, '[[enable "%s"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]') % (isHAEnabled)
                    except:
                        raise Exception ("An error occurred while modifying the HAManager service. Please review logs.")
                    #endtry
                else:
                    raise Exception ("No HAManager service was found for the provided server.")
                #endif
            else:
                raise Exception ("No server was provided to configure.")
            #endif
        else:
            raise Exception ("No HAManager information section was found in the provided configuration file.")
        #endif
    else:
        raise Exception ("No configuration file was provided.")
    #endif
#enddef

def setServletCaching(targetServer, isEnabled = "true"):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-servlet-caching")

        if (len(properties) != 0):
            isServletCachingEnabled = properties["enabled"] or isEnabled

            if (len(targetServer) != 0):
                targetWebContainer = AdminConfig.list('WebContainer', targetServer)

                if (len(targetWebContainer) != 0):
                    try:
                        AdminConfig.modify(targetWebContainer, '[[enableServletCaching "%s"]]') % (isServletCachingEnabled)
                    except:
                        raise Exception ("An error occurred while configuring servlet caching for the provided server. Please review logs.")
                    #endtry
                else:
                    raise Exception ("No web container was found for the provided server.")
                #endif
            else:
                raise Exception ("No server was provided to configure.")
            #endif
        else:
            raise Exception ("No servlet caching information section was found in the provided configuration file.")
        #endif
    else:
        raise Exception ("No configuration file was provided.")
    #endif
#enddef

def setPortletCaching(targetServer, isEnabled = "true"):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-portlet-caching")

        if (len(properties) != 0):
            isPortalServer = properties["is-portal-host"] or False

            if (isPortalServer):
                isPortletCachingEnabled = properties["enabled"] or isEnabled

                if (len(targetServer) != 0):
                    targetWebContainer = AdminConfig.list('WebContainer', targetServer)

                    if (targetWebContainer):
                        try:
                            AdminConfig.modify(targetWebContainer, '[[enablePortletCaching "%s"]]') % (isPortletCachingEnabled)
                        except:
                            raise Exception ("An error occurred while configuring portlet caching for the provided server. Please review logs.")
                        #endtry
                    else:
                        raise Exception ("No web container was found for the provided server.")
                    #endif
                else:
                    raise Exception ("No server was provided to configure.")
                #endif
            #endif
        else:
            raise Exception ("No portlet caching information section was found in the provided configuration file.")
        #endif
    else:
        raise Exception ("No configuration file was provided.")
    #endif
#enddef

def setServerTrace(targetServer, traceSpec = "*=info", outputType = "SPECIFIED_FILE", maxBackupFiles = 50, rolloverSize = 50, traceFilename = "\${SERVER_LOG_ROOT}/trace.log"):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-trace-settings")

        if (len(properties) != 0):
            traceSpecificationValue = properties["trace-spec"] or traceSpec
            traceOutputType = properties["output-type"] or outputType
            maxBackupFileCount = properties["max-backup-files"] or maxBackupFiles
            maxTraceFileSize = properties["max-file-size"] or rolloverSize
            traceFileNameAndPath = properties["trace-file-name"] or traceFilename

            if (len(targetServer) != 0):
                targetTraceService = AdminConfig.list('TraceService', targetServer)

                if (len(targetTraceService) != 0):
                    try:
                        AdminConfig.modify(targetTraceService, '[[startupTraceSpecification, "%s"]]') % (traceSpecificationValue)
                        AdminConfig.modify(targetTraceService, '[[traceOutputType, "%s"]]') % (traceOutputType)
                        AdminConfig.modify(targetTraceService, '[[traceLog, [["fileName", "%s"], ["maxNumberOfBackupFiles", "%d"], ["rolloverSize", "%d"]]]') % (traceFileNameAndPath, maxBackupFileCount, maxTraceFileSize)
                    except:
                        raise Exception ("An error occurred while configuring the trace service for the provided server. Please review logs.")
                    #endtry
                else:
                    raise Exception ("No trace service was found for the provided server.")
                #endif
            else:
                raise Exception ("No server was provided to configure.")
            #endif
        else:
            raise Exception ("No trace configuration information section was found in the provided configuration file.")
        #endif
    else:
        raise Exception ("No configuration file was provided.")
    #endif
#enddef

def setProcessExec(targetServer, runAsUser = "", runAsGroup = ""):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-process-settings")

        if (len(properties) != 0):
            runUserName = properties["run-user"] or runAsUser
            runGroupName = properties["run-group"] or runAsGroup

            if (len(targetServer) != 0):
                processExec = AdminConfig.list('ProcessExecution', targetServer)

                if (len(processExec) != 0):
                    try:
                        if ((len(runUserName) != 0) and (len(runGroupName) != 0)):
                            AdminConfig.modify(processExec, '[[runAsUser "%s"] [runAsGroup "%s"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]') % (runUserName, runGroupName)
                        elif (len(runUserName) != 0):
                            AdminConfig.modify(processExec, '[[runAsUser "%s"] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]') % (runUserName)
                        #end if
                    except:
                        raise Exception ("An error occurred while configuring process execution for the provided server. Please review logs.")
                    #endtry
                else:
                    raise Exception ("No process execution information was found for the provided server.")
                #endif
            else:
                raise Exception ("No server was provided to configure.")
            #endif
        else:
            raise Exception ("No process execution information section was found in the provided configuration file.")
        #endif
    else:
        raise Exception ("No configuration file was provided.")
    #endif
#enddef

def setJVMProperties(initialHeapSize = 2048, maxHeapSize = 2048):
    genericJvmArgs = ("${WPS_JVM_ARGUMENTS_EXT} -Dibm.stream.nio=true -Djava.io.tmpdir=${WAS_TEMP_DIR} -Xdump:stack:events=allocation,filter=#10m -Xgcpolicy:gencon "
        "-verbose:gc -Xverbosegclog:${SERVER_LOG_ROOT}/verbosegc.%Y%m%d.%H%M%S.%pid.txt,20,10000 -Dcom.ibm.websphere.alarmthreadmonitor.threshold.millis=40000 "
        "-Xmns1536M -Xmnx1536M -XX:MaxDirectMemorySize=256000000 -Xshareclasses:none -Dsun.reflect.inflationThreshold=0 -Djava.security.egd=file:/dev/./urandom "
        "-Dcom.sun.jndi.ldap.connect.pool.maxsize=200 -Dcom.sun.jndi.ldap.connect.pool.prefsize=200 -Dcom.sun.jndi.ldap.connect.pool.timeout=3000 "
        "-Djava.net.preferIPv4Stack=true -Dsun.net.inetaddr.ttl=600 -DdisableWSAddressCaching=true -Djava.awt.headless=true -Dcom.ibm.cacheLocalHost=true "
        "-Dcom.ibm.websphere.webservices.http.connectionKeepAlive=true -Dcom.ibm.websphere.webservices.http.maxConnection=1200 -Xnoagent -XX:+HeapDumpOnOutOfMemoryError "
        "-Dcom.ibm.websphere.webservices.http.connectionIdleTimeout=6000 -Dcom.ibm.websphere.webservices.http.connectionPoolCleanUpTime=6000 -XX:+UseStringDeduplication "
        "-Dcom.ibm.websphere.webservices.http.connectionTimeout=0 -Dlog4j2.formatMsgNoLookups=true -Xjit:iprofilerMemoryConsumptionLimit=67108864 -XX:+AggressiveOpts "
        "-Dephox.config.file=/opt/ephox/application.conf -Xrunjdwp=dt_socket,server=y,suspend=n,address=7792 -Dcom.ibm.xml.xlxp.jaxb.opti.level=3")

    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            if ((serverName) and (nodeName)):
                jvmConfigInfo = readConfigurationFileSection(configFile, "server-jvm-settings")

                if (len(jvmConfigInfo) != 0):
                    minHeap = jvmConfigInfo["initial-heap-size"] or initialHeapSize
                    maxHeap= jvmConfigInfo["max-heap-size"] or maxHeapSize
                    targetServer = AdminConfig.getid('/Node:%s/Server:%s/') % (nodeName, serverName)

                    if (len(targetServer) != 0):
                        try:
                            AdminTask.setJVMProperties('[-serverName %s -nodeName %s -verboseModeGarbageCollection true -initialHeapSize %d -maximumHeapSize + %d -debugMode false -genericJvmArguments %s]') \
                                % (serverName, nodeName, minHeap, maxHeap)
                        except:
                            raise Exception ("An error occurred while configuring the JVM for the provided server. Please review logs.")
                        #endtry
                    else:
                        raise Exception ("No server was provided to configure.")
                        #endif
                    #endif
                else:
                    raise Exception ("No JVM configuration information section was found in the provided configuration file.")
                #endif
            else:
                print("No node/server information was found in the provided configuration file.")
            #endif
        else:
            raise Exception ("No server information section was found in the provided configuration file.")
        #endif
    else:
        raise Exception ("No configuration file was provided.")
    #endif
#enddef

def configureCookies(targetServer, cookieName = "JSESSIONID"):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-cookie-settings")

        if (len(properties) != 0):
            cookieName = properties["cookie-name"] or cookieName
            targetCookie = AdminConfig.list("Cookie", targetServer)

            if (len(targetCookie) != 0):
                try:
                    AdminConfig.modify(targetCookie, '[[maximumAge "-1"] [name "JSESSIONID"] [domain ""] [secure "true"] [path "/"]]')
                except:
                    raise Exception ("An error occurred while configuring cookie settings for the provided server.")
                #endtry
            else:
                raise Exception ("No cookie configuration was found for the provided server")
            #endif
        else:
            raise Exception ("No cookie configuration section was found in the provided configuration file.")
        #endif
    else:
        raise Exception ("No configuration file was provided.")
    #endif
#enddef

## TODO
def configureThreadPools(targetServer):
    if (len(targetServer) != 0):
        threadPools = AdminConfig.list('ThreadPool', targetServer).split(lineSplit)

        if (len(threadPools) != 0):
            for threadPool in (threadPools):
                poolName = threadPool.split("(")[0]

                if (len(poolName) != 0):
                    try:
                        if (poolName == "server.startup"):
                            AdminConfig.modify(threadPool, '[[maximumSize "10"] [name "%s"] [inactivityTimeout "30000"] [minimumSize "0"] [description "This pool is used by WebSphere during server startup."] [isGrowable "false"]]') % (poolName)
                        elif (poolName == "WebContainer"):
                            AdminConfig.modify(threadPool, '[[maximumSize "75"] [name "%s"] [inactivityTimeout "5000"] [minimumSize "20"] [description ""] [isGrowable "false"]]') % (poolName)
                        elif (poolName == "HAManagerService.Pool"):
                            AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
                        #endif
                    except:
                        raise Exception ("An error occurred while configuring the JVM for the provided server. Please review logs.")
                    #endtry
                #endif
            #endfor
        else:
            raise Exception ("No thread pools were found for the provided server.")
        #endif
    else:
        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureTCPChannels(targetServer):
    if (len(targetServer) != 0):
        targetTCPChannels = AdminConfig.list('TCPInboundChannel', targetServer).split(lineSplit)

        if (len(targetTCPChannels) != 0):
            for tcpChannel in (targetTCPChannels):
                tcpName = tcpChannel.split("(")[0]

                if (len(tcpName) != 0):
                    try:
                        if (tcpName == "TCP_2"):
                            AdminConfig.modify(tcpChannel, '[[maxOpenConnections "50"]]')
                        else:
                            continue
                        #endif
                    except:
                        raise Exception ("An error occurred while configuring TCP Channel %s for the provided server. Please review logs.") % (tcpName)
                    #endtry
                else:
                    continue
                #endtry
            #endfor
        else:
            raise Exception ("No TCP Channels were found for the provided server.")
        #endif
    else:
        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureHTTPChannels(targetServer):
    if (len(targetServer) != 0):
        targetHTTPChannels = AdminConfig.list('HTTPInboundChannel', targetServer).split(lineSplit)

        if (len(targetHTTPChannels) != 0):
            for httpChannel in (targetHTTPChannels):
                if (len(httpChannel) != 0):
                    httpName = httpChannel.split("(")[0]

                    if (len(httpName) != 0):
                        if (httpName == "HTTP_2"):
                            try:
                                AdminConfig.modify(httpChannel, '[[maximumPersistentRequests "-1"] [persistentTimeout "300"] [enableLogging "true"]]')
                                AdminConfig.create('Property', httpChannel, '[[validationExpression ""] [name "RemoveServerHeader"] [description ""] [value "true"] [required "false"]]')
                            except:
                                raise Exception ("An error occurred while configuring HTTP Channel %s for the provided server. Please review logs.") % (httpName)
                            #endtry
                        else:
                            continue
                        #endif
                    else:
                        continue
                    #endif
                else:
                    continue
                #endif
            #endfor
        else:
            raise Exception ("No HTTP Channels were found for the provided server.")
        #endif
    else:
        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureContainerChains(targetServer):
    if (len(targetServer) != 0):
        targetTransport = AdminConfig.list('TransportChannelService', targetServer)

        if (len(targetTransport) != 0):
            containerChains = AdminTask.listChains(targetTransport, '[-acceptorFilter WebContainerInboundChannel]').split(lineSplit)

            if (len(containerChains) != 0):
                for chain in (containerChains):
                    if (len(chain) != 0):
                        chainName = chain.split("(")[0]

                        if (len(chainName) != 0):
                            if (chainName == "WCInboundDefault"):
                                continue
                            elif (chainName == "WCInboundDefaultSecure"):
                                continue
                            elif (chainName == "WCInboundAdminSecure"):
                                continue
                            else:
                                try:
                                    AdminTask.deleteChain(chain, '[-deleteChannels true]')
                                except:
                                    log("foo")
                                #endtry
                            #endif
                        else:
                            continue
                        #endif
                    else:
                        continue
                    #endif
                #endfor
            else:
                raise Exception ("No container chains were found for the provided server.")
            #endif
        else:
            raise Exception ("No transports were found for the provided server.")
        #endif
    else:
        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureTuningParams(targetServer):
    if (len(targetServer) != 0):
        targetTuning = AdminConfig.list('TuningParams', targetServer)

        if (targetTuning):
            try:
                AdminConfig.modify(targetTuning, '[[writeContents "ONLY_UPDATED_ATTRIBUTES"] [writeFrequency "END_OF_SERVLET_SERVICE"] [scheduleInvalidation "false"] [invalidationTimeout "60"]]')
            except:
                raise Exception ("An error occurred configuring the tuning parameters for the provided server. Please review logs.")
            #endtry
        else:
            raise Exception ("No target tuning parameters were found for the provided server.")
        #endif
    else:
        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureSessionManager(targetServer):
    if (len(targetServer) != 0):
        sessionManager = AdminConfig.list('SessionManager', targetServer)

        if (len(sessionManager) != 0):
            try:
                AdminConfig.modify(sessionManager, '[[enableSecurityIntegration "true"] [maxWaitTime "5"] [allowSerializedSesssionAccess "false"] [enableUrlRewriting "false"] [enable "true"] accessSessionOnTimeout "true" [enableSSLTracking "true"] [enableCookies "true"]]')
            except:
                raise Exception ("An error occurred configuring the session manager service for the provided server. Please review logs.")
            #endtry
        else:
            raise Exception ("No session manager was found for the provided server.")
        #endif
    else:
        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def serverStatus():
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            if ((nodeName) and (serverName)):
                targetServer = AdminConfig.getid('/Node:%s/Server:%s/') % (nodeName, serverName)

                if (len(targetServer) != 0):
                    try:
                        print(AdminControl.getAttribute(targetServer, 'state'))
                    except:
                        print("An error occurred trying to determine the state of server %s on node %s. Please review logs.") % (serverName, nodeName)
                    #endtry
                else:
                    print("No server was found with server name %s and node name %s.") % (serverName, nodeName)
                #endif
            else:
                print("No node/server information was found in the provided configuration file.")
            #endif
        else:
            print("No server information section was found in the provided configuration file.")
        #endif
    else:
        print("No configuration file was provided.")
    #endif
#enddef

def startServer(startWaitTime = 10):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            if ((len(nodeName) != 0) and (len(serverName) !=0)):
                startProperties = readConfigurationFileSection(configFile, "server-startup-settings")

                if (len(startProperties != 0)):
                    startWaitTimeSecs = startProperties["start-wait-time"] or startWaitTime

                    try:
                        AdminControl.startServer(nodeName, serverName, startWaitTimeSecs)
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        if (-1 != repr( parms ).find("already running")):
                            return
                        else:
                            print("An error occurred while starting server %s on node %s: %s %s") % (serverName, nodeName, str(exception), str(parms))
                        #endif
                    #endtry
                else:
                    print("No server startup settings section was found in the provided configuration file.")
                #endif
            else:
                print("No node/server information was found in the provided configuration file.")
            #endif
        else:
            print("No server information section was found in the provided configuration file.")
        #endif
    else:
        print("No configuration file was provided.")
    #endif
#enddef

def stopServer(immediate = False, terminate = False):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            if ((len(nodeName) != 0) and (len(serverName) !=0)):
                stopProperties = readConfigurationFileSection(configFile, "server-stop-options")

                if (len(stopProperties != 0)):
                    isImmediateStop = stopProperties["immediate-stop"] or immediate
                    isTerminateStop = stopProperties["terminate-stop"] or terminate

                    try:
                        if (isImmediateStop):
                            AdminControl.stopServer(nodename, servername, 'immediate' )
                        elif (isTerminateStop):
                            AdminControl.stopServer(nodename, servername, 'terminate' )
                        else:
                            AdminControl.stopServer(nodename, servername)
                        #endif
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        if (-1 != repr( parms ).find("already running")):
                            return
                        else:
                            # Some other error? scream and shout
                            raise Exception ("An error occurred stopping server %s: %s %s" % (serverName, str(exception),str(parms)))
                        #endif
                    #endtry
                else:
                    print("No server stop settings section was found in the provided configuration file.")
                #endif
            else:
                print("No node/server information was found in the provided configuration file.")
            #endif
        else:
            print("No server information section was found in the provided configuration file.")
        #endif
    else:
        print("No configuration file was provided.")
    #endif
#enddef

## TODO
def restartServer(restartTimeout = 300):
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            if ((len(nodeName) != 0) and (len(serverName) !=0)):
                restartProperties = readConfigurationFileSection(configFile, "server-stop-options")

                if (len(restartProperties != 0)):
                    restartTimeoutSecs = restartProperties["node-name"] or restartTimeout

                    if (serverStatus(nodeName, serverName) == "RUNNING"):
                        raise Exception ("Server %s is already running on node %s" % (serverName, nodeName))
                    else:
                        targetServer = AdminControl.completeObjectName('type=Server,node=%s,process=%s,*' % (nodeName, serverName))

                        if (len(targetServer) != 0):
                            try:
                                AdminControl.invoke(serverObjectName, 'restart')

                                elapsedTime = 0

                                if (restartTimeoutSecs > 0):
                                    sleepTime = 5
                                    isRunning = serverStatus(nodeName, serverName)

                                    while ((isRunning) and (elapsedTime < restartTimeout)):
                                        time.sleep(sleepTime)

                                        elapsedTime = elapsedTime + sleepTime
                                        isRunning = serverStatus(nodeName, serverName)
                                    #endwhile

                                    # Phase 2 - Wait for server to start (This can take another minute)
                                    while ((not isRunning) and (elapsedtimeseconds < restartTimeoutSecs)):
                                        sop(m,"Waiting %d of %d seconds for %s to restart. isRunning=%s" % (elapsedtimeseconds, restartTimeoutSecs, serverName, isRunning,))

                                        time.sleep(sleepTime)

                                        elapsedtimeseconds = elapsedtimeseconds + sleepTime

                                        isRunning = serverStatus(nodeName, serverName)
                                    #endwhile
                                #endif

                                isRunning = serverStatus(nodeName, serverName)

                                sop(m,"Exit. nodename=%s servername=%s maxwaitseconds=%d elapsedtimeseconds=%d Returning isRunning=%s" % (nodename, servername, maxwaitseconds, elapsedtimeseconds, isRunning))

                                return isRunning
                            except:
                                (exception, parms, tback) = sys.exc_info()

                                if (-1 != repr( parms ).find("already running")):
                                    return
                                else:
                                    # Some other error? scream and shout
                                    raise Exception ("An error occurred restarting server %s: %s %s" % (targetServer, str(exception),str(parms)))
                                #endif
                            #endtry
                        else:
                            raise Exception ("A server with name %s on node %s could not be found." % (serverName, nodeName))
                        #endif
                    #endif
                #endif
            else:
                print("No node/server information was found in the provided configuration file.")
            #endif
        else:
            print("No server information section was found in the provided configuration file.")
        #endif
    else:
        print("No configuration file was provided.")
    #endif
#enddf

def printHelp():
    print("This script performs server management tasks.")
    print("Execution: wsadmin.sh -lang jython -f applicationServerManagement.py <option> <configuration file>")
    print("Options are: ")
    print("    configure-all-servers: Performs configuration tasks for all servers in the cell.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain the server and node names.")
    print("                    This section may contain a value indicating if the server is a Portal server.")
    print("                [server-auto-restart]")
    print("                    This section may contain a value to determine the monitoring restart policy for the server. If no value is provided, the default value is \"STOPPED\".")
    print("                [server-default-vhost]")
    print("                    This section may contain a value to configure the default virtualhost. If no value is provided, the default value is \"default_host\".")
    print("                [server-servlet-caching]")
    print("                    This section may contain a value to configure servlet caching. If no value is provided, the default value is \"true\".")
    print("                [server-portlet-caching]")
    print("                    This section may contain a value to configure portlet caching. If no value is provided, the default value is \"true\".")
    print("                [server-trace-settings]")
    print("                    This section may contain a value to configure startup trace specifications. If no value is provided, the default value is \"*=info\".")
    print("                    This section may contain a value to configure the trace output type. If no value is provided, the default value is \"SPECIFIED_FILE\".")
    print("                    This section may contain a value to configure the maximum number of trace backup files. If no value is provided, the default value is 50.")
    print("                    This section may contain a value to configure the maximum size of the trace file before it is rolled over. If no value is provided, the default value is 50.")
    print("                    This section may contain a value to configure the trace filename. If no value is provided, the default value is \"'$' + ' {LOG_ROOT}/' + '$' + '{SERVER}/trace.log'.")
    print("                [server-process-settings]")
    print("                    This section may contain a value to configure the user to run the server as. If no value is provided, the \"runAsUser\" entry is not configured.")
    print("                    This section may contain a value to configure the group to run the server as. If no value is provided, the \"runAsGroup\" entry is not configured.")
    print("                [server-jvm-settings]")
    print("                    This section may contain a value to configure the initial JVM heap size. If no value is provided, the default value is 2048.")
    print("                    This section may contain a value to configure the maximum JVM heap size. If no value is provided, the default value is 2048.")
    print("                [server-cookie-settings]")
    print("                    This section may contain a value to configure the cookie name. If no value is provided, the default value is \"JSESSIONID\".")

    print("    configure-specified-server: Performs configuration tasks for a specified server on a node.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain the server and node names.")
    print("                    This section may contain a value indicating if the server is a Portal server.")
    print("                [server-auto-restart]")
    print("                    This section may contain a value to determine the monitoring restart policy for the server. If no value is provided, the default value is \"STOPPED\".")
    print("                [server-default-vhost]")
    print("                    This section may contain a value to configure the default virtualhost. If no value is provided, the default value is \"default_host\".")
    print("                [server-servlet-caching]")
    print("                    This section may contain a value to configure servlet caching. If no value is provided, the default value is \"true\".")
    print("                [server-portlet-caching]")
    print("                    This section may contain a value to configure portlet caching. If no value is provided, the default value is \"true\".")
    print("                [server-trace-settings]")
    print("                    This section may contain a value to configure startup trace specifications. If no value is provided, the default value is \"*=info\".")
    print("                    This section may contain a value to configure the trace output type. If no value is provided, the default value is \"SPECIFIED_FILE\".")
    print("                    This section may contain a value to configure the maximum number of trace backup files. If no value is provided, the default value is 50.")
    print("                    This section may contain a value to configure the maximum size of the trace file before it is rolled over. If no value is provided, the default value is 50.")
    print("                    This section may contain a value to configure the trace filename. If no value is provided, the default value is \"'$' + ' {LOG_ROOT}/' + '$' + '{SERVER}/trace.log'.")
    print("                [server-process-settings]")
    print("                    This section may contain a value to configure the user to run the server as. If no value is provided, the \"runAsUser\" entry is not configured.")
    print("                    This section may contain a value to configure the group to run the server as. If no value is provided, the \"runAsGroup\" entry is not configured.")
    print("                [server-jvm-settings]")
    print("                    This section may contain a value to configure the initial JVM heap size. If no value is provided, the default value is 2048.")
    print("                    This section may contain a value to configure the maximum JVM heap size. If no value is provided, the default value is 2048.")
    print("                [server-cookie-settings]")
    print("                    This section may contain a value to configure the cookie name. If no value is provided, the default value is \"JSESSIONID\".")

    print("    server-status: Retrieves and displays the current status of a given server on a node.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain the server and node names.")

    print("    start-server: Starts a server on a given node.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain the server and node names.")
    print("                [server-start-wait]")
    print("                    This section may contain a value to determine a wait time to start the server. If no value is provided, the default value is 10 seconds.")

    print("    stop-server: Stops a server on a given node.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain the server and node names.")
    print("                [server-stop-options]")
    print("                    This section may contain a value to determine if the server should be immediately stopped. If no value is provided, the default value is \"False\".")
    print("                    This section may contain a value to determine if the server should be terminated (killed). If no value is provided, the default value is \"False\".")

    print("    restart-server: Restarts a server on a given node.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain the server and node names.")
    print("                [server-restart-options]")
    print("                    This section may contain a value to determine the timeout for the restart operation. If no value is provided, the default value is 300 seconds.")
#enddef

##################################
# main
#################################
if (len(sys.argv) == 0):
    printHelp()
else:
    configFile = sys.argv[1]

    if (os.path.exists(configFile)) and (os.access(configFile, os.R_OK)):
        if (sys.argv[0] == "configure-all-servers"):
            configureAllServers()
        elif (sys.argv[0] == "configure-specified-server"):
            configureTargetServer()
        elif (sys.argv[0] == "server-status"):
            serverStatus()
        elif (sys.argv[0] == "start-server"):
            startServer()
        elif (sys.argv[0] == "stop-server"):
            stopServer()
        elif (sys.argv[0] == "restart-server"):
            restartServer()
        else:
            printHelp()
        #endif
    else:
        print("The provided configuration file either does not exist or cannot be read.")
    #endif
#endif
