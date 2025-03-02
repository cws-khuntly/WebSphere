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
import logging

configureLogging("../config/logging.xml")
consoleLogger = logging.getLogger("console-logger")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")

global configFile
global targetServer

lineSplit = java.lang.System.getProperty("line.separator")
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

## TODO
def configureAllServers():
    if (len(configFile) != 0):
        serverList = AdminTask.listServers('[-serverType APPLICATION_SERVER ]').split(lineSplit)

        debugLogger.log(serverList)

        if (len(serverList) != 0):
            infoLogger.log("Starting configuration for all servers in cell %s..") % (targetCell)
            consoleLogger.info("Starting configuration for all servers in cell %s..") % (targetCell)

            for server in (serverList):
                debugLogger.log(server)

                if (len(server) != 0):
                    infoLogger.log("Starting configuration for all servers in cell %s..") % (targetCell)
                    consoleLogger.info("Starting configuration for server %s..") % (server)

                    try:
                        debugLogger.log("Calling configureTargetServer()..")

                        configureTargetServer()

                        infoLogger.log("Configuration complete for server %s") % (server)
                        consoleLogger.info("Configuration complete for server %s") % (server)
                    except:
                        errorLogger.log("An error occurred configuring the server %s. Please review logs.") % (server)
                        consoleLogger.error("An error occurred configuring the server %s. Please review logs.") % (server)

                        continue
                    #endtry
                #endtry

                continue
            #endfor
        else:
            errorLogger.log("No servers were found in the cell %s.") % (targetCell)
            consoleLogger.error("No servers were found in the cell %s.") % (targetCell)
        #endif
    else:
        errorLogger.log("No configuration file was provided.")
        consoleLogger.error("No configuration file was provided.")
#enddef

