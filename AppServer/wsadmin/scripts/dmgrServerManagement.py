#==============================================================================
#
#          FILE:  dmgrServerManagement.py
#         USAGE:  wsadmin.sh -lang jython -p wsadmin.properties \
#                   -f dmgrServerManagement.py configure-dmgr <config-file>
#     ARGUMENTS:  configure-dmgr, <config-file>
#   DESCRIPTION:  Configures a target deployment manager with provided options.
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

configureLogging(str("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties"))
consoleInfoLogger = logging.getLogger(str("console-out-logger"))
consoleErrorLogger = logging.getLogger(str("console-err-logger"))
errorLogger = logging.getLogger(str("error-logger"))
debugLogger = logging.getLogger(str("debug-logger"))
infoLogger = logging.getLogger(str("info-logger"))

global configFile

lineSplit = java.lang.System.getProperty(str("line.separator"))
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureDeploymentManager():
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
                    infoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))
                    consoleInfoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))

                    configureWebContainer(targetServer)
                    setServerTrace(targetServer)
                    setProcessExec(targetServer)
                    setJVMProperties()

                    infoLogger.log(logging.INFO, str("Completed configuration for deployment manager {0}.").format(serverName))
                    consoleInfoLogger.log(logging.INFO, str("Completed configuration for deployment manager {0}.").format(serverName))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred performing configuration steps for deployment manager: {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred performing configuration steps for deployment manager {0}. Please review logs.").format(serverName))

                    raise Exception(str("An error occurred updating the web container for the provided server. Please review logs."))
                finally:
                    debugLogger.log(logging.DEBUG, str("Saving workspace changes and synchronizing the cell.."))

                    saveWorkspaceChanges()
                    syncAllNodes(nodeList, targetCell)

                    infoLogger.log(logging.INFO, str("Workspace changes have been saved and the cell has been synchronized."))
                    consoleInfoLogger.log(logging.INFO, str("Workspace changes have been saved and the cell has been synchronized."))
                #endfor
            else:
                errorLogger.log(logging.ERROR, str("No deployment manager was found with node name {0} and server name {1}}.").format(nodeName, serverName))
                consoleErrorLogger.log(logging.ERROR, str("No deployment manager was found with node name {0} and server name {1}.").format(nodeName, serverName))
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

def configureWebContainer(targetServer):
    debugLogger.log(logging.DEBUG, str(targetServer))

    if (len(targetServer) != 0):
        targetWebContainer = AdminConfig.list(str("WebContainer"), targetServer)

        debugLogger.log(logging.DEBUG, str(targetWebContainer))

        if (len(targetWebContainer) != 0):
            try:
                debugLogger.log(logging.DEBUG, str("Calling AdminConfig.create()"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.create(str(\"Property\"), targetWebContainer, str(\"[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.extractHostHeaderPort\"] [description \"\"] [value \"true\"] [required \"false\"]]\"))"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.create(str(\"Property\"), targetWebContainer, str(\"[[validationExpression \"\"] [name \"trusthostheaderport\"] [description \"\"] [value \"true\"] [required \"false\"]]\"))"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.create(str(\"Property\"), targetWebContainer, str(\"[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.invokefilterscompatibility\"] [description \"\"] [value \"true\"] [required \"false\"]]\"))"))

                AdminConfig.create(str("Property"), targetWebContainer, str("[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.extractHostHeaderPort\"] [description \"\"] [value \"true\"] [required \"false\"]]"))
                AdminConfig.create(str("Property"), targetWebContainer, str("[[validationExpression \"\"] [name \"trusthostheaderport\"] [description \"\"] [value \"true\"] [required \"false\"]]"))
                AdminConfig.create(str("Property"), targetWebContainer, str("[[validationExpression \"\"] [name \"com.ibm.ws.webcontainer.invokefilterscompatibility\"] [description \"\"] [value \"true\"] [required \"false\"]]"))

                debugLogger.log(logging.DEBUG, str("Modify complete."))
                infoLogger.log(logging.INFO, str("Completed configuration of target Web Container {0}.").format(targetWebContainer))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred updating the web container for the provided server: {0}: {1} {2}").format(targetServer, str(exception), str(parms)))

                raise Exception(str("An error occurred updating the web container for the provided server. Please review logs."))
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No web container was found for the provided server."))

            raise Exception(str("No web container was found for the provided server."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No server was provided to configure."))

        raise Exception(str("No server was provided to configure."))
    #endif
#enddef

def configureHAManager(targetServer):
    debugLogger.log(logging.DEBUG, str(targetServer))

    if (len(targetServer) != 0):
        debugLogger.log(logging.DEBUG, str(targetServer))

        if (len(configFile) != 0):
            isHAEnabled = returnPropertyConfiguration(configFile, str("server-hamanager"), str("enabled")) or "false"
            haManager = AdminConfig.list(str("HAManagerService"), targetServer)

            debugLogger.log(logging.DEBUG, str(isHAEnabled))
            debugLogger.log(logging.DEBUG, str(haManager))

            if (len(haManager) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(haManager, str(\"[[enable \"{0}\"] [activateEnabled \"true\"] [isAlivePeriodSec \"120\"] [transportBufferSize \"10\"] [activateEnabled \"true\"]]\").format(isHAEnabled))"))

                    AdminConfig.modify(haManager, str("[[enable \"{0}\"] [activateEnabled \"true\"] [isAlivePeriodSec \"120\"] [transportBufferSize \"10\"] [activateEnabled \"true\"]]").format(isHAEnabled))

                    debugLogger.log(logging.DEBUG, str("Modify complete."))
                    infoLogger.log(logging.INFO, str("Completed configuration of target HA Manager {0}.".format(haManager)))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating the HA Manager for the provided server: {0}: {1} {2}".format(targetServer, str(exception), str(parms))))

                    raise Exception(str("An error occurred updating the HA Manager for the provided server. Please review logs."))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No HA Manager was found for the provided server."))

                raise Exception(str("No HA Manager was found for the provided server."))
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

def setServerTrace(targetServer):
    debugLogger.log(logging.DEBUG, str(targetServer))

    if (len(targetServer) != 0):
        debugLogger.log(logging.DEBUG, str(targetServer))

        if (len(configFile) != 0):
            traceSpecificationValue = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("trace-spec")) or "*=info"
            traceOutputType = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("output-type")) or "SPECIFIED_FILE"
            maxBackupFileCount = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("max-backup-files")) or 50
            maxTraceFileSize = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("max-file-size")) or 50
            traceFileNameAndPath = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("output-type")) or "\${SERVER_LOG_ROOT}/trace.log"
            targetTraceService = AdminConfig.list(str("TraceService"), targetServer)

            debugLogger.log(logging.DEBUG, str(traceSpecificationValue))
            debugLogger.log(logging.DEBUG, str(traceOutputType))
            debugLogger.log(logging.DEBUG, str(maxBackupFileCount))
            debugLogger.log(logging.DEBUG, str(maxTraceFileSize))
            debugLogger.log(logging.DEBUG, str(traceFileNameAndPath))
            debugLogger.log(logging.DEBUG, str(targetTraceService))

            if (len(targetTraceService) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetTraceService, \"[[startupTraceSpecification, \"{0}\"]]\".format(traceSpecificationValue))"))
                    debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetTraceService, \"[[traceOutputType, \"{0}\"]]\".format(traceOutputType))"))
                    debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(targetTraceService, \"[[traceLog, [[fileName, \"{0}\"], [maxNumberOfBackupFiles, \"{1}\"], [rolloverSize, \"{2}\"]]]\".format(traceFileNameAndPath, maxBackupFileCount, maxTraceFileSize))"))

                    AdminConfig.modify(targetTraceService, str("[[startupTraceSpecification, \"{0}}\"]]").format(traceSpecificationValue))
                    AdminConfig.modify(targetTraceService, str("[[traceOutputType, \"{0}\"]]").format(traceOutputType))
                    AdminConfig.modify(targetTraceService, str("[[traceLog, [[fileName, \"{0}\"], [maxNumberOfBackupFiles, \"{1}\"], [rolloverSize, \"{2}\"]]]").format(traceFileNameAndPath, maxBackupFileCount, maxTraceFileSize))

                    debugLogger.log(logging.DEBUG, str("Modify complete."))
                    infoLogger.log(logging.INFO, str("Completed configuration of trace service {0}.").format(targetTraceService))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating the trace service for the provided server: {0}: {1} {2}").format(targetServer, str(exception), str(parms)))

                    raise Exception(str("An error occurred updating the trace service for the provided server. Please review logs."))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No trace service was found for the provided server."))

                raise Exception(str("No trace service was found for the provided server."))
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

def setProcessExec(targetServer):
    debugLogger.log(logging.DEBUG, str(targetServer))

    if (len(targetServer) != 0):
        if (len(configFile) != 0):
            runUserName = returnPropertyConfiguration(configFile, str("server-process-settings"), str("run-user")) or ""
            runGroupName = returnPropertyConfiguration(configFile, str("server-process-settings"), str("run-group")) or ""
            processExec = AdminConfig.list(str("ProcessExecution"), targetServer)

            debugLogger.log(logging.DEBUG, str(runUserName))
            debugLogger.log(logging.DEBUG, str(runGroupName))
            debugLogger.log(logging.DEBUG, str(processExec))

            if (len(processExec) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))

                    if ((len(runUserName) != 0) and (len(runGroupName) != 0)):
                        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(processExec, str(\"[[runAsUser \"{0}\"] [runAsGroup \"{1}\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]\").format(runUserName, runGroupName))"))

                        AdminConfig.modify(processExec, str("[[runAsUser \"{0}\"] [runAsGroup \"{1}\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]").format(runUserName, runGroupName))
                    elif (len(runUserName) != 0):
                        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(processExec, str(\"[[runAsUser \"{0}\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]\").format(runUserName))"))

                        AdminConfig.modify(processExec, str("[[runAsUser \"{0}\"] [runInProcessGroup \"0\"] [processPriority \"20\"] [umask \"022\"]]").format(runUserName))
                    #end if

                    debugLogger.log(logging.DEBUG, str("Modify complete."))
                    infoLogger.log(logging.INFO, str("Completed configuration of process execution {0}.").format(processExec))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating process execution for the provided server: {0}: {1} {2}").format(targetServer, str(exception), str(parms)))

                    raise Exception(str("An error occurred updating process execution for the provided server. Please review logs."))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No process execution was found for the provided server."))

                raise Exception(str("No process execution was found for the provided server."))
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

