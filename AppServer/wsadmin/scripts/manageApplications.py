#==============================================================================
#
#          FILE:  configureDMGR.py
#         USAGE:  wsadmin.sh -lang jython -f configureDMGR.py
#     ARGUMENTS:  wasVersion
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

configureLogging("../config/logging.xml")
consoleLogger = logging.getLogger("console-logger")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")

lineSplit = java.lang.System.getProperty('line.separator')
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def listApps():
    print("Listing all installed applications...")

    appList = AdminApp.list().split(lineSplit)

    if (appList):
        for app in (appList):
            print("Application: %s") % (app)
 
            continue
        #endfor
    else:
        raise ("No installed applications were found.")
    #endif
#enddef

def exportApp(appName):
    print("Exporting application " + appName + "..")

    exportPath = os.path.expanduser('~') + '/workspace/WebSphere/AppServer/files/EarFiles'

    os.makedirs(exportPath, exist_ok=True)

    AdminApp.export(appName, exportPath + '/' + appName + '.ear')
#enddef

def remapApplication(appName, targetCluster, vhostName="default_host"):
    moduleName = AdminApp.listModules('%s, -server').split('#')[1].split('+')[0] % (appName)

    if (moduleName):
        try:
            AdminApp.edit('%s, [ -MapModulesToServers [[ %s %s,WEB-INF/web.xml WebSphere:cell=dmgrCell01,cluster=%s %s]]]') % (appName, moduleName, targetCluster, vhostName)
        except:
            raise ("An error occurred while remapping the applicatin into target cluster %s") % (targetCluster)
        finally:
            saveWorkspaceChanges()
            syncAllNodes(nodeList, targetCell)
        #endtry
    else:
        raise ("No module was located for the provided application.")
    #endif
#enddef

def installSingleModule(appPath, clusterName, webserverNodeName, webserverName, vhostName="default_host"):
    appFileName = getFileNameFromPath(appPath)
    appName = getAppDisplayName(appPath)
    appModuleName = removeExtraExtension(getAppModuleName(appPath), 4)
    appWarName = getAppWarName(appPath)
    appMappingOptions = (
        '-MapModulesToServers [[ %s %s,WEB-INF/web.xml '
        'WebSphere:cell=%s,cluster=%s+WebSphere:cell=%s,node=%s,server=%s %s]]'
    ) % (appModuleName, appWarName, targetCell, clusterName, targetCell, webserverNodeName, webserverName, vhostName)
    appInstallOptions = (
        '[ -nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/%s/%s -distributeApp '
        '-nouseMetaDataFromBinary -nodeployejb -appname %s -createMBeansForResources -noreloadEnabled -nodeployws '
        '-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude '
        '-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema '
        '' + str(appMappingOptions).strip("()") + ']'
    ) % (targetCell, appFileName, appName)

    if (appInstallOptions):
        try:
            print("Installing application %s into cluster %s and webserver %s..") % (appName, clusterName, webserverName)

            AdminApp.install(appPath, str(appInstallOptions).strip("()"))
        except:
            raise ("An error occurred performing the installation. Please review logs.")
        finally:
            saveWorkspaceChanges()
            syncAllNodes(nodeList, targetCell)
        #endtry
    else:
        raise ("No application installation options were found. Cannot install application.")
    #endif
#enddef

def updateSingleModule(appPath, clusterName, webserverNodeName, webserverName, vhostName="default_host"):
    appFileName = getFileNameFromPath(appPath)
    appName = getAppDisplayName(appPath)
    appModuleName = getAppModuleName(appPath)
    appWarName = getAppWarName(appPath)
    appMappingOptions = (
        '-MapModulesToServers [[ %s %s,WEB-INF/web.xml '
        'WebSphere:cell=%s,cluster=%s+WebSphere:cell=%s,node=%s,server=%s]]'
        '-MapWebModToVH [[ %s %s,WEB-INF/web.xml %s ]]'
    ) % (appModuleName, appWarName, targetCell, clusterName, targetCell, webserverNodeName, webserverName, appModuleName, appWarName, vhostName)
    appUpdateOptions = (
        '[ -nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/%s/%s -distributeApp '
        '-nouseMetaDataFromBinary -nodeployejb -appname %s -createMBeansForResources -noreloadEnabled -nodeployws '
        '-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude '
        '-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema '
        '' + str(appMappingOptions).strip("()") + ']'
    ) % (targetCell, appFileName, appName)

    if (appUpdateOptions):
        try:
            print("Updating application %s in cluster %s and webserver %s..") % (appName, clusterName, webserverName)

            AdminApp.update(appName, 'app', str(appInstallOptions).strip("()"))
        except:
            raise ("An error occurred performing the update. Please review logs.")
        finally:
            saveWorkspaceChanges()
            syncAllNodes(nodeList, targetCell)
        #endtry
    else:
        raise ("No application update options were found. Cannot install application.")
    #endif
