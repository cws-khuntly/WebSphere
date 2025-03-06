#==============================================================================
#
#          FILE:  manageApplications.py
#         USAGE:  wsadmin.sh -lang jython -f manageApplications.py <options>
#     ARGUMENTS:  See help section
#   DESCRIPTION:  Performs application management functions
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

lineSplit = java.lang.System.getProperty('line.separator')
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def listApps():
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#listApps()"))
    debugLogger.log(logging.DEBUG, str("Listing installed applications in cell {0}").format(targetCell))
    consoleInfoLogger.log(logging.INFO, str("Listing installed applications in cell {0}").format(targetCell))

    appList = AdminApp.list().split(lineSplit)

    debugLogger.log(logging.DEBUG, str(appList))

    if (len(appList) != 0):
        for app in (appList):
            debugLogger.log(logging.DEBUG, str(app))

            consoleInfoLogger.log(logging.INFO, str("Application: {0}").format(app))
 
            continue
        #endfor
    else:
        consoleErrorLogger.log(logging.ERROR, str("No installed applications were found in cell {0}").format(targetCell))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#listApps()"))
#enddef

def exportApp(appName):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#exportApp(appName)"))
    debugLogger.log(logging.DEBUG, str(appName))

    print(str("Exporting application {0}..").format(appName))

    exportPath = str(os.path.expanduser("{0}") + "{1}").format("~", "/workspace/WebSphere/AppServer/files/EarFiles")

    debugLogger.log(logging.DEBUG, str(exportPath))

    try:
        os.makedirs(exportPath, exist_ok=True)

        debugLogger.log(logging.DEBUG, str("Executing command AdminApp.export()..."))
        debugLogger.log(logging.DEBUG, str("EXEC: AdminApp.export(str(\"{0}, {1}, {2}\").format(appName, str(\"{0}/{1}.ear\").format(exportPath, appName)))"))

        AdminApp.export(str("{0}, {1}, {2}").format(appName, str("{0}/{1}.ear").format(exportPath, appName)))
    except:
        (exception, parms, tback) = sys.exc_info()

        errorLogger.log(logging.ERROR, str("An error occurred exporting application {0}: {2} {3}").format(appName, str(exception), str(parms)))
        consoleErrorLogger.log(logging.ERROR, str("An error occurred exporting application {0}. Please review logs.").format(appName))
    #endtry

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#exportApp(appName)"))
#enddef

def remapApplication(appName, targetCluster, vhostName = "default_host"):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#remapApplication(appName, targetCluster, vhostName = \"default_host\")"))
    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(targetCluster))
    debugLogger.log(logging.DEBUG, str(vhostName))

    debugLogger.log(logging.DEBUG, str("Executing command AdminApp.listModules()..."))
    debugLogger.log(logging.DEBUG, str("EXEC: AdminApp.listModules(\"{0}, -server\").split(\"#\")[1].split(\"+\")[0].format(appName)"))

    moduleName = AdminApp.listModules("{0}, -server").split("#")[1].split("+")[0].format(appName)

    debugLogger.log(logging.DEBUG, str(moduleName))

    if (moduleName):
        try:
            debugLogger.log(logging.DEBUG, str("Executing command AdminApp.edit()..."))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminApp.edit(\"{0}, [-MapModulesToServers [[{1} {2}},WEB-INF/web.xml WebSphere:cell=dmgrCell01,cluster={3} {4}]]]\").format(appName, moduleName, targetCluster, vhostName)"))

            AdminApp.edit('{0}, [-MapModulesToServers [[{1} {2}},WEB-INF/web.xml WebSphere:cell=dmgrCell01,cluster={3} {4}]]]').format(appName, moduleName, targetCluster, vhostName)

            infoLogger.log(logging.INFO, str("Application {0} remapped to cluster {1}").format(appName, targetCluster))
            consoleInfoLogger.log(logging.INFO, str("Application {0} remapped to cluster {1}").format(appName, targetCluster))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred updating application {0} to cluster {1}: {2} {3}").format(appName, targetCluster, str(exception), str(parms)))
            consoleErrorLogger.log(logging.ERROR, str("An error occurred updating application {0} to cluster {1}. Please review logs.").format(appName, targetCluster))
        finally:
            saveWorkspaceChanges()
            syncAllNodes(nodeList)
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No module was found for application {0}").format(appName))
        consoleErrorLogger.log(logging.ERROR, str("No module was found for application {0}").format(appName))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#remapApplication(appName, targetCluster, vhostName = \"default_host\")"))