def configureTargetServer():
    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        debugLogger.log(properties)

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            debugLogger.log(nodeName)
            debugLogger.log(serverName)

            if ((len(nodeName) != 0) and (len(serverName) != 0)):
                targetServer = AdminConfig.getid('/Node:%s/Server:%s/') % (nodeName, serverName)

                debugLogger.log(targetServer)

                if (len(targetServer) != 0):
                    infoLogger.log("Starting configuration for server %s..") % (serverName)
                    consoleLogger.info("Starting configuration for server %s..") % (serverName)

                    try:
                        configureAutoRestart(configFile, targetServer)
                        configureWebContainer(targetServer)
                        setServerTrace(targetServer)
                        setProcessExec(targetServer)
                        configureThreadPools(targetServer)
                        setServletCaching(targetServer)
                        setPortletCaching(targetServer)
                        setJVMProperties(targetServer)

                        infoLogger.log("Completed configuration for server %s.") % (serverName)
                        consoleLogger.info("Completed configuration for server %s.") % (serverName)
                    except:
                        errorLogger.log("An error occurred performing configuration steps for server %s. Please review logs.")
                        consoleLogger.error("An error occurred performing configuration steps for server %s. Please review logs.")
                    finally:
                        debugLogger.log("Saving workspace changes and synchronizing the cell..")

                        saveWorkspaceChanges()
                        syncAllNodes(nodeList, targetCell)

                        infoLogger.log("Workspace changes have been saved and the cell has been synchronized.")
                        consoleLogger.info("Workspace changes have been saved and the cell has been synchronized.")
                    #endfor
                else:
                    errorLogger.log("No server was found with node name %s and server name %s.") % (nodeName, serverName)
                    consoleLogger.error("No server was found with node name %s and server name %s.") % (nodeName, serverName)
                #endif
            else:
                errorLogger.log("No node/server information was found in the provided configuration file.")
                consoleLogger.error("No node/server information was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No server information section was found in the provided configuration file.")
            consoleLogger.error("No server information section was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log("No configuration file was provided.")
        consoleLogger.error("No configuration file was provided.")
    #endif
#enddef

def configureAutoRestart(autoRestart = "STOPPED"):
    debugLogger.log(targetServer)
    debugLogger.log(autoRestart)

    if (len(targetServer) != 0):
        debugLogger.log(targetServer)

        if (len(configFile) != 0):
            properties = readConfigurationFileSection(configFile, "server-auto-restart")

            debugLogger.log(properties)

            if (len(properties) != 0):
                setRestartValue = properties["restart-policy"] or autoRestart
                monitorPolicy = AdminConfig.list('MonitoringPolicy', targetServer)

                debugLogger.log(setRestartValue)
                debugLogger.log(monitorPolicy)

                if (len(monitorPolicy) != 0):
                    try:
                        debugLogger.log("Calling AdminConfig.modify()")
                        debugLogger.log("EXEC: AdminConfig.modify(monitorPolicy, '[[maximumStartupAttempts \"3\"] [pingTimeout \"300\"] [pingInterval \"60\"] [autoRestart \"true\"] [nodeRestartState \"%s\"]]') % (setRestartValue)")

                        AdminConfig.modify(monitorPolicy, '[[maximumStartupAttempts "3"] [pingTimeout "300"] [pingInterval "60"] [autoRestart "true"] [nodeRestartState "%s"]]') % (setRestartValue)

                        debugLogger.log("Modify complete.")
                        infoLogger.log("Completed configuration of target Monitoring Policy %s.") % (monitorPolicy)
                    except:
                        (exception, parms) = sys.exc_info()

                        errorLogger.log("An error occurred updating the monitoring policy for the provided server: %s: %s %s") % (targetServer, str(exception), str(parms))

                        raise Exception ("An error occurred updating the monitoring policy for the provided server. Please review logs.")
                    #endtry
                else:
                    errorLogger.log("No monitoring policy was found for the provided server.")

                    raise Exception ("No monitoring policy was found for the provided server.")
                #endif
            else:
                errorLogger.log("No monitoring policy information section was found in the provided configuration file.")

                raise Exception ("No monitoring policy information section was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No configuration file was provided.")

            raise Exception ("No configuration file was provided.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureWebContainer(defaultVHost = "default_host"):
    debugLogger.log(targetServer)
    debugLogger.log(defaultVHost)

    if (len(targetServer) != 0):
        debugLogger.log(targetServer)

        if (len(configFile) != 0):
            properties = readConfigurationFileSection(configFile, "server-default-vhost")

            debugLogger.log(properties)

            if (len(properties) != 0):
                setDefaultHost = properties["virtual-host"] or defaultVHost
                targetWebContainer = AdminConfig.list('WebContainer', targetServer)

                debugLogger.log(setDefaultHost)
                debugLogger.log(targetWebContainer)

                if (len(targetWebContainer) != 0):
                    try:
                        debugLogger.log("Calling AdminConfig.create()")
                        debugLogger.log("EXEC: AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name \"com.ibm.ws.webcontainer.extractHostHeaderPort\"] [description \"\"] [value \"true\"] [required \"false\"]]')")
                        debugLogger.log("EXEC: AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name \"trusthostheaderport\"] [description \"\"] [value \"true\"] [required \"false\"]]')")
                        debugLogger.log("EXEC: AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name \"com.ibm.ws.webcontainer.invokefilterscompatibility\"] [description \"\"] [value \"true\"] [required \"false\"]]')")

                        AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.extractHostHeaderPort"] [description ""] [value "true"] [required "false"]]')
                        AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "trusthostheaderport"] [description ""] [value "true"] [required "false"]]')
                        AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.invokefilterscompatibility"] [description ""] [value "true"] [required "false"]]')

                        debugLogger.log("Calling AdminConfig.modify()")
                        debugLogger.log("EXEC: AdminConfig.modify(targetWebContainer, \"[[defaultVirtualHostName \"%s\"]]\") % (setDefaultHost)")

                        AdminConfig.modify(targetWebContainer, "[[defaultVirtualHostName \"%s\"]]") % (setDefaultHost)

                        debugLogger.log("Modify complete.")
                        infoLogger.log("Completed configuration of target Web Container %s.") % (targetWebContainer)
                    except:
                        (exception, parms) = sys.exc_info()

                        errorLogger.log("An error occurred updating the web container for the provided server: %s: %s %s") % (targetServer, str(exception), str(parms))

                        raise Exception ("An error occurred updating the web container for the provided server. Please review logs.")
                    #endtry
                else:
                    errorLogger.log("No web container was found for the provided server.")

                    raise Exception ("No web container was found for the provided server.")
                #endif
            else:
                errorLogger.log("No web container information section was found in the provided configuration file.")

                raise Exception ("No web container information section was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No configuration file was provided.")

            raise Exception ("No configuration file was provided.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureHAManager(isEnabled = "false"):
    debugLogger.log(targetServer)
    debugLogger.log(isEnabled)

    if (len(targetServer) != 0):
        debugLogger.log(targetServer)

        if (len(configFile) != 0):
            properties = readConfigurationFileSection(configFile, "server-hamanager")

            debugLogger.log(properties)

            if (len(properties) != 0):
                isHAEnabled = properties["enabled"] or isEnabled
                haManager = AdminConfig.list('HAManagerService', targetServer)

                debugLogger.log(isHAEnabled)
                debugLogger.log(haManager)

                if (len(haManager) != 0):
                    try:
                        debugLogger.log("Calling AdminConfig.modify()")
                        debugLogger.log("EXEC: AdminConfig.modify(haManager, \"[[enable \"%s\"] [activateEnabled \"true\"] [isAlivePeriodSec \"120\"] [transportBufferSize \"10\"] [activateEnabled \"true\"]]\") % (isHAEnabled)")

                        AdminConfig.modify(haManager, "[[enable \"%s\"] [activateEnabled \"true\"] [isAlivePeriodSec \"120\"] [transportBufferSize \"10\"] [activateEnabled \"true\"]]") % (isHAEnabled)

                        debugLogger.log("Modify complete.")
                        infoLogger.log("Completed configuration of target HA Manager %s.") % (haManager)
                    except:
                        (exception, parms) = sys.exc_info()

                        errorLogger.log("An error occurred updating the HA Manager for the provided server: %s: %s %s") % (targetServer, str(exception), str(parms))

                        raise Exception ("An error occurred updating the HA Manager for the provided server. Please review logs.")
                    #endtry
                else:
                    errorLogger.log("No HA Manager was found for the provided server.")

                    raise Exception ("No HA Manager was found for the provided server.")
                #endif
            else:
                errorLogger.log("No HA Manager information section was found in the provided configuration file.")

                raise Exception ("No HA Manager information section was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No configuration file was provided.")

            raise Exception ("No configuration file was provided.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def setServletCaching(isEnabled = "true"):
    debugLogger.log(targetServer)
    debugLogger.log(isEnabled)

    if (len(targetServer) != 0):
        debugLogger.log(targetServer)

        if (len(configFile) != 0):
            properties = readConfigurationFileSection(configFile, "server-servlet-caching")

            debugLogger.log(properties)

            if (len(properties) != 0):
                isServletCachingEnabled = properties["enabled"] or isEnabled
                targetWebContainer = AdminConfig.list('WebContainer', targetServer)

                debugLogger.log(isServletCachingEnabled)
                debugLogger.log(targetWebContainer)

                if (len(targetWebContainer) != 0):
                    try:
                        debugLogger.log("Calling AdminConfig.modify()")
                        debugLogger.log("EXEC: AdminConfig.modify(targetWebContainer, \"[[enableServletCaching \"%s\"]]\") % (isServletCachingEnabled)")

                        AdminConfig.modify(targetWebContainer, "[[enableServletCaching \"%s\"]]") % (isServletCachingEnabled)

                        debugLogger.log("Modify complete.")
                        infoLogger.log("Completed configuration of target web container %s.") % (targetWebContainer)
                    except:
                        (exception, parms) = sys.exc_info()

                        errorLogger.log("An error occurred updating servlet caching for the provided server: %s: %s %s") % (targetServer, str(exception), str(parms))

                        raise Exception ("An error occurred updating the servlet caching for the provided server. Please review logs.")
                    #endtry
                else:
                    errorLogger.log("No web container was found for the provided server.")

                    raise Exception ("No web container was found for the provided server.")
                #endif
            else:
                errorLogger.log("No web container information section was found in the provided configuration file.")

                raise Exception ("No web container information section was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No configuration file was provided.")

            raise Exception ("No configuration file was provided.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def setPortletCaching(isEnabled = "true"):
    debugLogger.log(targetServer)
    debugLogger.log(isEnabled)

    if (len(targetServer) != 0):
        debugLogger.log(targetServer)

        if (len(configFile) != 0):
            properties = readConfigurationFileSection(configFile, "server-portlet-caching")

            debugLogger.log(properties)

            if (len(properties) != 0):
                isPortalServer = properties["is-portal-host"] or False

                debugLogger.log(isPortalServer)

                if (isPortalServer):
                    isPortletCachingEnabled = properties["enabled"] or isEnabled
                    targetWebContainer = AdminConfig.list('WebContainer', targetServer)

                    debugLogger.log(isPortletCachingEnabled)
                    debugLogger.log(targetWebContainer)

                    if (len(targetWebContainer) != 0):
                        try:
                            debugLogger.log("Calling AdminConfig.modify()")
                            debugLogger.log("EXEC: AdminConfig.modify(targetWebContainer, \"[[enablePortletCaching \"%s\"]]\") % (isPortletCachingEnabled)")

                            AdminConfig.modify(targetWebContainer, "[[enablePortletCaching \"%s\"]]") % (isPortletCachingEnabled)

                            debugLogger.log("Modify complete.")
                            infoLogger.log("Completed configuration of target web container %s") % (targetWebContainer)
                        except:
                            (exception, parms) = sys.exc_info()

                            errorLogger.log("An error occurred updating portlet caching for the provided server: %s: %s %s") % (targetServer, str(exception), str(parms))

                            raise Exception ("An error occurred updating the portlet caching for the provided server. Please review logs.")
                        #endtry
                    else:
                        errorLogger.log("No web container was found for the provided server.")

                        raise Exception ("No web container was found for the provided server.")
                    #endif
                #endif
            else:
                errorLogger.log("No web container value was found in the provided configuration file.")

                raise Exception ("No web container value was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No configuration file was provided.")

            raise Exception ("No configuration file was provided.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def setServerTrace(traceSpec = "*=info", outputType = "SPECIFIED_FILE", maxBackupFiles = 50, rolloverSize = 50, traceFilename = "\${SERVER_LOG_ROOT}/trace.log"):
    debugLogger.log(targetServer)
    debugLogger.log(traceSpec)
    debugLogger.log(outputType)
    debugLogger.log(maxBackupFiles)
    debugLogger.log(rolloverSize)
    debugLogger.log(traceFilename)

    if (len(targetServer) != 0):
        debugLogger.log(targetServer)

        if (len(configFile) != 0):
            properties = readConfigurationFileSection(configFile, "server-trace-settings")

            debugLogger.log(properties)

            if (len(properties) != 0):
                traceSpecificationValue = properties["trace-spec"] or traceSpec
                traceOutputType = properties["output-type"] or outputType
                maxBackupFileCount = properties["max-backup-files"] or maxBackupFiles
                maxTraceFileSize = properties["max-file-size"] or rolloverSize
                traceFileNameAndPath = properties["trace-file-name"] or traceFilename
                targetTraceService = AdminConfig.list('TraceService', targetServer)

                debugLogger.log(traceSpecificationValue)
                debugLogger.log(traceOutputType)
                debugLogger.log(maxBackupFileCount)
                debugLogger.log(maxTraceFileSize)
                debugLogger.log(traceFileNameAndPath)
                debugLogger.log(targetTraceService)

                if (len(targetTraceService) != 0):
                    try:
                        debugLogger.log("Calling AdminConfig.modify()")
                        debugLogger.log("EXEC: AdminConfig.modify(targetTraceService, \"[[startupTraceSpecification, \"%s\"]]\") % (traceSpecificationValue)")
                        debugLogger.log("EXEC: AdminConfig.modify(targetTraceService, \"[[traceOutputType, \"%s\"]]\") % (traceOutputType)")
                        debugLogger.log("EXEC: AdminConfig.modify(targetTraceService, \"[[traceLog, [[fileName, \"%s\"], [maxNumberOfBackupFiles, \"%d\"], [rolloverSize, \"%d\"]]]\") % (traceFileNameAndPath, maxBackupFileCount, maxTraceFileSize)")

                        AdminConfig.modify(targetTraceService, "[[startupTraceSpecification, \"%s\"]]") % (traceSpecificationValue)
                        AdminConfig.modify(targetTraceService, "[[traceOutputType, \"%s\"]]") % (traceOutputType)
                        AdminConfig.modify(targetTraceService, "[[traceLog, [[fileName, \"%s\"], [maxNumberOfBackupFiles, \"%d\"], [rolloverSize, \"%d\"]]]") % (traceFileNameAndPath, maxBackupFileCount, maxTraceFileSize)

                        debugLogger.log("Modify complete.")
                        infoLogger.log("Completed configuration of trace service %s.") % (targetTraceService)
                    except:
                        (exception, parms) = sys.exc_info()

                        errorLogger.log("An error occurred updating the trace service for the provided server: %s: %s %s") % (targetServer, str(exception), str(parms))

                        raise Exception ("An error occurred updating the trace service for the provided server. Please review logs.")
                    #endtry
                else:
                    errorLogger.log("No trace service was found for the provided server.")

                    raise Exception ("No trace service was found for the provided server.")
                #endif
            else:
                errorLogger.log("No trace service value was found in the provided configuration file.")

                raise Exception ("No trace service value was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No configuration file was provided.")

            raise Exception ("No configuration file was provided.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def setProcessExec(runAsUser = "", runAsGroup = ""):
    debugLogger.log(targetServer)
    debugLogger.log(runAsUser)
    debugLogger.log(runAsGroup)

    if (len(targetServer) != 0):
        if (len(configFile) != 0):
            properties = readConfigurationFileSection(configFile, "server-process-settings")

            debugLogger.log(properties)

            if (len(properties) != 0):
                runUserName = properties["run-user"] or runAsUser
                runGroupName = properties["run-group"] or runAsGroup
                processExec = AdminConfig.list('ProcessExecution', targetServer)

                debugLogger.log(runUserName)
                debugLogger.log(runGroupName)
                debugLogger.log(processExec)

                if (len(processExec) != 0):
                    try:
                        debugLogger.log("Calling AdminConfig.modify()")

                        if ((len(runUserName) != 0) and (len(runGroupName) != 0)):
                            debugLogger.log("EXEC: AdminConfig.modify(processExec, \"[[runAsUser \"%s\"] [runAsGroup \"%s\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]\") % (runUserName, runGroupName)")

                            AdminConfig.modify(processExec, "[[runAsUser \"%s\"] [runAsGroup \"%s\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]") % (runUserName, runGroupName)
                        elif (len(runUserName) != 0):
                            debugLogger.log("EXEC: AdminConfig.modify(processExec, \"[[runAsUser \"%s\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]\") % (runUserName)")

                            AdminConfig.modify(processExec, "[[runAsUser \"%s\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]") % (runUserName)
                        #end if

                        debugLogger.log("Modify complete.")
                        infoLogger.log("Completed configuration of process execution %s.") % (processExec)
                    except:
                        (exception, parms) = sys.exc_info()

                        errorLogger.log("An error occurred updating process execution for the provided server: %s: %s %s") % (targetServer, str(exception), str(parms))

                        raise Exception ("An error occurred updating process execution for the provided server. Please review logs.")
                    #endtry
                else:
                    errorLogger.log("No process execution was found for the provided server.")

                    raise Exception ("No process execution was found for the provided server.")
                #endif
            else:
                errorLogger.log("No trace service value was found in the provided configuration file.")

                raise Exception ("No trace service value was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No configuration file was provided.")

            raise Exception ("No configuration file was provided.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
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
        "-Dephox.config.file=/opt/ephox/application.conf -Xrunjdwp=dt_socket,server=y,suspend=n,address=7792 -Dcom.ibm.xml.xlxp.jaxb.opti.level=3 -XtlhPrefetch")

    debugLogger.log(genericJvmArgs)
    debugLogger.log(initialHeapSize)
    debugLogger.log(maxHeapSize)

    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        debugLogger.log(properties)

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            debugLogger.log(nodeName)
            debugLogger.log(serverName)

            if ((serverName) and (nodeName)):
                jvmConfigInfo = readConfigurationFileSection(configFile, "server-jvm-settings")

                debugLogger.log(jvmConfigInfo)

                if (len(jvmConfigInfo) != 0):
                    minHeap = jvmConfigInfo["initial-heap-size"] or initialHeapSize
                    maxHeap= jvmConfigInfo["max-heap-size"] or maxHeapSize
                    targetServer = AdminConfig.getid('/Node:%s/Server:%s/') % (nodeName, serverName)

                    debugLogger.log(minHeap)
                    debugLogger.log(maxHeap)
                    debugLogger.log(targetServer)

                    if (len(targetServer) != 0):
                        try:
                            debugLogger.log("Calling AdminConfig.modify()")
                            debugLogger.log("AdminTask.setJVMProperties(\"[-serverName %s -nodeName %s -verboseModeGarbageCollection true -initialHeapSize %d -maximumHeapSize + %d -debugMode false -genericJvmArguments %s]\") \ % (serverName, nodeName, minHeap, maxHeap)")

                            AdminTask.setJVMProperties("[-serverName %s -nodeName %s -verboseModeGarbageCollection true -initialHeapSize %d -maximumHeapSize + %d -debugMode false -genericJvmArguments %s]") \
                                % (serverName, nodeName, minHeap, maxHeap)

                            debugLogger.log("Modify complete.")
                            infoLogger.log("Completed configuration of JVM properties for server %s.") % (targetServer)
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

def configureCookies(cookieName = "JSESSIONID"):
    debugLogger.log(targetServer)
    debugLogger.log(cookieName)

    if (len(targetServer) != 0):
        if (len(configFile) != 0):
            properties = readConfigurationFileSection(configFile, "server-cookie-settings")

            debugLogger.log(properties)

            if (len(properties) != 0):
                cookieName = properties["cookie-name"] or cookieName
                targetCookie = AdminConfig.list("Cookie", targetServer)

                debugLogger.log(cookieName)
                debugLogger.log(targetCookie)

                if (len(targetCookie) != 0):
                    try:
                        debugLogger.log("Calling AdminConfig.modify()")
                        debugLogger.log("EXEC: AdminConfig.modify(targetCookie, \"[[maximumAge \"-1\"] [name \"%s\"] [domain \"\"] [secure \"true\"] [path \"/\"]]\") % (cookieName)")

                        AdminConfig.modify(targetCookie, "[[maximumAge \"-1\"] [name \"%s\"] [domain \"\"] [secure \"true\"] [path \"/\"]]") % (cookieName)

                        debugLogger.log("Modify complete.")
                        infoLogger.log("Completed configuration of cookies %s.") % (targetCookie)
                    except:
                        (exception, parms) = sys.exc_info()

                        errorLogger.log("An error occurred updating cookie configuration for the provided server: %s: %s %s") % (targetServer, str(exception), str(parms))

                        raise Exception ("An error occurred updating cookie configuration. for the provided server. Please review logs.")
                    #endtry
                else:
                    errorLogger.log("No cookie configuration was found for the provided server.")

                    raise Exception ("No cookie configuration was found for the provided server.")
                #endif
            else:
                errorLogger.log("No cookie configuration section was found in the provided configuration file.")

                raise Exception ("No cookie configuration section was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No configuration file was provided.")

            raise Exception ("No configuration file was provided.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureThreadPools():
    debugLogger.log(targetServer)

    if (len(targetServer) != 0):
        threadPools = AdminConfig.list('ThreadPool', targetServer).split(lineSplit)

        debugLogger.log(threadPools)

        if (len(threadPools) != 0):
            for threadPool in (threadPools):
                debugLogger.log(threadPool)

                poolName = threadPool.split("(")[0]

                debugLogger.log(poolName)

                if (len(poolName) != 0):
                    try:
                        debugLogger.log("Calling AdminConfig.modify()")

                        if (poolName == "server.startup"):
                            debugLogger.log("EXEC: AdminConfig.modify(threadPool, \"[[minimumSize \"0\"] [maximumSize \"10\"] [name \"%s\"] [inactivityTimeout \"30000\"] [description \"This pool is used by WebSphere during server startup.\"] [isGrowable \"false\"]]\") % (poolName)")
                            
                            AdminConfig.modify(threadPool, "[[minimumSize \"20\"] [maximumSize \"10\"] [name \"%s\"] [inactivityTimeout \"30000\"] [description \"This pool is used by WebSphere during server startup.\"] [isGrowable \"false\"]]") % (poolName)
                        elif (poolName == "WebContainer"):
                            debugLogger.log("EXEC: AdminConfig.modify(threadPool, \"[[minimumSize \"0\"] [maximumSize \"75\"] [name \"%s\"] [inactivityTimeout \"5000\"] [minimumSize \"20\"] [description \"\"] [isGrowable \"false\"]]\") % (poolName)")

                            AdminConfig.modify(threadPool, "[[minimumSize \"20\"] [maximumSize \"75\"] [name \"%s\"] [inactivityTimeout \"5000\"] [description \"\"] [isGrowable \"false\"]]") % (poolName)
                        elif (poolName == "HAManagerService.Pool"):
                            debugLogger.log("EXEC: AdminConfig.modify(threadPool, \"[[minimumSize \"0\"] [maximumSize \"0\"] [name \"%s\"] [inactivityTimeout \"5000\"] [description \"\"] [isGrowable \"false\"]]\") % (poolName)")

                            AdminConfig.modify(threadPool, '[[minimumSize "0"] [maximumSize "6"] [inactivityTimeout "5000"] [isGrowable "true" ]]')
                        #endif

                        debugLogger.log("Modify complete.")
                        infoLogger.log("Completed configuration of thread pool %s.") % (poolName)
                    except:
                        errorLogger.log("An error occurred while configuring the thread pool %s. Please review logs.") % (poolName)

                        raise Exception ("An error occurred while configuring the thread pool %s. Please review logs.") % (poolName)
                    #endtry
                #endif
             #endfor
        else:
            errorLogger.log("No thread pools were found for the provided server.")

            raise Exception ("No thread pools were found for the provided server.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureTCPChannels():
    debugLogger.log(targetServer)

    if (len(targetServer) != 0):
        targetTCPChannels = AdminConfig.list('TCPInboundChannel', targetServer).split(lineSplit)

        debugLogger.log(targetTCPChannels)

        if (len(targetTCPChannels) != 0):
            for tcpChannel in (targetTCPChannels):
                debugLogger.log(tcpChannel)

                tcpName = tcpChannel.split("(")[0]

                debugLogger.log(tcpName)

                if (len(tcpName) != 0):
                    try:
                        if (tcpName == "TCP_2"):
                            debugLogger.log("Calling AdminConfig.modify()")
                            debugLogger.log("EXEC: AdminConfig.modify(tcpChannel, \"[[maxOpenConnections \"50\"]]\")")

                            AdminConfig.modify(tcpChannel, "[[maxOpenConnections \"50\"]]")

                            debugLogger.log("Modify complete.")
                            infoLogger.log("Completed configuration of TCP channel %s.") % (tcpName)
                        else:
                            continue
                        #endif
                    except:
                        errorLogger.log("An error occurred while configuring TCP Channel %s for the provided server. Please review logs.") % (tcpName)

                        raise Exception ("An error occurred while configuring TCP Channel %s for the provided server. Please review logs.") % (tcpName)
                    #endtry
                #endif
             #endfor
        else:
            errorLogger.log("No TCP channels were found for the provided server.")

            raise Exception ("No TCP channels were found for the provided server.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureHTTPChannels():
    debugLogger.log(targetServer)

    if (len(targetServer) != 0):
        targetHTTPChannels = AdminConfig.list('HTTPInboundChannel', targetServer).split(lineSplit)

        debugLogger.log(targetHTTPChannels)

        if (len(targetHTTPChannels) != 0):
            for httpChannel in (targetHTTPChannels):
                debugLogger.log(httpChannel)

                httpName = tcpChannel.split("(")[0]

                debugLogger.log(httpName)

                if (len(httpName) != 0):
                    try:
                        if (httpName == "HTTP_2"):
                            debugLogger.log("Calling AdminConfig.modify()")
                            debugLogger.log("EXEC: AdminConfig.modify(httpChannel, \"[[maximumPersistentRequests \"-1\"] [persistentTimeout \"300\"] [enableLogging \"true\"]]\")")

                            AdminConfig.modify(httpChannel, "[[maximumPersistentRequests \"-1\"] [persistentTimeout \"300\"] [enableLogging \"true\"]]")

                            debugLogger.log("Calling AdminConfig.create()")
                            debugLogger.log("EXEC: AdminConfig.create('Property', httpChannel, \"[[validationExpression \"\"] [name \"RemoveServerHeader\"] [description \"\"] [value \"true\"] [required \"false\"]]\")")

                            AdminConfig.create('Property', httpChannel, "[[validationExpression \"\"] [name \"RemoveServerHeader\"] [description \"\"] [value \"true\"] [required \"false\"]]")

                            debugLogger.log("Modify complete.")
                            infoLogger.log("Completed configuration of HTTP channel %s.") % (httpName)
                        else:
                            continue
                        #endif
                    except:
                        errorLogger.log("An error occurred while configuring HTTP Channel %s for the provided server. Please review logs.") % (tcpName)

                        raise Exception ("An error occurred while configuring HTTP Channel %s for the provided server. Please review logs.") % (tcpName)
                    #endtry
                #endif
             #endfor
        else:
            errorLogger.log("No HTTP channels were found for the provided server.")

            raise Exception ("No HTTP channels were found for the provided server.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureContainerChains():
    debugLogger.log(targetServer)

    if (len(targetServer) != 0):
        targetTransport = AdminConfig.list('TransportChannelService', targetServer)

        debugLogger.log(targetTransport)

        if (len(targetTransport) != 0):
            containerChains = AdminTask.listChains(targetTransport, '[-acceptorFilter WebContainerInboundChannel]').split(lineSplit)

            debugLogger.debug(containerChains)

            for chain in (containerChains):
                debugLogger.log(chain)

                chainName = chain.split("(")[0]

                debugLogger.log(chainName)

                if (len(chainName) != 0):
                    try:
                        if (chainName == "WCInboundDefault"):
                            continue
                        elif (chainName == "WCInboundDefault"):
                            continue
                        elif (chainName == "WCInboundAdminSecure"):
                            continue
                        else:    
                            debugLogger.log("Calling AdminTask.deleteChain()")
                            debugLogger.log("EXEC: AdminTask.deleteChain(chain, \"[-deleteChannels \"true\"]\")")

                            AdminTask.deleteChain(chain, "-deleteChannels \"true\"]")

                            debugLogger.log("Modify complete.")
                            infoLogger.log("Completed configuration of container chain %s.") % (chainName)
                        #endif
                    except:
                        errorLogger.log("An error occurred while configuring container chain %s for the provided server. Please review logs.") % (chainName)

                        raise Exception ("An error occurred while configuring container chain %s for the provided server. Please review logs.") % (chainName)
                    #endtry
                #endif
             #endfor
        else:
            errorLogger.log("No container chains were found for the provided server.")

            raise Exception ("No container chains were found for the provided server.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureTuningParams():
    debugLogger.log(targetServer)

    if (len(targetServer) != 0):
        targetTuning = AdminConfig.list('TuningParams', targetServer)

        debugLogger.log(targetTuning)

        if (len(targetTuning) != 0):
            try:
                debugLogger.log("Calling AdminConfig.modify")
                debugLogger.log("EXEC: AdminConfig.modify(targetTuning, \"[[writeContents \"ONLY_UPDATED_ATTRIBUTES\"] [writeFrequency \"END_OF_SERVLET_SERVICE\"] [scheduleInvalidation \"false\"] [invalidationTimeout \"60\"]]\")")

                AdminConfig.modify(targetTuning, "[[writeContents \"ONLY_UPDATED_ATTRIBUTES\"] [writeFrequency \"END_OF_SERVLET_SERVICE\"] [scheduleInvalidation \"false\"] [invalidationTimeout \"60\"]]")

                debugLogger.log("Modify complete.")
                infoLogger.log("Completed configuration of tuning parameters %s.") % (targetTuning)
            except:
                errorLogger.log("An error occurred while configuring tuning parameters for the provided server. Please review logs.")

                raise Exception ("An error occurred while configuring tuning parameters for the provided server. Please review logs.")
            #endtry
        else:
            errorLogger.log("No tuning parameters were found for the provided server.")

            raise Exception ("No tuning parameters were found for the provided server.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def configureSessionManager():
    debugLogger.log(targetServer)

    if (len(targetServer) != 0):
        targetSessionManager = AdminConfig.list('SessionManager', targetServer)

        debugLogger.log(targetSessionManager)

        if (len(targetSessionManager) != 0):
            try:
                debugLogger.log("Calling AdminConfig.modify")
                debugLogger.log("EXEC: AdminConfig.modify(targetSessionManager, \"[[enableSecurityIntegration \"true\"] [maxWaitTime \"5\"] [allowSerializedSesssionAccess \"false\"] [enableUrlRewriting \"false\"] [enable \"true\"] [accessSessionOnTimeout \"true\"] [enableSSLTracking \"true\"] [enableCookies \"true\"]]\")")

                AdminConfig.modify(targetSessionManager, "[[enableSecurityIntegration \"true\"] [maxWaitTime \"5\"] [allowSerializedSesssionAccess \"false\"] [enableUrlRewriting \"false\"] [enable \"true\"] [accessSessionOnTimeout \"true\"] [enableSSLTracking \"true\"] [enableCookies \"true\"]]")

                debugLogger.log("Modify complete.")
                infoLogger.log("Completed configuration of session manager %s.") % (targetSessionManager)
            except:
                errorLogger.log("An error occurred while configuring the session manager for the provided server. Please review logs.")

                raise Exception ("An error occurred while configuring the session manager for the provided server. Please review logs.")
            #endtry
        else:
            errorLogger.log("No session manager were found for the provided server.")

            raise Exception ("No session manager were found for the provided server.")
        #endif
    else:
        errorLogger.log("No server was provided to configure.")

        raise Exception ("No server was provided to configure.")
    #endif
#enddef

def serverStatus():
    serverState = "UNKNOWN"

    debugLogger.debug(serverState)

    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        debugLogger.log(properties)

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            debugLogger.log(nodeName)
            debugLogger.log(serverName)

            if ((nodeName) and (serverName)):
                targetServer = AdminConfig.getid('/Node:%s/Server:%s/') % (nodeName, serverName)

                debugLogger.debug(targetServer)

                if (len(targetServer) != 0):
                    try:
                        debugLogger.log("Calling AdminControl.getAttribute()")
                        debugLogger.log("EXEC: AdminControl.getAttribute(targetServer, \"state\")")

                        serverState = AdminControl.getAttribute(targetServer, "state")

                        debugLogger.debug(serverState)
                        infoLogger.log("Current server state of %s on node %s is: %s.") % (serverName, nodeName, serverState)
                        consoleLogger.info("Current server state of %s on node %s is: %s.") % (serverName, nodeName, serverState)
                    except:
                        (exception, parms) = sys.exc_info()

                        errorLogger.log("An error occurred trying to determine the state the provided server %s on node %s: %s %s") % (serverName, nodeName, str(exception), str(parms))
                        consoleLogger.error("An error occurred trying to determine the state the provided server %s on node %s") % (serverName, nodeName)
                    #endtry
                else:
                    errorLogger.log("No server named %s was found on node %s.") % (serverName, nodeName)
                    consoleLogger.error("No server named %s was found on node %s.") % (serverName, nodeName)
                #endif
            else:
                errorLogger.log("No node/server information was found in the provided configuration file.")
                consoleLogger.error("No node/server information was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No server information section was found in the provided configuration file.")
            consoleLogger.error("No server information section was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log("No configuration file was provided.")
        consoleLogger.error("No configuration file was provided.")
    #endif

    return serverState
#enddef

def startServer(startWaitTime = 10):
    debugLogger.debug(startWaitTime)

    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        debugLogger.log(properties)

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            debugLogger.log(nodeName)
            debugLogger.log(serverName)

            if ((nodeName) and (serverName)):
                targetServer = AdminConfig.getid('/Node:%s/Server:%s/') % (nodeName, serverName)

                debugLogger.log(targetServer)

                if (len(targetServer) != 0):
                    startProperties = readConfigurationFileSection(configFile, "server-start-options")

                    debugLogger.log(startProperties)

                    if (len(startProperties != 0)):
                        startWaitTimeSecs = startProperties["start-wait-time"] or startWaitTime

                        debugLogger.log(startWaitTimeSecs)

                        try:
                            debugLogger.debug("Calling AdminControl.startServer()")
                            debugLogger.debug("EXEC: AdminControl.startServer(nodeName, serverName, startWaitTimeSecs)")

                            AdminControl.startServer(nodeName, serverName, startWaitTimeSecs)

                            infoLogger.log("Startup for server %s on note %s initiated.") % (serverName, nodeName)
                            consoleLogger.info("Startup for server %s on note %s initiated.") % (serverName, nodeName)
                        except:
                            (exception, parms) = sys.exc_info()

                            errorLogger.log("An error occurred trying to determine the state the provided server %s on node %s: %s %s") % (serverName, nodeName, str(exception), str(parms))
                            consoleLogger.error("An error occurred trying to determine the state the provided server %s on node %s") % (serverName, nodeName)
                        #endtry
                    else:
                        errorLogger.log("No server startup options were found.")
                        consoleLogger.error("No server startup options were found.")
                    #endif
                else:
                    errorLogger.log("No server named %s was found on node %s.") % (serverName, nodeName)
                    consoleLogger.error("No server named %s was found on node %s.") % (serverName, nodeName)
                #endif
            else:
                errorLogger.log("No node/server information was found in the provided configuration file.")
                consoleLogger.error("No node/server information was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No server information section was found in the provided configuration file.")
            consoleLogger.error("No server information section was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log("No configuration file was provided.")
        consoleLogger.error("No configuration file was provided.")
    #endif
#enddef

def stopServer(immediate = False, terminate = False):
    debugLogger.debug(immediate)
    debugLogger.debug(terminate)

    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        debugLogger.log(properties)

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            debugLogger.log(nodeName)
            debugLogger.log(serverName)

            if ((nodeName) and (serverName)):
                stopProperties = readConfigurationFileSection(configFile, "server-stop-options")

                debugLogger.log(stopProperties)

                if (len(stopProperties != 0)):
                    isImmediateStop = stopProperties["immediate-stop"] or immediate
                    isTerminateStop = stopProperties["terminate-stop"] or terminate

                    debugLogger.log(isImmediateStop)
                    debugLogger.log(isTerminateStop)

                    try:
                        debugLogger.debug("Calling AdminControl.stopServer()")

                        if (isImmediateStop):
                            debugLogger.debug("EXEC: AdminControl.stopServer(nodeName, serverName, \"immediate\")")

                            AdminControl.stopServer(nodeName, serverName, "immediate")
                        elif (isTerminateStop):
                            debugLogger.debug("EXEC: AdminControl.stopServer(nodeName, serverName, \"terminate\")")

                            AdminControl.stopServer(nodeName, serverName, "terminate")
                        else:
                            debugLogger.debug("EXEC: AdminControl.stopServer(nodeName, serverName)")

                            AdminControl.stopServer(nodeName, serverName)
                        #endif

                        infoLogger.log("Shutdown for server %s on note %s initiated.") % (serverName, nodeName)
                        consoleLogger.info("Shutdown for server %s on note %s initiated.") % (serverName, nodeName)
                    except:
                        (exception, parms) = sys.exc_info()

                        if (-1 != repr( parms ).find("already running")):
                            return
                        else:
                            errorLogger.log("An error occurred while stopping server %s on node %s: %s %s") % (serverName, nodeName, str(exception), str(parms))
                            consoleLogger.info("An error occurred while stopping server %s on node %s.") % (serverName, nodeName)
                        #endif
                    #endtry
                else:
                    errorLogger.log("No server shutdown settings were found in the provided configuration file.")
                    consoleLogger.error("No server shutdown settings were found in the provided configuration file.")
                #endif
            else:
                errorLogger.log("No node/server information was found in the provided configuration file.")
                consoleLogger.error("No node/server information was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No server information section was found in the provided configuration file.")
            consoleLogger.error("No server information section was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log("No configuration file was provided.")
        consoleLogger.error("No configuration file was provided.")
    #endif
#enddef

def restartServer(restartTimeout = 300):
    isRunning = "UNKNOWN"

    debugLogger.debug(restartTimeout)
    debugLogger.debug(isRunning)

    if (len(configFile) != 0):
        properties = readConfigurationFileSection(configFile, "server-information")

        debugLogger.log(properties)

        if (len(properties) != 0):
            nodeName = properties["node-name"]
            serverName = properties["server-name"]

            debugLogger.log(nodeName)
            debugLogger.log(serverName)

            if ((nodeName) and (serverName)):
                targetServer = AdminConfig.getid('/Node:%s/Server:%s/') % (nodeName, serverName)

                debugLogger.log(targetServer)

                if (len(targetServer) != 0):
                    restartProperties = readConfigurationFileSection(configFile, "server-restart-options")

                    debugLogger.log(restartProperties)

                    if (len(restartProperties != 0)):
                        restartTimeoutSecs = startProperties["restart-timeout"] or restartTimeout

                        debugLogger.log(restartTimeoutSecs)

                        try:
                            AdminControl.invoke(targetServer, "restart")

                            elapsedTime = 0

                            debugLogger.log(elapsedTime)

                            if (restartTimeoutSecs > 0):
                                sleepTime = 5
                                isRunning = serverStatus(nodeName, serverName)

                                debugLogger.log(sleepTime)
                                debugLogger.log(isRunning)

                                while ((isRunning) and (elapsedTimeSeconds < restartTimeout)):
                                    debugLogger.log("Waiting for restart. Sleeping for %d..") % (sleepTime)

                                    time.sleep(sleepTime)

                                    elapsedTimeSeconds = elapsedTimeSeconds + sleepTime
                                    isRunning = serverStatus(nodeName, serverName)

                                    debugLogger.log(elapsedTimeSeconds)
                                    debugLogger.log(isRunning)
                                #endwhile

                                while ((not isRunning) and (elapsedTimeSeconds < restartTimeoutSecs)):
                                    debugLogger.log("Waiting for restart. Sleeping for %d..") % (sleepTime)
                                    infoLogger.log("Waiting %d of %d seconds for %s to restart. isRunning = %s" % (elapsedTimeSeconds, restartTimeoutSecs, serverName, isRunning,))
                                    consoleLogger.info("Waiting %d of %d seconds for %s to restart. isRunning = %s" % (elapsedTimeSeconds, restartTimeoutSecs, serverName, isRunning,))

                                    time.sleep(sleepTime)

                                    elapsedTimeSeconds = elapsedTimeSeconds + sleepTime
                                    isRunning = serverStatus(nodeName, serverName)

                                    debugLogger.log(elapsedTimeSeconds)
                                    debugLogger.log(isRunning)
                                #endwhile
                            #endif

                            isRunning = serverStatus(nodeName, serverName)

                            debugLogger.log(isRunning)
                            infoLogger.log("Restart completed for server %s on node %s. Elapsed time: %d.") % (serverName, nodeName, elapsedTimeSeconds)
                            consoleLogger.info("Restart completed for server %s on node %s. Elapsed time: %d.") % (serverName, nodeName, elapsedTimeSeconds)
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            if (-1 != repr( parms ).find("already running")):
                                return
                            else:
                                erorLogger.log("An error occurred restarting server %s: %s %s" % (targetServer, str(exception),str(parms)))
                                consoleLogger.error("An error occurred restarting server %s on node %s.") % (serverName, nodeName)
                            #endif
                        #endtry
                else:
                    errorLogger.log("No server named %s was found on node %s.") % (serverName, nodeName)
                    consoleLogger.error("No server named %s was found on node %s.") % (serverName, nodeName)
                #endif
            else:
                errorLogger.log("No node/server information was found in the provided configuration file.")
                consoleLogger.error("No node/server information was found in the provided configuration file.")
            #endif
        else:
            errorLogger.log("No server information section was found in the provided configuration file.")
            consoleLogger.error("No server information section was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log("No configuration file was provided.")
        consoleLogger.error("No configuration file was provided.")
    #endif

    return isRunning
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
