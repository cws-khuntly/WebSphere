#==============================================================================
#
#          FILE:  manageServers.py
#         USAGE:  wsadmin.sh -lang jython -p wsadmin.properties \
#                   -f manageServers.py <option> <config-file>
#     ARGUMENTS:  <option>, <config-file>
#   DESCRIPTION:  Configures servers with provided options.
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
errorLogger = logging.getLogger(str("error-logger"))
debugLogger = logging.getLogger(str("debug-logger"))
infoLogger = logging.getLogger(str("info-logger"))
consoleInfoLogger = logging.getLogger(str("info-logger"))
consoleErrorLogger = logging.getLogger(str("info-logger"))

lineSplit = java.lang.System.getProperty(str("line.separator"))
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureDeploymentManager():
    debugLogger.log(logging.DEBUG, str("ENTER: configureDeploymentManager()"))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, str(targetServer))

            if (len(targetServer) != 0):
                infoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))
                consoleInfoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))

                #
                # Enable/disable HAManager
                #
                isEnabled = returnPropertyConfiguration(configFile, str("server-hamanager"), str("enabled"))
                targetHAManager = AdminConfig.list("HAManagerService", targetServer)

                debugLogger.log(logging.DEBUG, str(isEnabled))
                debugLogger.log(logging.DEBUG, str(targetHAManager))

                if ((len(targetHAManager) != 0) and (len(isEnabled) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureHAManager()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureHAManager(targetHAManager, isEnabled)"))

                        configureHAManager(targetHAManager, isEnabled)

                        infoLogger.log(logging.INFO, str("Completed configuration of HAManager service {0} on server {1}").format(targetHAManager, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of HAManager service on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring HAManager service {0} on server {1}: {2} {3}").format(targetHAManager, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the HAManager service on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure trace service
                #
                traceSpec = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("trace-spec"))
                outputType = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("output-type"))
                maxBackupFiles = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("max-backup-files"))
                maxFileSize = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("max-file-size"))
                traceFileName = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("trace-file-name"))
                targetTraceService = AdminConfig.list("TraceService", targetServer)

                debugLogger.log(logging.DEBUG, str(traceSpec))
                debugLogger.log(logging.DEBUG, str(outputType))
                debugLogger.log(logging.DEBUG, str(maxBackupFiles))
                debugLogger.log(logging.DEBUG, str(maxFileSize))
                debugLogger.log(logging.DEBUG, str(traceFileName))
                debugLogger.log(logging.DEBUG, str(outputType))
                debugLogger.log(logging.DEBUG, str(targetTraceService))

                if ((len(targetTraceService) != 0) and (len(traceSpec) != 0) and (len(outputType) != 0)
                    and (len(maxBackupFiles) != 0) and (len(maxFileSize) != 0) and (len(traceFileName) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setServerTrace()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)"))

                        setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)

                        infoLogger.log(logging.INFO, str("Completed configuration of trace service {0} on server {1}").format(targetTraceService, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of trace service on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring trace service {0} on server {1}: {2} {3}").format(targetTraceService, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the trace service on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure process execution
                #
                runAsUser = returnPropertyConfiguration(configFile, str("server-process-settings"), str("run-user"))
                runAsGroup = returnPropertyConfiguration(configFile, str("server-process-settings"), str("run-group"))
                targetProcessExec = AdminConfig.list("ProcessExecution", targetServer)

                debugLogger.log(logging.DEBUG, str(runAsUser))
                debugLogger.log(logging.DEBUG, str(runAsGroup))
                debugLogger.log(logging.DEBUG, str(targetProcessExec))

                if ((len(targetProcessExec) != 0) and (len(runAsGroup) != 0) and (len(runAsGroup) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setProcessExec()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setProcessExec(targetProcessExec, runAsUser, runAsGroup)"))

                        setProcessExec(targetProcessExec, runAsUser, runAsGroup)

                        infoLogger.log(logging.INFO, str("Completed configuration of process execution {0} on server {1}").format(targetTraceService, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of process execution on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring process execution {0} on server {1}: {2} {3}").format(targetProcessExec, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure JVM properties
                #
                initialHeapSize = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("initial-heap-size")) or 1024
                maxHeapSize = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("max-heap-size")) or 1024
                genericJVMArguments = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("jvm-arguments")) or ""
                hprofArguments = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("hprof-arguments")) or ""

                debugLogger.log(logging.DEBUG, str(initialHeapSize))
                debugLogger.log(logging.DEBUG, str(maxHeapSize))
                debugLogger.log(logging.DEBUG, str(genericJVMArguments))
                debugLogger.log(logging.DEBUG, str(hprofArguments))

                if ((len(initialHeapSize) != 0) and (len(maxHeapSize) != 0) and (len(genericJVMArguments) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setJVMProperties()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)"))

                        setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)

                        infoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring JVM properties on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Save workspace changes
                #
                try:
                    debugLogger.log(logging.DEBUG, str("Calling saveWorkspaceChanges()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: saveWorkspaceChanges()"))

                    saveWorkspaceChanges()

                    debugLogger.log(logging.DEBUG, str("All workspace changes saved to master repository."))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository: {0} {1}").format(str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository. Please review logs."))
                #endtry

                #
                # Synchronize nodes
                #
                try:
                    debugLogger.log(logging.DEBUG, str("Calling syncNodes()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: syncNodes(nodeList, targetCell)"))

                    syncNodes(nodeList, targetCell)

                    debugLogger.log(logging.DEBUG, str("Node synchronization complete for cell {0}.").format(targetCell))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred synchronizing changes to cell {0}: {1} {2}").format(targetCell, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred synchronizing changes to cell {0}. Please review logs.").format(targetCell))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No deployment manager was found with node name {0} and server name {1}.").format(nodeName, serverName))
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

    debugLogger.log(logging.DEBUG, str("EXIT: configureDeploymentManager()"))
