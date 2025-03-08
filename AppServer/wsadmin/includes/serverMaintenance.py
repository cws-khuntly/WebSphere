
#==============================================================================
#
#          FILE:  serverMaintenance.py
#         USAGE:  Include file containing various wsadmin functions
#     ARGUMENTS:  N/A
#
#   DESCRIPTION:  Various useful wsadmin functions
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
import logging

errorLogger = logging.getLogger(str("error-logger"))
debugLogger = logging.getLogger(str("debug-logger"))
infoLogger = logging.getLogger(str("info-logger"))

lineSplit = java.lang.System.getProperty("line.separator")

def configureAutoRestart(targetServer, autoRestart="STOPPED"):
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
        "-Xmns1536M -Xmnx1536M -XX:MaxDirectMemorySize=256000000 -Xshareclasses:none -Dsun.reflect.inflationThreshold=0 -Djava.security.egd=file:/dev/./urandom "
        "-Dcom.sun.jndi.ldap.connect.pool.maxsize=200 -Dcom.sun.jndi.ldap.connect.pool.prefsize=200 -Dcom.sun.jndi.ldap.connect.pool.timeout=3000 "
        "-Djava.net.preferIPv4Stack=true -Dsun.net.inetaddr.ttl=600 -DdisableWSAddressCaching=true -Djava.awt.headless=true -Dcom.ibm.cacheLocalHost=true"
        "-Dcom.ibm.websphere.webservices.http.connectionKeepAlive=true -Dcom.ibm.websphere.webservices.http.maxConnection=1200 -Xnoagent "
        "-Dcom.ibm.websphere.webservices.http.connectionIdleTimeout=6000 -Dcom.ibm.websphere.webservices.http.connectionPoolCleanUpTime=6000 "
        "-Dcom.ibm.websphere.webservices.http.connectionTimeout=0 -Dlog4j2.formatMsgNoLookups=true -Xjit:iprofilerMemoryConsumptionLimit=67108864 "
        "-Dephox.config.file=/opt/ephox/application.conf -Xrunjdwp=dt_socket,server=y,suspend=n,address=7792 -Dcom.ibm.xml.xlxp.jaxb.opti.level=3")

    if ((serverName) and (nodeName)):
        AdminTask.setJVMProperties('[-serverName %s -nodeName %s -verboseModeGarbageCollection true -initialHeapSize %s -maximumHeapSize + %s -debugMode false -genericJvmArguments %s]') \
            % (serverName, nodeName, initialHeapSize, maxHeapSize)
    else:
        raise "No server was found with the provided name: " + serverName + "."
    #endif
#enddef

