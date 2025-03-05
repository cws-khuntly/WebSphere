#==============================================================================
#
#          FILE:  wsincludes.py
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
consoleInfoLogger = logging.getLogger(str("info-logger"))
consoleErrorLogger = logging.getLogger(str("info-logger"))

def getWebSphereVariable(variableName, nodeName = None, serverName = None, clusterName = None):
    returnValue = "None"

    debugLogger.log(logging.DEBUG, str(variableName))
    debugLogger.log(logging.DEBUG, str(nodeName))
    debugLogger.log(logging.DEBUG, str(serverName))
    debugLogger.log(logging.DEBUG, str(clusterName))
    debugLogger.log(logging.DEBUG, str(mapToReturn))

    mapList = getVariableMap(nodeName, serverName, clusterName)

    debugLogger.log(logging.DEBUG, str(mapList))

    if (mapList != None):
        entries = AdminConfig.showAttribute(map, "entries")
        entries = entries[1:-1].split(' ')

        debugLogger.log(logging.DEBUG, str(entries))
        
        for entry in (entries):
            debugLogger.log(logging.DEBUG, str(entry))

            attributeName = AdminConfig.showAttribute(entry, "symbolicName")
            attributeValue = AdminConfig.showAttribute(entry, "value")

            if (variableName == attributeName):
                returnValue = attributeValue
            #endif
        #endfor
    #endif

    return returnValue
#enddef

def configureCookies(cookieName = "JSESSIONID"):
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

                    raise Exception(str("An error occurred updating cookie configuration {0} for server {1}. Please review logs.").format(targetCookie, targetServer))
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
#enddef

def configuretargetThreadPools(startMinThreads = 0, startMaxThreads = 10, webMinThreads = 20, webMaxThreads = 50, haMinThreads = 0, haMaxThreads = 5, targetPoolNames = ("server.startup", "WebContainer", "HAManagerService.Pool")):
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

                        raise Exception(str("An error occurred updating thread pool name {0} in thread pool {1} for server {1}.").format(targetPoolName, targetThreadPool, targetServer))
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
#enddef

def configureTCPChannels(maxConnections = 50):
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

                        raise Exception(str("An error occurred updating TCP channel name {0} in TCP channel {1} for server {1}.").format(tcpChannelName, targetTCPChannel, targetServer))
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
#enddef

def configureHTTPChannels(maxConnections = 10):
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

                        raise Exception(str("An error occurred updating HTTP channel name {0} in HTTP channel {1} for server {1}.").format(httpChannelName, targetHTTPChannel, targetServer))
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
#enddef

def configureContainerChains(chainsToSkip = ("WCInboundDefault", "WCInboundDefaultSecure", "WCInboundAdminSecure")):
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

                        raise Exception(str("An error occurred updating container chain name {0} in container chain {1} for server {1}.").format(targetContainerChainName, targetContainerChain, targetServer))
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
#enddef

def configureTuningParams(writeContent = "ONLY_UPDATED_ATTRIBUTES", writeFrequency = "END_OF_SERVLET_SERVICE"):
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

                raise Exception(str("An error occurred updating tuning parameters {0} for server {1}.").format(targetTuningParams, targetContainerChain, targetServer))
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No tuning parameters were found for server {0}.").format(targetServer))

            raise Exception(str("No tuning parameters were found for server {0}.").format(targetServer))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif
#enddef

def configureSessionManager():
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

                raise Exception(str("An error occurred updating session manager {0} for server {1}.").format(targetSessionManager, targetContainerChain, targetServer))
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No session manager was found for server {0}.").format(targetServer))

            raise Exception(str("No session manager was found for server {0}.").format(targetServer))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif
#enddef

def serverStatus():
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
                    consoleInfoLogger.log(logging.INFO, str("Current server state of {0} on node {1} is: {2}.").format(serverName, nodeName, serverState))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred trying to determine the state the provided server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred trying to determine the state the provided server {0} on node {1}").format(serverName, nodeName))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
                consoleErrorLogger.loglogging.ERROR, str(("No server named {0} was found on node {1}.").format(serverName, nodeName))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            consoleErrorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif

    return serverState
#enddef

