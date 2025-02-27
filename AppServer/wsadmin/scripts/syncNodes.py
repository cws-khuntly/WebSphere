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

configureLogging("../config/logging.xml")
consoleLogger = logging.getLogger("console-logger")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")

lineSplit = java.lang.System.getProperty("line.separator")
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def performNodeSync():
    saveWorkspaceChanges()
    syncAllNodes(nodeList, targetCell)
#enddef

##################################
# main
#################################
performNodeSync()