def configureCookies(targetServer, cookieName = "JSESSIONID"):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureCookies(targetServer, cookieName = \"JSESSIONID\")"))
    debugLogger.log(logging.DEBUG, str(targetServer))
    debugLogger.log(logging.DEBUG, str(cookieName))

    if (len(targetServer) != 0):
        debugLogger.log(logging.DEBUG, str(targetServer))

        if (len(configFile) != 0):
            serverCookieName = returnPropertyConfiguration(configFile, str("server-cookie-settings"), str("cookie-name")) or cookieName
            targetCookie = AdminConfig.list("Cookie", targetServer)

            debugLogger.log(logging.DEBUG, str(serverCookieName))
            debugLogger.log(logging.DEBUG, str(targetCookie))

            if (len(targetCookie) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetCookie, \"[[maximumAge \"-1\"] [name \"{0}\"] [domain \"\"] [secure \"true\"] [path \"/\"]]\").format(serverCookieName)"))

                    AdminConfig.modify(targetCookie, str("[[maximumAge \"-1\"] [name \"{0}\"] [domain \"\"] [secure \"true\"] [path \"/\"]]").format(serverCookieName))

                    infoLogger.log(logging.INFO, str("Completed configuration of server cookie configuration {0}.").format(targetCookie))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating cookie configuration {0} for server {1}: {2} {3}".format(targetCookie, targetServer, str(exception), str(parms))))

                    raise Exception(str("An error occurred updating cookie configuration {0} for server {1}: {2} {3}".format(targetCookie, targetServer, str(exception), str(parms))))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No cookie configuration was found for the provided server."))

                raise Exception(str("No cookie configuration was found for the provided server."))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No configuration file was provided."))

            raise Exception(str("No configuration file was provided."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureCookies(targetServer, cookieName = \"JSESSIONID\")"))
#enddef

def configuretargetThreadPools(targetServer, startMinThreads = 0, startMaxThreads = 10, webMinThreads = 20, webMaxThreads = 50, haMinThreads = 0, haMaxThreads = 5, targetPoolNames = ("server.startup", "WebContainer", "HAManagerService.Pool")):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configuretargetThreadPools(targetServer, startMinThreads = 0, startMaxThreads = 10, webMinThreads = 20, webMaxThreads = 50, haMinThreads = 0, haMaxThreads = 5, targetPoolNames = (\"server.startup\", \"WebContainer\", \"HAManagerService.Pool\""))
    debugLogger.log(logging.DEBUG, str(targetServer))
    debugLogger.log(logging.DEBUG, str(startMinThreads))
    debugLogger.log(logging.DEBUG, str(startMaxThreads))
    debugLogger.log(logging.DEBUG, str(webMinThreads))
    debugLogger.log(logging.DEBUG, str(webMaxThreads))
    debugLogger.log(logging.DEBUG, str(haMinThreads))
    debugLogger.log(logging.DEBUG, str(haMaxThreads))
    debugLogger.log(logging.DEBUG, str(targetPoolNames))

    if (len(targetServer) != 0):
        targetThreadPools = AdminConfig.list("targetThreadPool", targetServer).split(lineSplit)

        debugLogger.log(logging.DEBUG, str(targetThreadPools))

        if (len(targetThreadPools) != 0):
            for targetThreadPool in (targetThreadPools):
                debugLogger.log(logging.DEBUG, str(targetThreadPool))

                targetPoolName = targetThreadPool.split("(")[0]

                debugLogger.log(logging.DEBUG, (str(targetPoolName)))

                if (len(targetPoolName) != 0):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))

                        if (targetPoolName == "server.startup"):
                            startupMinThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("startup-min-thread-size")) or startMinThreads
                            startupMaxThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("startup-max-thread-size")) or startMaxThreads

                            debugLogger.log(logging.DEBUG, str(startupMinThreads))
                            debugLogger.log(logging.DEBUG, str(startupMaxThreads))
                            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetThreadPool, \"[[minimumSize \"20\"] [maximumSize \"10\"] [name \"{0}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]\").format(startupMinThreads, startupMaxThreads, targetPoolName)"))
                            
                            AdminConfig.modify(targetThreadPool, str("[[minimumSize \"{0}\"] [maximumSize \"{1}\"] [name \"{2}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]").format(startupMinThreads, startupMaxThreads, targetPoolName))

                            infoLogger.log(logging.INFO, str("Completed configuration of thread pool name {0} in thread pool {1}.").format(targetPoolName, targetThreadPool))
                        elif (targetPoolName == "WebContainer"):
                            webContainerMinThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("webcontainer-min-thread-size")) or webMinThreads
                            webContainerMaxThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("webcontainer-max-thread-size")) or webMaxThreads

                            debugLogger.log(logging.DEBUG, str(webContainerMinThreads))
                            debugLogger.log(logging.DEBUG, str(webContainerMaxThreads))
                            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetThreadPool, \"[[minimumSize \"20\"] [maximumSize \"10\"] [name \"{0}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]\").format(startupMinThreads, startupMaxThreads, targetPoolName)"))

                            AdminConfig.modify(targetThreadPool, str("[[minimumSize \"{0}\"] [maximumSize \"{1}\"] [name \"{2}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]").format(webContainerMinThreads, webContainerMaxThreads, targetPoolName))

                            infoLogger.log(logging.INFO, str("Completed configuration of thread pool name {0} in thread pool {1}.").format(targetPoolName, targetThreadPool))
                        elif (targetPoolName == "HAManagerService.Pool"):
                            HAManagerMinThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("hamanager-min-thread-size")) or haMinThreads
                            HAManagerMaxThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("hamanager-max-thread-size")) or haMaxThreads

                            debugLogger.log(logging.DEBUG, str(HAManagerMinThreads))
                            debugLogger.log(logging.DEBUG, str(HAManagerMaxThreads))
                            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetThreadPool, \"[[minimumSize \"20\"] [maximumSize \"10\"] [name \"{0}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]\").format(HAManagerMinThreads, HAManagerMaxThreads, targetPoolName)"))

                            AdminConfig.modify(targetThreadPool, str("[[minimumSize \"{0}\"] [maximumSize \"{1}\"] [name \"{2}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]").format(HAManagerMinThreads, HAManagerMaxThreads, targetPoolName))

                            infoLogger.log(logging.INFO, str("Completed configuration of thread pool name {0} in thread pool {1}.").format(targetPoolName, targetThreadPool))
                        #endif
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred updating thread pool name {0} in thread pool {1} for server {2}: {3} {4}".format(targetPoolName, targetThreadPool, targetServer, str(exception), str(parms))))

                        raise Exception(str("An error occurred updating thread pool name {0} in thread pool {1} for server {2}: {3} {4}".format(targetPoolName, targetThreadPool, targetServer, str(exception), str(parms))))
                    #endtry
                #endif
             #endfor
        else:
            errorLogger.log(logging.ERROR, str("No thread pools were found for server {0}.").format(targetServer))

            raise Exception(str("No thread pools were found for server {0}.").format(targetServer))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configuretargetThreadPools(targetServer, startMinThreads = 0, startMaxThreads = 10, webMinThreads = 20, webMaxThreads = 50, haMinThreads = 0, haMaxThreads = 5, targetPoolNames = (\"server.startup\", \"WebContainer\", \"HAManagerService.Pool\""))
