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

sys.path.append(os.path.expanduser('~') + '/workspace/WebSphere/AppServer/wsadmin/includes/')

import includes

lineSplit = java.lang.System.getProperty('line.separator')

targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def listApps():
    print ("Listing all installed applications...")

    appList = AdminApp.list().split(lineSplit)

    for app in (appList):
        print ("Application: " + app)
 
        continue
    #endfor
#enddef

def remapApplication(appName, targetCluster):
    moduleName = AdminApp.listModules('' + appName + '', '-server').split('#')[1].split('+')[0]

    AdminApp.edit('' + app + '', '[ -MapModulesToServers [[ \'' + appName + '\' ' + moduleName + ',WEB-INF/web.xml WebSphere:cell=dmgrCell01,cluster=' + targetCluster + ' ]]]')

    includes.saveWorkspaceChanges()
    includes.syncAllNodes(nodeList)
#enddef

def exportApp(appName):
    print ("Exporting application " + appName + "..")

    exportPath = os.path.expanduser('~') + '/workspace/WebSphere/AppServer/files/EarFiles'

    os.makedirs(exportPath, exist_ok=True)

    AdminApp.export(appName, exportPath + '/' + appName + '.ear')
#enddef

def installSingleModule(appPath, clusterName, webserverNodeName, webserverName):
    appFileName = includes.getFileNameFromPath(appPath)
    appName = includes.getAppDisplayName(appPath)
    appModuleName = includes.removeExtraExtension(includes.getAppModuleName(appPath), 4)
    appWarName = includes.getAppWarName(appPath)
    appMappingOptions = (
        '-MapModulesToServers [[ ' + appModuleName + ' ' + appWarName + ',WEB-INF/web.xml '
        'WebSphere:cell=' + targetCell + ',cluster=' + clusterName + '+WebSphere:cell=' + targetCell + ',node=' + webserverNodeName + ',server=' + webserverName + ']]'
    )
    appInstallOptions = (
        '[ -nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/' + targetCell + '/' + appFileName + ' -distributeApp '
        '-nouseMetaDataFromBinary -nodeployejb -appname ' + appName + ' -createMBeansForResources -noreloadEnabled -nodeployws '
        '-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude '
        '-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema '
        '' + str(appMappingOptions).strip("()") + ']'
    )

    print ("Installing application " + appName + " into cluster " + clusterName + " and webserver " + webserverName + "..")

    AdminApp.install(appPath, str(appInstallOptions).strip("()"))

    includes.saveWorkspaceChanges()
    includes.syncAllNodes(nodeList)
#enddef

def updateSingleModule(appPath, clusterName, webserverNodeName, webserverName, vhostName):
    appFileName = includes.getFileNameFromPath(appPath)
    appName = includes.getAppDisplayName(appPath)
    appModuleName = includes.getAppModuleName(appPath)
    appWarName = includes.getAppWarName(appPath)
    appMappingOptions = (
        '-MapModulesToServers [[ ' + appModuleName + ' ' + appWarName + ',WEB-INF/web.xml '
        'WebSphere:cell=' + targetCell + ',cluster=' + clusterName + '+WebSphere:cell=' + targetCell + ',node=' + webserverNodeName + ',server=' + webserverName + ']]'
        '-MapWebModToVH [[ ' + appModuleName + ' ' + appWarName + ',WEB-INF/web.xml ' + vhostName + ' ]]'
    )

    appUpdateOptions = (
        '[ -nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/' + targetCell + '/' + appFileName + ' -distributeApp '
        '-nouseMetaDataFromBinary -nodeployejb -appname ' + appName + ' -createMBeansForResources -noreloadEnabled -nodeployws '
        '-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude '
        '-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema '
        '' + str(appMappingOptions).strip("()") + ']'
    )

    print ("Updating application " + appName + " in cluster " + clusterName + " + and webserver " + webserverName + "..")

    AdminApp.update(appName, 'app', str(appUpdateOptions).strip("()"))

    includes.saveWorkspaceChanges()
    includes.syncAllNodes(nodeList)
#enddef