#enddef

def installSingleModuleToSingleHost(appPath, clusterName, webserverNodeName, webserverName, vhostName = "default_host"):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#installSingleModuleToSingleHost(appPath, clusterName, webserverNodeName, webserverName, vhostName = \"default_host\")"))
    debugLogger.log(logging.DEBUG, str(appPath))
    debugLogger.log(logging.DEBUG, str(clusterName))
    debugLogger.log(logging.DEBUG, str(webserverNodeName))
    debugLogger.log(logging.DEBUG, str(webserverName))
    debugLogger.log(logging.DEBUG, str(vhostName))

    appFileName = getFileNameFromPath(str(appPath))
    appName = getAppDisplayName(str(appPath))
    appModuleName = removeExtraExtension(getAppModuleName(str(appPath)), 4)
    appWarName = getAppWarName(str(appPath))

    debugLogger.log(logging.DEBUG, str(appFileName))
    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(appModuleName))
    debugLogger.log(logging.DEBUG, str(appWarName))

    appMappingOptions = (str("-MapModulesToServers [[{0} {1},WEB-INF/web.xml "
        "WebSphere:cell={2},cluster={3}+WebSphere:cell={2},node={4},server={5}]]"
    ).format(appModuleName, appWarName, targetCell, clusterName, webserverNodeName, webserverName))

    debugLogger.log(logging.DEBUG, str(appMappingOptions))

    if (len(appMappingOptions != 0)):
        appInstallOptions = (str("[-nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/{0}/{1} -distributeApp "
            "-nouseMetaDataFromBinary -nodeployejb -appname {2} -createMBeansForResources -noreloadEnabled -nodeployws "
            "-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude "
            "-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema {4}]"
        ).format(targetCell, appFileName, appName, str(appMappingOptions).strip("()")))

        debugLogger.log(logging.DEBUG, str(appInstallOptions))

        if (len(appInstallOptions) != 0):
            try:
                debugLogger.log(logging.DEBUG, str("Executing command installApplicationModuleToCluster()..."))
                debugLogger.log(logging.DEBUG, str("EXEC: installApplicationModuleToCluster(str(appInstallOptions).strip(\"()\"))"))

                installApplicationModuleToCluster(str(appInstallOptions).strip("()"))

                infoLogger.log(logging.INFO, str("Installation of {0} to cluster {1} complete.").format(appName, clusterName))
                consoleInfoLogger.log(logging.INFO, str("Installation of {0} to cluster {1} complete.").format(appName, clusterName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred installing application {0} to cluster {1}: {1} {2}").format(appPath, clusterName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurred installing application {0} to cluster {1}. Please review logs.").format(appPath, clusterName))
            finally:
                saveWorkspaceChanges()
                syncAllNodes(nodeList)
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No application installation options were found for application {0}. Cannot install application.").format(appName))
            consoleErrorLogger.log(logging.ERROR, str("No application installation options were found for application {0}. Cannot install application.").format(appName))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No application mapping options were found for application {0}. Cannot install application.").format(appName))
        consoleErrorLogger.log(logging.ERROR, str("No application mapping options were found for application {0}. Cannot install application.").format(appName))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#installSingleModuleToSingleHost(appPath, clusterName, webserverNodeName, webserverName, vhostName = \"default_host\")"))
#enddef

