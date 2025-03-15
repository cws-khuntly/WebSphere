#==============================================================================
#
#          FILE:  serverManagement.py
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
import time
import logging

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")

lineSplit = java.lang.System.getProperty("line.separator")

def createApplicationServer(targetNode, targetServer):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#createApplicationServer(targetNode, targetServer)")
    debugLogger.log(logging.DEBUG, targetNode)
    debugLogger.log(logging.DEBUG, targetServer)

    if ((len(targetNode) != 0) and (len(targetServer) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.createApplicationServer()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminTask.createApplicationServer(str(\"{0}\", \"[-name {1} -templateName default -genUniquePorts true]\").format(targetNode, targetServer))")

            AdminTask.createApplicationServer(str("{0}", "[-name {1} -templateName default -genUniquePorts true]").format(targetNode, targetServer))

            infoLogger.log(logging.INFO, str("Successfully created new application server {0} in node {1}.").format(targetServer, targetNode))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("Failed to create server {0} in node {1}: {2} {3}").format(targetServer, targetNode, str(exception), str(parms)))

            raise Exception(str("Failed to create server {0} in node {1}: {2} {3}").format(targetServer, targetNode, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No node/server information was provided.")

        raise Exception("No node/server information was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#createApplicationServer(targetNode, targetServer)")
#enddef

def configureAutoRestart(targetMonitorPolicy, policyOption):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureAutoRestart(targetMonitorPolicy, policyOption)")
    debugLogger.log(logging.DEBUG, targetMonitorPolicy)
    debugLogger.log(logging.DEBUG, policyOption)

    if ((len(targetMonitorPolicy) != 0) and (len(policyOption) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(monitorPolicy, str(\"[[maximumStartupAttempts \"3\"] [pingTimeout \"300\"] [pingInterval \"60\"] [autoRestart \"true\"] [nodeRestartState \"{0}\"]]\").format(policyOption))")

            AdminConfig.modify(targetMonitorPolicy, str("[[maximumStartupAttempts \"3\"] [pingTimeout \"300\"] [pingInterval \"60\"] [autoRestart \"true\"] [nodeRestartState \"{0}\"]]").format(policyOption))

            infoLogger.log(logging.INFO, str("Completed configuration of monitoring policy {0}. New startup state: {1}").format(targetMonitorPolicy, policyOption))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating monitoring policy {0} with option {1}: {2} {3}").format(targetMonitorPolicy, policyOption, str(exception), str(parms)))

            raise Exception(str("An error occurred updating monitoring policy {0} with option {1}: {2} {3}").format(targetMonitorPolicy, policyOption, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No monitor policy was provided or no policy option was provided.")

        raise Exception("No monitor policy was provided or no policy option was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureAutoRestart(monitorPolicy, policyOption)")
#enddef

def configureWebContainer(targetWebContainer, vhostName, cookieName, servletCachingEnabled, isPortalServer, portletCachingEnabled):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureWebContainer(targetWebContainer, vhostName, cookieName, servletCachingEnabled, isPortalServer, portletCachingEnabled)")
    debugLogger.log(logging.DEBUG, targetWebContainer)
    debugLogger.log(logging.DEBUG, vhostName)
    debugLogger.log(logging.DEBUG, cookieName)
    debugLogger.log(logging.DEBUG, servletCachingEnabled)
    debugLogger.log(logging.DEBUG, isPortalServer)
    debugLogger.log(logging.DEBUG, portletCachingEnabled)

    if (len(targetWebContainer) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"Property\", targetWebContainer, \"[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.extractHostHeaderPort\"] [description \"\"] [value \"true\"] [required \"false\"]]\")")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"Property\", targetWebContainer, \"[[validationExpression \"\"] [name \"trusthostheaderport\"] [description \"\"] [value \"true\"] [required \"false\"]]\")")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"Property\", targetWebContainer, \"[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.invokefilterscompatibility\"] [description \"\"] [value \"true\"] [required \"false\"]]\")")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"Property\", targetWebContainer, str(\"[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.httpOnlyCookies\"] [description \"\"] [value \"{0}}\"] [required \"false\"]]\").format(cookieName))")

            AdminConfig.create("Property", targetWebContainer, "[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.extractHostHeaderPort\"] [description \"\"] [value \"true\"] [required \"false\"]]")
            AdminConfig.create("Property", targetWebContainer, "[[validationExpression \"\"] [name \"trusthostheaderport\"] [description \"\"] [value \"true\"] [required \"false\"]]")
            AdminConfig.create("Property", targetWebContainer, "[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.invokefilterscompatibility\"] [description \"\"] [value \"true\"] [required \"false\"]]")
            AdminConfig.create("Property", targetWebContainer, str("[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.httpOnlyCookies\"] [description \"\"], [value \"{0}\"] [required \"false\"]]").format(cookieName))

            debugLogger.log(logging.DEBUG, "Calling AdminTask.setAdminActiveSecuritySettings()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminTask.setAdminActiveSecuritySettings(\"[-customProperties[\"com.ibm.ws.security.addHttpOnlyAttributeToCookies=true\"]]\")")

            AdminTask.setAdminActiveSecuritySettings("[-customProperties [\"com.ibm.ws.security.addHttpOnlyAttributeToCookies=true\"]]")

            infoLogger.log(logging.INFO, str("Completed adding web container properties in web container {0}.").format(targetWebContainer))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating web container configuration {0}: {1} {2}").format(targetWebContainer, str(exception), str(parms)))

            raise Exception(str("An error occurred updating web container configuration {0}: {1} {2}").format(targetWebContainer, str(exception), str(parms)))
        #endtry

        if (len(vhostName) != 0):
            try:
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetWebContainer, str(\"[[defaultVirtualHostName {0}]]\").format(setVirtualHost))")

                AdminConfig.modify(targetWebContainer, str("[[defaultVirtualHostName {0}]]").format(vhostName))

                infoLogger.log(logging.INFO, str("Completed setting default virtual host for web container {0} with default host {1}").format(targetWebContainer, vhostName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred updating web container {0} with default host {1}: {2} {3}").format(targetWebContainer, vhostName, str(exception), str(parms)))

                raise Exception(str("An error occurred updating web container {0} with default host {1}: {2} {3}").format(targetWebContainer, vhostName, str(exception), str(parms)))
            #endtry
        #endif

        if (len(servletCachingEnabled) != 0):
            try:
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetWebContainer, str(\"[[enableServletCaching \"{0}\"]]\").format(servletCachingEnabled))")

                AdminConfig.modify(targetWebContainer, str("[[enableServletCaching \"{0}\"]]").format(servletCachingEnabled))

                infoLogger.log(logging.INFO, str("Completed servlet caching configuration web container {0}. New caching state: {1}").format(targetWebContainer, servletCachingEnabled))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred modifying the servlet caching state for web container {0} with value {1}: {2} {3}").format(targetWebContainer, servletCachingEnabled, str(exception), str(parms)))

                raise Exception(str("An error occurred modifying the servlet caching state for web container {0} with value {1}: {2} {3}").format(targetWebContainer, servletCachingEnabled, str(exception), str(parms)))
            #endtry
        #endif

        if ((len(isPortalServer) != 0) and (isPortalServer == "true") and (len(portletCachingEnabled) != 0)):
            try:
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetWebContainer, str(\"[[enablePortletCaching \"{0}\"]]\").format(portletCachingEnabled))")

                AdminConfig.modify(targetWebContainer, str("[[enablePortletCaching \"{0}\"]]").format(portletCachingEnabled))

                infoLogger.log(logging.INFO, str("Completed portlet caching configuration web container {0}. New caching state: {1}").format(targetWebContainer, portletCachingEnabled))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred modifying the portlet caching state for web container {0} with value {1}: {2} {3}").format(targetWebContainer, portletCachingEnabled, str(exception), str(parms)))

                raise Exception(str("An error occurred modifying the portlet caching state for web container {0} with value {1}: {2} {3}").format(targetWebContainer, portletCachingEnabled, str(exception), str(parms)))
            #endtry
        #endif
    else:
        errorLogger.log(logging.ERROR, "No web container was provided to configure.")

        raise Exception("No web container was provided to configure.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureWebContainer(targetWebContainer, vhostName, cookieName, servletCachingEnabled, isPortalServer, portletCachingEnabled)")
#enddef

def configureHAManager(targetHAManager, enableHA):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureHAManager(targetHAManager, enableHA)")
    debugLogger.log(logging.DEBUG, targetHAManager)
    debugLogger.log(logging.DEBUG, enableHA)

    if ((len(targetHAManager) != 0) and (len(enableHA) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(haManager, str(\"[[enable \"{0}\"] [activateEnabled \"{0}\"] [isAlivePeriodSec \"120\"] [transportBufferSize \"10\"]]\").format(isEnabled))")

            AdminConfig.modify(targetHAManager, str("[[enable \"{0}\"] [activateEnabled \"{0}\"] [isAlivePeriodSec \"120\"] [transportBufferSize \"10\"]]").format(enableHA))

            infoLogger.log(logging.INFO, str("Completed HA Manager configuration {1}. New HAManager state: {1}").format(targetHAManager, enableHA))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred modifying the HA Manager service {0} to value {1}: {2} {3}").format(targetHAManager, enableHA, str(exception), str(parms)))

            raise Exception(str("An error occurred modifying the HA Manager service {0} to value {1}: {2} {3}").format(targetHAManager, enableHA, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No HA Manager service was provided or no HA Manager state was provided.")

        raise Exception("No HA Manager service was provided or no HA Manager state was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureHAManager(targetHAManager, enableHA)")
#enddef

def configureCookies(targetCookie, cookieName, cookiePath):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureCookies(targetCookie, cookieName, cookiePath)")
    debugLogger.log(logging.DEBUG, targetCookie)
    debugLogger.log(logging.DEBUG, cookieName)
    debugLogger.log(logging.DEBUG, cookiePath)

    if ((len(targetCookie) != 0) and (len(cookieName) != 0) and (len(cookiePath) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetCookie, str(\"[[maximumAge \"-1\"] [name \"{0}\"] [domain \"\"] [secure \"true\"] [path \"{1}\"]]\").format(cookieName, cookiePath))")

            AdminConfig.modify(targetCookie, str("[[maximumAge \"-1\"] [name \"{0}\"] [domain \"\"] [secure \"true\"] [path \"{1}\"]]").format(cookieName, cookiePath))

            infoLogger.log(logging.INFO, str("Completed configuration of server cookie configuration {0} with values {1} {2}.").format(targetCookie, cookieName, cookiePath))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating cookie configuration {0} with values {1} {2}: {3} {4}").format(targetCookie, cookieName, cookiePath, str(exception), str(parms)))

            raise Exception(str("An error occurred updating cookie configuration {0} with values {1} {2}: {3} {4}").format(targetCookie, cookieName, cookiePath, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No cookie configuration was provided or no cookie name/cookie path was provided.")

        raise Exception("No cookie configuration was provided or no cookie name/cookie path was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureCookies(targetCookie, cookieName, cookiePath)")
#enddef

def configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, targetPoolNames):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, targetPoolNames)")
    debugLogger.log(logging.DEBUG, targetThreadPools)
    debugLogger.log(logging.DEBUG, startMinThreads)
    debugLogger.log(logging.DEBUG, startMaxThreads)
    debugLogger.log(logging.DEBUG, webMinThreads)
    debugLogger.log(logging.DEBUG, webMaxThreads)
    debugLogger.log(logging.DEBUG, haMinThreads)
    debugLogger.log(logging.DEBUG, haMaxThreads)
    debugLogger.log(logging.DEBUG, targetPoolNames)

    if (len(targetThreadPools) != 0):
        for targetThreadPool in (targetThreadPools):
            debugLogger.log(logging.DEBUG, targetThreadPool)

            targetPoolName = targetThreadPool.split("(")[0]

            debugLogger.log(logging.DEBUG, targetPoolName)

            if (len(targetPoolName) != 0):
                try:
                    debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")

                    if ((targetPoolName == "server.startup") and (len(startMinThreads) != 0) and (len(startMaxThreads) != 0)):
                        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetThreadPool, str(\"[[minimumSize \"20\"] [maximumSize \"10\"] [name \"{0}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]\").format(startMinThreads, startMaxThreads, targetPoolName))")
                        
                        AdminConfig.modify(targetThreadPool, str("[[minimumSize \"{0}\"] [maximumSize \"{1}\"] [name \"{2}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]").format(startMinThreads, startMaxThreads, targetPoolName))

                        infoLogger.log(logging.INFO, str("Completed configuration of thread pool name {0} in thread pool {1}.").format(targetPoolName, targetThreadPool))
                    elif ((targetPoolName == "WebContainer") and (len(webMinThreads) != 0) and (len(webMaxThreads) != 0)):
                        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetThreadPool, str(\"[[minimumSize \"20\"] [maximumSize \"10\"] [name \"{0}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]\").format(startupMinThreads, startupMaxThreads, targetPoolName))")

                        AdminConfig.modify(targetThreadPool, str("[[minimumSize \"{0}\"] [maximumSize \"{1}\"] [name \"{2}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]").format(webMinThreads, webMaxThreads, targetPoolName))

                        infoLogger.log(logging.INFO, str("Completed configuration of thread pool name {0} in thread pool {1}.").format(targetPoolName, targetThreadPool))
                    elif ((targetPoolName == "HAManagerService.Pool") and (len(haMinThreads) != 0) and (len(haMaxThreads) != 0)):
                        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetThreadPool, str(\"[[minimumSize \"20\"] [maximumSize \"10\"] [name \"{0}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]\").format(HAManagerMinThreads, HAManagerMaxThreads, targetPoolName))")

                        AdminConfig.modify(targetThreadPool, str("[[minimumSize \"{0}\"] [maximumSize \"{1}\"] [name \"{2}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]").format(haMinThreads, haMaxThreads, targetPoolName))

                        infoLogger.log(logging.INFO, str("Completed configuration of thread pool name {0} in thread pool {1}.").format(targetPoolName, targetThreadPool))
                    #endif
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating thread pool name {0} in thread pool {1}: {2} {3}").format(targetPoolName, targetThreadPool, str(exception), str(parms)))

                    raise Exception(str("An error occurred updating thread pool name {0} in thread pool {1}: {2} {3}").format(targetPoolName, targetThreadPool, str(exception), str(parms)))
                #endtry
            #endif
        #endfor
    else:
        errorLogger.log(logging.ERROR, "No thread pools were provided to configure.")

        raise Exception("No thread pools were provided to configure.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, targetPoolNames)")
#enddef

def configureTCPChannels(targetTCPChannels, maxConnections):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureTCPChannels(targetTCPChannels, maxConnections)")
    debugLogger.log(logging.DEBUG, targetTCPChannels)
    debugLogger.log(logging.DEBUG, maxConnections)

    if ((len(targetTCPChannels) != 0) and (len(maxConnections) != 0)):
        for targetTCPChannel in (targetTCPChannels):
            debugLogger.log(logging.DEBUG, targetTCPChannel)

            tcpChannelName = targetTCPChannel.split("(")[0]

            debugLogger.log(logging.DEBUG, tcpChannelName)

            if (len(tcpChannelName) != 0):
                try:
                    debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")

                    if (tcpChannelName == "TCP_2"):
                        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(tcpChannelName, str(\"[[maxOpenConnections \"{0}\"]]\").format(maxConnections)"))
                        
                        AdminConfig.modify(tcpChannelName, str("[[maxOpenConnections \"{0}\"]]").format(maxConnections))

                        infoLogger.log(logging.INFO, str("Completed configuration of TCP channel {0} in TCP channels {1}.").format(tcpChannelName, targetTCPChannel))
                    #endif
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating TCP channel name {0} in TCP channel {1}: {2} {3}").format(tcpChannelName, targetTCPChannel, str(exception), str(parms)))

                    raise Exception(str("An error occurred updating TCP channel name {0} in TCP channel {1}: {2} {3}").format(tcpChannelName, targetTCPChannel, str(exception), str(parms)))
                #endtry
            #endif
        #endfor
    else:
        errorLogger.log(logging.ERROR, "No TCP channels were provided or no max connections were provided.")

        raise Exception("No TCP channels were provided or no max connections were provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureTCPChannels(targetTCPChannels, maxConnections)")
#enddef

# TODO
def configureHTTPChannels(targetHTTPChannels, maxConnections):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureHTTPChannels(targetHTTPChannels, maxConnections)")
    debugLogger.log(logging.DEBUG, targetHTTPChannels)
    debugLogger.log(logging.DEBUG, maxConnections)

    if (len(targetHTTPChannels) != 0):
        for targetHTTPChannel in (targetHTTPChannels):
            debugLogger.log(logging.DEBUG, targetHTTPChannel)

            httpChannelName = targetHTTPChannel.split("(")[0]

            debugLogger.log(logging.DEBUG, httpChannelName)

            if (len(httpChannelName) != 0):
                try:
                    debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")

                    if (httpChannelName == "HTTP_2"):
                        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(httpChannel, \"[[maximumPersistentRequests \"-1\"] [persistentTimeout \"300\"] [enableLogging \"true\"]]\")")

                        AdminConfig.modify(targetHTTPChannel, "[[maximumPersistentRequests \"-1\"] [persistentTimeout \"300\"] [enableLogging \"true\"]]")

                        debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
                        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"Property\", httpChannel, \"[[validationExpression \"\"] [name \"RemoveServerHeader\"] [description \"\"] [value \"true\"] [required \"false\"]]\")")

                        AdminConfig.create("Property", targetHTTPChannel, "[[validationExpression \"\"] [name \"RemoveServerHeader\"] [description \"\"] [value \"true\"] [required \"false\"]]")

                        infoLogger.log(logging.INFO, str("Completed configuration of HTTP channel {0} in HTTP channels {1}.").format(httpChannelName, targetHTTPChannels))
                    #endif
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating HTTP channel name {0} in HTTP channel {1}: {2} {3}").format(httpChannelName, targetHTTPChannel, str(exception), str(parms)))

                    raise Exception(str("An error occurred updating HTTP channel name {0} in HTTP channel {1}: {2} {3}").format(httpChannelName, targetHTTPChannel, str(exception), str(parms)))
                #endtry
            #endif
        #endfor
    else:
        errorLogger.log(logging.ERROR, "No HTTP channels were provided to configure.")

        raise Exception("No HTTP channels were provided to configure.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureHTTPChannels(targetServer, maxConnections = 50")
#enddef

def configureContainerChains(targetContainerChains, chainsToSkip):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureContainerChains(targetContainerChains, chainsToSkip)")
    debugLogger.log(logging.DEBUG, targetContainerChains)
    debugLogger.log(logging.DEBUG, chainsToSkip)

    if (len(targetContainerChains) != 0):
        for targetContainerChain in (targetContainerChains):
            debugLogger.log(logging.DEBUG, targetContainerChain)

            targetContainerChainName = targetContainerChain.split("(")[0]

            debugLogger.log(logging.DEBUG, targetContainerChainName)

            if (len(targetContainerChainName) != 0):
                try:
                    if (targetContainerChainName in chainsToSkip):
                        debugLogger.log(logging.DEBUG, "targetContainerChainName {0} found in chainsToSkip").format(targetContainerChainName)

                        continue
                    else:    
                        debugLogger.log(logging.DEBUG, "Calling AdminTask.deleteChain()")
                        debugLogger.log(logging.DEBUG, "EXEC: AdminTask.deleteChain(chain, str(\"[-deleteChannels \"true\"]\"))")

                        AdminTask.deleteChain(targetContainerChain, "[-deleteChannels \"true\"]")

                        infoLogger.log(logging.INFO, str("Completed configuration of container chain {0} in container chain {1}.").format(targetContainerChainName, targetContainerChain))
                    #endif
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating container chain name {0} in container chain {1}: {3} {4}").format(targetContainerChainName, targetContainerChain, str(exception), str(parms)))

                    raise Exception(str("An error occurred updating container chain name {0} in container chain {1}: {3} {4}").format(targetContainerChainName, targetContainerChain, str(exception), str(parms)))
                #endtry
            #endfor
    else:
        errorLogger.log(logging.ERROR, "No container chains were provided to configure.")

        raise Exception("No container chains were provided to configure.")
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureContainerChains(targetContainerChains, chainsToSkip)"))
#enddef

def configureTuningParams(targetTuningParams, writeContent, writeFrequency, maxInMemorySessions):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureTuningParams(targetTuningParams, writeContent, writeFrequency, maxInMemorySessions)")
    debugLogger.log(logging.DEBUG, targetTuningParams)
    debugLogger.log(logging.DEBUG, writeContent)
    debugLogger.log(logging.DEBUG, writeFrequency)
    debugLogger.log(logging.DEBUG, maxInMemorySessions)

    if ((len(targetTuningParams) != 0) and (len(writeContent) != 0) and (len(writeFrequency) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetTuning, str(\"[[writeContents \"{0}\"] [writeFrequency \"{1}\"] [scheduleInvalidation \"false\"] [invalidationTimeout \"60\"] [maxInMemorySessionCount {2}]]\").format(writeContent, writeFrequency, maxInMemorySessions))")
    
            AdminConfig.modify(targetTuningParams, str("[[writeContents \"{0}\"] [writeFrequency \"{1}\"] [scheduleInvalidation \"false\"] [invalidationTimeout \"60\"] [maxInMemorySessionCount {2}]]").format(writeContent, writeFrequency, maxInMemorySessions))

            infoLogger.log(logging.INFO, str("Completed configuration of tuning parameters {0} with values {1} {2}.").format(targetTuningParams, writeContent, writeFrequency))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating tuning parameters {0} with values {1} {2}: {3} {4}").format(targetTuningParams, writeContent, writeFrequency, str(exception), str(parms)))

            raise Exception(str("An error occurred updating tuning parameters {0} with values {1} {2}: {3} {4}").format(targetTuningParams, writeContent, writeFrequency, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No tuning parameters were provided or no write content/write frequency was provided")

        raise Exception("No tuning parameters were provided or no write content/write frequency was provided")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureTuningParams(targetTuningParams, writeContent, writeFrequency, maxInMemorySessions)")
#enddef

def configureSessionManager(targetSessionManager):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureSessionManager(targetSessionManager)")
    debugLogger.log(logging.DEBUG, targetSessionManager)

    if (len(targetSessionManager) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetSessionManager, str(\"[[enableSecurityIntegration \"true\"] [maxWaitTime \"5\"] [allowSerializedSesssionAccess \"false\"] [enableUrlRewriting \"false\"] [enable \"true\"] [accessSessionOnTimeout \"true\"] [enableSSLTracking \"true\"] [enableCookies \"true\"]]\"))")
    
            AdminConfig.modify(targetSessionManager, str("[[enableSecurityIntegration \"true\"] [maxWaitTime \"5\"] [allowSerializedSesssionAccess \"false\"] [enableUrlRewriting \"false\"] [enable \"true\"] [accessSessionOnTimeout \"true\"] [enableSSLTracking \"true\"] [enableCookies \"true\"]]"))

            infoLogger.log(logging.INFO, str("Completed configuration of session manager {0}.").format(targetSessionManager))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating session manager {0}: {1} {2}").format(targetSessionManager, str(exception), str(parms)))

            raise Exception(str("An error occurred updating session manager {0}: {1} {2}").format(targetSessionManager, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No session manager was provided to configure")

        raise Exception("No session manager was provided to configure")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureSessionManager(targetSessionManager)")
#enddef

def configureServerHostname(targetServer, hostName):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#configureServerHostname(targetServer, hostName)")
    debugLogger.log(logging.DEBUG, targetServer)
    debugLogger.log(logging.DEBUG, hostName)

    if ((len(targetServer) != 0) and (len(hostName) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetServer, str(\"[[hostName \"{0}\"]]\").format(hostName))")

            AdminConfig.modify(targetServer, str("[[hostName \"{0}\"]]").format(hostName))

            infoLogger.log(logging.INFO, str("Successfully modified hostname for server {0} to {1}.").format(targetServer, hostName))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred while modifying the hostname for server {0} to {1}: {2} {3}").format(targetServer, hostName, str(exception), str(parms)))

            raise Exception(str("An error occurred while modifying the hostname for server {0} to {1}: {2} {3}").format(targetServer, hostName, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No server was provided to modify or no new hostname was provided.")

        raise Exception("No server was provided to modify or no new hostname was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureServerHostname(targetServer, hostName)")
#enddef

def setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, rolloverSize, traceFilename):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, rolloverSize, traceFilename)")
    debugLogger.log(logging.DEBUG, targetTraceService)
    debugLogger.log(logging.DEBUG, traceSpec)
    debugLogger.log(logging.DEBUG, outputType)
    debugLogger.log(logging.DEBUG, maxBackupFiles)
    debugLogger.log(logging.DEBUG, rolloverSize)
    debugLogger.log(logging.DEBUG, traceFilename)

    if ((len(targetTraceService) != 0) and (len(traceSpec) != 0) and (len(outputType) != 0)
        and (len(maxBackupFiles) != 0) and (len(rolloverSize) != 0) and (len(traceFilename) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetTraceService, str(\"[[\"startupTraceSpecification\", \"{0}\"]]\").format(traceSpec))")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetTraceService, str(\"[[\"traceOutputType\", \"{0}\"]]\").format(outputType))")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetTraceService, str(\"[[\"traceLog\", [[\"fileName\", \"{0}\"], [\"maxNumberOfBackupFiles\", \"{1}\"], [\"rolloverSize\", \"{2}\"]]\").format(traceFilename, maxBackupFiles, rolloverSize))")

            AdminConfig.modify(targetTraceService, str("[[\"startupTraceSpecification\", \"{0}\"]]").format(traceSpec))
            AdminConfig.modify(targetTraceService, str("[[\"traceOutputType\", \"{0}\"]]").format(outputType))
            AdminConfig.modify(targetTraceService, str("[[\"traceLog\", [[\"fileName\", \"{0}\"], [\"maxNumberOfBackupFiles\", \"{1}\"], [\"rolloverSize\", \"{2}\"]]]]").format(traceFilename, maxBackupFiles, rolloverSize))

            infoLogger.log(logging.INFO, str("Completed configuration of trace service {0}.").format(targetTraceService))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred modifying the trace service configuration for trace service {0}: {1} {2}").format(targetTraceService, str(exception), str(parms)))

            raise Exception(str("An error occurred modifying the trace service configuration for trace service {0}: {1} {2}").format(targetTraceService, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No trace service was provided or no trace service configuration values were provided.")

        raise Exception("No trace service was provided or no trace service configuration values were provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, rolloverSize, traceFilename)")
#enddef

def setProcessExec(targetProcessExec, runAsUser, runAsGroup):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#setProcessExec(targetProcessExec, runAsUser = \"\", runAsGroup = \"\")")
    debugLogger.log(logging.DEBUG, targetProcessExec)
    debugLogger.log(logging.DEBUG, runAsUser)
    debugLogger.log(logging.DEBUG, runAsGroup)

    if (len(targetProcessExec) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.modify()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(targetProcessExec, str(\"[[runAsUser \"{0}\"] [runAsGroup \"{1}\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]\").format(runAsUser, runAsGroup))")

            AdminConfig.modify(targetProcessExec, str("[[runAsUser \"{0}\"] [runAsGroup \"{1}\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]").format(runAsUser, runAsGroup))

            infoLogger.log(logging.INFO, str("Completed configuration of process execution {0} with runtime user {1} and runtime group {2}.").format(targetProcessExec, runAsUser, runAsGroup))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating process execution {0} with runtime user {1} and runtime group {2}: {2} {3}").format(targetProcessExec, runAsUser, runAsGroup, str(exception), str(parms)))

            raise Exception(str("An error occurred updating process execution {0} with runtime user {1} and runtime group {2}: {2} {3}").format(targetProcessExec, runAsUser, runAsGroup, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No process execution was provided or no runtime user/group information was provided.")

        raise Exception("No process execution was provided or no runtime user/group information was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#setProcessExec(targetProcessExec, runAsUser = \"\", runAsGroup = \"\")")
#enddef

def setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, jvmArgs, hprofArgs):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, jvmArgs, hprofArgs = \"\")")
    debugLogger.log(logging.DEBUG, serverName)
    debugLogger.log(logging.DEBUG, nodeName)
    debugLogger.log(logging.DEBUG, initialHeapSize)
    debugLogger.log(logging.DEBUG, maxHeapSize)
    debugLogger.log(logging.DEBUG, jvmArgs)
    debugLogger.log(logging.DEBUG, hprofArgs)

    if ((len(nodeName) != 0) and (len(serverName) != 0)
        and (len(initialHeapSize) != 0) and (len(maxHeapSize) != 0)
        and (len(jvmArgs) != 0)):

        if (len(hprofArgs) != 0):
            setJVMOptions = (str("[-nodeName {0} -serverName {1} -initialHeapSize {2} -maximumHeapSize {3} -runHProf true -hprofArguments {4} "
                "-genericJvmArguments \"{5}\"]").format(nodeName, serverName, initialHeapSize, maxHeapSize, hprofArgs, jvmArgs))
        else:
            setJVMOptions = (str("[-nodeName {0} -serverName {1} -initialHeapSize {2} -maximumHeapSize {3} "
                "-genericJvmArguments \"{5}\"]").format(nodeName, serverName, initialHeapSize, maxHeapSize, jvmArgs))
        #endif

        debugLogger.log(logging.DEBUG, setJVMOptions)

        try:
            debugLogger.log(logging.DEBUG, "Calling AdminTask.setJVMProperties()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminTask.setJVMProperties(setJVMOptions)")

            AdminTask.setJVMProperties(setJVMOptions)

            infoLogger.log(logging.INFO, str("Completed configuration of JVM properties for server {0} on node {1}.").format(serverName, nodeName))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred setting JVM properties for server {0} on node {2}: {3} {4}").format(serverName, nodeName, str(exception), str(parms)))

            raise Exception(str("An error occurred setting JVM properties for server {0} on node {2}: {3} {4}").format(serverName, nodeName, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No server/node information was provided or no JVM properties were provided.")

        raise Exception("No server/node information was provided or no JVM properties were provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, jvmArgs, hprofArgs = \"\")")
#enddef

def getServerStatus(targetServer):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#getServerStatus(targetServer)")
    debugLogger.log(logging.DEBUG, targetServer)

    serverState = "UNKNOWN"

    debugLogger.log(logging.DEBUG, serverState)

    if (len(targetServer) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminControl.getAttribute()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminControl.getAttribute(targetServer, \"state\")")

            serverState = AdminControl.getAttribute(targetServer, "state")

            debugLogger.log(logging.DEBUG, serverState)
            infoLogger.log(logging.INFO, str("Current server state of {0} is: {1}.").format(targetServer, serverState))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred trying to determine the state the provided server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))

            raise Exception(str("An error occurred trying to determine the state the provided server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No server named {0} was found.").format(targetServer))

        raise Exception(str("No server named {0} was found.").format(targetServer))
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#getServerStatus(targetServer)")

    return serverState
#enddef

def startServer(serverName, nodeName, startWaitTime):
    debugLogger.log(logging.DEBUG, "ENTER: serverMaintenance#startServer(serverName, nodeName, startWaitTime = 10)")
    debugLogger.log(logging.DEBUG, serverName)
    debugLogger.log(logging.DEBUG, nodeName)
    debugLogger.log(logging.DEBUG, startWaitTime)

    if ((len(nodeName) != 0) and (len(serverName) != 0) and (len(startWaitTime) != 0)):
        targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

        debugLogger.log(logging.DEBUG, targetServer)

        if (len(targetServer) != 0):
            try:
                debugLogger.log(logging.DEBUG, "Calling AdminControl.getAttribute()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminControl.startServer(nodeName, serverName, startupWaitTime)")

                AdminControl.startServer(nodeName, serverName, startWaitTime)

                infoLogger.log(logging.INFO, str("Startup for server {0} on node {1} has been initiated.").format(serverName, nodeName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred trying start server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))

                raise Exception(str("An error occurred trying start server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
            #endtry
        else:
            errorLogger.log(logging.ERROR, "No server named {0} was found on node {1}.").format(serverName, nodeName)

            raise Exception("No server named {0} was found on node {1}.").format(serverName, nodeName)
        #endif
    else:
        errorLogger.log(logging.ERROR, "No node/server information was provided.")

        raise Exception("No node/server information was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#startServer(serverName, nodeName, startWaitTime = 10)")
#enddef

def stopServer(serverName, nodeName, immediate, terminate):
    debugLogger.log(logging.DEBUG, "ENTER: stopServer(serverName, nodeName, immediate = False, terminate = False)")
    debugLogger.log(logging.DEBUG, serverName)
    debugLogger.log(logging.DEBUG, nodeName)
    debugLogger.log(logging.DEBUG, immediate)
    debugLogger.log(logging.DEBUG, terminate)

    if ((len(nodeName) != 0) and (len(serverName) != 0)):
        targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

        debugLogger.log(logging.DEBUG, targetServer)

        if (len(targetServer) != 0):
            debugLogger.log(logging.DEBUG, "Calling AdminControl.stopServer()")

            try:
                if (immediate):
                    debugLogger.log(logging.DEBUG, "EXEC: AdminControl.stopServer(nodeName, serverName, \"immediate\")")

                    AdminControl.stopServer(nodeName, serverName, "immediate")
                elif (terminate):
                    debugLogger.log(logging.DEBUG, "EXEC: AdminControl.stopServer(nodeName, serverName, \"terminate\")")

                    AdminControl.stopServer(nodeName, serverName, "terminate")
                else:
                    debugLogger.log(logging.DEBUG, "EXEC: AdminControl.stopServer(nodeName, serverName)")

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
        errorLogger.log(logging.ERROR, "No node/server information was provided.")

        raise Exception(str("No node/server information was provided."))
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: stopServer(serverName, nodeName, immediate = False, terminate = False)")
#enddef

def restartServer(targetServer, restartTimeout):
    debugLogger.log(logging.DEBUG, "ENTER: restartServer(targetServer, restartTimeout = 600)")
    debugLogger.log(logging.DEBUG, targetServer)
    debugLogger.log(logging.DEBUG, restartTimeout)

    isRunning = "UNKNOWN"

    debugLogger.log(logging.DEBUG, isRunning)

    if (len(targetServer) != 0):
        debugLogger.log(logging.DEBUG, "Calling AdminControl.invoke()")

        try:
            AdminControl.invoke(targetServer, "restart")

            elapsedTime = 0

            debugLogger.log(elapsedTime)

            if (restartTimeout > 0):
                sleepTime = 5
                isRunning = getServerStatus(targetServer)

                debugLogger.log(logging.DEBUG, sleepTime)
                debugLogger.log(logging.DEBUG, isRunning)

                while ((isRunning) and (elapsedTimeSeconds < restartTimeout)):
                    debugLogger.log(logging.DEBUG, str("Waiting for restart. Sleeping for {0}..").format(sleepTime))

                    time.sleep(sleepTime)

                    elapsedTimeSeconds = elapsedTimeSeconds + sleepTime
                    isRunning = getServerStatus(targetServer)

                    debugLogger.log(logging.DEBUG, elapsedTimeSeconds)
                    debugLogger.log(logging.DEBUG, isRunning)
                #endwhile

                while ((not isRunning) and (elapsedTimeSeconds < restartTimeout)):
                    debugLogger.log(logging.DEBUG, str("Waiting for restart. Sleeping for %d..").format(sleepTime))
                    infoLogger.log(logging.INFO, str("Waiting {0} of {1} seconds for {2} to restart. isRunning = {3}").format(elapsedTimeSeconds, restartTimeout, targetServer, isRunning))

                    time.sleep(sleepTime)

                    elapsedTimeSeconds = elapsedTimeSeconds + sleepTime
                    isRunning = getServerStatus(targetServer)

                    debugLogger.log(logging.DEBUG, elapsedTimeSeconds)
                    debugLogger.log(logging.DEBUG, isRunning)
                #endwhile
            #endif

            isRunning = getServerStatus(targetServer)

            debugLogger.log(logging.DEBUG, isRunning)
            infoLogger.log(logging.INFO, str("Restart completed for server {0} on node {1}. Elapsed time: {2}.").format(targetServer, elapsedTimeSeconds))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred trying to restart server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
            raise Exception(str("An error occurred trying to restart server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No server named {0} was found.").format(targetServer))

        raise Exception(str("No server named {0} was found.").format(targetServer))
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: restartServer(serverName, nodeName, restartTimeout = 600)")
#enddef
