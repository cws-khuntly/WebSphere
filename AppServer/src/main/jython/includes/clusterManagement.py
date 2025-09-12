#==============================================================================
#
#          FILE:  clusterManagement.py
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
import time
import logging

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")

targetCell = AdminControl.getCell()
lineSplit = java.lang.System.getProperty("line.separator")

def createServerCluster(targetCluster):
    debugLogger.log(logging.DEBUG, "ENTER: clusterManagement#createServerCluster(targetCluster)")
    debugLogger.log(logging.DEBUG, targetCluster)

    if (len(targetCluster) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.getid()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.getid(str(\"/ServerCluster:{0}/\").format(targetCluster))")

            isExistingCluster = AdminConfig.getid(str("/ServerCluster:{0}/").format(targetCluster))

            debugLogger.log(logging.DEBUG, isExistingCluster)

            if (len(isExistingCluster) != 0):
                errorLogger.log(logging.ERROR, str("A cluster named {0} already exists.").format(targetCluster))

                raise Exception(str("A cluster named {0} already exists.").format(targetCluster))
            #endif

            debugLogger.log(logging.DEBUG, "Calling AdminConfig.createCluster()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminTask.createCluster(str(\"[-clusterConfig [-clusterName {0} -preferLocal true]]\").format(targetCluster))")

            AdminTask.createCluster(str("[-clusterConfig [-clusterName {0} -preferLocal true]]").format(targetCluster))

            infoLogger.log(logging.INFO, str("Successfully created cluster {0}.").format(targetCluster))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("Failed to create cluster {0}: {1} {2}").format(targetCluster, str(exception), str(parms)))

            raise Exception(str("Failed to create cluster {0}: {1} {2}").format(targetCluster, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No cluster information was provided.")

        raise Exception("No cluster information was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#createServerCluster(targetCluster)")
#enddef

def createApplicationServerInCluster(targetCluster, targetNode, targetServer):
    debugLogger.log(logging.DEBUG, "ENTER: clusterManagement#createApplicationServerInCluster(targetCluster, targetNode, targetServer)")
    debugLogger.log(logging.DEBUG, targetCluster)
    debugLogger.log(logging.DEBUG, targetNode)
    debugLogger.log(logging.DEBUG, targetServer)

    if ((len(targetCluster) != 0) and (len(targetNode) != 0) and (len(targetServer) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.getid()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.getid(str(\"/Node:{0}/Server:{1}/\").format(targetNode, targetServer))")

            isExistingServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(targetNode, targetServer))

            debugLogger.log(logging.DEBUG, isExistingServer)

            if (len(isExistingServer) != 0):
                errorLogger.log(logging.ERROR, str("A server named {0} already exists on node {1}.").format(targetServer, targetNode))

                raise Exception(str("A server named {0} already exists on node {1}.").format(targetServer, targetNode))
            #endif

            debugLogger.log(logging.DEBUG, "Calling AdminConfig.createClusterMember()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminTask.createClusterMember(str(\"[-clusterName {0} -memberConfig[-memberNode {1} -memberName {2} -memberWeight 2]]\").format(targetCluster, targetNode, targetServer))")

            AdminTask.createClusterMember(str("[-clusterName {0} -memberConfig[-memberNode {1} -memberName {2} -memberWeight 2]]").format(targetCluster, targetNode, targetServer))

            infoLogger.log(logging.INFO, str("Successfully created cluster member {0} in cluster {1}.").format(targetServer, targetCluster))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("Failed to create cluster member {0} in cluster {1}: {2} {3}").format(targetServer, targetCluster, str(exception), str(parms)))

            raise Exception(str("Failed to create cluster member {0} in cluster {1}: {2} {3}").format(targetServer, targetCluster, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No cluster information was provided.")

        raise Exception("No cluster information was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: serverMaintenance#createApplicationServerInCluster(targetCluster, targetNode, targetServer)")
#enddef

def restartCluster(targetCluster, restartTimeout = 600):
    debugLogger.log(logging.DEBUG, "ENTER: clusterManagement#restartCluster(targetCluster, restartTimeout = 600)")
    debugLogger.log(logging.DEBUG, targetCluster)
    debugLogger.log(logging.DEBUG, restartTimeout)

    elapsedTime = 0
    sleepTime = 5

    debugLogger.log(logging.DEBUG, elapsedTime)
    debugLogger.log(logging.DEBUG, sleepTime)

    if (len(targetCluster) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.getid()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.getid(str(\"/ServerCluster:{0}/\").format(targetCluster))")

            clusterObject = AdminConfig.getid(str("/ServerCluster:{0}/").format(targetCluster))

            debugLogger.log(logging.DEBUG, clusterObject)

            if (len(clusterObject) != 0):
                debugLogger.log(logging.DEBUG, str("Issuing ripplestart for cluster {0}.").format(targetCluster))
                debugLogger.log(logging.DEBUG, "Calling AdminClusterManagement.rippleStartSingleCluster()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminClusterManagement.rippleStartSingleCluster(targetCluster)")

                AdminClusterManagement.rippleStartSingleCluster(targetCluster)

                debugLogger.log(logging.DEBUG, "Calling AdminConfig.showAttribute()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.showAttribute(clusterObject, \"members\")")

                clusterMembers = AdminConfig.showAttribute(clusterObject, "members")

                debugLogger.log(logging.DEBUG, clusterMembers)

                if (len(clusterMemberList) != 0):
                    for clusterMember in (clusterMembers):
                        debugLogger.log(logging.DEBUG, clusterMember)
                        debugLogger.log(logging.DEBUG, "Calling AdminConfig.getAttribute()")
                        debugLogger.log(logging.DEBUG, "EXEC: AdminControl.getAttribute(clusterMember, \"nodeName\")")
                        debugLogger.log(logging.DEBUG, "EXEC: AdminControl.getAttribute(clusterMember, \"name\")")

                        serverNodeName = AdminControl.getAttribute(clusterMember, "nodeName")
                        serverJVMName = AdminControl.getAttribute(clusterMember, "memberName")

                        debugLogger.log(logging.DEBUG, serverNodeName)
                        debugLogger.log(logging.DEBUG, serverJVMName)
                        debugLogger.log(logging.DEBUG, "Calling AdminConfig.getid()")
                        debugLogger.log(logging.DEBUG, "EXEC: AdminControl.getid(str(\"/Node:{0}/Server:{1}/\").format(serverNodeName, serverJVMName))")

                        targetServer = AdminConfig.getid(str("/Node:{0}/Server:{1}/").format(serverNodeName, serverJVMName))

                        debugLogger.log(logging.DEBUG, targetServer)

                        if (len(targetServer) != 0):
                            debugLogger.log(logging.DEBUG, "Calling getServerStatus()")
                            debugLogger.log(logging.DEBUG, "EXEC: getServerStatus(targetServer)")

                            currentServerStatus = getServerStatus(targetServer)

                            debugLogger.log(logging.DEBUG, currentServerStatus)

                            while (currentServerStatus != "STARTED"):
                                debugLogger.log(logging.DEBUG, str("Waiting for restart. Sleeping for {0}..").format(sleepTime))

                                time.sleep(sleepTime)

                                elapsedTimeSeconds = (elapsedTimeSeconds + sleepTime)
                                currentServerStatus = getServerStatus(targetServer)

                                debugLogger.log(logging.DEBUG, elapsedTimeSeconds)
                                debugLogger.log(logging.DEBUG, currentServerStatus)

                                if (elapsedTimeSeconds >= restartTimeout):
                                    errorLogger.log(logging.ERROR, str("A timeout occurred while starting cluster member {0}.").format(targetServer))

                                    raise Exception(str("A timeout occurred while starting cluster member {0}.").format(targetServer))
                                #endif
                            #endwhile
                        #endif
                    #endfor
                else:
                    errorLogger.log(logging.ERROR, str("No cluster members were found in cluster {0}.").format(targetCluster))

                    raise Exception(str("No cluster members were found in cluster {0}.").format(targetCluster))
                #endif
            else:
                errorLogger.log(logging.ERROR, str("No cluster named {0} was found.").format(targetCluster))

                raise Exception(str("No cluster named {0} was found.").format(targetCluster))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("Failed to create cluster member {0} in cluster {1}: {2} {3}").format(targetServer, targetCluster, str(exception), str(parms)))

            raise Exception(str("Failed to create cluster member {0} in cluster {1}: {2} {3}").format(targetServer, targetCluster, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No cluster information was provided.")

        raise Exception("No cluster information was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: clusterManagement#restartCluster(targetCluster, restartTimeout = 600)")
#enddef
