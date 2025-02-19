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
#        AUTHOR:  Kevin Huntly <kevin.huntly@bcbsma.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

import os
import sys
import time

sys.path.append(os.path.expanduser('~') + '/lib/wasadmin/')

import includes

lineSplit = java.lang.System.getProperty('line.separator')

targetCell = AdminControl.getCell()
appList = AdminApp.list().split(lineSplit)
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def listApps():
    for app in appList:
        print(app)
 
        continue
    #endfor
#enddef

def remapApplication():
    for app in appList:
        moduleName = AdminApp.listModules('' + app + '', '-server').split('#')[1].split('+')[0]

        AdminApp.edit('' + app + '', '[ -MapModulesToServers [[ \'' + app + '\' ' + moduleName + ',WEB-INF/web.xml WebSphere:cell=dmgrCell01,cluster=TestCluster ]]]')

        continue
    #endfor

    saveWorkspaceChanges()
    syncAllNodes(nodeList)
#enddef

def exportApp(appName):
    exportPath = os.path.expanduser('~') + '/workspace/WebSphere/AppServer/files/'

    os.makedirs(exportPath, exist_ok=True)

    AdminApp.export(appName, exportPath + '/' + appName + '.ear')
#enddef

def performAppInstallation(appName, appPath, clusterName, webserverNodeName, webserverName):
    print('Installing application ' + appName + ' into cluster ' + clusterName + ' + and webserver ' + webserverName + '..')

    AdminApp.install('' + appPath + '', '[ -distributeApp -appname ' + appName + ' -MapModulesToServers [[ ' + appModule + ' ' + warName + ',WEB-INF/web.xml WebSphere:cell=' + targetCell + ',cluster=' + clusterName + '+WebSphere:cell=' + targetCell + ',node=' + webserverNodeName + ',server=' + webserverName + ']]]' )

    saveWorkspaceChanges()
    syncAllNodes(nodeList)
#enddef

def performAppUpdate(appName, appModule, warName, clusterName, webserverNodeName, webserverName):
    lineSplit = java.lang.System.getProperty('line.separator')
    nodeList = AdminTask.listManagedNodes().split(lineSplit)
    targetCell = AdminControl.getCell()

    AdminApp.install('' + appPath + '', '[ -distributeApp -appname ' + appName + ' -MapModulesToServers [[ ' + appModule + ' ' + warName + ',WEB-INF/web.xml WebSphere:cell=' + targetCell + ',cluster=' + clusterName + '+WebSphere:cell=' + targetCell + ',node=' + webserverNodeName + ',server=' + webserverName + ']]]' )

    saveWorkspaceChanges()
    syncAllNodes(nodeList)
#enddef

def performAppUninstall(appName):
    print('Removing application ' + appName + '..')

    AdminApplication.uninstall('' + appName + '')

    saveWorkspaceChanges()
    syncAllNodes(nodeList)
#enddef

def printHelp():
    print('This script performs an application management.')
    print('Execution: wsadmin.sh -lang jython -f /path/to/clusterInstallApp.py <option> <appname> <binary path> <cluster name>')
    print('<option> is one of list, install or uninstall.')
    print('<appname> is the application name to be installed or removed. Required for both available options.')
    print('<binary path> is the full path to the binaries for the application to be installed. Required if <option> install.')
    print('<cluster name> is the WebSphere cluster to install the application into. Required if <option> install.')
#enddef

##################################
# main
#################################
if ((len(sys.argv) == 1) and (sys.argv[0] == 'listApps')):
    listApps()
else:
    if (sys.argv[0] == 'install'):
        if (len(sys.argv) == 4):
            performAppInstallation(sys.argv[1], sys.argv[2], sys.argv[3])
        else:
            printHelp()
    elif (sys.argv[0] == 'uninstall'):
        if (len(sys.argv) == 2):
            performAppUninstall(sys.argv[1])
        else:
            printHelp()
        #endif
    #endif
#endif