#enddef

def configureNodeAgent():
    debugLogger.log(logging.DEBUG, str("ENTER: configureNodeAgent()"))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, str(targetServer))

            if (len(targetServer) != 0):
                infoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))
                consoleInfoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))

                #
                # Enable/disable HAManager
                #
                isEnabled = returnPropertyConfiguration(configFile, str("server-hamanager"), str("enabled"))
                targetHAManager = AdminConfig.list("HAManagerService", targetServer)

                debugLogger.log(logging.DEBUG, str(isEnabled))
                debugLogger.log(logging.DEBUG, str(targetHAManager))

                if ((len(targetHAManager) != 0) and (len(isEnabled) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureHAManager()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureHAManager(targetHAManager, isEnabled)"))

                        configureHAManager(targetHAManager, isEnabled)

                        infoLogger.log(logging.INFO, str("Completed configuration of HAManager service {0} on server {1}").format(targetHAManager, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of HAManager service on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring HAManager service {0} on server {1}: {2} {3}").format(targetHAManager, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the HAManager service on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure trace service
                #
                traceSpec = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("trace-spec"))
                outputType = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("output-type"))
                maxBackupFiles = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("max-backup-files"))
                maxFileSize = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("max-file-size"))
                traceFileName = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("trace-file-name"))
                targetTraceService = AdminConfig.list("TraceService", targetServer)

                debugLogger.log(logging.DEBUG, str(traceSpec))
                debugLogger.log(logging.DEBUG, str(outputType))
                debugLogger.log(logging.DEBUG, str(maxBackupFiles))
                debugLogger.log(logging.DEBUG, str(maxFileSize))
                debugLogger.log(logging.DEBUG, str(traceFileName))
                debugLogger.log(logging.DEBUG, str(outputType))
                debugLogger.log(logging.DEBUG, str(targetTraceService))

                if ((len(targetTraceService) != 0) and (len(traceSpec) != 0) and (len(outputType) != 0)
                    and (len(maxBackupFiles) != 0) and (len(maxFileSize) != 0) and (len(traceFileName) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setServerTrace()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)"))

                        setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)

                        infoLogger.log(logging.INFO, str("Completed configuration of trace service {0} on server {1}").format(targetTraceService, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of trace service on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring trace service {0} on server {1}: {2} {3}").format(targetTraceService, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the trace service on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure process execution
                #
                runAsUser = returnPropertyConfiguration(configFile, str("server-process-settings"), str("run-user"))
                runAsGroup = returnPropertyConfiguration(configFile, str("server-process-settings"), str("run-group"))
                targetProcessExec = AdminConfig.list("ProcessExecution", targetServer)

                debugLogger.log(logging.DEBUG, str(runAsUser))
                debugLogger.log(logging.DEBUG, str(runAsGroup))
                debugLogger.log(logging.DEBUG, str(targetProcessExec))

                if ((len(targetProcessExec) != 0) and (len(runAsGroup) != 0) and (len(runAsGroup) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setProcessExec()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setProcessExec(targetProcessExec, runAsUser, runAsGroup)"))

                        setProcessExec(targetProcessExec, runAsUser, runAsGroup)

                        infoLogger.log(logging.INFO, str("Completed configuration of process execution {0} on server {1}").format(targetTraceService, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of process execution on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring process execution {0} on server {1}: {2} {3}").format(targetProcessExec, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure JVM properties
                #
                initialHeapSize = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("initial-heap-size")) or 512
                maxHeapSize = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("max-heap-size")) or 512
                genericJVMArguments = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("jvm-arguments")) or ""
                hprofArguments = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("hprof-arguments")) or ""

                debugLogger.log(logging.DEBUG, str(initialHeapSize))
                debugLogger.log(logging.DEBUG, str(maxHeapSize))
                debugLogger.log(logging.DEBUG, str(genericJVMArguments))
                debugLogger.log(logging.DEBUG, str(hprofArguments))

                if ((len(initialHeapSize) != 0) and (len(maxHeapSize) != 0) and (len(genericJVMArguments) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setJVMProperties()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)"))

                        setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)

                        infoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring JVM properties on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Save workspace changes
                #
                try:
                    debugLogger.log(logging.DEBUG, str("Calling saveWorkspaceChanges()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: saveWorkspaceChanges()"))

                    saveWorkspaceChanges()

                    debugLogger.log(logging.DEBUG, str("All workspace changes saved to master repository."))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository: {0} {1}").format(str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository. Please review logs."))
                #endtry

                #
                # Synchronize nodes
                #
                try:
                    debugLogger.log(logging.DEBUG, str("Calling syncNodes()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: syncNodes(nodeList, targetCell)"))

                    syncNodes(nodeList, targetCell)

                    debugLogger.log(logging.DEBUG, str("Node synchronization complete for cell {0}.").format(targetCell))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred synchronizing changes to cell {0}: {1} {2}").format(targetCell, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred synchronizing changes to cell {0}. Please review logs.").format(targetCell))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No deployment manager was found with node name {0} and server name {1}.").format(nodeName, serverName))
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

    debugLogger.log(logging.DEBUG, str("EXIT: configureNodeAgent()"))