def installSingleModuleToMultipleHosts(appPath, clusterName, webserverNodeName1, webserverName1, webserverNodeName2, webserverName2, vhostName = "default_host"):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#installSingleModuleToMultipleHosts(appPath, clusterName, webserverNodeName1, webserverName1, webserverNodeName2, webserverName2, vhostName = \"default_host\")"))
    debugLogger.log(logging.DEBUG, str(appPath))
    debugLogger.log(logging.DEBUG, str(clusterName))
    debugLogger.log(logging.DEBUG, str(webserverNodeName1))
    debugLogger.log(logging.DEBUG, str(webserverName1))
    debugLogger.log(logging.DEBUG, str(webserverNodeName2))
    debugLogger.log(logging.DEBUG, str(webserverName2))
    debugLogger.log(logging.DEBUG, str(vhostName))

    appFileName = getFileNameFromPath(str(appPath))
    appName = getAppDisplayName(str(appPath))
    appModuleName = removeExtraExtension(getAppModuleName(str(appPath)), 4)
    appWarName = getAppWarName(str(appPath))

    debugLogger.log(logging.DEBUG, str(appFileName))
    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(appModuleName))
    debugLogger.log(logging.DEBUG, str(appWarName))

    appMappingOptions = (str("-MapModulesToServers [[ {0} {1},WEB-INF/web.xml "
        "WebSphere:cell={2},cluster={3}+WebSphere:cell={2},node={4},server={5}+WebSphere:cell={2},node={6},server={7}]]"
    ).format(appModuleName, appWarName, targetCell, clusterName, webserverNodeName1, webserverName1, webserverNodeName2, webserverName2))

    debugLogger.log(logging.DEBUG, str(appMappingOptions))

    appInstallOptions = (str("[-nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/{0}/{1} -distributeApp "
        "-nouseMetaDataFromBinary -nodeployejb -appname {2} -createMBeansForResources -noreloadEnabled -nodeployws "
        "-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude "
        "-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema {4}]"
    ).format(targetCell, appFileName, appName, str(appMappingOptions).strip("()")))

    debugLogger.log(logging.DEBUG, str(appInstallOptions))

    if (len(appMappingOptions != 0)):
        appInstallOptions = (str("[-nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/{0}/{1} -distributeApp "
            "-nouseMetaDataFromBinary -nodeployejb -appname {2} -createMBeansForResources -noreloadEnabled -nodeployws "
            "-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude "
            "-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema {4}]"
        ).format(targetCell, appFileName, appName, str(appMappingOptions).strip("()")))

        debugLogger.log(logging.DEBUG, str(appInstallOptions))

        if (len(appInstallOptions) != 0):
            try:
                debugLogger.log(logging.DEBUG, str("Executing command installApplicationModuleToCluster()..."))
                debugLogger.log(logging.DEBUG, str("EXEC: installApplicationModuleToCluster(str(appInstallOptions).strip(\"()\"))"))

                installApplicationModuleToCluster(str(appInstallOptions).strip("()"))

                infoLogger.log(logging.INFO, str("Installation of {0} to cluster {1} complete.").format(appName, clusterName))
                consoleInfoLogger.log(logging.INFO, str("Installation of {0} to cluster {1} complete.").format(appName, clusterName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred installing application {0} to cluster {1}: {1} {2}").format(appPath, clusterName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurred installing application {0} to cluster {1}. Please review logs.").format(appPath, clusterName))
            finally:
                saveWorkspaceChanges()
                syncAllNodes(nodeList)
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No application installation options were found for application {0}. Cannot install application.").format(appName))
            consoleErrorLogger.log(logging.ERROR, str("No application installation options were found for application {0}. Cannot install application.").format(appName))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No application mapping options were found for application {0}. Cannot install application.").format(appName))
        consoleErrorLogger.log(logging.ERROR, str("No application mapping options were found for application {0}. Cannot install application.").format(appName))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#installSingleModuleToMultipleHosts(appPath, clusterName, webserverNodeName1, webserverName1, webserverNodeName2, webserverName2, vhostName = \"default_host\")"))
