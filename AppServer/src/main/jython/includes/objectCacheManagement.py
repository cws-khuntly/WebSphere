#==============================================================================
#
#          FILE:  objectCacheManagement.py
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

import sys
import logging

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")

lineSplit = java.lang.System.getProperty("line.separator")

def createObjectCache(targetCell, targetCluster, targetCacheInstanceName, targetCacheJNDIName):
    debugLogger.log(logging.DEBUG, "ENTER: objectCacheManagement#createObjectCache(targetCell, targetCluster, targetCacheInstanceName, targetCacheJNDIName)")
    debugLogger.log(logging.DEBUG, targetCell)
    debugLogger.log(logging.DEBUG, targetCluster)
    debugLogger.log(logging.DEBUG, targetCacheInstanceName)
    debugLogger.log(logging.DEBUG, targetCacheJNDIName)

    if ((len(targetCacheInstanceName) != 0) and (len(targetCacheJNDIName) != 0)):
        debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.list(\"DataReplicationDomain\", AdminConfig.getid(targetCell)).split(lineSplit)")

        existingReplicationDomains = AdminConfig.list("DataReplicationDomain", AdminConfig.getid(str("/Cell:{0}/").format(targetCell))).split(lineSplit)

        debugLogger.log(logging.DEBUG, existingReplicationDomains)

        if (len(existingReplicationDomains) == 0):
            debugLogger.log(logging.DEBUG, "No existing data replication domains current exist. Creating one.")

            try:
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"DataReplicationDomain\", AdminConfig.getid(str(\"/Cell:{0}/\").format(targetCell)), \"[[name \"ReplicationDomain\"]]\")")

                dataReplicationDomain = AdminConfig.create("DataReplicationDomain", AdminConfig.getid(str("/Cell:{0}/").format(targetCell)), "[[name \"ReplicationDomain\"]]")

                debugLogger.log(logging.DEBUG, dataReplicationDomain)
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"DataReplication\", dataReplicationDomain, \"[[requestTimeout 5] [numberOfReplicas -1]]\")")

                AdminConfig.create("DataReplication", dataReplicationDomain, "[[requestTimeout 5] [numberOfReplicas -1]]")
            except:
                (exception, parms, tback) = sys.exc_info()

                errorLogger.log(logging.ERROR, str("An error occurred creating a new replication domain: {0} {1}").format(str(exception), str(parms)))

                raise Exception(str("An error occurred creating a new replication domain: {0} {1}").format(str(exception), str(parms)))
            #endtry
        #endif

        debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.list(\"DataReplicationDomain\", AdminConfig.getid(str(\"/Cell:{0}/\").format(targetCell))).split(lineSplit)")

        existingCacheInstances = AdminConfig.list("DataReplicationDomain", AdminConfig.getid(str("/Cell:{0}/").format(targetCell))).split(lineSplit)

        debugLogger.log(logging.DEBUG, existingCacheInstances)

        if (len(existingCacheInstances) != 0):
            for existingCacheInstance in (existingCacheInstances):
                debugLogger.log(logging.DEBUG, existingCacheInstance)
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.showAttribute()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.showAttribute(existingCacheInstance, \"name\")")

                existingCacheInstanceName = AdminConfig.showAttribute(existingCacheInstance, "name")

                debugLogger.log(logging.DEBUG, existingCacheInstanceName)

                if ((len(existingCacheInstanceName) != 0) and (str(existingCacheInstanceName) == targetCacheInstanceName)):
                    errorLogger.log(logging.ERROR, str("An object cache instance named {0} already exists in cell {1}.").format(targetCacheInstanceName, targetCell))

                    raise Exception(str("An object cache instance named {0} already exists in cell {1}.").format(targetCacheInstanceName, targetCell))
                #endif

                continue
            #endfor
        #endif

        try:
            clusterObjectID = AdminConfig.getid(str("/ServerCluster:{0}/").format(targetCluster))
            cacheProvider = AdminConfig.list("CacheProvider", clusterObjectID)
            diskCacheEvictionPolicy = AdminConfig.list("DiskCacheEvictionPolicy", clusterObjectID)
            objectCacheInstance = AdminTask.createObjectCacheInstance(cacheProvider, str("[-name \"{0}\" -jndiName \"{1}\"]").format(str(targetCacheInstanceName, targetCacheJNDIName)))
            drsSettings = AdminConfig.create("DRSSettings", objectCacheInstance, "[]")
            diskCacheCustomPerformanceSettings = AdminConfig.create("DiskCacheCustomPerformanceSettings", objectCacheInstance, "[]")

            debugLogger.log(logging.DEBUG, clusterObjectID)
            debugLogger.log(logging.DEBUG, cacheProvider)
            debugLogger.log(logging.DEBUG, diskCacheEvictionPolicy)
            debugLogger.log(logging.DEBUG, objectCacheInstance)
            debugLogger.log(logging.DEBUG, drsSettings)
            debugLogger.log(logging.DEBUG, diskCacheCustomPerformanceSettings)

            AdminConfig.modify(diskCacheEvictionPolicy, "[[algorithm \"NONE\"] [highThreshold \"80\"] [lowThreshold \"70\"]]")
            AdminConfig.modify(drsSettings, str("[[messageBrokerDomainName \"{0}\"]]").format(dataReplicationDomain))
            AdminConfig.modify(diskCacheCustomPerformanceSettings, "[[maxBufferedTemplates \"100\"] [maxBufferedCacheIdsPerMetaEntry \"1000\"] [maxBufferedDependencyIds \"10000\"]]")
            AdminConfig.modify(objectCacheInstance, str("[[defaultPriority \"1\"] [name \"{0}\"] [disableDependencyId \"false\"] [flushToDiskOnStop \"false\"] [enableCacheReplication \"true\"] "
                "[diskCachePerformanceLevel \"BALANCED\"] [enableDiskOffload \"false\"] [diskCacheEntrySizeInMB \"0\"] [replicationType \"PUSH_PULL\"] [cacheSize \"2000\"] [jndiName \"{1}\"] "
                "[diskCacheSizeInGB \"0\"] [useListenerContext \"false\"] [pushFrequency \"1\"] [diskCacheCleanupFrequency \"0\"] [diskCacheSizeInEntries \"0\"]]").format(targetCacheInstanceName, targetCacheJNDIName))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred creating object cache instance {0}: {1} {2}").format(targetCacheInstanceName, str(exception), str(parms)))

            raise Exception(str("An error occurred creating object cache instance {0}: {1} {2}").format(targetCacheInstanceName, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No cache instane name was provided or no cache JNDI name was provided.")

        raise Exception("No cache instane name was provided or no cache JNDI name was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: objectCacheManagement#createObjectCache(targetCell, targetCluster, targetCacheInstanceName, targetCacheJNDIName)")
#enddef