def installEJBApplication(appPath, clusterName, webserverNodeName, webserverName):
    appFileName = includes.getFileNameFromPath(appPath)
    appName = includes.getAppDisplayName(appPath)
    appModuleName = includes.getAppModuleName(appPath)
    appWarName = includes.getAppWarName(appPath)
    appMappingOptions = (
        '-MapModulesToServers [[ ' + appModuleName + ' ' + appWarName + ',WEB-INF/web.xml '
        'WebSphere:cell=' + targetCell + ',cluster=' + clusterName + '+WebSphere:cell=' + targetCell + ',node=' + webserverNodeName + ',server=' + webserverName + ']]'
    )
    appInstallOptions = (
        '[ -nopreCompileJSPs -installed.ear.destination $(APP_INSTALL_ROOT)/' + targetCell + '/' + appFileName + ' -distributeApp '
        '-nouseMetaDataFromBinary -deployejb -appname ' + appName + ' -createMBeansForResources -noreloadEnabled -nodeployws '
        '-validateinstall warn -processEmbeddedConfig -filepermission .*\.dll=755#.*\.so=755#.*\.a=755#.*\.sl=755 -noallowDispatchRemoteInclude '
        '-noallowServiceRemoteInclude -asyncRequestDispatchType DISABLED -nouseAutoLink -noenableClientModule -clientMode isolated -novalidateSchema '
        '' + str(appMappingOptions).strip("()") + ']'
    )

    print ("Installing EJB application " + appName + " in cluster " + clusterName + " + and webserver " + webserverName + "..")

    AdminApp.update(appName, 'app', str(appInstallOptions).strip("()"))

    includes.saveWorkspaceChanges()
    includes.syncAllNodes(nodeList)
#enddef

def modifyStartupWeightForApplication(appPath, startWeight):
    appFileName = includes.getFileNameFromPath(appPath)
    appName = includes.getAppDisplayName(appPath)

    print ("Changing the startup weight for " + appName + " to " + startWeight + "..")

    appDeployment = AdminConfig.getid("/Deployment:" + appName + "/")
    appDeploymentObject = AdminConfig.showAttribute(appDeployment, "deployedObject")

    AdminConfig.modify(appDeploymentObject, [['startingWeight', '' + startWeight + '']])

    includes.saveWorkspaceChanges()
    includes.syncAllNodes(nodeList)
#enddef

def disableApplicationStartup(appName):
    print ("Disabling autostart for application " + appName + "..")

    appDeployment = AdminConfig.getid("/Deployment:" + appName + "/")
    appDeploymentObject = AdminConfig.showAttribute(appDeployment, "deployedObject")

    AdminConfig.modify(appDeploymentObject, [['startingWeight', '' + startWeight + '']])

    includes.saveWorkspaceChanges()
    includes.syncAllNodes(nodeList)
#enddef

def performAppUninstall(appName):
    print ("Removing application " + appName + "..")

    AdminApp.uninstall(appName)

    includes.saveWorkspaceChanges()
    includes.syncAllNodes(nodeList)
#enddef

def printHelp():
    print ("This script performs an application management.")
    print ("Execution: wsadmin.sh -lang jython -f /path/to/clusterInstallApp.py <option> <appname> <binary path> <cluster name>")
    print ("<option> - One of list, install, update, uninstall, change-weight, export.")
    print ("<app path> - The path to the application to install or modify.")
    print ("<cluster name> - The cluster to install or update the application into. Required if option is install or update.")
    print ("<webserver node name> - The webserver node name as defined in the deployment manager for mapping. Required if option is install or update.")
    print ("<webserver name> - The webserver name as defined in the deployment manager for mapping. Required if option is install or update.")
    print ("<start weight> - Only required if option is change-weight.")
#enddef

##################################
# main
#################################
if ((len(sys.argv) == 1) and (sys.argv[0] == "list")):
    listApps()
else:
    if (sys.argv[0] == "install"):
        if (len(sys.argv) == 5):
            installSingleModule(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
        else:
            printHelp()
        #endif
    if (sys.argv[0] == "update"):
        if (len(sys.argv) == 5):
            updateSingleModule(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
        else:
            printHelp()
        #endif
    elif (sys.argv[0] == "uninstall"):
        if (len(sys.argv) == 2):
            performAppUninstall(sys.argv[1])
        else:
            printHelp()
        #endif
    elif (sys.argv[0] == "export"):
        if (len(sys.argv) == 1):
            exportApp(sys.argv[1])
        else:
            printHelp()
        #endif
    elif (sys.argv[0] == "change-weight"):
        if (len(sys.argv) == 2):
            modifyStartupWeightForApplication(sys.argv[1], sys.argv[2])
        else:
            printHelp()
        #endif
    #endif
#endif
