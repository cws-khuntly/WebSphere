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

                    try:
                        debugLogger.log(logging.DEBUG, str("Calling configureWebContainer()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: configureWebContainer(targetServer)"))

                        configureWebContainer(targetServer)

                        debugLogger.log(logging.DEBUG, str("Web Container configuration complete."))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring the web container on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred performing configuration steps for deployment manager {0}. Please review logs.").format(serverName))
                    #endtry

                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setServerTrace()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setServerTrace(targetServer)"))

                        setServerTrace(targetServer)

                        debugLogger.log(logging.DEBUG, str("Server Trace configuration complete."))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring the trace options on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred performing configuration steps for deployment manager {0}. Please review logs.").format(serverName))
                    #endtry

                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setProcessExec()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setProcessExec(targetServer)"))

                        setProcessExec(targetServer)

                        debugLogger.log(logging.DEBUG, str("Process Exec configuration complete."))
                        (targetServer)
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring process execution on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred performing configuration steps for deployment manager {0}. Please review logs.").format(serverName))
                    #endtry

                    try:
                        debugLogger.log(logging.DEBUG, str("Calling setJVMProperties()"))
                        debugLogger.log(logging.DEBUG, str("EXEC: setJVMProperties()"))

                        setJVMProperties()

                        debugLogger.log(logging.DEBUG, str("JVM properties configuration complete."))
                    except:
                        (exception, parms, tback) = sys.exc_info()

                        errorLogger.log(logging.ERROR, str("An error occurred configuring JVM properties on server {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                        consoleErrorLogger.log(logging.ERROR, str("An error occurred performing configuration steps for deployment manager {0}. Please review logs.").format(serverName))
                    #endtry

                    infoLogger.log(logging.INFO, str("Completed configuration for deployment manager {0}.").format(serverName))
                    consoleInfoLogger.log(logging.INFO, str("Completed configuration for deployment manager {0}.").format(serverName))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred performing configuration steps for deployment manager: {0}: {1} {2}").format(targetServer, str(exception), str(parms)))
                    consoleErrorLogger.log(logging.ERROR, str("An error occurred performing configuration steps for deployment manager {0}. Please review logs.").format(serverName))
                finally:
                    debugLogger.log(logging.DEBUG, str("Saving workspace changes and synchronizing the cell.."))

                    saveWorkspaceChanges()
                    syncAllNodes(nodeList, targetCell)

                    infoLogger.log(logging.INFO, str("Workspace changes have been saved and the cell has been synchronized."))
                    consoleInfoLogger.log(logging.INFO, str("Workspace changes have been saved and the cell has been synchronized."))
                #endfor
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