def setJVMProperties():
    genericJvmArgs = ("-Dibm.stream.nio=true -Djava.io.tmpdir=${WAS_TEMP_DIR} -Xdump:stack:events=allocation,filter=#10m -Xgcpolicy:gencon "
        "-Dcom.ibm.websphere.alarmthreadmonitor.threshold.millis=40000 -Xshareclasses:none -Dsun.reflect.inflationThreshold=0 -Djava.security.egd=file:/dev/./urandom "
        "-Dcom.sun.jndi.ldap.connect.pool.maxsize=200 -Dcom.sun.jndi.ldap.connect.pool.prefsize=200 -Dcom.sun.jndi.ldap.connect.pool.timeout=3000 "
        "-Djava.net.preferIPv4Stack=true -Dsun.net.inetaddr.ttl=600 -Djava.awt.headless=true -Djava.compiler=NONE -Xnoagent "
        "-Xrunjdwp=dt_socket,server=y,suspend=n,address=7792 -Dcom.ibm.cacheLocalHost=true -Dcom.ibm.xml.xlxp.jaxb.opti.level=3")

    debugLogger.log(logging.DEBUG, str(genericJvmArgs))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))

        debugLogger.log(logging.DEBUG, nodeName)
        debugLogger.log(logging.DEBUG, serverName)

        if ((serverName) and (nodeName)):
            minHeap = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("initial-heap-size")) or 2048
            maxHeap = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("max-heap-size")) or 2048
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, str(minHeap))
            debugLogger.log(logging.DEBUG, str(maxHeap))
            debugLogger.log(logging.DEBUG, str(targetServer))

            if (len(targetServer) != 0):
                try:
                    debugLogger.log(logging.DEBUG, str("Calling AdminConfig.modify()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: AdminTask.setJVMProperties(str(\"[-serverName {0} -nodeName {1} -verboseModeGarbageCollection true -initialHeapSize {2} -maximumHeapSize + {3} -debugMode false -genericJvmArguments {4}}]\").format(serverName, nodeName, minHeap, maxHeap))"))

                    AdminTask.setJVMProperties(str("[-serverName {0} -nodeName {1} -verboseModeGarbageCollection true -initialHeapSize {2} -maximumHeapSize + {3} -debugMode false -genericJvmArguments {4}}]").format(serverName, nodeName, minHeap, maxHeap))

                    debugLogger.log(logging.DEBUG, str("Modify complete."))
                    infoLogger.log(logging.INFO, str("Completed configuration of JVM properties for server {0}.").format(targetServer))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating JVM configuration for the provided server: {0}: {1} {2}").format(targetServer, str(exception), str(parms)))

                    raise Exception(str("An error occurred updating JVM configuration for the provided server. Please review logs."))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No server with name {0} was found on node {1}").format(serverName, nodeName))

                raise Exception(str("No server with name {0} was found on node {1}").format(serverName, nodeName))
            #endif
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))

            raise Exception(str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))

        raise Exception(str("No configuration file was provided."))
    #endif
