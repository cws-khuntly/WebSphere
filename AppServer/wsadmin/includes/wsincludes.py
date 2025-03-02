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

def saveWorkspaceChanges():
    try:
        debugLogger.log(logging.DEBUG, str("Calling AdminConfig.save()"))
        debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.save()"))

        AdminConfig.save()

        debugLogger.log(logging.DEBUG, str("Saved all pending workspace changes."))
        infoLogger.log(logging.INFO, str("Saved all pending workspace changes."))
    except:
        (exception, parms, tback) = sys.exc_info()

        errorLogger.log(logging.ERROR, str("An error occurred while saving workspace changes: {0} {1}").format(str(exception), str(parms)))

        raise Exception(str("An error occurred while saving workspace changes. Please review logs."))
    #endtry    
#enddef

def syncAllNodes(nodeList, cellName):
    debugLogger.log(logging.DEBUG, str(nodeList))
    debugLogger.log(logging.DEBUG, str(cellName))

    if (len(nodeList) != 0):
        try:
            debugLogger.log(logging.DEBUG, str("Performing nodeSync for cell {0}..").format(cellName))
            consoleInfoLogger.log(logging.INFO, str("Performing nodeSync for cell {0}..").format(cellName))

            AdminNodeManagement.syncActiveNodes()

            for node in (nodeList):
                debugLogger.log(logging.DEBUG, str(node))

                nodeRepo = AdminControl.completeObjectName(str("type=ConfigRepository,process=nodeagent,node={0},*").format(node))

                debugLogger.log(logging.DEBUG, str(nodeRepo))

                if (nodeRepo):
                    debugLogger.log(logging.DEBUG, str("Calling AdminControl.invoke()"))
                    debugLogger.log(logging.DEBUG, str("AdminControl.invoke(nodeRepo, str(\"refreshRepositoryEpoch\"))"))

                    AdminControl.invoke(nodeRepo, str("refreshRepositoryEpoch"))

                    debugLogger.log(logging.DEBUG, str("Submitted refreshRepositoryEpoch."))
                    infoLogger.log(logging.INFO, str("Submitted refreshRepositoryEpoch."))
                #endif

                syncNode = AdminControl.completeObjectName(str("cell={0},node={1},type=NodeSync,*").format(cellName, node))

                debugLogger.log(logging.DEBUG, str(syncNode))

                if (syncNode):
                    debugLogger.log(logging.DEBUG, str("Calling AdminControl.invoke()"))
                    debugLogger.log(logging.DEBUG, str("AdminControl.invoke(syncNode, str(\"sync\"))"))

                    AdminControl.invoke(syncNode, str("sync"))

                    debugLogger.log(logging.DEBUG, str("Submitted sync."))
                    infoLogger.log(logging.INFO, str("Submitted sync."))
                #endif

                continue
            #endfor
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred performing the node synchronization operation: {0} {1}").format(str(exception), str(parms)))

            raise Exception(str("An error occurred performing node synchronization operation. Please review logs."))
        #endtry
    #endif
#enddef
