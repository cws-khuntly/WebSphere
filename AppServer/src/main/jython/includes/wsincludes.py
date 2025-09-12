#==============================================================================
#
#          FILE:  wsincludes.py
#         USAGE:  Include file containing various wsadmin functions
#     ARGUMENTS:  N/A
#
#   DESCRIPTION:  Various useful wsadmin functions
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

import sys
import logging

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")

lineSplit = java.lang.System.getProperty("line.separator")

def getWebSphereVariable(variableName, nodeName = None, serverName = None, clusterName = None):
    debugLogger.log(logging.DEBUG, "ENTER: wsincludes#getWebSphereVariable(variableName, nodeName = None, serverName = None, clusterName = None)")
    debugLogger.log(logging.DEBUG, variableName)
    debugLogger.log(logging.DEBUG, nodeName)
    debugLogger.log(logging.DEBUG, serverName)
    debugLogger.log(logging.DEBUG, clusterName)

    returnValue = "None"

    debugLogger.log(logging.DEBUG, returnValue)

    mapList = getVariableMap(nodeName, serverName, clusterName)

    debugLogger.log(logging.DEBUG, str(mapList))

    if (mapList != None):
        entries = AdminConfig.showAttribute(map, "entries")
        entries = entries[1:-1].split(' ')

        debugLogger.log(logging.DEBUG, entries)

        for entry in (entries):
            debugLogger.log(logging.DEBUG, entry)

            attributeName = AdminConfig.showAttribute(entry, "symbolicName")
            attributeValue = AdminConfig.showAttribute(entry, "value")

            if (variableName == attributeName):
                returnValue = attributeValue
            #endif
        #endfor
    #endif

    debugLogger.log(logging.DEBUG, returnValue)
    debugLogger.log(logging.DEBUG, "EXIT: wsincludes#getWebSphereVariable(variableName, nodeName = None, serverName = None, clusterName = None)")

    return returnValue
#enddef

def getModuleNames(appName):
    debugLogger.log(logging.DEBUG, "ENTER: wsincludes#getModuleNames(appName)")
    debugLogger.log(logging.DEBUG, appName)

    moduleNames = []

    debugLogger.log(logging.DEBUG, moduleNames)

    if (len(appName) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminApp.listModules()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminApp.listModules(appName, \"-server\")")

            appModules = AdminApp.listModules(appName, "-server")

            debugLogger.log(logging.DEBUG, appModules)

            for appModule in (appModules):
                debugLogger.log(logging.DEBUG, appModule)

                moduleName = str(appModule).split("#")[1].split("+")[0]

                debugLogger.log(logging.DEBUG, moduleName)

                moduleNames.append(moduleName)

                debugLogger.log(logging.DEBUG, moduleNames)
            #endfor
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred listing modules for {0}: {1} {2}").format(appName, str(exception), str(parms)))

            raise Exception(str("An error occurred listing modules for {0}: {1} {2}").format(appName, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No application was provided to obtain modules for.")

        raise Exception("No application was provided to obtain modules for.")
    #endif

    debugLogger.log(logging.DEBUG, moduleNames)

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#configureServerHostname(targetServer, hostName)")

    return moduleNames
#enddef

def saveWorkspaceChanges():
    debugLogger.log(logging.DEBUG, "ENTER: saveWorkspaceChanges()")

    try:
        debugLogger.log(logging.DEBUG, "Calling AdminConfig.save()")
        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.save()")

        AdminConfig.save()

        infoLogger.log(logging.INFO, "Saved all pending workspace changes.")
    except:
        (exception, parms, tback) = sys.exc_info()

        errorLogger.log(logging.ERROR, str("An error occurred while saving workspace changes: {0} {1}").format(str(exception), str(parms)))

        raise Exception(str("An error occurred while saving workspace changes: {0} {1}").format(str(exception), str(parms)))
    #endtry

    debugLogger.log(logging.DEBUG, "EXIT: saveWorkspaceChanges():")
#enddef

def syncNodes(nodeList, cellName):
    debugLogger.log(logging.DEBUG, "ENTER: syncNodes(nodeList, cellName)")
    debugLogger.log(logging.DEBUG, nodeList)
    debugLogger.log(logging.DEBUG, cellName)

    if (len(nodeList) != 0):
        debugLogger.log(logging.DEBUG, str("Performing nodeSync for cell {0}..").format(cellName))
        debugLogger.log(logging.DEBUG, str("Calling AdminNodeManagement.syncActiveNodes()").format(cellName))
        debugLogger.log(logging.DEBUG, str("EXEC: AdminNodeManagement.syncActiveNodes()").format(cellName))

        AdminNodeManagement.syncActiveNodes()

        for node in (nodeList):
            try:
                debugLogger.log(logging.DEBUG, node)
                debugLogger.log(logging.DEBUG, "Calling AdminControl.completeObjectName()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminControl.completeObjectName(str(\"type=ConfigRepository,process=nodeagent,node={0},*\").format(node))")

                nodeRepo = AdminControl.completeObjectName(str("type=ConfigRepository,process=nodeagent,node={0},*").format(node))

                debugLogger.log(logging.DEBUG, str(nodeRepo))

                if (nodeRepo):
                    debugLogger.log(logging.DEBUG, "Calling AdminControl.invoke()")
                    debugLogger.log(logging.DEBUG, "AdminControl.invoke(nodeRepo, str(\"refreshRepositoryEpoch\"))")

                    AdminControl.invoke(nodeRepo, "refreshRepositoryEpoch")

                    infoLogger.log(logging.INFO, "Submitted refreshRepositoryEpoch.")
                #endif

                debugLogger.log(logging.DEBUG, "Calling AdminControl.completeObjectName()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminControl.completeObjectName(str(\"cell={0},node={1},type=NodeSync,*\").format(cellName, node))")

                syncNode = AdminControl.completeObjectName(str("cell={0},node={1},type=NodeSync,*").format(cellName, node))

                debugLogger.log(logging.DEBUG, syncNode)

                if (syncNode):
                    debugLogger.log(logging.DEBUG, "Calling AdminControl.invoke()")
                    debugLogger.log(logging.DEBUG, "AdminControl.invoke(syncNode, str(\"sync\"))")

                    AdminControl.invoke(syncNode, "sync")

                    infoLogger.log(logging.INFO, "Submitted sync.")
                #endif

                continue
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred performing the node synchronization operation on node {0}: {1} {2}").format(node, str(exception), str(parms)))

                raise Exception(str("An error occurred performing the node synchronization operation on node {0}: {1} {2}").format(node, str(exception), str(parms)))
            #endtry
        #endfor
    else:
        errorLogger.log(logging.ERROR, str("No nodes were found in the cell {0}").format(cellName))

        raise Exception(str("No nodes were found in the cell {0}").format(cellName))
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: syncNodes(nodeList, cellName)")
#enddef