#enddef

def updateSingleModuleToSingleHost(appPath, clusterName, webserverNodeName, webserverName, vhostName = "default_host"):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#updateSingleModuleToSingleHost(appPath, clusterName, webserverNodeName, webserverName, vhostName = \"default_host\")"))
    debugLogger.log(logging.DEBUG, str(appPath))
    debugLogger.log(logging.DEBUG, str(clusterName))
    debugLogger.log(logging.DEBUG, str(webserverNodeName))
    debugLogger.log(logging.DEBUG, str(webserverName))
    debugLogger.log(logging.DEBUG, str(vhostName))

    appFileName = getFileNameFromPath(str(appPath))
    appName = getAppDisplayName(str(appPath))
    appModuleName = removeExtraExtension(getAppModuleName(str(appPath)), 4)
    appWarName = getAppWarName(str(appPath))

    debugLogger.log(logging.DEBUG, str(appFileName))
    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(appModuleName))
    debugLogger.log(logging.DEBUG, str(appWarName))

    appMappingOptions = (str("-MapModulesToServers [[{0} {1},WEB-INF/web.xml "
        "WebSphere:cell={2},cluster={3}+WebSphere:cell={2},node={4},server={5}]]"
    ).format(appModuleName, appWarName, targetCell, clusterName, webserverNodeName, webserverName))

    debugLogger.log(logging.DEBUG, str(appMappingOptions))

    if (len(appMappingOptions != 0)):
        appInstallOptions = (str("[-nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/{0}/{1} -distributeApp "
            "-nouseMetaDataFromBinary -nodeployejb -appname {2} -createMBeansForResources -noreloadEnabled -nodeployws "
            "-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude "
            "-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema {4}]"
        ).format(targetCell, appFileName, appName, str(appMappingOptions).strip("()")))

        debugLogger.log(logging.DEBUG, str(appInstallOptions))

        if (len(appInstallOptions) != 0):
            try:
                debugLogger.log(logging.DEBUG, str("Executing command updateApplicationModuleToCluster()..."))
                debugLogger.log(logging.DEBUG, str("EXEC: updateApplicationModuleToCluster(str(appInstallOptions).strip(\"()\"))"))

                updateApplicationModuleToCluster(str(appInstallOptions).strip("()"))

                infoLogger.log(logging.INFO, str("Update of application {0} to cluster {1} complete.").format(appName, clusterName))
                consoleInfoLogger.log(logging.INFO, str("Update of application {0} to cluster {1} complete.").format(appName, clusterName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred updating application {0} to cluster {1}: {1} {2}").format(appPath, clusterName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurred updating application {0} to cluster {1}. Please review logs.").format(appPath, clusterName))
            finally:
                saveWorkspaceChanges()
                syncAllNodes(nodeList)
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No application installation options were found for application {0}. Cannot update application.").format(appName))
            consoleErrorLogger.log(logging.ERROR, str("No application installation options were found for application {0}. Cannot update application.").format(appName))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No application mapping options were found for application {0}. Cannot update application.").format(appName))
        consoleErrorLogger.log(logging.ERROR, str("No application mapping options were found for application {0}. Cannot update application.").format(appName))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#updateSingleModuleToSingleHost(appPath, clusterName, webserverNodeName, webserverName, vhostName = \"default_host\")"))
#enddef