#enddef

def configureTCPChannels(targetServer, maxConnections = 50):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureTCPChannels(targetServer, maxConnections = 50"))
    debugLogger.log(logging.DEBUG, str(targetServer))
    debugLogger.log(logging.DEBUG, str(maxConnections))

    if (len(targetServer) != 0):
        targetTCPChannels = AdminConfig.list("TCPInboundChannel", targetServer).split(lineSplit)

        debugLogger.log(logging.DEBUG, str(targetTCPChannels))

        if (len(targetTCPChannels) != 0):
            for targetTCPChannel in (targetTCPChannels):
                debugLogger.log(logging.DEBUG, str(targetTCPChannel))

                tcpChannelName = targetTCPChannel.split("(")[0]

                debugLogger.log(logging.DEBUG, (str(tcpChannelName)))

                if (len(tcpChannelName) != 0):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))

                        if (tcpChannelName == "TCP_2"):
                            tcpChannelMaxOpenConnections = returnPropertyConfiguration(configFile, str("server-tcp-channels"), str("max-open-connections")) or maxConnections

                            debugLogger.log(logging.DEBUG, str(tcpChannelMaxOpenConnections))
                            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(tcpChannelName, str(\"[[maxOpenConnections \"{0}\"]]\").format(tcpChannelMaxOpenConnections)"))
                            
                            AdminConfig.modify(tcpChannelName, str("[[maxOpenConnections \"{0}\"]]").format(tcpChannelMaxOpenConnections))

                            infoLogger.log(logging.INFO, str("Completed configuration of TCP channel {0} in TCP channels {1}.").format(tcpChannelName, targetTCPChannel))
                        #endif
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred updating TCP channel name {0} in TCP channel {1} for server {2}: {3} {4}".format(tcpChannelName, targetTCPChannel, targetServer, str(exception), str(parms))))

                        raise Exception(str("An error occurred updating TCP channel name {0} in TCP channel {1} for server {2}: {3} {4}".format(tcpChannelName, targetTCPChannel, targetServer, str(exception), str(parms))))
                    #endtry
                #endif
             #endfor
        else:
            errorLogger.log(logging.ERROR, str("No TCP channels were found for server {0}.").format(targetServer))

            raise Exception(str("No TCP channels were found for server {0}.").format(targetServer))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureTCPChannels(targetServer, maxConnections = 50"))
#enddef

def configureHTTPChannels(targetServer, maxConnections = 10):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureHTTPChannels(targetServer, maxConnections = 10"))
    debugLogger.log(logging.DEBUG, str(targetServer))
    debugLogger.log(logging.DEBUG, str(maxConnections))

    if (len(targetServer) != 0):
        targetHTTPChannels = AdminConfig.list("HTTPInboundChannel", targetServer).split(lineSplit)

        debugLogger.log(logging.DEBUG, str(targetHTTPChannels))

        if (len(targetHTTPChannels) != 0):
            for targetHTTPChannel in (targetHTTPChannels):
                debugLogger.log(logging.DEBUG, str(targetHTTPChannel))

                httpChannelName = targetHTTPChannel.split("(")[0]

                debugLogger.log(logging.DEBUG, (str(httpChannelName)))

                if (len(httpChannelName) != 0):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))

                        if (httpChannelName == "HTTP_2"):
                            httpChannelMaxOpenConnections = returnPropertyConfiguration(configFile, str("server-http-channels"), str("max-open-connections")) or maxConnections

                            debugLogger.log(logging.DEBUG, str("httpChannelMaxOpenConnections"))
                            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(httpChannel, str(\"[[maximumPersistentRequests \"-1\"] [persistentTimeout \"300\"] [enableLogging \"true\"]]\"))"))

                            AdminConfig.modify(targetHTTPChannel, str("[[maximumPersistentRequests \"-1\"] [persistentTimeout \"300\"] [enableLogging \"true\"]]"))

                            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.create()"))
                            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.create(\"Property\", httpChannel, str(\"[[validationExpression \"\"] [name \"RemoveServerHeader\"] [description \"\"] [value \"true\"] [required \"false\"]]\"))"))

                            AdminConfig.create("Property", targetHTTPChannel, str("[[validationExpression \"\"] [name \"RemoveServerHeader\"] [description \"\"] [value \"true\"] [required \"false\"]]"))

                            infoLogger.log(logging.INFO, str("Completed configuration of HTTP channel {0} in HTTP channels {1}.").format(httpChannelName, targetHTTPChannels))
                        #endif
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred updating HTTP channel name {0} in HTTP channel {1} for server {2}: {3} {4}".format(httpChannelName, targetHTTPChannel, targetServer, str(exception), str(parms))))

                        raise Exception(str("An error occurred updating HTTP channel name {0} in HTTP channel {1} for server {2}: {3} {4}".format(httpChannelName, targetHTTPChannel, targetServer, str(exception), str(parms))))
                    #endtry
                #endif
             #endfor
        else:
            errorLogger.log(logging.ERROR, str("No HTTP channels were found for server {0}.").format(targetServer))

            raise Exception(str("No HTTP channels were found for server {0}.").format(targetServer))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureHTTPChannels(targetServer, maxConnections = 10"))
#enddef

def configureContainerChains(targetServer, chainsToSkip = ("WCInboundDefault", "WCInboundDefaultSecure", "WCInboundAdminSecure")):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureContainerChains(targetServer, chainsToSkip = (\"WCInboundDefault\", \"WCInboundDefaultSecure\", \"WCInboundAdminSecure\""))
    debugLogger.log(logging.DEBUG, str(chainsToSkip))

    if (len(targetServer) != 0):
        targetTransport = AdminConfig.list("TransportChannelService", targetServer)

        debugLogger.log(logging.DEBUG, str(targetTransport))

        if (len(targetTransport) != 0):
            targetChainsToSkip = returnPropertyConfiguration(configFile, str("server-container-chains"), str("skip-chains")) or chainsToSkip
            targetContainerChains = AdminTask.listChains(targetTransport, str("[-acceptorFilter WebContainerInboundChannel]")).split(lineSplit)

            debugLogger.log(logging.DEBUG, str(targetChainsToSkip))
            debugLogger.log(logging.DEBUG, str(targetContainerChains))

            for targetContainerChain in (targetContainerChains):
                debugLogger.log(logging.DEBUG, str(targetContainerChain))

                targetContainerChainName = targetContainerChain.split("(")[0]

                debugLogger.log(logging.DEBUG, (str(targetContainerChainName)))

                if (len(targetContainerChainName) != 0):
                    try:
                        if (targetContainerChainName in chainsToSkip):
                            debugLogger.log(logging.DEBUG, str("targetContainerChainName {0} found in chainsToSkip").format(targetContainerChainName))

                            continue
                        else:    
                            debugLogger.log(logging.DEBUG, str("Calling AdminTask.deleteChain()"))
                            debugLogger.log(logging.DEBUG, str("EXEC: AdminTask.deleteChain(chain, str(\"[-deleteChannels \"true\"]\"))"))

                            AdminTask.deleteChain(targetContainerChain, str("[-deleteChannels \"true\"]"))

                            infoLogger.log(logging.INFO, str("Completed configuration of container chain {0} in container chain {1}.").format(targetContainerChainName, targetContainerChain))
                        #endif
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred updating container chain name {0} in container chain {1} for server {2}: {3} {4}".format(targetContainerChainName, targetContainerChain, targetServer, str(exception), str(parms))))

                        raise Exception(str("An error occurred updating container chain name {0} in container chain {1} for server {2}: {3} {4}".format(targetContainerChainName, targetContainerChain, targetServer, str(exception), str(parms))))
                    #endtry
             #endfor
        else:
            errorLogger.log(logging.ERROR, str("No container chains were found for server {0}.").format(targetServer))

            raise Exception(str("No container chains were found for server {0}.").format(targetServer))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureContainerChains(targetServer, chainsToSkip = (\"WCInboundDefault\", \"WCInboundDefaultSecure\", \"WCInboundAdminSecure\""))
#enddef

def configureTuningParams(targetServer, writeContent = "ONLY_UPDATED_ATTRIBUTES", writeFrequency = "END_OF_SERVLET_SERVICE"):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureTuningParams(targetServer, writeContent = \"ONLY_UPDATED_ATTRIBUTES\", writeFrequency = \"END_OF_SERVLET_SERVICE\""))
    debugLogger.log(logging.DEBUG, str(targetServer))
    debugLogger.log(logging.DEBUG, str(writeContent))
    debugLogger.log(logging.DEBUG, str(writeFrequency))

    if (len(targetServer) != 0):
        targetWriteContents = returnPropertyConfiguration(configFile, str("server-tuning-params"), str("write-content")) or writeContent
        targetWriteFrequency = returnPropertyConfiguration(configFile, str("server-tuning-params"), str("write-frequency")) or writeFrequency
        targetTuningParams = AdminConfig.list("TuningParams", targetServer)

        debugLogger.log(logging.DEBUG, str(targetTuningParams))

        if (len(targetTuningParams) != 0):
            try:
                debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetTuning, str(\"[[writeContents \"{0}\"] [writeFrequency \"{1}\"] [scheduleInvalidation \"false\"] [invalidationTimeout \"60\"]]\").format(targetWriteContents, targetWriteFrequency))"))
        
                AdminConfig.modify(targetTuning, str("[[writeContents \"{0}\"] [writeFrequency \"{1}\"] [scheduleInvalidation \"false\"] [invalidationTimeout \"60\"]]").format(targetWriteContents, targetWriteFrequency))

                infoLogger.log(logging.INFO, str("Completed configuration of tuning parameters {0} on server {1}.").format(targetTuningParams, targetServer))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred updating tuning parameters {0} for server {1}: {2} {3}".format(targetTuningParams, targetServer, str(exception), str(parms))))

                raise Exception(str("An error occurred updating tuning parameters {0} for server {1}: {2} {3}".format(targetTuningParams, targetServer, str(exception), str(parms))))
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No tuning parameters were found for server {0}.").format(targetServer))

            raise Exception(str("No tuning parameters were found for server {0}.").format(targetServer))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureTuningParams(targetServer, writeContent = \"ONLY_UPDATED_ATTRIBUTES\", writeFrequency = \"END_OF_SERVLET_SERVICE\""))