#enddef

def installSingleEJBModule(appPath, clusterName):
    appFileName = getFileNameFromPath(appPath)
    appName = getAppDisplayName(appPath)
    appModuleName = getAppModuleName(appPath)
    appWarName = getAppWarName(appPath)
    appMappingOptions = (
        '-MapModulesToServers [[ %s %s,WEB-INF/web.xml '
        'WebSphere:cell=%s,cluster=%s]]'
    ) % (appModuleName, appWarName, targetCell, clusterName)
    appInstallOptions = (
        '[ -nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/%s/%s -distributeApp '
        '-nouseMetaDataFromBinary -deployejb -appname %s -createMBeansForResources -noreloadEnabled -nodeployws '
        '-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude '
        '-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema '
        '' + str(appMappingOptions).strip("()") + ']'
    ) % (targetCell, appFileName, appName)

    if (appInstallOptions):
        try:
            print("Installing EJB application %s in cluster %s..") % (appName, clusterName)

            AdminApp.install(appPath, str(appInstallOptions).strip("()"))
        except:
            raise ("An error occurred performing the installation. Please review logs.")
        finally:
            saveWorkspaceChanges()
            syncAllNodes(nodeList, targetCell)
        #endtry
    else:
        raise ("No application installation options were found. Cannot install application.")
    #endif
#enddef

def updateSingleEJBModule(appPath, clusterName):
    appFileName = getFileNameFromPath(appPath)
    appName = getAppDisplayName(appPath)
    appModuleName = getAppModuleName(appPath)
    appWarName = getAppWarName(appPath)
    appMappingOptions = (
        '-MapModulesToServers [[ %s %s,WEB-INF/web.xml '
        'WebSphere:cell=%s,cluster=%s]]'
    ) % (appModuleName, appWarName, targetCell, clusterName)
    appUpdateOptions = (
        '[ -nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/%s/%s -distributeApp '
        '-nouseMetaDataFromBinary -deployejb -appname %s -createMBeansForResources -noreloadEnabled -nodeployws '
        '-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude '
        '-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema '
        '' + str(appMappingOptions).strip("()") + ']'
    ) % (targetCell, appFileName, appName)

    if (appUpdateOptions):
        try:
            print("Updating EJB application %s in cluster %s..") % (appName, clusterName)

            AdminApp.update(appName, 'app', str(appInstallOptions).strip("()"))
        except:
            raise ("An error occurred performing the update. Please review logs.")
        finally:
            saveWorkspaceChanges()
            syncAllNodes(nodeList, targetCell)
        #endtry
    else:
        raise ("No application update options were found. Cannot install application.")
    #endif
#enddef

def modifyStartupWeightForApplication(appPath, startWeight=50):
    appName = getAppDisplayName(appPath)
    appDeployment = AdminConfig.getid("/Deployment:" + appName + "/")
    appDeploymentObject = AdminConfig.showAttribute(appDeployment, "deployedObject")

    if (appDeploymentObject):
        try:
            print("Modifying startup weight for %s to %d..") % (appName, startWeight)

            AdminConfig.modify(appDeploymentObject, [['startingWeight', '%d']]) % (startWeight)
        except:
            raise ("An error occurred while updating the start weight for application %s. Please review logs.") % (appName)
        finally:
            saveWorkspaceChanges()
            syncAllNodes(nodeList, targetCell)
        #endtry
    else:
        raise ("Unable to locate application deployment for %s.") % (appName)
    #endif
#enddef

def changeApplicationStatus(appName, newStatus="true"):
    appDeployment = AdminConfig.getid("/Deployment:" + appName + "/")
    appDeploymentObject = AdminConfig.showAttribute(appDeployment, "deployedObject")
    targetMappings = AdminConfig.showAttribute(appDeploymentObject, 'targetMappings')

    if (targetMappings):
        for targetMapping in (targetMappings):
            try:
                print("Changing target application status for %s to %s ..") % (appName, newStatus)

                AdminConfig.modify(targetMapping, [['enable', '%s']]) % (newStatus)
            except:
                raise ("An error occurred changing the status for application %s to %s") % (appName, newStatus)
            finally:
                saveWorkspaceChanges()
                syncAllNodes(nodeList, targetCell)
            #endtry
        #endfor
    else:
        raise ("No mappings were found for application %s") % (appName)
    #endif
#enddef

def performAppUninstall(appName):
    print("Removing application " + appName + "..")

    if (appName):
        try:
            print("Removing application %s..") % (appName)

            AdminApp.uninstall(appName)
        except:
            raise ("An error occurred while removing application %s") % (appName)
        finally:
            saveWorkspaceChanges()
            syncAllNodes(nodeList, targetCell)  
        #endtry
    else:
        raise ("No application was provided to uninstall")
    #endif
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