def startServer(startWaitTime = 10):
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
                    consoleInfoLogger.log(logging.INFO, str("Startup for server {0} on node {1} has been initiated.").format(serverName, nodeName))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred trying start server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred trying start server {0} on node {1}").format(serverName, nodeName))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
                consoleErrorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            consoleErrorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif
#enddef

def stopServer(immediate = False, terminate = False):
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
                    consoleInfoLogger.log(logging.INFO, str("Shutdown of server {0} on node {1} has been initiated.").format(serverName, nodeName))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred trying stop server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred trying stop server {0} on node {1}").format(serverName, nodeName))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
                consoleErrorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            consoleErrorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif
#enddef

def restartServer(restartTimeout = 300):
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
                    consoleInfoLogger.log(logging.INFO, str("Restart completed for server {0} on node {1}. Elapsed time: {2}.").format(serverName, nodeName, elapsedTimeSeconds))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred trying to restart server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred trying to restart server {0} on node {1}").format(serverName, nodeName))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
                consoleErrorLogger.log(logging.ERROR, str("No server named {0} was found on node {1}.").format(serverName, nodeName))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            consoleErrorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif
#enddef

def saveWorkspaceChanges():
    try:
        debugLogger.log(logging.DEBUG, str("Calling AdminConfig.save()"))
        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.save()"))

        AdminConfig.save()

        infoLogger.log(logging.INFO, str("Saved all pending workspace changes."))
    except:
        (exception, parms, tback) = sys.exc_info()

        errorLogger.log(logging.ERROR, str("An error occurred while saving workspace changes: {0} {1}").format(str(exception), str(parms)))

        raise Exception(str("An error occurred while saving workspace changes. Please review logs."))
    #endtry    
#enddef

def syncAllNodes(nodeList, cellName):
    debugLogger.log(logging.DEBUG, str(nodeList))
    debugLogger.log(logging.DEBUG, str(cellName))

    if (len(nodeList) != 0):
        debugLogger.log(logging.DEBUG, str("Performing nodeSync for cell {0}..").format(cellName))
        consoleInfoLogger.log(logging.INFO, str("Performing nodeSync for cell {0}..").format(cellName))

        AdminNodeManagement.syncActiveNodes()

        for node in (nodeList):
            try:
                debugLogger.log(logging.DEBUG, str(node))
                debugLogger.log(logging.DEBUG, str("Calling AdminControl.completeObjectName()"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminControl.completeObjectName(str(\"type=ConfigRepository,process=nodeagent,node={0},*\").format(node))"))

                nodeRepo = AdminControl.completeObjectName(str("type=ConfigRepository,process=nodeagent,node={0},*").format(node))

                debugLogger.log(logging.DEBUG, str(nodeRepo))

                if (nodeRepo):
                    debugLogger.log(logging.DEBUG, str("Calling AdminControl.invoke()"))
                    debugLogger.log(logging.DEBUG, str("AdminControl.invoke(nodeRepo, str(\"refreshRepositoryEpoch\"))"))

                    AdminControl.invoke(nodeRepo, str("refreshRepositoryEpoch"))

                    infoLogger.log(logging.INFO, str("Submitted refreshRepositoryEpoch."))
                #endif

                debugLogger.log(logging.DEBUG, str("Calling AdminControl.completeObjectName()"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminControl.completeObjectName(str(\"cell={0},node={1},type=NodeSync,*\").format(cellName, node))"))

                syncNode = AdminControl.completeObjectName(str("cell={0},node={1},type=NodeSync,*").format(cellName, node))

                debugLogger.log(logging.DEBUG, str(syncNode))

                if (syncNode):
                    debugLogger.log(logging.DEBUG, str("Calling AdminControl.invoke()"))
                    debugLogger.log(logging.DEBUG, str("AdminControl.invoke(syncNode, str(\"sync\"))"))

                    AdminControl.invoke(syncNode, str("sync"))

                    infoLogger.log(logging.INFO, str("Submitted sync."))
                #endif

                continue
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred performing the node synchronization operation on node {0}: {1} {2}").format(node, str(exception), str(parms)))

                raise Exception(str("An error occurred performing the node synchronization operation on node {0}. Please review logs.").format(node))
            #endtry
        #endfor
    else:
        errorLogger.log(logging.ERROR, str("No nodes were found in the cell {0}").format(cellName))

        raise Exception(str("No nodes were found in the cell {0}").format(cellName))
    #endif
#enddef