def installSingleEJBModuleToSingleHost(appPath, clusterName):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#installSingleEJBModuleToSingleHost(appPath, clusterName)"))
    debugLogger.log(logging.DEBUG, str(appPath))
    debugLogger.log(logging.DEBUG, str(clusterName))
    debugLogger.log(logging.DEBUG, str(webserverNodeName))
    debugLogger.log(logging.DEBUG, str(webserverName))
    debugLogger.log(logging.DEBUG, str(vhostName))

    appFileName = getFileNameFromPath(str(appPath))
    appName = getAppDisplayName(str(appPath))
    appModuleName = removeExtraExtension(getAppModuleName(str(appPath)), 4)
    appWarName = getAppWarName(str(appPath))

    debugLogger.log(logging.DEBUG, str(appFileName))
    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(appModuleName))
    debugLogger.log(logging.DEBUG, str(appWarName))

    appMappingOptions = (str("-MapModulesToServers [[{0} {1},WEB-INF/web.xml "
        "WebSphere:cell={2},cluster={3}+WebSphere:cell={2},node={4},server={5}]]"
    ).format(appModuleName, appWarName, targetCell, clusterName, webserverNodeName, webserverName))

    debugLogger.log(logging.DEBUG, str(appMappingOptions))

    if (len(appMappingOptions != 0)):
        appInstallOptions = (str("[-nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/{0}/{1} -distributeApp "
            "-nouseMetaDataFromBinary -deployejb -appname {2} -createMBeansForResources -noreloadEnabled -nodeployws "
            "-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude "
            "-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema {4}]"
        ).format(targetCell, appFileName, appName, str(appMappingOptions).strip("()")))

        debugLogger.log(logging.DEBUG, str(appInstallOptions))

        if (len(appInstallOptions) != 0):
            try:
                debugLogger.log(logging.DEBUG, str("Executing command installEJBApplicationModuleToCluster()..."))
                debugLogger.log(logging.DEBUG, str("EXEC: installEJBApplicationModuleToCluster(str(appInstallOptions).strip(\"()\"))"))

                installEJBApplicationModuleToCluster(str(appInstallOptions).strip("()"))

                infoLogger.log(logging.INFO, str("Installation of EJB application {0} to cluster {1} complete.").format(appName, clusterName))
                consoleInfoLogger.log(logging.INFO, str("Installation of EJB application {0} to cluster {1} complete.").format(appName, clusterName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred installing EJB application {0} to cluster {1}: {1} {2}").format(appPath, clusterName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurred installing EJB application {0} to cluster {1}. Please review logs.").format(appPath, clusterName))
            finally:
                saveWorkspaceChanges()
                syncAllNodes(nodeList)
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No application installation options were found for EJB application {0}. Cannot install application.").format(appName))
            consoleErrorLogger.log(logging.ERROR, str("No application installation options were found for EJB application {0}. Cannot install application.").format(appName))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No application mapping options were found for EJB application {0}. Cannot install application.").format(appName))
        consoleErrorLogger.log(logging.ERROR, str("No application mapping options were found for EJB application {0}. Cannot install application.").format(appName))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#installSingleEJBModuleToSingleHost(appPath, clusterName"))
#enddef