#enddef

def configureSessionManager(targetServer):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureSessionManager(targetServer)"))
    debugLogger.log(logging.DEBUG, str(targetServer))

    if (len(targetServer) != 0):
        targetSessionManager = AdminConfig.list("SessionManager", targetServer)

        debugLogger.log(logging.DEBUG, str(targetSessionManager))

        if (len(targetSessionManager) != 0):
            try:
                debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetSessionManager, str(\"[[enableSecurityIntegration \"true\"] [maxWaitTime \"5\"] [allowSerializedSesssionAccess \"false\"] [enableUrlRewriting \"false\"] [enable \"true\"] [accessSessionOnTimeout \"true\"] [enableSSLTracking \"true\"] [enableCookies \"true\"]]\"))"))
        
                AdminConfig.modify(targetSessionManager, str("[[enableSecurityIntegration \"true\"] [maxWaitTime \"5\"] [allowSerializedSesssionAccess \"false\"] [enableUrlRewriting \"false\"] [enable \"true\"] [accessSessionOnTimeout \"true\"] [enableSSLTracking \"true\"] [enableCookies \"true\"]]"))

                infoLogger.log(logging.INFO, str("Completed configuration of session manager {0} on server {1}.").format(targetSessionManager, targetServer))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred updating session manager {0} for server {1}: {2} {3}".format(targetSessionManager, targetServer, str(exception), str(parms))))

                raise Exception(str("An error occurred updating session manager {0} for server {1}: {2} {3}".format(targetSessionManager, targetServer, str(exception), str(parms))))
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No session manager was found for server {0}.").format(targetServer))

            raise Exception(str("No session manager was found for server {0}.").format(targetServer))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureSessionManager(targetServer)"))