#enddef

def configureApplicationServer():
    debugLogger.log(logging.DEBUG, str("ENTER: configureApplicationServer()"))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))
        isPortalServer = returnPropertyConfiguration(configFile, str("server-information"), str("is-portal-server"))

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))
        debugLogger.log(logging.DEBUG, str(isPortalServer))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, str(targetServer))

            if (len(targetServer) != 0):
                infoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))
                consoleInfoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))

                #
                # Enable/disable HAManager
                #
                isEnabled = returnPropertyConfiguration(configFile, str("server-hamanager"), str("enabled"))
                targetHAManager = AdminConfig.list("HAManagerService", targetServer)

                debugLogger.log(logging.DEBUG, str(isEnabled))
                debugLogger.log(logging.DEBUG, str(targetHAManager))

                if ((len(targetHAManager) != 0) and (len(isEnabled) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureHAManager()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureHAManager(targetHAManager, isEnabled)"))

                        configureHAManager(targetHAManager, isEnabled)

                        infoLogger.log(logging.INFO, str("Completed configuration of HAManager service {0} on server {1}").format(targetHAManager, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of HAManager service on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring HAManager service {0} on server {1}: {2} {3}").format(targetHAManager, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the HAManager service on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure trace service
                #
                traceSpec = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("trace-spec")) or "*=info"
                outputType = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("output-type")) or "SPECIFIED_FILE"
                maxBackupFiles = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("max-backup-files")) or "10"
                maxFileSize = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("max-file-size")) or "50"
                traceFileName = returnPropertyConfiguration(configFile, str("server-trace-settings"), str("trace-file-name")) or "${SERVER_LOG_ROOT}/trace.log"
                targetTraceService = AdminConfig.list("TraceService", targetServer)

                debugLogger.log(logging.DEBUG, str(traceSpec))
                debugLogger.log(logging.DEBUG, str(outputType))
                debugLogger.log(logging.DEBUG, str(maxBackupFiles))
                debugLogger.log(logging.DEBUG, str(maxFileSize))
                debugLogger.log(logging.DEBUG, str(traceFileName))
                debugLogger.log(logging.DEBUG, str(outputType))
                debugLogger.log(logging.DEBUG, str(targetTraceService))

                if ((len(targetTraceService) != 0) and (len(traceSpec) != 0) and (len(outputType) != 0)
                    and (len(maxBackupFiles) != 0) and (len(maxFileSize) != 0) and (len(traceFileName) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setServerTrace()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)"))

                        setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)

                        infoLogger.log(logging.INFO, str("Completed configuration of trace service {0} on server {1}").format(targetTraceService, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of trace service on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring trace service {0} on server {1}: {2} {3}").format(targetTraceService, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the trace service on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure process execution
                #
                runAsUser = returnPropertyConfiguration(configFile, str("server-process-settings"), str("run-user"))
                runAsGroup = returnPropertyConfiguration(configFile, str("server-process-settings"), str("run-group"))
                targetProcessExec = AdminConfig.list("ProcessExecution", targetServer)

                debugLogger.log(logging.DEBUG, str(runAsUser))
                debugLogger.log(logging.DEBUG, str(runAsGroup))
                debugLogger.log(logging.DEBUG, str(targetProcessExec))

                if ((len(targetProcessExec) != 0) and (len(runAsGroup) != 0) and (len(runAsGroup) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setProcessExec()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setProcessExec(targetProcessExec, runAsUser, runAsGroup)"))

                        setProcessExec(targetProcessExec, runAsUser, runAsGroup)

                        infoLogger.log(logging.INFO, str("Completed configuration of process execution {0} on server {1}").format(targetTraceService, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of process execution on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring process execution {0} on server {1}: {2} {3}").format(targetProcessExec, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure JVM properties
                #
                initialHeapSize = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("initial-heap-size")) or 2048
                maxHeapSize = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("max-heap-size")) or 2048
                genericJVMArguments = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("jvm-arguments")) or ""
                hprofArguments = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("hprof-arguments")) or ""

                debugLogger.log(logging.DEBUG, str(initialHeapSize))
                debugLogger.log(logging.DEBUG, str(maxHeapSize))
                debugLogger.log(logging.DEBUG, str(genericJVMArguments))
                debugLogger.log(logging.DEBUG, str(hprofArguments))

                if ((len(initialHeapSize) != 0) and (len(maxHeapSize) != 0) and (len(genericJVMArguments) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setJVMProperties()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)"))

                        setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)

                        infoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring JVM properties on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure auto restart policy
                #
                enableAutoRestart = returnPropertyConfiguration(configFile, str("server-auto-restart"), str("restart-policy")) or "STOPPED"
                targetMonitorPolicy = AdminConfig.list("MonitoringPolicy", targetServer)

                debugLogger.log(logging.DEBUG, str(enableAutoRestart))
                debugLogger.log(logging.DEBUG, str(targetMonitorPolicy))

                if (len(targetMonitorPolicy) != 0):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureAutoRestart()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureAutoRestart(targetMonitorPolicy, enableAutoRestart)"))

                        configureAutoRestart(targetMonitorPolicy, enableAutoRestart)

                        infoLogger.log(logging.INFO, str("Completed configuration of monitoring policy on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of monitoring policy on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring monitoring policy {0} on server {1}: {2} {3}").format(targetMonitorPolicy, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the monitoring policy on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure web container
                #
                virtualHost = returnPropertyConfiguration(configFile, str("server-web-container"), str("virtual-host")) or "default_host"
                enableServletCaching = returnPropertyConfiguration(configFile, str("server-web-container"), str("servlet-caching-enabled")) or "true"
                enablePortletCaching = returnPropertyConfiguration(configFile, str("server-web-container"), str("portlet-caching-enabled")) or "true"
                targetWebContainer = AdminConfig.list("WebContainer", targetServer)

                debugLogger.log(logging.DEBUG, str(virtualHost))
                debugLogger.log(logging.DEBUG, str(enableServletCaching))
                debugLogger.log(logging.DEBUG, str(enablePortletCaching))
                debugLogger.log(logging.DEBUG, str(targetWebContainer))

                if (len(targetWebContainer) != 0):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureWebContainer()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureWebContainer(targetWebContainer, virtualHost, enableServletCaching, isPortalServer, enablePortletCaching)"))

                        configureWebContainer(targetWebContainer, virtualHost, enableServletCaching, isPortalServer, enablePortletCaching)

                        infoLogger.log(logging.INFO, str("Completed configuration of web container {0} on server {1}").format(targetWebContainer, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of web container on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring web container {0} on server {1}: {2} {3}").format(targetWebContainer, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the web container on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure server cookies
                #
                cookieName = returnPropertyConfiguration(configFile, str("server-cookie-settings"), str("cookie-name")) or "JSESSIONID"
                cookiePath = returnPropertyConfiguration(configFile, str("server-web-container"), str("cookie-path")) or "/"
                targetCookie = AdminConfig.list("Cookie", targetServer)

                debugLogger.log(logging.DEBUG, str(cookieName))
                debugLogger.log(logging.DEBUG, str(cookiePath))
                debugLogger.log(logging.DEBUG, str(targetCookie))

                if (len(targetCookie) != 0):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureCookies()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureCookies(targetCookie, cookieName, cookiePath)"))

                        configureCookies(targetCookie, cookieName, cookiePath)

                        infoLogger.log(logging.INFO, str("Completed configuration of cookies {0} on server {1}").format(targetCookie, serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of cookies on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring cookies {0} on server {1}: {2} {3}").format(targetCookie, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the cookies on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure thread pools
                #
                startMinThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("startup-min-thread-size"))
                startMaxThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("startup-max-thread-size"))
                webMinThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("webcontainer-min-thread-size"))
                webMaxThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("webcontainer-max-thread-size"))
                haMinThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("hamanager-min-thread-size"))
                haMaxThreads = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("hamanager-max-thread-size"))
                threadPools = returnPropertyConfiguration(configFile, str("server-thread-pools"), str("pool-names"))
                targetThreadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)

                debugLogger.log(logging.DEBUG, str(startMinThreads))
                debugLogger.log(logging.DEBUG, str(startMaxThreads))
                debugLogger.log(logging.DEBUG, str(webMinThreads))
                debugLogger.log(logging.DEBUG, str(webMaxThreads))
                debugLogger.log(logging.DEBUG, str(haMinThreads))
                debugLogger.log(logging.DEBUG, str(haMaxThreads))
                debugLogger.log(logging.DEBUG, str(targetThreadPools))

                if (len(targetThreadPools) != 0):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configuretargetThreadPools()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, threadPools)"))

                        configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, threadPools)

                        infoLogger.log(logging.INFO, str("Completed configuration of thread pools on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of thread pools on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring thread pools {0} on server {1}: {2} {3}").format(targetThreadPools, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring thread pools on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure TCP channels
                #
                tcpMaxOpenConnections = returnPropertyConfiguration(configFile, str("server-tcp-channels"), str("max-open-connections"))
                targetTCPChannels = AdminConfig.list("TCPInboundChannel", targetServer).split(lineSplit)

                debugLogger.log(logging.DEBUG, str(tcpMaxOpenConnections))
                debugLogger.log(logging.DEBUG, str(targetTCPChannels))

                if (len(targetTCPChannels) != 0):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureTCPChannels()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureTCPChannels(targetTCPChannels, tcpMaxOpenConnections)"))

                        configureTCPChannels(targetTCPChannels, tcpMaxOpenConnections)

                        infoLogger.log(logging.INFO, str("Completed configuration of TCP channels on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of TCP channels on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring TCP channels {0} on server {1}: {2} {3}").format(targetTCPChannels, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring TCP channels on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure HTTP channels
                #
                httpMaxOpenConnections = returnPropertyConfiguration(configFile, str("server-http-channels"), str("max-open-connections"))
                targetHTTPChannels = AdminConfig.list("HTTPInboundChannel", targetServer).split(lineSplit)

                debugLogger.log(logging.DEBUG, str(tcpMaxOpenConnections))
                debugLogger.log(logging.DEBUG, str(targetHTTPChannels))

                if (len(targetHTTPChannels != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureHTTPChannels()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureHTTPChannels(targetHTTPChannels, httpMaxOpenConnections)"))

                        configureHTTPChannels(targetHTTPChannels, httpMaxOpenConnections)

                        infoLogger.log(logging.INFO, str("Completed configuration of HTTP channels on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of HTTP channels on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring HTTP channels {0} on server {1}: {2} {3}").format(targetHTTPChannels, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring HTTP channels on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure container chains
                #
                chainsToSkip = returnPropertyConfiguration(configFile, str("server-container-chains"), str("skip-chains"))
                targetContainerChains = AdminTask.listChains(targetTransport, "[-acceptorFilter WebContainerInboundChannel]").split(lineSplit)

                debugLogger.log(logging.DEBUG, str(chainsToSkip))
                debugLogger.log(logging.DEBUG, str(targetContainerChains))

                if (len(targetContainerChains != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureContainerChains()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureContainerChains(targetContainerChains, chainsToSkip)"))

                        configureContainerChains(targetContainerChains, chainsToSkip)

                        infoLogger.log(logging.INFO, str("Completed configuration container chains on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of container chains on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring container chains {0} on server {1}: {2} {3}").format(targetContainerChains, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring container chains on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure tuning parameters
                #
                writeContent = returnPropertyConfiguration(configFile, str("server-tuning-params"), str("write-content")) or "ONLY_UPDATED_ATTRIBUTES"
                writeFrequency = returnPropertyConfiguration(configFile, str("server-tuning-params"), str("write-frequency")) or "END_OF_SERVLET_SERVICE"
                targetTuningParams = AdminConfig.list("TuningParams", targetServer)

                debugLogger.log(logging.DEBUG, str(writeContent))
                debugLogger.log(logging.DEBUG, str(writeFrequency))
                debugLogger.log(logging.DEBUG, str(targetTuningParams))

                if (len(targetTuningParams != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureTuningParams()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureTuningParams(targetTuningParams, writeContent, writeFrequency)"))

                        configureTuningParams(targetTuningParams, writeContent, writeFrequency)

                        infoLogger.log(logging.INFO, str("Completed configuration of tuning parameters on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of tuning parameters on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring tuning parameters {0} on server {1}: {2} {3}").format(targetTuningParams, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred tuning parameters chains on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Configure session manager
                # TODO
                #
                targetSessionManager = AdminConfig.list("TuningParams", targetServer)

                debugLogger.log(logging.DEBUG, str(targetSessionManager))

                if (len(targetSessionManager != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureSessionManager()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureSessionManager(targetSessionManager)"))

                        configureSessionManager(targetSessionManager)

                        infoLogger.log(logging.INFO, str("Completed configuration of session manager on server {0}").format(serverName))
                        consoleInfoLogger.log(logging.INFO, str("Completed configuration of session manager on server {0}").format(serverName))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring session manager {0} on server {1}: {2} {3}").format(targetTuningParams, targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred session manager chains on server {0}. Please review logs.").format(serverName))
                    #endtry
                #endif

                #
                # Save workspace changes
                #
                try:
                    debugLogger.log(logging.DEBUG, str("Calling saveWorkspaceChanges()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: saveWorkspaceChanges()"))

                    saveWorkspaceChanges()

                    debugLogger.log(logging.DEBUG, str("All workspace changes saved to master repository."))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository: {0} {1}").format(str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository. Please review logs."))
                #endtry

                #
                # Synchronize nodes
                #
                try:
                    debugLogger.log(logging.DEBUG, str("Calling syncNodes()"))
                    debugLogger.log(logging.DEBUG, str("EXEC: syncNodes(nodeList, targetCell)"))

                    syncNodes(nodeList, targetCell)

                    debugLogger.log(logging.DEBUG, str("Node synchronization complete for cell {0}.").format(targetCell))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred synchronizing changes to cell {0}: {1} {2}").format(targetCell, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred synchronizing changes to cell {0}. Please review logs.").format(targetCell))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No deployment manager was found with node name {0} and server name {1}.").format(nodeName, serverName))
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

    debugLogger.log(logging.DEBUG, str("EXIT: configureApplicationServer()"))
#enddef

def getServerStatus():
    debugLogger.log(logging.DEBUG, str("ENTER: getServerStatus()"))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            #
            # Get the current status of the server
            #
            try:
                debugLogger.log(logging.DEBUG, str("Calling serverStatus()"))
                debugLogger.log(logging.DEBUG, str("EXEC: serverStatus(serverName, nodeName)"))

                serverStatus = serverStatus(serverName, nodeName)

                debugLogger.log(logging.DEBUG, str("Current server state: {0}").format(serverStatus))

                consoleInfoLogger.log(logging.INFO, str("The current status of server {0} on node {1} is {2}").format(serverName, nodeName, serverStatus))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred retrieving the current state of server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurred retrieving the current state of server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            consoleErrorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: getServerStatus()"))
#enddef

def startApplicationServer():
    debugLogger.log(logging.DEBUG, str("ENTER: startApplicationServer()"))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))
        startWaitTime = returnPropertyConfiguration(configFile, str("server-start-options"), str("start-wait-time")) or "10"

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))
        debugLogger.log(logging.DEBUG, str(startWaitTime))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            #
            # Start the application server
            #
            try:
                debugLogger.log(logging.DEBUG, str("Calling startServer()"))
                debugLogger.log(logging.DEBUG, str("EXEC: startServer(serverName, nodeName, startWaitTime)"))

                startServer(serverName, nodeName, startWaitTime)

                debugLogger.log(logging.DEBUG, str("An attempt to start server {0} on node {1} has been initiated.").format(serverName, nodeName))

                consoleInfoLogger.log(logging.INFO, str("An attempt to start server {0} on node {1} has been initiated.").format(serverName, nodeName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred trying to start server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurredtrying to start server server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            consoleErrorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: startApplicationServer()"))
#enddef

def stopApplicationServer():
    debugLogger.log(logging.DEBUG, str("ENTER: stopApplicationServer()"))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))
        stopServerImmediate = returnPropertyConfiguration(configFile, str("server-stop-options"), str("immediate-stop")) or False
        stopServerTerminate = returnPropertyConfiguration(configFile, str("server-stop-options"), str("terminate-stop")) or False

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))
        debugLogger.log(logging.DEBUG, str(stopServerImmediate))
        debugLogger.log(logging.DEBUG, str(stopServerTerminate))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            #
            # Start the application server
            #
            try:
                debugLogger.log(logging.DEBUG, str("Calling stopServer()"))
                debugLogger.log(logging.DEBUG, str("EXEC: stopServer(serverName, nodeName, stopServerImmediate, stopServerImmediate)"))

                stopServer(serverName, nodeName, stopServerImmediate, stopServerImmediate)

                debugLogger.log(logging.DEBUG, str("An attempt to stop server {0} on node {1} has been initiated.").format(serverName, nodeName))

                consoleInfoLogger.log(logging.INFO, str("An attempt to stop server {0} on node {1} has been initiated.").format(serverName, nodeName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred trying to stop server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurredtrying to stop server server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            consoleErrorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: stopApplicationServer()"))
#enddef

def restartApplicationServer():
    debugLogger.log(logging.DEBUG, str("ENTER: restartApplicationServer()"))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name"))
        serverName = returnPropertyConfiguration(configFile, str("server-information"), str("server-name"))
        restartTimeout = returnPropertyConfiguration(configFile, str("server-restart-options"), str("restart-timeout")) or "600"

        debugLogger.log(logging.DEBUG, str(nodeName))
        debugLogger.log(logging.DEBUG, str(serverName))
        debugLogger.log(logging.DEBUG, str(restartTimeout))

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            #
            # Start the application server
            #
            try:
                debugLogger.log(logging.DEBUG, str("Calling stopServer()"))
                debugLogger.log(logging.DEBUG, str("EXEC: restartServer(serverName, nodeName, restartTimeout)"))

                restartServer(serverName, nodeName, restartTimeout)

                debugLogger.log(logging.DEBUG, str("An attempt to restart server {0} on node {1} has been initiated.").format(serverName, nodeName))

                consoleInfoLogger.log(logging.INFO, str("An attempt to restart server {0} on node {1} has been initiated.").format(serverName, nodeName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred trying to restart server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurredtrying to restart server server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
            consoleErrorLogger.log(logging.ERROR, str("No node/server information was found in the provided configuration file."))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: restartApplicationServer()"))
#enddef

def printHelp():
    print(str("This script performs server management tasks."))
    print(str("Execution: wsadmin.sh -lang jython -f serverManagement.py <option> <configuration file>"))
    print(str("Options are: "))

    print(str("    configure-deployment-manager: Performs configuration tasks for a deployment manager."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain a value indicating the server name."))
    print(str("                    This section must contain a value indicating the node name."))
    print(str("                [server-trace-settings]"))
    print(str("                    This section may contain a value to configure startup trace specifications. If no value is provided, the default value is \"*=info\"."))
    print(str("                    This section may contain a value to configure the trace output type. If no value is provided, the default value is \"SPECIFIED_FILE\"."))
    print(str("                    This section may contain a value to configure the maximum number of trace backup files. If no value is provided, the default value is \"50\"."))
    print(str("                    This section may contain a value to configure the maximum size of the trace file before it is rolled over. If no value is provided, the default value is \"50\"."))
    print(str("                    This section may contain a value to configure the trace filename. If no value is provided, the default value is \"${SERVER_LOG_ROOT}/trace.log\"."))
    print(str("                [server-process-settings]"))
    print(str("                    This section may contain a value to configure the user to run the server as. If no value is provided, the \"runAsUser\" entry is not configured."))
    print(str("                    This section may contain a value to configure the group to run the server as. If no value is provided, the \"runAsGroup\" entry is not configured."))
    print(str("                [server-jvm-settings]"))
    print(str("                    This section may contain a value to configure the initial JVM heap size (in megabytes). If no value is provided, the default value is \"1024\"."))
    print(str("                    This section may contain a value to configure the maximum JVM heap size (in megabytes). If no value is provided, the default value is \"1024\"."))
    print(str("                [server-hamanager]"))
    print(str("                    This section may contain a value to enable or disable the HA Manager service."))

    print(str("    configure-nodeagent: Performs configuration tasks for a nodeagent."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain a value indicating the server name."))
    print(str("                    This section must contain a value indicating the node name."))
    print(str("                [server-trace-settings]"))
    print(str("                    This section may contain a value to configure startup trace specifications. If no value is provided, the default value is \"*=info\"."))
    print(str("                    This section may contain a value to configure the trace output type. If no value is provided, the default value is \"SPECIFIED_FILE\"."))
    print(str("                    This section may contain a value to configure the maximum number of trace backup files. If no value is provided, the default value is \"50\"."))
    print(str("                    This section may contain a value to configure the maximum size of the trace file before it is rolled over. If no value is provided, the default value is \"50\"."))
    print(str("                    This section may contain a value to configure the trace filename. If no value is provided, the default value is \"${SERVER_LOG_ROOT}/trace.log\"."))
    print(str("                [server-process-settings]"))
    print(str("                    This section may contain a value to configure the user to run the server as. If no value is provided, the \"runAsUser\" entry is not configured."))
    print(str("                    This section may contain a value to configure the group to run the server as. If no value is provided, the \"runAsGroup\" entry is not configured."))
    print(str("                [server-jvm-settings]"))
    print(str("                    This section may contain a value to configure the initial JVM heap size (in megabytes). If no value is provided, the default value is \"512\"."))
    print(str("                    This section may contain a value to configure the maximum JVM heap size (in megabytes). If no value is provided, the default value is \"512\"."))

    print(str("    configure-application-server: Performs configuration tasks for an application server."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain a value indicating the server name."))
    print(str("                    This section must contain a value indicating the node name."))
    print(str("                    This section may indicate if the server is a WebSphere Portal server. If no value is provided, the default is \"false\""))
    print(str("                [server-auto-restart]"))
    print(str("                    This section must contain the server and node names."))
    print(str("                    This section may contain a value to determine if the nodeagent should automatically start the server if it finds it down. If not provided, the default value is \"STOPPED\""))
    print(str("                [server-web-container]"))
    print(str("                    This section may contain a value to set the default virtual host. If not provided, the default value is \"default_host\"."))
    print(str("                    This section may contain a value to determine if servlet caching is enabled. If not provided, the default value is \"true\"."))
    print(str("                [server-hamanager]"))
    print(str("                    This section may contain a value to determine if the HA Manager service should be enabled. No default value is provided."))
    print(str("                [server-trace-settings]"))
    print(str("                    This section may contain a value to configure startup trace specifications. If no value is provided, the default value is \"*=info\"."))
    print(str("                    This section may contain a value to configure the trace output type. If no value is provided, the default value is \"SPECIFIED_FILE\"."))
    print(str("                    This section may contain a value to configure the maximum number of trace backup files. If no value is provided, the default value is 50."))
    print(str("                    This section may contain a value to configure the maximum size of the trace file before it is rolled over. If no value is provided, the default value is 50."))
    print(str("                    This section may contain a value to configure the trace filename. If no value is provided, the default value is \"${SERVER_LOG_ROOT}/trace.log\"."))
    print(str("                [server-process-settings]"))
    print(str("                    This section may contain a value to configure the user to run the server as. If no value is provided, the \"runAsUser\" entry is not configured."))
    print(str("                    This section may contain a value to configure the group to run the server as. If no value is provided, the \"runAsGroup\" entry is not configured."))
    print(str("                [server-jvm-settings]"))
    print(str("                    This section may contain a value to configure the initial JVM heap size (in megabytes). If no value is provided, the default value is \"2048\"."))
    print(str("                    This section may contain a value to configure the maximum JVM heap size (in megabytes). If no value is provided, the default value is \"2048\"."))
    print(str("                [server-thread-pools]"))
    print(str("                    This section may contain a value to configure the initial server startup thread pool minimum size. No default is provided."))
    print(str("                    This section may contain a value to configure the initial server startup thread pool maximum size. No default is provided."))
    print(str("                    This section may contain a value to configure the initial web container thread pool minimum size. No default is provided."))
    print(str("                    This section may contain a value to configure the initial web container thread pool maximum size. No default is provided."))
    print(str("                    This section may contain a value to configure the initial HA Manager thread pool minimum size. No default is provided."))
    print(str("                    This section may contain a value to configure the initial HA Manager thread pool maximum size. No default is provided."))
    print(str("                        NOTE: If the [server-hamanger] section disables the HA Manager service, these values should be set to \"0\"."))
    print(str("                    This section may contain a list of thread pools to configure. No default is provided."))
    print(str("                [server-tcp-channels]"))
    print(str("                    This section may contain a value to configure the maximum number of open TCP connections. No default is provided."))
    print(str("                [server-http-channels]"))
    print(str("                    This section may contain a value to configure the maximum number of open TCP connections. No default is provided."))
    print(str("                [server-container-chains]"))
    print(str("                    This section may contain a list of container chains to skip. No default is provided."))
    print(str("                [server-tuning-params]"))
    print(str("                    This section may contain a value indicating the session write content policy. If no value is provided, the default is \"ONLY_UPDATED_ATTRIBUTES\""))
    print(str("                    This section may contain a value indicating the session write frequency policy. If no value is provided, the default is \"END_OF_SERVLET_SERVICE\""))
    print(str("                [server-cookie-settings]"))
    print(str("                    This section may contain a value indicating the name of the session cookie. If no value is provided, the default is \"JSESSIONID\""))
    print(str("                    This section may contain a value indicating the path for the session cookie. If no value is provided, the default is \"/\""))

    print(str("    server-status: Retrieves and displays the current status of a given server on a node."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain a value indicating the server name."))
    print(str("                    This section must contain a value indicating the node name."))

    print(str("    start-server: Starts a server on a given node."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain a value indicating the server name."))
    print(str("                    This section must contain a value indicating the node name."))
    print(str("                [server-start-options]"))
    print(str("                    This section may contain a value to determine a wait time to start the server (in seconds). If no value is provided, the default value is \"10\"."))

    print(str("    stop-server: Stops a server on a given node."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain a value indicating the server name."))
    print(str("                    This section must contain a value indicating the node name."))
    print(str("                [server-stop-options]"))
    print(str("                    This section may contain a value to determine if the server should be immediately stopped. If no value is provided, the default value is \"False\"."))
    print(str("                    This section may contain a value to determine if the server should be terminated (killed). If no value is provided, the default value is \"False\"."))

    print(str("    restart-server: Restarts a server on a given node."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain a value indicating the server name."))
    print(str("                    This section must contain a value indicating the node name."))
    print(str("                [server-restart-options]"))
    print(str("                    This section may contain a value to determine the timeout for the restart operation (in seconds). If no value is provided, the default value is \"600\"."))
#enddef

##################################
# main
#################################
if (len(sys.argv) == 0):
    printHelp()
else:
    configFile = str(sys.argv[1])

    if (os.path.exists(configFile)) and (os.access(configFile, os.R_OK)):
        if (sys.argv[0] == str("configure-deployment-manager")):
            configureDeploymentManager()
        elif (sys.argv[0] == str("configure-nodeagent")):
            configureNodeAgent()
        elif (sys.argv[0] == str("configure-application-server")):
            configureApplicationServer()
        elif (sys.argv[0] == str("server-status")):
            getServerStatus()
        elif (sys.argv[0] == str("start-server")):
            startApplicationServer()
        elif (sys.argv[0] == str("stop-server")):
            stopApplicationServer()
        elif (sys.argv[0] == str("restart-server")):
            restartApplicationServer()
        else:
            printHelp()
        #endif
    else:
        print(str("The provided configuration file either does not exist or cannot be read."))
    #endif
#endif