def updateSingleEJBModuleToSingleHost(appPath, clusterName):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#updateSingleEJBModuleToSingleHost(appPath, clusterName)"))
    debugLogger.log(logging.DEBUG, str(appPath))
    debugLogger.log(logging.DEBUG, str(clusterName))
    debugLogger.log(logging.DEBUG, str(webserverNodeName))
    debugLogger.log(logging.DEBUG, str(webserverName))
    debugLogger.log(logging.DEBUG, str(vhostName))

    appFileName = getFileNameFromPath(str(appPath))
    appName = getAppDisplayName(str(appPath))
    appModuleName = removeExtraExtension(getAppModuleName(str(appPath)), 4)
    appWarName = getAppWarName(str(appPath))

    debugLogger.log(logging.DEBUG, str(appFileName))
    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(appModuleName))
    debugLogger.log(logging.DEBUG, str(appWarName))

    appMappingOptions = (str("-MapModulesToServers [[{0} {1},WEB-INF/web.xml "
        "WebSphere:cell={2},cluster={3}+WebSphere:cell={2},node={4},server={5}]]"
    ).format(appModuleName, appWarName, targetCell, clusterName, webserverNodeName, webserverName))

    debugLogger.log(logging.DEBUG, str(appMappingOptions))

    if (len(appMappingOptions != 0)):
        appInstallOptions = (str("[-nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/{0}/{1} -distributeApp "
            "-nouseMetaDataFromBinary -deployejb -appname {2} -createMBeansForResources -noreloadEnabled -nodeployws "
            "-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude "
            "-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema {4}]"
        ).format(targetCell, appFileName, appName, str(appMappingOptions).strip("()")))

        debugLogger.log(logging.DEBUG, str(appInstallOptions))

        if (len(appInstallOptions) != 0):
            try:
                debugLogger.log(logging.DEBUG, str("Executing command updateEJBApplicationModuleToCluster()..."))
                debugLogger.log(logging.DEBUG, str("EXEC: updateEJBApplicationModuleToCluster(str(appInstallOptions).strip(\"()\"))"))

                updateEJBApplicationModuleToCluster(str(appInstallOptions).strip("()"))

                infoLogger.log(logging.INFO, str("Update of EJB application {0} to cluster {1} complete.").format(appName, clusterName))
                consoleInfoLogger.log(logging.INFO, str("Update of EJB application {0} to cluster {1} complete.").format(appName, clusterName))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred updating EJB application {0} to cluster {1}: {1} {2}").format(appPath, clusterName, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurred updating EJB application {0} to cluster {1}. Please review logs.").format(appPath, clusterName))
            finally:
                saveWorkspaceChanges()
                syncAllNodes(nodeList)
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No application installation options were found for EJB application {0}. Cannot update application.").format(appName))
            consoleErrorLogger.log(logging.ERROR, str("No application installation options were found for EJB application {0}. Cannot update application.").format(appName))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No application installation options were found for EJB application {0}. Cannot update application.").format(appName))
        consoleErrorLogger.log(logging.ERROR, str("No application mapping options were found for EJB application {0}. Cannot update application.").format(appName))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#updateSingleEJBModuleToSingleHost(appPath, clusterName"))
#enddef

def modifyStartupWeightForApplication(appPath, startWeight = 50):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#modifyStartupWeightForApplication(appPath, startWeight)"))
    debugLogger.log(logging.DEBUG, str(appPath))
    debugLogger.log(logging.DEBUG, str(startWeight))

    appName = getAppDisplayName(appPath)
    appDeployment = AdminConfig.getid(str("/Deployment:{0}/").format(appName))

    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(appDeployment))

    if (len(appDeployment) != 0):
        appDeploymentObject = AdminConfig.showAttribute(appDeployment, "deployedObject")

        debugLogger.log(logging.DEBUG, str(appDeploymentObject))

        if (len(appDeploymentObject != 0)):
            try:
                debugLogger.log(logging.DEBUG, str("Executing command updateStartupWeightForApplication()..."))
                debugLogger.log(logging.DEBUG, str("EXEC: updateStartupWeightForApplication(str(appDeploymentObject), startWeight)"))

                updateStartupWeightForApplication(str(appDeploymentObject), startWeight)

                infoLogger.log(logging.INFO, str("Update of application {0} complete. New startup weight: {2}").format(appName, startWeight))
                consoleInfoLogger.log(logging.INFO, str("Update of application {0} complete. New startup weight: {2}.").format(appName, startWeight))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred updating application {0} with start weight of {1}: {1} {2}").format(appName, startWeight, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurred updating application {0} with start weight of {1}. Please review logs.").format(appName, startWeight))
            finally:
                saveWorkspaceChanges()
                syncAllNodes(nodeList)
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application").format(appName, targetCell))
            consoleErrorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application.").format(appName, targetCell))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application").format(appName, targetCell))
        consoleErrorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application.").format(appName, targetCell))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#modifyStartupWeightForApplication(appPath, startWeight"))
#enddef

