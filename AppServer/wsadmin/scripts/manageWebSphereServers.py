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

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")
consoleInfoLogger = logging.getLogger("console-out")
consoleErrorLogger = logging.getLogger("console-err")

targetCell = AdminControl.getCell()
lineSplit = java.lang.System.getProperty("line.separator")
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureDeploymentManager():
    debugLogger.log(logging.DEBUG, "ENTER: configureDeploymentManager()")

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, "server-information", "node-name")
        serverName = returnPropertyConfiguration(configFile, "server-information", "server-name")

        debugLogger.log(logging.DEBUG, nodeName)
        debugLogger.log(logging.DEBUG, serverName)

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, targetServer)

            if (len(targetServer) != 0):
                infoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))
                consoleInfoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))

                #
                # Enable/disable HAManager
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    isEnabled = returnPropertyConfiguration(configFile, "server-hamanager", "enabled")
                    targetHAManager = AdminConfig.list("HAManagerService", targetServer)

                    debugLogger.log(logging.DEBUG, isEnabled)
                    debugLogger.log(logging.DEBUG, targetHAManager)

                    if ((len(targetHAManager) != 0) and (len(isEnabled) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureHAManager()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureHAManager(targetHAManager, isEnabled)")

                            configureHAManager(targetHAManager, isEnabled)

                            infoLogger.log(logging.INFO, str("Completed configuration of HAManager service {0} on server {1}").format(targetHAManager, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of HAManager service on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring HAManager service {0} on server {1}: {2} {3}").format(targetHAManager, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the HAManager service on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure trace service
                #
                propertyExists = checkIfPropertySectionExists("server-trace-settings")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    traceSpec = returnPropertyConfiguration(configFile, "server-trace-settings", "trace-spec")
                    outputType = returnPropertyConfiguration(configFile, "server-trace-settings", "output-type")
                    maxBackupFiles = returnPropertyConfiguration(configFile, "server-trace-settings", "max-backup-files")
                    maxFileSize = returnPropertyConfiguration(configFile, "server-trace-settings", "max-file-size")
                    traceFileName = returnPropertyConfiguration(configFile, "server-trace-settings", "trace-file-name")
                    targetTraceService = AdminConfig.list("TraceService", targetServer)

                    debugLogger.log(logging.DEBUG, traceSpec)
                    debugLogger.log(logging.DEBUG, outputType)
                    debugLogger.log(logging.DEBUG, maxBackupFiles)
                    debugLogger.log(logging.DEBUG, maxFileSize)
                    debugLogger.log(logging.DEBUG, traceFileName)
                    debugLogger.log(logging.DEBUG, outputType)
                    debugLogger.log(logging.DEBUG, targetTraceService)

                    if ((len(targetTraceService) != 0) and (len(traceSpec) != 0) and (len(outputType) != 0)
                        and (len(maxBackupFiles) != 0) and (len(maxFileSize) != 0) and (len(traceFileName) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling setServerTrace()")
                            debugLogger.log(logging.DEBUG, "EXEC: setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)")

                            setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)

                            infoLogger.log(logging.INFO, str("Completed configuration of trace service {0} on server {1}").format(targetTraceService, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of trace service on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring trace service {0} on server {1}: {2} {3}").format(targetTraceService, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the trace service on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure process execution
                #
                propertyExists = checkIfPropertySectionExists("server-process-settings")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    runAsUser = returnPropertyConfiguration(configFile, "server-process-settings", "run-user")
                    runAsGroup = returnPropertyConfiguration(configFile, "server-process-settings", "run-group")
                    targetProcessExec = AdminConfig.list("ProcessExecution", targetServer)

                    debugLogger.log(logging.DEBUG, runAsUser)
                    debugLogger.log(logging.DEBUG, runAsGroup)
                    debugLogger.log(logging.DEBUG, targetProcessExec)

                    if ((len(targetProcessExec) != 0) and (len(runAsGroup) != 0) and (len(runAsGroup) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling setProcessExec()")
                            debugLogger.log(logging.DEBUG, "EXEC: setProcessExec(targetProcessExec, runAsUser, runAsGroup)")

                            setProcessExec(targetProcessExec, runAsUser, runAsGroup)

                            infoLogger.log(logging.INFO, str("Completed configuration of process execution {0} on server {1}").format(targetTraceService, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of process execution on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring process execution {0} on server {1}: {2} {3}").format(targetProcessExec, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure JVM properties
                #
                propertyExists = checkIfPropertySectionExists("server-jvm-settings")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    initialHeapSize = returnPropertyConfiguration(configFile, "server-jvm-settings", "initial-heap-size") or 1024
                    maxHeapSize = returnPropertyConfiguration(configFile, "server-jvm-settings", "max-heap-size") or 1024
                    genericJVMArguments = returnPropertyConfiguration(configFile, "server-jvm-settings", "jvm-arguments") or ""
                    hprofArguments = returnPropertyConfiguration(configFile, "server-jvm-settings", "hprof-arguments") or ""

                    debugLogger.log(logging.DEBUG, str(initialHeapSize))
                    debugLogger.log(logging.DEBUG, str(maxHeapSize))
                    debugLogger.log(logging.DEBUG, str(genericJVMArguments))
                    debugLogger.log(logging.DEBUG, str(hprofArguments))

                    if ((len(initialHeapSize) != 0) and (len(maxHeapSize) != 0) and (len(genericJVMArguments) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling setJVMProperties()")
                            debugLogger.log(logging.DEBUG, "EXEC: setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)")

                            setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)

                            infoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring JVM properties on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Save workspace changes
                #
                try:
                    debugLogger.log(logging.DEBUG, "Calling saveWorkspaceChanges()")
                    debugLogger.log(logging.DEBUG, "EXEC: saveWorkspaceChanges()")

                    saveWorkspaceChanges()

                    debugLogger.log(logging.DEBUG, "All workspace changes saved to master repository.")
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository: {0} {1}").format(str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository. Please review logs."))
                #endtry

                #
                # Synchronize nodes
                #
                try:
                    debugLogger.log(logging.DEBUG, "Calling syncNodes()")
                    debugLogger.log(logging.DEBUG, "EXEC: syncNodes(nodeList, targetCell)")

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
            errorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
            consoleErrorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log(logging.ERROR, "No configuration file was provided.")
        consoleErrorLogger.log(logging.ERROR, "No configuration file was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: configureDeploymentManager()")
#enddef

def configureNodeAgent():
    debugLogger.log(logging.DEBUG, str("ENTER: configureNodeAgent()"))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, "server-information", "node-name")
        serverName = returnPropertyConfiguration(configFile, "server-information", "server-name")

        debugLogger.log(logging.DEBUG, nodeName)
        debugLogger.log(logging.DEBUG, serverName)

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, targetServer)

            if (len(targetServer) != 0):
                infoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))
                consoleInfoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))

                #
                # Enable/disable HAManager
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    isEnabled = returnPropertyConfiguration(configFile, "server-hamanager", "enabled")
                    targetHAManager = AdminConfig.list("HAManagerService", targetServer)

                    debugLogger.log(logging.DEBUG, isEnabled)
                    debugLogger.log(logging.DEBUG, targetHAManager)

                    if ((len(targetHAManager) != 0) and (len(isEnabled) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureHAManager()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureHAManager(targetHAManager, isEnabled)")

                            configureHAManager(targetHAManager, isEnabled)

                            infoLogger.log(logging.INFO, str("Completed configuration of HAManager service {0} on server {1}").format(targetHAManager, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of HAManager service on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring HAManager service {0} on server {1}: {2} {3}").format(targetHAManager, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the HAManager service on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure trace service
                #
                propertyExists = checkIfPropertySectionExists("server-trace-settings")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    traceSpec = returnPropertyConfiguration(configFile, "server-trace-settings", "trace-spec")
                    outputType = returnPropertyConfiguration(configFile, "server-trace-settings", "output-type")
                    maxBackupFiles = returnPropertyConfiguration(configFile, "server-trace-settings", "max-backup-files")
                    maxFileSize = returnPropertyConfiguration(configFile, "server-trace-settings", "max-file-size")
                    traceFileName = returnPropertyConfiguration(configFile, "server-trace-settings", "trace-file-name")
                    targetTraceService = AdminConfig.list("TraceService", targetServer)

                    debugLogger.log(logging.DEBUG, traceSpec)
                    debugLogger.log(logging.DEBUG, outputType)
                    debugLogger.log(logging.DEBUG, maxBackupFiles)
                    debugLogger.log(logging.DEBUG, maxFileSize)
                    debugLogger.log(logging.DEBUG, traceFileName)
                    debugLogger.log(logging.DEBUG, outputType)
                    debugLogger.log(logging.DEBUG, targetTraceService)

                    if ((len(targetTraceService) != 0) and (len(traceSpec) != 0) and (len(outputType) != 0)
                        and (len(maxBackupFiles) != 0) and (len(maxFileSize) != 0) and (len(traceFileName) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling setServerTrace()")
                            debugLogger.log(logging.DEBUG, "EXEC: setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)")

                            setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)

                            infoLogger.log(logging.INFO, str("Completed configuration of trace service {0} on server {1}").format(targetTraceService, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of trace service on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring trace service {0} on server {1}: {2} {3}").format(targetTraceService, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the trace service on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure process execution
                #
                propertyExists = checkIfPropertySectionExists("server-process-settings")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    runAsUser = returnPropertyConfiguration(configFile, "server-process-settings", "run-user")
                    runAsGroup = returnPropertyConfiguration(configFile, "server-process-settings", "run-group")
                    targetProcessExec = AdminConfig.list("ProcessExecution", targetServer)

                    debugLogger.log(logging.DEBUG, runAsUser)
                    debugLogger.log(logging.DEBUG, runAsGroup)
                    debugLogger.log(logging.DEBUG, targetProcessExec)

                    if ((len(targetProcessExec) != 0) and (len(runAsGroup) != 0) and (len(runAsGroup) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling setProcessExec()")
                            debugLogger.log(logging.DEBUG, "EXEC: setProcessExec(targetProcessExec, runAsUser, runAsGroup)")

                            setProcessExec(targetProcessExec, runAsUser, runAsGroup)

                            infoLogger.log(logging.INFO, str("Completed configuration of process execution {0} on server {1}").format(targetTraceService, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of process execution on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring process execution {0} on server {1}: {2} {3}").format(targetProcessExec, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure JVM properties
                #
                propertyExists = checkIfPropertySectionExists("server-jvm-settings")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    initialHeapSize = returnPropertyConfiguration(configFile, "server-jvm-settings", "initial-heap-size") or 512
                    maxHeapSize = returnPropertyConfiguration(configFile, "server-jvm-settings", "max-heap-size") or 512
                    genericJVMArguments = returnPropertyConfiguration(configFile, "server-jvm-settings", "jvm-arguments") or ""
                    hprofArguments = returnPropertyConfiguration(configFile, "server-jvm-settings", "hprof-arguments") or ""

                    debugLogger.log(logging.DEBUG, initialHeapSize)
                    debugLogger.log(logging.DEBUG, maxHeapSize)
                    debugLogger.log(logging.DEBUG, genericJVMArguments)
                    debugLogger.log(logging.DEBUG, hprofArguments)

                    if ((len(initialHeapSize) != 0) and (len(maxHeapSize) != 0) and (len(genericJVMArguments) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling setJVMProperties()")
                            debugLogger.log(logging.DEBUG, "EXEC: setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)")

                            setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)

                            infoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring JVM properties on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Save workspace changes
                #
                try:
                    debugLogger.log(logging.DEBUG, "Calling saveWorkspaceChanges()")
                    debugLogger.log(logging.DEBUG, "EXEC: saveWorkspaceChanges()")

                    saveWorkspaceChanges()

                    debugLogger.log(logging.DEBUG, "All workspace changes saved to master repository.")
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository: {0} {1}").format(str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository. Please review logs."))
                #endtry

                #
                # Synchronize nodes
                #
                try:
                    debugLogger.log(logging.DEBUG, "Calling syncNodes()")
                    debugLogger.log(logging.DEBUG, "EXEC: syncNodes(nodeList, targetCell)")

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
            errorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
            consoleErrorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log(logging.ERROR, "No configuration file was provided.")
        consoleErrorLogger.log(logging.ERROR, "No configuration file was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: configureNodeAgent()")
#enddef

def configureApplicationServer():
    debugLogger.log(logging.DEBUG, "ENTER: configureApplicationServer()")

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, "server-information", "node-name")
        serverName = returnPropertyConfiguration(configFile, "server-information", "server-name")
        isPortalServer = returnPropertyConfiguration(configFile, "server-information", "is-portal-server")

        debugLogger.log(logging.DEBUG, nodeName)
        debugLogger.log(logging.DEBUG, serverName)
        debugLogger.log(logging.DEBUG, isPortalServer)

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

            debugLogger.log(logging.DEBUG, targetServer)

            if (len(targetServer) != 0):
                infoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))
                consoleInfoLogger.log(logging.INFO, str("Starting configuration for deployment manager {0}..").format(serverName))

                #
                # Add shared libraries, if any
                #
                propertyExists = checkIfPropertySectionExists("server-shared-libraries")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    sharedLibraryName = returnPropertyConfiguration(configFile, "server-shared-libraries", "library-name")

                    debugLogger.log(logging.DEBUG, sharedLibraryName)
                    debugLogger.log(logging.DEBUG, sharedLibraryClasspath)

                    if ((len(sharedLibraryName) != 0) and (len(sharedLibraryClasspath) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling addSharedLibraryToServer()")
                            debugLogger.log(logging.DEBUG, "EXEC: addSharedLibraryToServer(targetServer, sharedLibraryName)")

                            addSharedLibraryToServer(targetServer, sharedLibraryName)

                            infoLogger.log(logging.INFO, str("Completed adding shared library {0} on server {1}").format(sharedLibraryName, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed adding shared library {0} on server {1}").format(sharedLibraryName, serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred adding shared library {0} on server {1}: {2} {3}").format(targetHAManager, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred adding shared library {0} on server {1}: {2} {3}").format(targetHAManager, targetServer, str(exception), str(parms)))
                        #endtry
                    #endif
                #endif

                #
                # Enable/disable HAManager
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    isEnabled = returnPropertyConfiguration(configFile, "server-hamanager", "enabled")
                    targetHAManager = AdminConfig.list("HAManagerService", targetServer)

                    debugLogger.log(logging.DEBUG, isEnabled)
                    debugLogger.log(logging.DEBUG, targetHAManager)

                    if ((len(targetHAManager) != 0) and (len(isEnabled) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureHAManager()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureHAManager(targetHAManager, isEnabled)")

                            configureHAManager(targetHAManager, isEnabled)

                            infoLogger.log(logging.INFO, str("Completed configuration of HAManager service {0} on server {1}").format(targetHAManager, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of HAManager service on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring HAManager service {0} on server {1}: {2} {3}").format(targetHAManager, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the HAManager service on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure trace service
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    traceSpec = returnPropertyConfiguration(configFile, "server-trace-settings", "trace-spec") or "*=info"
                    outputType = returnPropertyConfiguration(configFile, "server-trace-settings", "output-type") or "SPECIFIED_FILE"
                    maxBackupFiles = returnPropertyConfiguration(configFile, "server-trace-settings", "max-backup-files") or "10"
                    maxFileSize = returnPropertyConfiguration(configFile, "server-trace-settings", "max-file-size") or "50"
                    traceFileName = returnPropertyConfiguration(configFile, "server-trace-settings", "trace-file-name") or "${SERVER_LOG_ROOT}/trace.log"
                    targetTraceService = AdminConfig.list("TraceService", targetServer)

                    debugLogger.log(logging.DEBUG, traceSpec)
                    debugLogger.log(logging.DEBUG, outputType)
                    debugLogger.log(logging.DEBUG, maxBackupFiles)
                    debugLogger.log(logging.DEBUG, maxFileSize)
                    debugLogger.log(logging.DEBUG, traceFileName)
                    debugLogger.log(logging.DEBUG, outputType)
                    debugLogger.log(logging.DEBUG, targetTraceService)

                    if ((len(targetTraceService) != 0) and (len(traceSpec) != 0) and (len(outputType) != 0)
                        and (len(maxBackupFiles) != 0) and (len(maxFileSize) != 0) and (len(traceFileName) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling setServerTrace()")
                            debugLogger.log(logging.DEBUG, "EXEC: setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)")

                            setServerTrace(targetTraceService, traceSpec, outputType, maxBackupFiles, maxFileSize, traceFileName)

                            infoLogger.log(logging.INFO, str("Completed configuration of trace service {0} on server {1}").format(targetTraceService, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of trace service on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring trace service {0} on server {1}: {2} {3}").format(targetTraceService, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the trace service on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure process execution
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    runAsUser = returnPropertyConfiguration(configFile, "server-process-settings", "run-user")
                    runAsGroup = returnPropertyConfiguration(configFile, "server-process-settings", "run-group")
                    targetProcessExec = AdminConfig.list("ProcessExecution", targetServer)

                    debugLogger.log(logging.DEBUG, runAsUser)
                    debugLogger.log(logging.DEBUG, runAsGroup)
                    debugLogger.log(logging.DEBUG, targetProcessExec)

                    if ((len(targetProcessExec) != 0) and (len(runAsGroup) != 0) and (len(runAsGroup) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling setProcessExec()")
                            debugLogger.log(logging.DEBUG, "EXEC: setProcessExec(targetProcessExec, runAsUser, runAsGroup)")

                            setProcessExec(targetProcessExec, runAsUser, runAsGroup)

                            infoLogger.log(logging.INFO, str("Completed configuration of process execution {0} on server {1}").format(targetTraceService, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of process execution on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring process execution {0} on server {1}: {2} {3}").format(targetProcessExec, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure JVM properties
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    initialHeapSize = returnPropertyConfiguration(configFile, "server-jvm-settings", "initial-heap-size") or 2048
                    maxHeapSize = returnPropertyConfiguration(configFile, "server-jvm-settings", "max-heap-size") or 2048
                    genericJVMArguments = returnPropertyConfiguration(configFile, "server-jvm-settings", "jvm-arguments") or ""
                    hprofArguments = returnPropertyConfiguration(configFile, "server-jvm-settings", "hprof-arguments") or ""

                    debugLogger.log(logging.DEBUG, initialHeapSize)
                    debugLogger.log(logging.DEBUG, maxHeapSize)
                    debugLogger.log(logging.DEBUG, genericJVMArguments)
                    debugLogger.log(logging.DEBUG, hprofArguments)

                    if ((len(initialHeapSize) != 0) and (len(maxHeapSize) != 0) and (len(genericJVMArguments) != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling setJVMProperties()")
                            debugLogger.log(logging.DEBUG, "EXEC: setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)")

                            setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments, hprofArguments)

                            infoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of JVM properties on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring JVM properties on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the process execution on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure auto restart policy
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    enableAutoRestart = returnPropertyConfiguration(configFile, "server-auto-restart", "restart-policy") or "STOPPED"
                    targetMonitorPolicy = AdminConfig.list("MonitoringPolicy", targetServer)

                    debugLogger.log(logging.DEBUG, enableAutoRestart)
                    debugLogger.log(logging.DEBUG, targetMonitorPolicy)

                    if (len(targetMonitorPolicy) != 0):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureAutoRestart()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureAutoRestart(targetMonitorPolicy, enableAutoRestart)")

                            configureAutoRestart(targetMonitorPolicy, enableAutoRestart)

                            infoLogger.log(logging.INFO, str("Completed configuration of monitoring policy on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of monitoring policy on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring monitoring policy {0} on server {1}: {2} {3}").format(targetMonitorPolicy, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the monitoring policy on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure web container
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    virtualHost = returnPropertyConfiguration(configFile, "server-web-container", "virtual-host") or "default_host"
                    enableServletCaching = returnPropertyConfiguration(configFile, "server-web-container", "servlet-caching-enabled") or "true"
                    enablePortletCaching = returnPropertyConfiguration(configFile, "server-web-container", "portlet-caching-enabled") or "true"
                    targetWebContainer = AdminConfig.list("WebContainer", targetServer)

                    debugLogger.log(logging.DEBUG, virtualHost)
                    debugLogger.log(logging.DEBUG, enableServletCaching)
                    debugLogger.log(logging.DEBUG, enablePortletCaching)
                    debugLogger.log(logging.DEBUG, targetWebContainer)

                    if (len(targetWebContainer) != 0):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureWebContainer()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureWebContainer(targetWebContainer, virtualHost, enableServletCaching, isPortalServer, enablePortletCaching)")

                            configureWebContainer(targetWebContainer, virtualHost, enableServletCaching, isPortalServer, enablePortletCaching)

                            infoLogger.log(logging.INFO, str("Completed configuration of web container {0} on server {1}").format(targetWebContainer, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of web container on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring web container {0} on server {1}: {2} {3}").format(targetWebContainer, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the web container on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure server cookies
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    cookieName = returnPropertyConfiguration(configFile, "server-cookie-settings", "cookie-name") or "JSESSIONID"
                    cookiePath = returnPropertyConfiguration(configFile, "server-web-container", "cookie-path") or "/"
                    targetCookie = AdminConfig.list("Cookie", targetServer)

                    debugLogger.log(logging.DEBUG, cookieName)
                    debugLogger.log(logging.DEBUG, cookiePath)
                    debugLogger.log(logging.DEBUG, targetCookie)

                    if (len(targetCookie) != 0):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureCookies()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureCookies(targetCookie, cookieName, cookiePath)")

                            configureCookies(targetCookie, cookieName, cookiePath)

                            infoLogger.log(logging.INFO, str("Completed configuration of cookies {0} on server {1}").format(targetCookie, serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of cookies on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring cookies {0} on server {1}: {2} {3}").format(targetCookie, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring the cookies on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure thread pools
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    startMinThreads = returnPropertyConfiguration(configFile, "server-thread-pools", "startup-min-thread-size")
                    startMaxThreads = returnPropertyConfiguration(configFile, "server-thread-pools", "startup-max-thread-size")
                    webMinThreads = returnPropertyConfiguration(configFile, "server-thread-pools", "webcontainer-min-thread-size")
                    webMaxThreads = returnPropertyConfiguration(configFile, "server-thread-pools", "webcontainer-max-thread-size")
                    haMinThreads = returnPropertyConfiguration(configFile, "server-thread-pools", "hamanager-min-thread-size")
                    haMaxThreads = returnPropertyConfiguration(configFile, "server-thread-pools", "hamanager-max-thread-size")
                    threadPools = returnPropertyConfiguration(configFile, "server-thread-pools", "pool-names")
                    targetThreadPools = AdminConfig.list("ThreadPool", targetServer).split(lineSplit)

                    debugLogger.log(logging.DEBUG, startMinThreads)
                    debugLogger.log(logging.DEBUG, startMaxThreads)
                    debugLogger.log(logging.DEBUG, webMinThreads)
                    debugLogger.log(logging.DEBUG, webMaxThreads)
                    debugLogger.log(logging.DEBUG, haMinThreads)
                    debugLogger.log(logging.DEBUG, haMaxThreads)
                    debugLogger.log(logging.DEBUG, targetThreadPools)

                    if (len(targetThreadPools) != 0):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configuretargetThreadPools()")
                            debugLogger.log(logging.DEBUG, "EXEC: configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, threadPools)")

                            configuretargetThreadPools(targetThreadPools, startMinThreads, startMaxThreads, webMinThreads, webMaxThreads, haMinThreads, haMaxThreads, threadPools)

                            infoLogger.log(logging.INFO, str("Completed configuration of thread pools on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of thread pools on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring thread pools {0} on server {1}: {2} {3}").format(targetThreadPools, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring thread pools on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure TCP channels
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    tcpMaxOpenConnections = returnPropertyConfiguration(configFile, "server-tcp-channels", "max-open-connections")
                    targetTCPChannels = AdminConfig.list("TCPInboundChannel", targetServer).split(lineSplit)

                    debugLogger.log(logging.DEBUG, tcpMaxOpenConnections)
                    debugLogger.log(logging.DEBUG, targetTCPChannels)

                    if (len(targetTCPChannels) != 0):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureTCPChannels()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureTCPChannels(targetTCPChannels, tcpMaxOpenConnections)")

                            configureTCPChannels(targetTCPChannels, tcpMaxOpenConnections)

                            infoLogger.log(logging.INFO, str("Completed configuration of TCP channels on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of TCP channels on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring TCP channels {0} on server {1}: {2} {3}").format(targetTCPChannels, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring TCP channels on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure HTTP channels
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    httpMaxOpenConnections = returnPropertyConfiguration(configFile, "server-http-channels", "max-open-connections")
                    targetHTTPChannels = AdminConfig.list("HTTPInboundChannel", targetServer).split(lineSplit)

                    debugLogger.log(logging.DEBUG, httpMaxOpenConnections)
                    debugLogger.log(logging.DEBUG, targetHTTPChannels)

                    if (len(targetHTTPChannels != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureHTTPChannels()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureHTTPChannels(targetHTTPChannels, httpMaxOpenConnections)")

                            configureHTTPChannels(targetHTTPChannels, httpMaxOpenConnections)

                            infoLogger.log(logging.INFO, str("Completed configuration of HTTP channels on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of HTTP channels on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring HTTP channels {0} on server {1}: {2} {3}").format(targetHTTPChannels, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring HTTP channels on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure container chains
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    chainsToSkip = returnPropertyConfiguration(configFile, "server-container-chains", "skip-chains")
                    targetContainerChains = AdminTask.listChains(targetTransport, "[-acceptorFilter WebContainerInboundChannel]").split(lineSplit)

                    debugLogger.log(logging.DEBUG, chainsToSkip)
                    debugLogger.log(logging.DEBUG, targetContainerChains)

                    if (len(targetContainerChains != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureContainerChains()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureContainerChains(targetContainerChains, chainsToSkip)")

                            configureContainerChains(targetContainerChains, chainsToSkip)

                            infoLogger.log(logging.INFO, str("Completed configuration container chains on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of container chains on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring container chains {0} on server {1}: {2} {3}").format(targetContainerChains, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred configuring container chains on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure tuning parameters
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    writeContent = returnPropertyConfiguration(configFile, "server-tuning-params", "write-content") or "ONLY_UPDATED_ATTRIBUTES"
                    writeFrequency = returnPropertyConfiguration(configFile, "server-tuning-params", "write-frequency") or "END_OF_SERVLET_SERVICE"
                    targetTuningParams = AdminConfig.list("TuningParams", targetServer)

                    debugLogger.log(logging.DEBUG, writeContent)
                    debugLogger.log(logging.DEBUG, writeFrequency)
                    debugLogger.log(logging.DEBUG, targetTuningParams)

                    if (len(targetTuningParams != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureTuningParams()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureTuningParams(targetTuningParams, writeContent, writeFrequency)")

                            configureTuningParams(targetTuningParams, writeContent, writeFrequency)

                            infoLogger.log(logging.INFO, str("Completed configuration of tuning parameters on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of tuning parameters on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring tuning parameters {0} on server {1}: {2} {3}").format(targetTuningParams, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred tuning parameters chains on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Configure session manager
                # TODO
                #
                propertyExists = checkIfPropertySectionExists("server-hamanager")

                debugLogger.log(logging.DEBUG, propertyExists)

                if (propertyExists):
                    targetSessionManager = AdminConfig.list("TuningParams", targetServer)

                    debugLogger.log(logging.DEBUG, targetSessionManager)

                    if (len(targetSessionManager != 0)):
                        try:
                            debugLogger.log(logging.DEBUG, "Calling configureSessionManager()")
                            debugLogger.log(logging.DEBUG, "EXEC: configureSessionManager(targetSessionManager)")

                            configureSessionManager(targetSessionManager)

                            infoLogger.log(logging.INFO, str("Completed configuration of session manager on server {0}").format(serverName))
                            consoleInfoLogger.log(logging.INFO, str("Completed configuration of session manager on server {0}").format(serverName))
                        except:
                            (exception, parms, tback) = sys.exc_info()

                            errorLogger.log(logging.ERROR, str("An error occurred configuring session manager {0} on server {1}: {2} {3}").format(targetTuningParams, targetServer, str(exception), str(parms)))
                            consoleErrorLogger.log(logging.ERROR, str("An error occurred session manager chains on server {0}. Please review logs.").format(serverName))
                        #endtry
                    #endif
                #endif

                #
                # Save workspace changes
                #
                try:
                    debugLogger.log(logging.DEBUG, "Calling saveWorkspaceChanges()")
                    debugLogger.log(logging.DEBUG, "EXEC: saveWorkspaceChanges()")

                    saveWorkspaceChanges()

                    debugLogger.log(logging.DEBUG, "All workspace changes saved to master repository.")
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository: {0} {1}").format(str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred saving configuration changes to the master repository. Please review logs."))
                #endtry

                #
                # Synchronize nodes
                #
                try:
                    debugLogger.log(logging.DEBUG, "Calling syncNodes()")
                    debugLogger.log(logging.DEBUG, "EXEC: syncNodes(nodeList, targetCell)")

                    syncNodes(nodeList, targetCell)

                    debugLogger.log(logging.DEBUG, str("Node synchronization complete for cell {0}.").format(targetCell))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred synchronizing changes to cell {0}: {1} {2}").format(targetCell, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred synchronizing changes to cell {0}. Please review logs.").format(targetCell))
                #endtry
            else:
                errorLogger.log(logging.ERROR, str("No application server was found with node name {0} and server name {1}.").format(nodeName, serverName))
                consoleErrorLogger.log(logging.ERROR, str("No application server was found with node name {0} and server name {1}.").format(nodeName, serverName))
            #endif
        else:
            errorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
            consoleErrorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log(logging.ERROR, "No configuration file was provided.")
        consoleErrorLogger.log(logging.ERROR, "No configuration file was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: configureApplicationServer()")
#enddef

def showServerStatus():
    debugLogger.log(logging.DEBUG, "ENTER: showServerStatus()")

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, "server-information", "node-name")
        serverName = returnPropertyConfiguration(configFile, "server-information", "server-name")
        targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(nodeName, serverName))

        debugLogger.log(logging.DEBUG, nodeName)
        debugLogger.log(logging.DEBUG, serverName)
        debugLogger.log(logging.DEBUG, targetServer)

        if (len(targetServer) != 0):
            #
            # Get the current status of the server
            #
            try:
                debugLogger.log(logging.DEBUG, "Calling getServerStatus()")
                debugLogger.log(logging.DEBUG, "EXEC: getServerStatus(targetServer)")

                serverStatus = getServerStatus(targetServer)

                debugLogger.log(logging.DEBUG, str("Current server state: {0}").format(serverStatus))

                consoleInfoLogger.log(logging.INFO, str("The current status of server {0} on node {1} is {2}").format(serverName, nodeName, serverStatus))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred retrieving the current state of server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurred retrieving the current state of server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
            #endtry
        else:
            errorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
            consoleErrorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log(logging.ERROR, "No configuration file was provided.")
        consoleErrorLogger.log(logging.ERROR, "No configuration file was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: getServerStatus()")
#enddef

def startApplicationServer():
    debugLogger.log(logging.DEBUG, "ENTER: startApplicationServer()")

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, "server-information", "node-name")
        serverName = returnPropertyConfiguration(configFile, "server-information", "server-name")
        startWaitTime = returnPropertyConfiguration(configFile, "server-start-options", "start-wait-time") or "10"
        targetServer = AdminControl.completeObjectName(str("cell={0},node={1},name={2},type=Server,*").format(targetCell, nodeName, serverName))

        debugLogger.log(logging.DEBUG, nodeName)
        debugLogger.log(logging.DEBUG, serverName)
        debugLogger.log(logging.DEBUG, startWaitTime)
        debugLogger.log(logging.DEBUG, targetServer)

        if (len(targetServer) != 0):
            #
            # Start the application server
            #
            try:
                debugLogger.log(logging.DEBUG, "Calling startServer()")
                debugLogger.log(logging.DEBUG, "EXEC: startServer(targetServer, startWaitTime)")

                startServer(targetServer, startWaitTime)

                debugLogger.log(logging.DEBUG, str("An attempt to start server {0} on node {1} has been initiated.").format(serverName, nodeName))

                consoleInfoLogger.log(logging.INFO, str("An attempt to start server {0} on node {1} has been initiated.").format(serverName, nodeName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred trying to start server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurredtrying to start server server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
            #endtry
        else:
            errorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
            consoleErrorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log(logging.ERROR, "No configuration file was provided.")
        consoleErrorLogger.log(logging.ERROR, "No configuration file was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: startApplicationServer()")
#enddef

def stopApplicationServer():
    debugLogger.log(logging.DEBUG, str("ENTER: stopApplicationServer()"))

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, "server-information", "node-name")
        serverName = returnPropertyConfiguration(configFile, "server-information", "server-name")
        stopServerImmediate = returnPropertyConfiguration(configFile, "server-stop-options", "immediate-stop") or False
        stopServerTerminate = returnPropertyConfiguration(configFile, "server-stop-options", "terminate-stop") or False

        debugLogger.log(logging.DEBUG, nodeName)
        debugLogger.log(logging.DEBUG, serverName)
        debugLogger.log(logging.DEBUG, stopServerImmediate)
        debugLogger.log(logging.DEBUG, stopServerTerminate)

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            #
            # Start the application server
            #
            try:
                debugLogger.log(logging.DEBUG, "Calling stopServer()")
                debugLogger.log(logging.DEBUG, "EXEC: stopServer(serverName, nodeName, stopServerImmediate, stopServerImmediate)")

                stopServer(serverName, nodeName, stopServerImmediate, stopServerImmediate)

                debugLogger.log(logging.DEBUG, str("An attempt to stop server {0} on node {1} has been initiated.").format(serverName, nodeName))

                consoleInfoLogger.log(logging.INFO, str("An attempt to stop server {0} on node {1} has been initiated.").format(serverName, nodeName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred trying to stop server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurredtrying to stop server server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
            #endtry
        else:
            errorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
            consoleErrorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log(logging.ERROR, "No configuration file was provided.")
        consoleErrorLogger.log(logging.ERROR, "No configuration file was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: stopApplicationServer()")
#enddef

def restartApplicationServer():
    debugLogger.log(logging.DEBUG, "ENTER: restartApplicationServer()")

    if (len(configFile) != 0):
        nodeName = returnPropertyConfiguration(configFile, "server-information", "node-name")
        serverName = returnPropertyConfiguration(configFile, "server-information", "server-name")
        restartTimeout = returnPropertyConfiguration(configFile, "server-restart-options", "restart-timeout") or "600"

        debugLogger.log(logging.DEBUG, nodeName)
        debugLogger.log(logging.DEBUG, serverName)
        debugLogger.log(logging.DEBUG, restartTimeout)

        if ((len(nodeName) != 0) and (len(serverName) != 0)):
            #
            # Start the application server
            #
            try:
                debugLogger.log(logging.DEBUG, "Calling stopServer()")
                debugLogger.log(logging.DEBUG, "EXEC: restartServer(serverName, nodeName, restartTimeout)")

                restartServer(serverName, nodeName, restartTimeout)

                debugLogger.log(logging.DEBUG, str("An attempt to restart server {0} on node {1} has been initiated.").format(serverName, nodeName))

                consoleInfoLogger.log(logging.INFO, str("An attempt to restart server {0} on node {1} has been initiated.").format(serverName, nodeName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred trying to restart server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurredtrying to restart server server {0} on node {1}: {2} {3}").format(serverName, nodeName, str(exception), str(parms)))
            #endtry
        else:
            errorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
            consoleErrorLogger.log(logging.ERROR, "No node/server information was found in the provided configuration file.")
        #endif
    else:
        errorLogger.log(logging.ERROR, "No configuration file was provided.")
        consoleErrorLogger.log(logging.ERROR, "No configuration file was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: restartApplicationServer()")
#enddef

def printHelp():
    print("This script performs server management tasks.")
    print("Execution: wsadmin.sh -lang jython -f serverManagement.py <option> <configuration file>")
    print("Options are: ")

    print("    configure-deployment-manager: Performs configuration tasks for a deployment manager.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain a value indicating the server name.")
    print("                    This section must contain a value indicating the node name.")
    print("                [server-trace-settings]")
    print("                    This section may contain a value to configure startup trace specifications. If no value is provided, the default value is \"*=info\".")
    print("                    This section may contain a value to configure the trace output type. If no value is provided, the default value is \"SPECIFIED_FILE\".")
    print("                    This section may contain a value to configure the maximum number of trace backup files. If no value is provided, the default value is \"50\".")
    print("                    This section may contain a value to configure the maximum size of the trace file before it is rolled over. If no value is provided, the default value is \"50\".")
    print("                    This section may contain a value to configure the trace filename. If no value is provided, the default value is \"${SERVER_LOG_ROOT}/trace.log\".")
    print("                [server-process-settings]")
    print("                    This section may contain a value to configure the user to run the server as. If no value is provided, the \"runAsUser\" entry is not configured.")
    print("                    This section may contain a value to configure the group to run the server as. If no value is provided, the \"runAsGroup\" entry is not configured.")
    print("                [server-jvm-settings]")
    print("                    This section may contain a value to configure the initial JVM heap size (in megabytes). If no value is provided, the default value is \"1024\".")
    print("                    This section may contain a value to configure the maximum JVM heap size (in megabytes). If no value is provided, the default value is \"1024\".")
    print("                [server-hamanager]")
    print("                    This section may contain a value to enable or disable the HA Manager service.")

    print("    configure-nodeagent: Performs configuration tasks for a nodeagent.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain a value indicating the server name.")
    print("                    This section must contain a value indicating the node name.")
    print("                [server-trace-settings]")
    print("                    This section may contain a value to configure startup trace specifications. If no value is provided, the default value is \"*=info\".")
    print("                    This section may contain a value to configure the trace output type. If no value is provided, the default value is \"SPECIFIED_FILE\".")
    print("                    This section may contain a value to configure the maximum number of trace backup files. If no value is provided, the default value is \"50\".")
    print("                    This section may contain a value to configure the maximum size of the trace file before it is rolled over. If no value is provided, the default value is \"50\".")
    print("                    This section may contain a value to configure the trace filename. If no value is provided, the default value is \"${SERVER_LOG_ROOT}/trace.log\".")
    print("                [server-process-settings]")
    print("                    This section may contain a value to configure the user to run the server as. If no value is provided, the \"runAsUser\" entry is not configured.")
    print("                    This section may contain a value to configure the group to run the server as. If no value is provided, the \"runAsGroup\" entry is not configured.")
    print("                [server-jvm-settings]")
    print("                    This section may contain a value to configure the initial JVM heap size (in megabytes). If no value is provided, the default value is \"512\".")
    print("                    This section may contain a value to configure the maximum JVM heap size (in megabytes). If no value is provided, the default value is \"512\".")

    print("    configure-application-server: Performs configuration tasks for an application server.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain a value indicating the server name.")
    print("                    This section must contain a value indicating the node name.")
    print("                    This section may indicate if the server is a WebSphere Portal server. If no value is provided, the default is \"false\"")
    print("                [server-auto-restart]")
    print("                    This section must contain the server and node names.")
    print("                    This section may contain a value to determine if the nodeagent should automatically start the server if it finds it down. If not provided, the default value is \"STOPPED\"")
    print("                [server-web-container]")
    print("                    This section may contain a value to set the default virtual host. If not provided, the default value is \"default_host\".")
    print("                    This section may contain a value to determine if servlet caching is enabled. If not provided, the default value is \"true\".")
    print("                [server-hamanager]")
    print("                    This section may contain a value to determine if the HA Manager service should be enabled. No default value is provided.")
    print("                [server-trace-settings]")
    print("                    This section may contain a value to configure startup trace specifications. If no value is provided, the default value is \"*=info\".")
    print("                    This section may contain a value to configure the trace output type. If no value is provided, the default value is \"SPECIFIED_FILE\".")
    print("                    This section may contain a value to configure the maximum number of trace backup files. If no value is provided, the default value is 50.")
    print("                    This section may contain a value to configure the maximum size of the trace file before it is rolled over. If no value is provided, the default value is 50.")
    print("                    This section may contain a value to configure the trace filename. If no value is provided, the default value is \"${SERVER_LOG_ROOT}/trace.log\".")
    print("                [server-process-settings]")
    print("                    This section may contain a value to configure the user to run the server as. If no value is provided, the \"runAsUser\" entry is not configured.")
    print("                    This section may contain a value to configure the group to run the server as. If no value is provided, the \"runAsGroup\" entry is not configured.")
    print("                [server-jvm-settings]")
    print("                    This section may contain a value to configure the initial JVM heap size (in megabytes). If no value is provided, the default value is \"2048\".")
    print("                    This section may contain a value to configure the maximum JVM heap size (in megabytes). If no value is provided, the default value is \"2048\".")
    print("                [server-thread-pools]")
    print("                    This section may contain a value to configure the initial server startup thread pool minimum size. No default is provided.")
    print("                    This section may contain a value to configure the initial server startup thread pool maximum size. No default is provided.")
    print("                    This section may contain a value to configure the initial web container thread pool minimum size. No default is provided.")
    print("                    This section may contain a value to configure the initial web container thread pool maximum size. No default is provided.")
    print("                    This section may contain a value to configure the initial HA Manager thread pool minimum size. No default is provided.")
    print("                    This section may contain a value to configure the initial HA Manager thread pool maximum size. No default is provided.")
    print("                        NOTE: If the [server-hamanger] section disables the HA Manager service, these values should be set to \"0\".")
    print("                    This section may contain a list of thread pools to configure. No default is provided.")
    print("                [server-tcp-channels]")
    print("                    This section may contain a value to configure the maximum number of open TCP connections. No default is provided.")
    print("                [server-http-channels]")
    print("                    This section may contain a value to configure the maximum number of open TCP connections. No default is provided.")
    print("                [server-container-chains]")
    print("                    This section may contain a list of container chains to skip. No default is provided.")
    print("                [server-tuning-params]")
    print("                    This section may contain a value indicating the session write content policy. If no value is provided, the default is \"ONLY_UPDATED_ATTRIBUTES\"")
    print("                    This section may contain a value indicating the session write frequency policy. If no value is provided, the default is \"END_OF_SERVLET_SERVICE\"")
    print("                [server-cookie-settings]")
    print("                    This section may contain a value indicating the name of the session cookie. If no value is provided, the default is \"JSESSIONID\"")
    print("                    This section may contain a value indicating the path for the session cookie. If no value is provided, the default is \"/\"")

    print("    server-status: Retrieves and displays the current status of a given server on a node.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain a value indicating the server name.")
    print("                    This section must contain a value indicating the node name.")

    print("    start-server: Starts a server on a given node.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain a value indicating the server name.")
    print("                    This section must contain a value indicating the node name.")
    print("                [server-start-options]")
    print("                    This section may contain a value to determine a wait time to start the server (in seconds). If no value is provided, the default value is \"10\".")

    print("    stop-server: Stops a server on a given node.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain a value indicating the server name.")
    print("                    This section must contain a value indicating the node name.")
    print("                [server-stop-options]")
    print("                    This section may contain a value to determine if the server should be immediately stopped. If no value is provided, the default value is \"False\".")
    print("                    This section may contain a value to determine if the server should be terminated (killed). If no value is provided, the default value is \"False\".")

    print("    restart-server: Restarts a server on a given node.")
    print("        <configuration file>: The configuration file containing the information necessary to make appropriate changes.")
    print("            The provided configuration file must contain the following sections:")
    print("                [server-information]")
    print("                    This section must contain a value indicating the server name.")
    print("                    This section must contain a value indicating the node name.")
    print("                [server-restart-options]")
    print("                    This section may contain a value to determine the timeout for the restart operation (in seconds). If no value is provided, the default value is \"600\".")
#enddef

##################################
# main
#################################
if (len(sys.argv) == 0):
    printHelp()
else:
    configFile = str(sys.argv[1])

    if (os.path.exists(configFile)) and (os.access(configFile, os.R_OK)):
        if (sys.argv[0] == "configure-deployment-manager"):
            configureDeploymentManager()
        elif (sys.argv[0] == "configure-nodeagent"):
            configureNodeAgent()
        elif (sys.argv[0] == "configure-application-server"):
            configureApplicationServer()
        elif (sys.argv[0] == "add-shared-library"):
            addSharedLibraryToServer()
        elif (sys.argv[0] == "server-status"):
            showServerStatus()
        elif (sys.argv[0] == "start-server"):
            startApplicationServer()
        elif (sys.argv[0] == "stop-server"):
            stopApplicationServer()
        elif (sys.argv[0] == "restart-server"):
            restartApplicationServer()
        else:
            printHelp()
        #endif
    else:
        print("The provided configuration file either does not exist or cannot be read.")
    #endif
#endif
