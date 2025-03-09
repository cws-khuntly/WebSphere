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
                initialHeapSize = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("initial-heap-size"))
                maxHeapSize = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("max-heap-size"))
                genericJVMArguments = returnPropertyConfiguration(configFile, str("server-jvm-settings"), str("jvm-arguments"))

                debugLogger.log(logging.DEBUG, str(initialHeapSize))
                debugLogger.log(logging.DEBUG, str(maxHeapSize))
                debugLogger.log(logging.DEBUG, str(genericJVMArguments))

                if ((len(initialHeapSize) != 0) and (len(maxHeapSize) != 0) and (len(genericJVMArguments) != 0)):
                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setJVMProperties()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments)"))

                        setJVMProperties(serverName, nodeName, initialHeapSize, maxHeapSize, genericJVMArguments)

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

def printHelp():
    print(str("This script performs server management tasks."))
    print(str("Execution: wsadmin.sh -lang jython -f serverManagement.py <option> <configuration file>"))
    print(str("Options are: "))

    print(str("    configure-all-servers: Performs configuration tasks for all servers in the cell."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain the server and node names."))
    print(str("                    This section may contain a value indicating if the server is a Portal server."))
    print(str("                [server-auto-restart]"))
    print(str("                    This section may contain a value to determine the monitoring restart policy for the server. If no value is provided, the default value is \"STOPPED\"."))
    print(str("                [server-default-vhost]"))
    print(str("                    This section may contain a value to configure the default virtualhost. If no value is provided, the default value is \"default_host\"."))
    print(str("                [server-servlet-caching]"))
    print(str("                    This section may contain a value to configure servlet caching. If no value is provided, the default value is \"true\"."))
    print(str("                [server-portlet-caching]"))
    print(str("                    This section may contain a value to configure portlet caching. If no value is provided, the default value is \"true\"."))
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
    print(str("                [server-cookie-settings]"))
    print(str("                    This section may contain a value to configure the cookie name. If no value is provided, the default value is \"JSESSIONID\"."))

    print(str("    configure-specified-server: Performs configuration tasks for a specified server on a node."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain the server and node names."))
    print(str("                    This section may contain a value indicating if the server is a Portal server."))
    print(str("                [server-auto-restart]"))
    print(str("                    This section may contain a value to determine the monitoring restart policy for the server. If no value is provided, the default value is \"STOPPED\"."))
    print(str("                [server-default-vhost]"))
    print(str("                    This section may contain a value to configure the default virtualhost. If no value is provided, the default value is \"default_host\"."))
    print(str("                [server-servlet-caching]"))
    print(str("                    This section may contain a value to configure servlet caching. If no value is provided, the default value is \"true\"."))
    print(str("                [server-portlet-caching]"))
    print(str("                    This section may contain a value to configure portlet caching. If no value is provided, the default value is \"true\"."))
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
    print(str("                [server-cookie-settings]"))
    print(str("                    This section may contain a value to configure the cookie name. If no value is provided, the default value is \"JSESSIONID\"."))

    print(str("    configure-deployment-manager: Performs configuration tasks for a provided deployment manager."))
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

    print(str("    server-status: Retrieves and displays the current status of a given server on a node."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain the server and node names."))

    print(str("    start-server: Starts a server on a given node."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain the server and node names."))
    print(str("                [server-start-wait]"))
    print(str("                    This section may contain a value to determine a wait time to start the server. If no value is provided, the default value is 10 seconds."))

    print(str("    stop-server: Stops a server on a given node."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain the server and node names."))
    print(str("                [server-stop-options]"))
    print(str("                    This section may contain a value to determine if the server should be immediately stopped. If no value is provided, the default value is \"False\"."))
    print(str("                    This section may contain a value to determine if the server should be terminated (killed). If no value is provided, the default value is \"False\"."))

    print(str("    restart-server: Restarts a server on a given node."))
    print(str("        <configuration file>: The configuration file containing the information necessary to make appropriate changes."))
    print(str("            The provided configuration file must contain the following sections:"))
    print(str("                [server-information]"))
    print(str("                    This section must contain the server and node names."))
    print(str("                [server-restart-options]"))
    print(str("                    This section may contain a value to determine the timeout for the restart operation. If no value is provided, the default value is 300 seconds."))
#enddef

##################################
# main
#################################
if (len(sys.argv) == 0):
    printHelp()
else:
    configFile = str(sys.argv[1])

    if (os.path.exists(configFile)) and (os.access(configFile, os.R_OK)):
        if (sys.argv[0] == str("configure-all-servers")):
            configureAllServers()
        elif (sys.argv[0] == str("configure-specified-server")):
            configureTargetServer()
        elif (sys.argv[0] == str("configure-deployment-manager")):
            configureDeploymentManager()
        elif (sys.argv[0] == str("server-status")):
            serverStatus()
        elif (sys.argv[0] == str("start-server")):
            startServer()
        elif (sys.argv[0] == str("stop-server")):
            stopServer()
        elif (sys.argv[0] == str("restart-server")):
            restartServer()
        else:
            printHelp()
        #endif
    else:
        print(str("The provided configuration file either does not exist or cannot be read."))
    #endif
#endif