def changeApplicationStatus(appName, newStatus = "true"):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#changeApplicationStatus(appName, newStatus = \"true\")"))
    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(newStatus))

    appDeployment = AdminConfig.getid(str("/Deployment:{0}/").format(appName))
    appDeploymentObject = AdminConfig.showAttribute(appDeployment, "deployedObject")

    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(appDeployment))

    if (len(appDeployment) != 0):
        debugLogger.log(logging.DEBUG, str(appDeploymentObject))

        if (len(appDeploymentObject != 0)):
            try:
                debugLogger.log(logging.DEBUG, str("Executing command updateStartupWeightForApplication()..."))
                debugLogger.log(logging.DEBUG, str("EXEC: updateStartupWeightForApplication(str(appDeploymentObject), newStatus)"))

                updateStartupWeightForApplication(str(appDeploymentObject), newStatus)

                infoLogger.log(logging.INFO, str("Update of application {0} complete. New startup weight: {2}").format(appName, newStatus))
                consoleInfoLogger.log(logging.INFO, str("Update of application {0} complete. New startup weight: {2}.").format(appName, newStatus))
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred updating application {0} with start weight of {1}: {1} {2}").format(appName, newStatus, str(exception), str(parms)))
                consoleErrorLogger.log(logging.ERROR, str("An error occurred updating application {0} with start weight of {1}. Please review logs.").format(appName, newStatus))
            finally:
                saveWorkspaceChanges()
                syncAllNodes(nodeList)
            #endtry
        else:
            errorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application.").format(appName, targetCell))
            consoleErrorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application.").format(appName, targetCell))
        #endif
    else:
        errorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application").format(appName, targetCell))
        consoleErrorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application.").format(appName, targetCell))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#modifyStartupWeightForApplication(appName, newStatus"))
#enddef

def performAppUninstall(appName):
    debugLogger.log(logging.DEBUG, str("ENTER: manageApplications#performAppUninstall(appName)"))
    debugLogger.log(logging.DEBUG, str(appName))

    appDeployment = AdminConfig.getid(str("/Deployment:{0}/").format(appName))

    debugLogger.log(logging.DEBUG, str(appDeployment))

    if (len(appDeployment) != 0):
        try:
            debugLogger.log(logging.DEBUG, str("Executing command removeInstalledApplication()..."))
            debugLogger.log(logging.DEBUG, str("EXEC: removeInstalledApplication(appName)"))

            removeInstalledApplication(appName)

            infoLogger.log(logging.INFO, str("Removal of application {0} complete.").format(appName))
            consoleInfoLogger.log(logging.INFO, str("Removal of application {0} complete.").format(appName))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred removing application {0}: {1} {2}").format(appName, str(exception), str(parms)))
            consoleErrorLogger.log(logging.ERROR, str("An error occurred removing application {0}. Please review logs.").format(appName))
        finally:
            saveWorkspaceChanges()
            syncAllNodes(nodeList)
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application").format(appName, targetCell))
        consoleErrorLogger.log(logging.ERROR, str("No application deployment was found for application {0} in cell {1}. Cannot update application.").format(appName, targetCell))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: manageApplications#performAppUninstall(appName"))
#enddef