#enddef

def printHelp():
    print(str("This script performs server management tasks."))
    print(str("Execution: wsadmin.sh -lang jython -f configureDeploymentManager.py <option> <configuration file>"))
    print(str("Options are: "))
    print(str("    configure-dmgr: Performs configuration tasks for a provided deployment manager."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain the server and node names."))
    print(str("                [server-trace-settings]"))
    print(str("                    This section may contain a value to configure startup trace specifications. If no value is provided, the default value is \"*=info\"."))
    print(str("                    This section may contain a value to configure the trace output type. If no value is provided, the default value is \"SPECIFIED_FILE\"."))
    print(str("                    This section may contain a value to configure the maximum number of trace backup files. If no value is provided, the default value is 50."))
    print(str("                    This section may contain a value to configure the maximum size of the trace file before it is rolled over. If no value is provided, the default value is 50."))
    print(str("                    This section may contain a value to configure the trace filename. If no value is provided, the default value is \"'$' + ' {LOG_ROOT}/' + '$' + '{SERVER}/trace.log'."))
    print(str("                [server-process-settings]"))
    print(str("                    This section may contain a value to configure the user to run the server as. If no value is provided, the \"runAsUser\" entry is not configured."))
    print(str("                    This section may contain a value to configure the group to run the server as. If no value is provided, the \"runAsGroup\" entry is not configured."))
    print(str("                [server-jvm-settings]"))
    print(str("                    This section may contain a value to configure the initial JVM heap size. If no value is provided, the default value is 2048."))
    print(str("                    This section may contain a value to configure the maximum JVM heap size. If no value is provided, the default value is 2048."))
#enddef

##################################
# main
#################################
if (len(sys.argv) == 0):
    printHelp()
else:
    configFile = sys.argv[1]

    if (os.path.exists(configFile)) and (os.access(configFile, os.R_OK)):
        configureDeploymentManager()
    else:
        print(str("The provided configuration file either does not exist or cannot be read."))
    #endif
#endif
