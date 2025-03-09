
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
import time
import logging

errorLogger = logging.getLogger(str("error-logger"))
debugLogger = logging.getLogger(str("debug-logger"))
infoLogger = logging.getLogger(str("info-logger"))

lineSplit = java.lang.System.getProperty("line.separator")

def configureAutoRestart(targetMonitorPolicy, policyOption):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureAutoRestart(targetMonitorPolicy, policyOption)"))
    debugLogger.log(logging.DEBUG, str(targetMonitorPolicy))
    debugLogger.log(logging.DEBUG, str(policyOption))

    if ((len(targetMonitorPolicy) != 0) and (len(policyOption) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(monitorPolicy, str(\"[[maximumStartupAttempts \"3\"] [pingTimeout \"300\"] [pingInterval \"60\"] [autoRestart \"true\"] [nodeRestartState \"{0}\"]]\").format(policyOption))"))

            AdminConfig.modify(targetMonitorPolicy, str("[[maximumStartupAttempts \"3\"] [pingTimeout \"300\"] [pingInterval \"60\"] [autoRestart \"true\"] [nodeRestartState \"{0}\"]]").format(policyOption))

            infoLogger.log(logging.INFO, str("Completed configuration of monitoring policy {0}. New startup state: {1}").format(targetMonitorPolicy, policyOption))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating monitoring policy {0} with option {1}: {2} {3}".format(targetMonitorPolicy, policyOption, str(exception), str(parms))))

            raise Exception(str("An error occurred updating monitoring policy {0} with option {1}: {2} {3}".format(targetMonitorPolicy, policyOption, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No monitor policy was provided or no policy option was provided."))

        raise Exception(str("No monitor policy was provided or no policy option was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureAutoRestart(monitorPolicy, policyOption)"))
#enddef

def configureWebContainer(targetWebContainer, vhostName):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureWebContainer(targetWebContainer, vhostName)"))
    debugLogger.log(logging.DEBUG, str(targetWebContainer))
    debugLogger.log(logging.DEBUG, str(vhostName))

    if ((len(targetWebContainer) != 0) and (len(vhostName) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.create()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.create(\"Property\", targetWebContainer, \"[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.extractHostHeaderPort\"] [description \"\"] [value \"true\"] [required \"false\"]]\")"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.create(\"Property\", targetWebContainer, \"[[validationExpression \"\"] [name \"trusthostheaderport\"] [description \"\"] [value \"true\"] [required \"false\"]]\")"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.create(\"Property\", targetWebContainer, \"[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.invokefilterscompatibility\"] [description \"\"] [value \"true\"] [required \"false\"]]\")"))

            AdminConfig.create("Property", targetWebContainer, "[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.extractHostHeaderPort\"] [description \"\"] [value \"true\"] [required \"false\"]]")
            AdminConfig.create("Property", targetWebContainer, "[[validationExpression \"\"] [name \"trusthostheaderport\"] [description \"\"] [value \"true\"] [required \"false\"]]")
            AdminConfig.create("Property", targetWebContainer, "[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.invokefilterscompatibility\"] [description \"\"] [value \"true\"] [required \"false\"]]")

            infoLogger.log(logging.INFO, str("Completed adding web container properties in web container {0} with default host {1}.").format(targetWebContainer, vhostName))

            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetWebContainer, \"[[defaultVirtualHostName {0}]]\").format(setVirtualHost)"))

            AdminConfig.modify(targetWebContainer, "[[defaultVirtualHostName {0}]]").format(vhostName)

            infoLogger.log(logging.INFO, str("Completed configuration of web container {0} with default host {1}").format(targetWebContainer, vhostName))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating web container {0} with default host {1}: {2} {3}".format(targetWebContainer, vhostName, str(exception), str(parms))))

            raise Exception(str("An error occurred updating web container {0} with default host {1}: {2} {3}".format(targetWebContainer, vhostName, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No web container was provided or no virtual host was provided."))

        raise Exception(str("No web container was provided or no virtual host was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureWebContainer(targetWebContainer, vhostName)"))
#enddef

def configureHAManager(targetHAManager, enableHA):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureHAManager(targetHAManager, enableHA)"))
    debugLogger.log(logging.DEBUG, str(targetHAManager))
    debugLogger.log(logging.DEBUG, str(enableHA))

    if ((len(targetHAManager) != 0) and (len(enableHA) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(haManager, str(\"[[enable \"{0}\"] [activateEnabled \"{0}\"] [isAlivePeriodSec \"120\"] [transportBufferSize \"10\"]]\").format(isEnabled))"))

            AdminConfig.modify(targetHAManager, str("[[enable \"{0}\"] [activateEnabled \"{0}\"] [isAlivePeriodSec \"120\"] [transportBufferSize \"10\"]]").format(enableHA))

            infoLogger.log(logging.INFO, str("Completed HA Manager configuration {1}. New HAManager state: {1}").format(targetHAManager, enableHA))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred modifying the HA Manager service {0} to value {1}: {2} {3}".format(targetHAManager, enableHA, str(exception), str(parms))))

            raise Exception(str("An error occurred modifying the HA Manager service {0} to value {1}: {2} {3}".format(targetHAManager, enableHA, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No HA Manager service was provided or no HA Manager state was provided."))

        raise Exception(str("No HA Manager service was provided or no HA Manager state was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureHAManager(targetHAManager, enableHA)"))
#enddef

def configureCookies(targetCookie, cookieName, cookiePath):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureCookies(targetCookie, cookieName, cookiePath)"))
    debugLogger.log(logging.DEBUG, str(targetCookie))
    debugLogger.log(logging.DEBUG, str(cookieName))
    debugLogger.log(logging.DEBUG, str(cookiePath))

    if ((len(targetCookie) != 0) and (len(cookieName) != 0) and (len(cookiePath) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetCookie, str(\"[[maximumAge \"-1\"] [name \"{0}\"] [domain \"\"] [secure \"true\"] [path \"{1}\"]]\").format(cookieName, cookiePath))"))

            AdminConfig.modify(targetCookie, str("[[maximumAge \"-1\"] [name \"{0}\"] [domain \"\"] [secure \"true\"] [path \"{1}\"]]").format(cookieName, cookiePath))

            infoLogger.log(logging.INFO, str("Completed configuration of server cookie configuration {0} with values {1} {2}.").format(targetCookie, cookieName, cookiePath))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating cookie configuration {0} with values {1} {2}: {3} {4}".format(targetCookie, cookieName, cookiePath, str(exception), str(parms))))

            raise Exception(str("An error occurred updating cookie configuration {0} with values {1} {2}: {3} {4}".format(targetCookie, cookieName, cookiePath, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No cookie configuration was provided or no cookie name/cookie path was provided."))

        raise Exception(str("No cookie configuration was provided or no cookie name/cookie path was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureCookies(targetCookie, cookieName, cookiePath)"))
#enddef

def configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, targetPoolNames):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, targetPoolNames)"))
    debugLogger.log(logging.DEBUG, str(targetThreadPools))
    debugLogger.log(logging.DEBUG, str(startMinThreads))
    debugLogger.log(logging.DEBUG, str(startMaxThreads))
    debugLogger.log(logging.DEBUG, str(webMinThreads))
    debugLogger.log(logging.DEBUG, str(webMaxThreads))
    debugLogger.log(logging.DEBUG, str(haMinThreads))
    debugLogger.log(logging.DEBUG, str(haMaxThreads))
    debugLogger.log(logging.DEBUG, str(targetPoolNames))

    if (len(targetThreadPools) != 0):
        for targetThreadPool in (targetThreadPools):
            debugLogger.log(logging.DEBUG, str(targetThreadPool))

            targetPoolName = targetThreadPool.split("(")[0]

            debugLogger.log(logging.DEBUG, (str(targetPoolName)))

            if (len(targetPoolName) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))

                    if ((targetPoolName == "server.startup") and (len(startMinThreads) != 0) and (len(startMaxThreads) != 0)):
                        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetThreadPool, str(\"[[minimumSize \"20\"] [maximumSize \"10\"] [name \"{0}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]\").format(startMinThreads, startMaxThreads, targetPoolName))"))
                        
                        AdminConfig.modify(targetThreadPool, str("[[minimumSize \"{0}\"] [maximumSize \"{1}\"] [name \"{2}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]").format(startMinThreads, startMaxThreads, targetPoolName))

                        infoLogger.log(logging.INFO, str("Completed configuration of thread pool name {0} in thread pool {1}.").format(targetPoolName, targetThreadPool))
                    elif ((targetPoolName == "WebContainer") and (len(webMinThreads) != 0) and (len(webMaxThreads) != 0)):
                        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetThreadPool, str(\"[[minimumSize \"20\"] [maximumSize \"10\"] [name \"{0}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]\").format(startupMinThreads, startupMaxThreads, targetPoolName))"))

                        AdminConfig.modify(targetThreadPool, str("[[minimumSize \"{0}\"] [maximumSize \"{1}\"] [name \"{2}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]").format(webMinThreads, webMaxThreads, targetPoolName))

                        infoLogger.log(logging.INFO, str("Completed configuration of thread pool name {0} in thread pool {1}.").format(targetPoolName, targetThreadPool))
                    elif ((targetPoolName == "HAManagerService.Pool") and (len(haMinThreads) != 0) and (len(haMaxThreads) != 0)):
                        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetThreadPool, str(\"[[minimumSize \"20\"] [maximumSize \"10\"] [name \"{0}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]\").format(HAManagerMinThreads, HAManagerMaxThreads, targetPoolName))"))

                        AdminConfig.modify(targetThreadPool, str("[[minimumSize \"{0}\"] [maximumSize \"{1}\"] [name \"{2}\"] [inactivityTimeout \"30000\"] [description \"\"] [isGrowable \"false\"]]").format(haMinThreads, haMaxThreads, targetPoolName))

                        infoLogger.log(logging.INFO, str("Completed configuration of thread pool name {0} in thread pool {1}.").format(targetPoolName, targetThreadPool))
                    #endif
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating thread pool name {0} in thread pool {1}: {2} {3}".format(targetPoolName, targetThreadPool, str(exception), str(parms))))

                    raise Exception(str("An error occurred updating thread pool name {0} in thread pool {1}: {2} {3}".format(targetPoolName, targetThreadPool, str(exception), str(parms))))
                #endtry
            #endif
            #endfor
    else:
        errorLogger.log(logging.ERROR, str("No thread pools were provided to configure."))

        raise Exception(str("No thread pools were provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, targetPoolNames)"))
#enddef

def configureTCPChannels(targetTCPChannels, maxConnections):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureTCPChannels(targetTCPChannels, maxConnections)"))
    debugLogger.log(logging.DEBUG, str(targetTCPChannels))
    debugLogger.log(logging.DEBUG, str(maxConnections))

    if ((len(targetTCPChannels) != 0) and (len(maxConnections) != 0)):
        for targetTCPChannel in (targetTCPChannels):
            debugLogger.log(logging.DEBUG, str(targetTCPChannel))

            tcpChannelName = targetTCPChannel.split("(")[0]

            debugLogger.log(logging.DEBUG, (str(tcpChannelName)))

            if (len(tcpChannelName) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))

                    if (tcpChannelName == "TCP_2"):
                        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(tcpChannelName, str(\"[[maxOpenConnections \"{0}\"]]\").format(maxConnections)"))
                        
                        AdminConfig.modify(tcpChannelName, str("[[maxOpenConnections \"{0}\"]]").format(maxConnections))

                        infoLogger.log(logging.INFO, str("Completed configuration of TCP channel {0} in TCP channels {1}.").format(tcpChannelName, targetTCPChannel))
                    #endif
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating TCP channel name {0} in TCP channel {1}: {2} {3}".format(tcpChannelName, targetTCPChannel, str(exception), str(parms))))

                    raise Exception(str("An error occurred updating TCP channel name {0} in TCP channel {1}: {2} {3}".format(tcpChannelName, targetTCPChannel, str(exception), str(parms))))
                #endtry
            #endif
            #endfor
    else:
        errorLogger.log(logging.ERROR, str("No TCP channels were provided or no max connections were provided."))

        raise Exception(str("No TCP channels were provided or no max connections were provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureTCPChannels(targetTCPChannels, maxConnections)"))
#enddef

# TODO
def configureHTTPChannels(targetHTTPChannels, maxConnections = 50):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureHTTPChannels(targetHTTPChannels, maxConnections)"))
    debugLogger.log(logging.DEBUG, str(targetHTTPChannels))
    debugLogger.log(logging.DEBUG, str(maxConnections))

    if (len(targetHTTPChannels) != 0):
        for targetHTTPChannel in (targetHTTPChannels):
            debugLogger.log(logging.DEBUG, str(targetHTTPChannel))

            httpChannelName = targetHTTPChannel.split("(")[0]

            debugLogger.log(logging.DEBUG, (str(httpChannelName)))

            if (len(httpChannelName) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))

                    if (httpChannelName == "HTTP_2"):
                        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(httpChannel, str(\"[[maximumPersistentRequests \"-1\"] [persistentTimeout \"300\"] [enableLogging \"true\"]]\"))"))

                        AdminConfig.modify(targetHTTPChannel, str("[[maximumPersistentRequests \"-1\"] [persistentTimeout \"300\"] [enableLogging \"true\"]]"))

                        debugLogger.log(logging.DEBUG, str("Calling AdminConfig.create()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.create(\"Property\", httpChannel, str(\"[[validationExpression \"\"] [name \"RemoveServerHeader\"] [description \"\"] [value \"true\"] [required \"false\"]]\"))"))

                        AdminConfig.create("Property", targetHTTPChannel, str("[[validationExpression \"\"] [name \"RemoveServerHeader\"] [description \"\"] [value \"true\"] [required \"false\"]]"))

                        infoLogger.log(logging.INFO, str("Completed configuration of HTTP channel {0} in HTTP channels {1}.").format(httpChannelName, targetHTTPChannels))
                    #endif
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating HTTP channel name {0} in HTTP channel {1}: {2} {3}".format(httpChannelName, targetHTTPChannel, str(exception), str(parms))))

                    raise Exception(str("An error occurred updating HTTP channel name {0} in HTTP channel {1}: {2} {3}".format(httpChannelName, targetHTTPChannel, str(exception), str(parms))))
                #endtry
            #endif
            #endfor
    else:
        errorLogger.log(logging.ERROR, str("No HTTP channels were provided to configure."))

        raise Exception(str("No HTTP channels were provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureHTTPChannels(targetServer, maxConnections = 50"))
#enddef

def configureContainerChains(targetContainerChains, chainsToSkip):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureContainerChains(targetContainerChains, chainsToSkip)"))
    debugLogger.log(logging.DEBUG, str(targetContainerChains))
    debugLogger.log(logging.DEBUG, str(chainsToSkip))

    if (len(targetContainerChains) != 0):
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

                    errorLogger.log(logging.ERROR, str("An error occurred updating container chain name {0} in container chain {1}: {3} {4}".format(targetContainerChainName, targetContainerChain, str(exception), str(parms))))

                    raise Exception(str("An error occurred updating container chain name {0} in container chain {1}: {3} {4}".format(targetContainerChainName, targetContainerChain, str(exception), str(parms))))
                #endtry
            #endfor
    else:
        errorLogger.log(logging.ERROR, str("No container chains were provided to configure."))

        raise Exception(str("No container chains were provided to configure."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureContainerChains(targetContainerChains, chainsToSkip)"))
#enddef

def configureTuningParams(targetTuningParams, writeContent, writeFrequency):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureTuningParams(targetTuningParams, writeContent, writeFrequency)"))
    debugLogger.log(logging.DEBUG, str(targetTuningParams))
    debugLogger.log(logging.DEBUG, str(writeContent))
    debugLogger.log(logging.DEBUG, str(writeFrequency))

    if ((len(targetTuningParams) != 0) and (len(writeContent) != 0) and (len(writeFrequency) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetTuning, str(\"[[writeContents \"{0}\"] [writeFrequency \"{1}\"] [scheduleInvalidation \"false\"] [invalidationTimeout \"60\"]]\").format(targetWriteContents, targetWriteFrequency))"))
    
            AdminConfig.modify(targetTuningParams, str("[[writeContents \"{0}\"] [writeFrequency \"{1}\"] [scheduleInvalidation \"false\"] [invalidationTimeout \"60\"]]").format(writeContent, writeFrequency))

            infoLogger.log(logging.INFO, str("Completed configuration of tuning parameters {0} with values {1} {2}.").format(targetTuningParams, writeContent, writeFrequency))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating tuning parameters {0} with values {1} {2}: {3} {4}".format(targetTuningParams, writeContent, writeFrequency, str(exception), str(parms))))

            raise Exception(str("An error occurred updating tuning parameters {0} with values {1} {2}: {3} {4}".format(targetTuningParams, writeContent, writeFrequency, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No tuning parameters were provided or no write content/write frequency was provided"))

        raise Exception(str("No tuning parameters were provided or no write content/write frequency was provided"))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureTuningParams(targetTuningParams, writeContent, writeFrequency)"))
#enddef

# TODO
def configureSessionManager(targetSessionManager):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#configureSessionManager(targetSessionManager)"))
    debugLogger.log(logging.DEBUG, str(targetSessionManager))

    if (len(targetSessionManager) != 0):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetSessionManager, str(\"[[enableSecurityIntegration \"true\"] [maxWaitTime \"5\"] [allowSerializedSesssionAccess \"false\"] [enableUrlRewriting \"false\"] [enable \"true\"] [accessSessionOnTimeout \"true\"] [enableSSLTracking \"true\"] [enableCookies \"true\"]]\"))"))
    
            AdminConfig.modify(targetSessionManager, str("[[enableSecurityIntegration \"true\"] [maxWaitTime \"5\"] [allowSerializedSesssionAccess \"false\"] [enableUrlRewriting \"false\"] [enable \"true\"] [accessSessionOnTimeout \"true\"] [enableSSLTracking \"true\"] [enableCookies \"true\"]]"))

            infoLogger.log(logging.INFO, str("Completed configuration of session manager {0}.").format(targetSessionManager))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating session manager {0}: {1} {2}".format(targetSessionManager, str(exception), str(parms))))

            raise Exception(str("An error occurred updating session manager {0}: {1} {2}".format(targetSessionManager, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No session manager was provided to configure"))

        raise Exception(str("No session manager was provided to configure"))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#configureSessionManager(targetSessionManager)"))
#enddef

def setServletCaching(targetWebContainer, isEnabled):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#setServletCaching(targetWebContainer, isEnabled)"))
    debugLogger.log(logging.DEBUG, str(targetWebContainer))
    debugLogger.log(logging.DEBUG, str(isEnabled))

    if ((len(targetWebContainer) != 0) and (len(isEnabled) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetWebContainer, str(\"[[enableServletCaching \"{0}\"]]\").format(isEnabled))"))

            AdminConfig.modify(targetWebContainer, str("[[enableServletCaching \"{0}\"]]").format(isEnabled))

            infoLogger.log(logging.INFO, str("Completed servlet caching configurationin web container {0}. New caching state: {1}").format(targetWebContainer, isEnabled))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred modifying the servlet caching state for web container {0} with value {1}: {2} {3}".format(targetWebContainer, isEnabled, str(exception), str(parms))))

            raise Exception(str("An error occurred modifying the servlet caching state for web container {0} with value {1}: {2} {3}".format(targetWebContainer, isEnabled, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No web container was provided to configure or no caching state was provided."))

        raise Exception(str("No web container was provided to configure or no caching state was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#setServletCaching(targetWebContainer, isEnabled)"))
#enddef

def setPortletCaching(targetWebContainer, isEnabled):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#setPortletCaching(targetWebContainer, isEnabled)"))
    debugLogger.log(logging.DEBUG, str(targetWebContainer))
    debugLogger.log(logging.DEBUG, str(isEnabled))

    if ((len(targetWebContainer) != 0) and (len(isEnabled) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetWebContainer, str(\"[[enablePortletCaching \"{0}\"]]\").format(isEnabled))"))

            AdminConfig.modify(targetWebContainer, str("[[enablePortletCaching \"{0}\"]]").format(isEnabled))

            infoLogger.log(logging.INFO, str("Completed portlet caching configurationin web container {0}. New caching state: {1}").format(targetWebContainer, isEnabled))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred modifying the portlet caching state for web container {0} with value {1}: {2} {3}".format(targetWebContainer, isEnabled, str(exception), str(parms))))

            raise Exception(str("An error occurred modifying the portlet caching state for web container {0} with value {1}: {2} {3}".format(targetWebContainer, isEnabled, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No web container was provided to configure or no caching state was provided."))

        raise Exception(str("No web container was provided to configure or no caching state was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#setPortletCaching(targetWebContainer, isEnabled)"))
#enddef

def setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, rolloverSize, traceFilename):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, rolloverSize, traceFilename)"))
    debugLogger.log(logging.DEBUG, str(targetTraceService))
    debugLogger.log(logging.DEBUG, str(traceSpec))
    debugLogger.log(logging.DEBUG, str(outputType))
    debugLogger.log(logging.DEBUG, str(maxBackupFiles))
    debugLogger.log(logging.DEBUG, str(rolloverSize))
    debugLogger.log(logging.DEBUG, str(traceFilename))

    if ((len(targetTraceService) != 0) and (len(traceSpec) != 0) and (len(outputType) != 0)
        and (len(maxBackupFiles) != 0) and (len(rolloverSize) != 0) and (len(traceFilename) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetTraceService, str(\"[[\"startupTraceSpecification\", \"{0}\"]]\").format(traceSpec))"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetTraceService, str(\"[[\"traceOutputType\", \"{0}\"]]\").format(outputType))"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetTraceService, str(\"[[\"traceLog\", [[\"fileName\", \"{0}\"], [\"maxNumberOfBackupFiles\", \"{1}\"], [\"rolloverSize\", \"{2}\"]]\").format(traceFilename, maxBackupFiles, rolloverSize))"))

            AdminConfig.modify(targetTraceService, str("[[\"startupTraceSpecification\", \"{0}\"]]").format(traceSpec))
            AdminConfig.modify(targetTraceService, str("[[\"traceOutputType\", \"{0}\"]]").format(outputType))
            AdminConfig.modify(targetTraceService, str("[[\"traceLog\", [[\"fileName\", \"{0}\"], [\"maxNumberOfBackupFiles\", \"{1}\"], [\"rolloverSize\", \"{2}\"]]]]").format(traceFilename, maxBackupFiles, rolloverSize))

            infoLogger.log(logging.INFO, str("Completed configuration of trace service {0}.").format(targetTraceService))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred modifying the trace service configuration for trace service {0}: {1} {2}".format(targetTraceService, str(exception), str(parms))))

            raise Exception(str("An error occurred modifying the trace service configuration for trace service {0}: {1} {2}".format(targetTraceService, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No trace service was provided or no trace service configuration values were provided."))

        raise Exception(str("No trace service was provided or no trace service configuration values were provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, rolloverSize, traceFilename)"))
#enddef

def setProcessExec(targetProcessExec, runAsUser, runAsGroup):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#setProcessExec(targetProcessExec, runAsUser, runAsGroup)"))
    debugLogger.log(logging.DEBUG, str(targetProcessExec))
    debugLogger.log(logging.DEBUG, str(runAsUser))
    debugLogger.log(logging.DEBUG, str(runAsGroup))

    if ((len(targetProcessExec) != 0) and (len(runAsUser) != 0) and (len(runAsGroup) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetProcessExec, str(\"[[runAsUser \"{0}\"] [runAsGroup \"{1}\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]\").format(runAsUser, runAsGroup))"))

            AdminConfig.modify(targetProcessExec, str("[[runAsUser \"{0}\"] [runAsGroup \"{1}\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]").format(runAsUser, runAsGroup))

            infoLogger.log(logging.INFO, str("Completed configuration of process execution {0} with runtime user {1} and runtime group {2}.").format(targetProcessExec, runAsUser, runAsGroup))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating process execution {0} with runtime user {1} and runtime group {2}: {2} {3}".format(targetProcessExec, runAsUser, runAsGroup, str(exception), str(parms))))

            raise Exception(str("An error occurred updating process execution {0} with runtime user {1} and runtime group {2}: {2} {3}".format(targetProcessExec, runAsUser, runAsGroup, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No process execution was provided or no runtime user/group information was provided."))

        raise Exception(str("No process execution was provided or no runtime user/group information was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#setProcessExec(targetProcessExec, runAsUser, runAsGroup)"))
#enddef

def setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, jvmArgs, hprofArgs):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, jvmArgs, hprofArgs)"))
    debugLogger.log(logging.DEBUG, str(serverName))
    debugLogger.log(logging.DEBUG, str(nodeName))
    debugLogger.log(logging.DEBUG, str(initialHeapSize))
    debugLogger.log(logging.DEBUG, str(maxHeapSize))
    debugLogger.log(logging.DEBUG, str(jvmArgs))
    debugLogger.log(logging.DEBUG, str(hprofArgs))

    if ((len(nodeName) != 0) and (len(serverName) != 0)
        and (len(initialHeapSize) != 0) and (len(maxHeapSize) != 0)
        and (len(jvmArgs) != 0) and (len(hprofArgs) != 0)):
        setJVMOptions = (str("[-nodeName {0} -serverName {1} -initialHeapSize {2} -maximumHeapSize {3} -runHProf true -hprofArguments {4} "
            "-genericJvmArguments \"{5}\"]").format(nodeName, serverName, initialHeapSize, maxHeapSize, hprofArgs, jvmArgs))

        debugLogger.log(logging.DEBUG, str(setJVMOptions))

        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminTask.setJVMProperties()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminTask.setJVMProperties(setJVMOptions)"))

            AdminTask.setJVMProperties(setJVMOptions)

            infoLogger.log(logging.INFO, str("Completed configuration of JVM properties for server {0} on node {1}.").format(serverName, nodeName))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred setting JVM properties for server {0} on node {2}: {3} {4}".format(serverName, nodeName, str(exception), str(parms))))

            raise Exception(str("An error occurred setting JVM properties for server {0} on node {2}: {3} {4}".format(serverName, nodeName, str(exception), str(parms))))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No server/node information was provided or no JVM properties were provided."))

        raise Exception(str("No server/node information was provided or no JVM properties were provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, jvmArgs, hprofArgs)"))
#enddef

def serverStatus(serverName, nodeName):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#serverStatus(serverName, nodeName)"))
    debugLogger.log(logging.DEBUG, str(serverName))
    debugLogger.log(logging.DEBUG, str(nodeName))

    serverState = "UNKNOWN"

    debugLogger.log(logging.DEBUG, str(serverState))

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

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#serverStatus(serverName, nodeName)"))

    return serverState
#enddef

def startServer(serverName, nodeName, startWaitTime = 10):
    debugLogger.log(logging.DEBUG, str("ENTER: serverMaintenance#startServer(serverName, nodeName, startWaitTime = 10)"))
    debugLogger.log(logging.DEBUG, str(serverName))
    debugLogger.log(logging.DEBUG, str(nodeName))
    debugLogger.log(logging.DEBUG, str(startWaitTime))

    if ((len(nodeName) != 0) and (len(serverName) != 0) and (len(startWaitTime) != 0)):
        targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

        debugLogger.log(logging.DEBUG, str(targetServer))

        if (len(targetServer) != 0):
            try:
                debugLogger.log(logging.DEBUG, str("Calling AdminControl.getAttribute()"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminControl.startServer(nodeName, serverName, startupWaitTime)"))

                AdminControl.startServer(nodeName, serverName, startWaitTime)

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
        errorLogger.log(logging.ERROR, str("No node/server information was provided."))
        raise Exception(str("No node/server information was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: serverMaintenance#startServer(serverName, nodeName, startWaitTime = 10)"))
#enddef

def stopServer(serverName, nodeName, immediate = False, terminate = False):
    debugLogger.log(logging.DEBUG, str("ENTER: stopServer(serverName, nodeName, immediate = False, terminate = False)"))
    debugLogger.debug(logging.DEBUG, str(serverName))
    debugLogger.debug(logging.DEBUG, str(nodeName))
    debugLogger.debug(logging.DEBUG, str(immediate))
    debugLogger.debug(logging.DEBUG, str(terminate))

    if ((len(nodeName) != 0) and (len(serverName) != 0)):
        targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

        debugLogger.log(logging.DEBUG, str(targetServer))

        if (len(targetServer) != 0):
            debugLogger.log(logging.DEBUG, str("Calling AdminControl.stopServer()"))

            try:
                if (immediate):
                    debugLogger.debug(logging.DEBUG, str("EXEC: AdminControl.stopServer(nodeName, serverName, str(\"immediate\"))"))

                    AdminControl.stopServer(nodeName, serverName, str("immediate"))
                elif (terminate):
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
        errorLogger.log(logging.ERROR, str("No node/server information was provided."))
        raise Exception(str("No node/server information was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: stopServer(serverName, nodeName, immediate = False, terminate = False):"))
#enddef

def restartServer(serverName, nodeName, restartTimeout = 600):
    debugLogger.log(logging.DEBUG, str("ENTER: restartServer(serverName, nodeName, restartTimeout = 600)"))
    debugLogger.debug(logging.DEBUG, str(serverName))
    debugLogger.debug(logging.DEBUG, str(nodeName))
    debugLogger.debug(logging.DEBUG, str(restartTimeout))

    isRunning = "UNKNOWN"

    debugLogger.debug(logging.DEBUG, str(isRunning))

    if ((len(nodeName) != 0) and (len(serverName) != 0)):
        targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

        debugLogger.log(logging.DEBUG, str(targetServer))

        if (len(targetServer) != 0):
            debugLogger.log(logging.DEBUG, str("Calling AdminControl.invoke()"))

            try:
                AdminControl.invoke(targetServer, str("restart"))

                elapsedTime = 0

                debugLogger.log(elapsedTime)

                if (restartTimeout > 0):
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

                    while ((not isRunning) and (elapsedTimeSeconds < restartTimeout)):
                        debugLogger.log(logging.DEBUG, str("Waiting for restart. Sleeping for %d..").format(sleepTime))
                        infoLogger.log(logging.INFO, str("Waiting {0} of {1} seconds for {2} to restart. isRunning = {3}").format(elapsedTimeSeconds, restartTimeout, serverName, isRunning))

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
        errorLogger.log(logging.ERROR, str("No node/server information provided."))
        raise Exception(str("No node/server information provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: restartServer(serverName, nodeName, restartTimeout = 600)"))
#enddef