def printHelp():
    print("This script performs an application management.")
    print("Execution: wsadmin.sh -lang jython -f applicationManagement.py <options>")
    print("Options are: ")
    print("    list-installed-applications: Lists all installed applications. No changes are made.")

    print("    export-installed-application: Exports an application from the repository. No changes are made.")
    print("        appName: The name of the application to export.")

    print("    remap-application: Re-maps a provided application into a new cluster.")
    print("        appName: The name of the application to remap.")
    print("        clusterName: The name of the cluster to remap the application into.")
    print("        vhostName: The name of the virtual host for the application. Default value: default_host")

    print("    install-single-app: Installs a single EAR into the application repository. Cannot be used if multiple JAR/WAR files exist within the supplied EAR.")
    print("        appPath: The full path to the application binaries.")
    print("        clusterName: The name of the cluster to install the application into.")
    print("        webserverNodeName: The name of the webserver node that will host the application.")
    print("        webserverName: The hostname of the webserver node that will host the application.")
    print("        vhostName: The name of the virtual host for the application. Default value: default_host")

    print("    update-single-app: Updates a single EAR into the application repository. Cannot be used if multiple JAR/WAR files exist within the supplied EAR.")
    print("        appPath: The full path to the application binaries.")
    print("        clusterName: The name of the cluster to install the application into.")
    print("        webserverNodeName: The name of the webserver node that will host the application.")
    print("        webserverName: The hostname of the webserver node that will host the application.")
    print("        vhostName: The name of the virtual host for the application. Default value: default_host")

    print("    install-single-ejb: Installs a single EAR containing an EJB into the application repository. Cannot be used if multiple EJB files exist within the supplied EAR.")
    print("        appPath: The full path to the application binaries.")
    print("        clusterName: The name of the cluster to install the application into.")

    print("    update-single-ejb: Updates a single EAR containing an EJB into the application repository. Cannot be used if multiple EJB files exist within the supplied EAR.")
    print("        appPath: The full path to the application binaries.")
    print("        clusterName: The name of the cluster to install the application into.")

    print("    change-start-weight: Changes the starting weight for a provided application.")
    print("        appPath: The full path to the application binaries.")
    print("        startWeight: The new starting weight for the application. Default value: 50.")

    print("    change-application-status: Changes the application startup status for a provided application.")
    print("        appName: The name of the application to change.")
    print("        newStatus: The new startup status for the application. Default value: true.")

    print("    uninstall-application: Removes a provided application from the repository.")
    print("        appName: The name of the application to remove.")
#enddef

##################################
# main
#################################
if (len(sys.argv) != 0):
    if (sys.argv[0] == "list-installed-applications"):
        listApps()
    elif (sys.argv[0] == "export-installed-application"):
        if (len(sys.argv) == 2):
            exportApp(sys.argv[1])
        else:
            printHelp()
        #endif
    elif (sys.argv[0] == "remap-application"):
        if (len(sys.argv) == 3):
            remapApplication(sys.argv[1], sys.argv[2])
        elif (len(sys.argv) == 4):
            remapApplication(sys.argv[1], sys.argv[2], sys.argv[3])
        else:
            ## no options supplied
            printHelp()
        #endif
    elif (sys.argv[0] == "install-single-app"):
        if (len(sys.argv) == 5):
            installSingleModule(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
        elif (len(sys.argv) == 6):
            installSingleModule(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
        else:
            ## no options supplied
            printHelp()
        #endif
    elif (sys.argv[0] == "update-single-app"):
        if (len(sys.argv) == 5):
            installSingleModule(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
        elif (len(sys.argv) == 6):
            installSingleModule(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
        else:
            ## no options supplied
            printHelp()
        #endif
    elif (sys.argv[0] == "install-single-ejb"):
        if (len(sys.argv) == 3):
            installSingleEJBModule(sys.argv[1], sys.argv[2])
        else:
            ## no options supplied
            printHelp()
        #endif
    elif (sys.argv[0] == "update-single-ejb"):
        if (len(sys.argv) == 3):
            updateSingleEJBModule(sys.argv[1], sys.argv[2])
        else:
            ## no options supplied
            printHelp()
        #endif
    elif (sys.argv[0] == "change-start-weight"):
        if (len(sys.argv) == 2):
            modifyStartupWeightForApplication(sys.argv[1])
        elif (len(sys.argv) == 3):
            modifyStartupWeightForApplication(sys.argv[1], sys.argv[2])
        else:
            ## no options supplied
            printHelp()
        #endif
    elif (sys.argv[0] == "change-application-status"):
        if (len(sys.argv) == 2):
            changeApplicationStatus(sys.argv[1])
        elif (len(sys.argv) == 3):
            changeApplicationStatus(sys.argv[1], sys.argv[2])
        else:
            ## no options supplied
            printHelp()
        #endif
    elif (sys.argv[0] == "uninstall-application"):
        if (len(sys.argv) == 2):
            performAppUninstall(sys.argv[1])
        else:
            ## no options supplied
            printHelp()
        #endif
    else:
        ## invalid option specified
        printHelp()
    #endif
else:
    ## no arguments were provided
    printHelp()
#endif