#enddef

def serverStatus():
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#serverStatus()"))
    serverState = "UNKNOWN"

    debugLogger.log(logging.DEBUG, str(serverState))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, str(targetServer))

            if (len(targetServer) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminControl.getAttribute()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: AdminControl.getAttribute(targetServer, \"state\")"))

                    serverState = AdminControl.getAttribute(targetServer, str("state"))

                    debugLogger.debug(logging.DEBUG, serverState)
                    infoLogger.log(logging.INFO, str("Current server state of {0} on node {1} is: {2}.").format(serverName, nodeName, serverState))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred trying to determine the state the provided server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                    raise Exception(str("An error occurred trying to determine the state the provided server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
                raise Exception(str(("No server named {0} was found on node {1}.").format(serverName, nodeName)))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            raise Exception(str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        raise Exception(str("No configuration file was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#serverStatus()"))

    return serverState
#enddef

def startServer(startWaitTime = 10):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#startServer(startWaitTime = 10)"))
    debugLogger.log(logging.DEBUG, str(startWaitTime))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            startupWaitTime = returnPropertyConfiguration(configFile, str("server-start-options"), str("start-wait-time")) or startWaitTime
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, str(startupWaitTime))
            debugLogger.log(logging.DEBUG, str(targetServer))

            if (len(targetServer) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminControl.getAttribute()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: AdminControl.startServer(nodeName, serverName, startupWaitTime)"))

                    AdminControl.startServer(nodeName, serverName, startupWaitTime)

                    infoLogger.log(logging.INFO, str("Startup for server {0} on node {1} has been initiated.").format(serverName, nodeName))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred trying start server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                    raise Exception(str("An error occurred trying start server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
                raise Exception(str("No server named {0} was found on node {1}.").format(serverName, nodeName))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            raise Exception(str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        raise Exception(str("No configuration file was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#startServer(startWaitTime = 10)"))
#enddef

def stopServer(immediate = False, terminate = False):
    debugLogger.log(logging.DEBUG, str("ENTER: stopServer(immediate = False, terminate = False):"))
    debugLogger.debug(logging.DEBUG, str(immediate))
    debugLogger.debug(logging.DEBUG, str(terminate))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            isImmediateStop = returnPropertyConfiguration(configFile, str("server-stop-options"), str("immediate-stop")) or immediate
            isTerminateStop = returnPropertyConfiguration(configFile, str("server-stop-options"), str("terminate-stop")) or terminate
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, str(isImmediateStop))
            debugLogger.log(logging.DEBUG, str(isTerminateStop))
            debugLogger.log(logging.DEBUG, str(targetServer))

            if (len(targetServer) != 0):
                debugLogger.log(logging.DEBUG, str("Calling AdminControl.stopServer()"))

                try:
                    if (isImmediateStop):
                        debugLogger.debug(logging.DEBUG, str("EXEC: AdminControl.stopServer(nodeName, serverName, str(\"immediate\"))"))

                        AdminControl.stopServer(nodeName, serverName, str("immediate"))
                    elif (isTerminateStop):
                        debugLogger.debug(logging.DEBUG, str("EXEC: AdminControl.stopServer(nodeName, serverName, str(\"terminate\"))"))

                        AdminControl.stopServer(nodeName, serverName, str("terminate"))
                    else:
                        debugLogger.debug(logging.DEBUG, str("EXEC: AdminControl.stopServer(nodeName, serverName)"))

                        AdminControl.stopServer(nodeName, serverName)
                    #endif

                    infoLogger.log(logging.INFO, str("Shutdown of server {0} on node {1} has been initiated.").format(serverName, nodeName))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred trying stop server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                    raise Exception(str("An error occurred trying stop server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
                raise Exception(str("No server named {0} was found on node {1}.").format(serverName, nodeName))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            raise Exception(str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        raise Exception(str("No configuration file was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: stopServer(immediate = False, terminate = False):"))
#enddef

def restartServer(restartTimeout = 300):
    debugLogger.log(logging.DEBUG, str("ENTER: restartServer(restartTimeout = 300)"))
    isRunning = "UNKNOWN"

    debugLogger.debug(logging.DEBUG, str(restartTimeout))
    debugLogger.debug(logging.DEBUG, str(isRunning))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            restartTimeoutSecs = returnPropertyConfiguration(configFile, str("server-restart-options"), str("restart-timeout")) or restartTimeout
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, str(restartTimeoutSecs))
            debugLogger.log(logging.DEBUG, str(targetServer))

            if (len(targetServer) != 0):
                debugLogger.log(logging.DEBUG, str("Calling AdminControl.invoke()"))

                try:
                    AdminControl.invoke(targetServer, str("restart"))

                    elapsedTime = 0

                    debugLogger.log(elapsedTime)

                    if (restartTimeoutSecs > 0):
                        sleepTime = 5
                        isRunning = serverStatus(nodeName, serverName)

                        debugLogger.log(logging.DEBUG, str(sleepTime))
                        debugLogger.log(logging.DEBUG, str(isRunning))

                        while ((isRunning) and (elapsedTimeSeconds < restartTimeout)):
                            debugLogger.log(logging.DEBUG, str("Waiting for restart. Sleeping for {0}..").format(sleepTime))

                            time.sleep(sleepTime)

                            elapsedTimeSeconds = elapsedTimeSeconds + sleepTime
                            isRunning = serverStatus(nodeName, serverName)

                            debugLogger.log(logging.DEBUG, str(elapsedTimeSeconds))
                            debugLogger.log(logging.DEBUG, str(isRunning))
                        #endwhile

                        while ((not isRunning) and (elapsedTimeSeconds < restartTimeoutSecs)):
                            debugLogger.log(logging.DEBUG, str("Waiting for restart. Sleeping for %d..").format(sleepTime))
                            infoLogger.log(logging.INFO, str("Waiting {0} of {1} seconds for {2} to restart. isRunning = {3}").format(elapsedTimeSeconds, restartTimeoutSecs, serverName, isRunning))
                            consoleInfoLogger.log(logging.INFO, str("Waiting {0} of {1} seconds for {2} to restart. isRunning = {3}").format(elapsedTimeSeconds, restartTimeoutSecs, serverName, isRunning))

                            time.sleep(sleepTime)

                            elapsedTimeSeconds = elapsedTimeSeconds + sleepTime
                            isRunning = serverStatus(nodeName, serverName)

                            debugLogger.log(logging.DEBUG, str(elapsedTimeSeconds))
                            debugLogger.log(logging.DEBUG, str(isRunning))
                        #endwhile
                    #endif

                    isRunning = serverStatus(nodeName, serverName)

                    debugLogger.log(logging.DEBUG, str(isRunning))
                    infoLogger.log(logging.INFO, str("Restart completed for server {0} on node {1}. Elapsed time: {2}.").format(serverName, nodeName, elapsedTimeSeconds))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred trying to restart server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                    raise Exception(str("An error occurred trying to restart server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
                raise Exception(str("No server named {0} was found on node {1}.").format(serverName, nodeName))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            raise Exception(str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        raise Exception(str("No configuration file was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: restartServer(restartTimeout = 300)"))
#enddef
