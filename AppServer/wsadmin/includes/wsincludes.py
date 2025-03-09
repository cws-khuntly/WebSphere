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

errorLogger = logging.getLogger(str("error-logger"))
debugLogger = logging.getLogger(str("debug-logger"))
infoLogger = logging.getLogger(str("info-logger"))

lineSplit = java.lang.System.getProperty("line.separator")

def getWebSphereVariable(variableName, nodeName = None, serverName = None, clusterName = None):
    debugLogger.log(logging.DEBUG, str("ENTER: wsincludes#getWebSphereVariable(variableName, nodeName = None, serverName = None, clusterName = None)"))
    debugLogger.log(logging.DEBUG, str(variableName))
    debugLogger.log(logging.DEBUG, str(nodeName))
    debugLogger.log(logging.DEBUG, str(serverName))
    debugLogger.log(logging.DEBUG, str(clusterName))

    returnValue = "None"

    debugLogger.log(logging.DEBUG, str(returnValue))

    mapList = getVariableMap(nodeName, serverName, clusterName)

    debugLogger.log(logging.DEBUG, str(mapList))

    if (mapList != None):
        entries = AdminConfig.showAttribute(map, "entries")
        entries = entries[1:-1].split(' ')

        debugLogger.log(logging.DEBUG, str(entries))

        for entry in (entries):
            debugLogger.log(logging.DEBUG, str(entry))

            attributeName = AdminConfig.showAttribute(entry, "symbolicName")
            attributeValue = AdminConfig.showAttribute(entry, "value")

            if (str(variableName) == str(attributeName)):
                returnValue = attributeValue
            #endif
        #endfor
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: wsincludes#getWebSphereVariable(variableName, nodeName = None, serverName = None, clusterName = None)"))

    return returnValue
#enddef

def saveWorkspaceChanges():
    debugLogger.log(logging.DEBUG, str("ENTER: saveWorkspaceChanges()"))

    try:
        debugLogger.log(logging.DEBUG, str("Calling AdminConfig.save()"))
        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.save()"))

        AdminConfig.save()

        infoLogger.log(logging.INFO, str("Saved all pending workspace changes."))
    except:
        (exception, parms, tback) = sys.exc_info()

        errorLogger.log(logging.ERROR, str("An error occurred while saving workspace changes: {0} {1}").format(str(exception), str(parms)))

        raise Exception(str("An error occurred while saving workspace changes: {0} {1}").format(str(exception), str(parms)))
    #endtry

    debugLogger.log(logging.DEBUG, str("EXIT: saveWorkspaceChanges():"))
#enddef

def syncNodes(nodeList, cellName):
    debugLogger.log(logging.DEBUG, str("ENTER: syncNodes(nodeList, cellName)"))
    debugLogger.log(logging.DEBUG, str(nodeList))
    debugLogger.log(logging.DEBUG, str(cellName))

    if (len(nodeList) != 0):
        debugLogger.log(logging.DEBUG, str("Performing nodeSync for cell {0}..").format(cellName))
        debugLogger.log(logging.DEBUG, str("Calling AdminNodeManagement.syncActiveNodes()").format(cellName))
        debugLogger.log(logging.DEBUG, str("EXEC: AdminNodeManagement.syncActiveNodes()").format(cellName))

        AdminNodeManagement.syncActiveNodes()

        for node in (nodeList):
            try:
                debugLogger.log(logging.DEBUG, str(node))
                debugLogger.log(logging.DEBUG, str("Calling AdminControl.completeObjectName()"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminControl.completeObjectName(str(\"type=ConfigRepository,process=nodeagent,node={0},*\").format(node))"))

                nodeRepo = AdminControl.completeObjectName(str("type=ConfigRepository,process=nodeagent,node={0},*").format(node))

                debugLogger.log(logging.DEBUG, str(nodeRepo))

                if (nodeRepo):
                    debugLogger.log(logging.DEBUG, str("Calling AdminControl.invoke()"))
                    debugLogger.log(logging.DEBUG, str("AdminControl.invoke(nodeRepo, str(\"refreshRepositoryEpoch\"))"))

                    AdminControl.invoke(nodeRepo, str("refreshRepositoryEpoch"))

                    infoLogger.log(logging.INFO, str("Submitted refreshRepositoryEpoch."))
                #endif

                debugLogger.log(logging.DEBUG, str("Calling AdminControl.completeObjectName()"))
                debugLogger.log(logging.DEBUG, str("EXEC: AdminControl.completeObjectName(str(\"cell={0},node={1},type=NodeSync,*\").format(cellName, node))"))

                syncNode = AdminControl.completeObjectName(str("cell={0},node={1},type=NodeSync,*").format(cellName, node))

                debugLogger.log(logging.DEBUG, str(syncNode))

                if (syncNode):
                    debugLogger.log(logging.DEBUG, str("Calling AdminControl.invoke()"))
                    debugLogger.log(logging.DEBUG, str("AdminControl.invoke(syncNode, str(\"sync\"))"))

                    AdminControl.invoke(syncNode, str("sync"))

                    infoLogger.log(logging.INFO, str("Submitted sync."))
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

    debugLogger.log(logging.DEBUG, str("EXIT: syncNodes(nodeList, cellName)"))
#enddef
