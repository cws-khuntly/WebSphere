#==============================================================================
#
#          FILE:  restartCluster.py
#         USAGE:  wsadmin.sh -lang jython -f restartCluster.py
#     ARGUMENTS:  (clusterName)
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
logger = logging.getLogger(__name__)

lineSplit = java.lang.System.getProperty("line.separator")
targetCell = AdminControl.getCell()
clusterList = AdminConfig.list('ServerCluster').split(lineSplit)

def createCluster(cellname, clustername, createReplicationDomain=False, nodeScopedRouting=False ):
    m = "createCluster:"
    sop(m,"Entry. cellname=%s clustername=%s createReplicationDomain=%s nodeScopedRouting=%s" % ( cellname, clustername, createReplicationDomain, nodeScopedRouting ))

    # Check input.
    if (False != createReplicationDomain and True != createReplicationDomain):
        raise m + " Error. createReplicationDomain must be True or False. createReplicationDomain=%s" % repr(createReplicationDomain)
    if (False != nodeScopedRouting and True != nodeScopedRouting):
        raise m + " Error. nodeScopedRouting must be True or False. nodeScopedRouting=%s" % repr(nodeScopedRouting)

    # Convert to a string value.
    preferLocal = nodeScopedRouting and 'true' or 'false'

    if createReplicationDomain == True:
        sop(m,'Calling AdminTask.createCluster([-clusterConfig [-clusterName %s -preferLocal %s] -replicationDomain [-createDomain true]]' % (clustername, preferLocal))
        return AdminTask.createCluster('[-clusterConfig [-clusterName %s -preferLocal %s] -replicationDomain [-createDomain true]]' % (clustername, preferLocal))
    else:
        sop(m,'Calling AdminTask.createCluster([-clusterConfig [-clusterName %s -preferLocal %s]]' % (clustername, preferLocal))
        return AdminTask.createCluster('[-clusterConfig [-clusterName %s -preferLocal %s]]' % (clustername, preferLocal))

def createServerInCluster( clustername, nodename, servername, sessionReplication = False):
    sop(m,"Entry. clustername=%s nodename=%s servername=%s sessionReplication=%s" % ( clustername, nodename, servername, sessionReplication ))
    if sessionReplication == True:
        sop(m,'Calling AdminTask.createClusterMember([-clusterName %s -memberConfig[-memberNode %s -memberName %s -memberWeight 2 -replicatorEntry true]])' % (clustername,nodename,servername))
        AdminTask.createClusterMember('[-clusterName %s -memberConfig[-memberNode %s -memberName %s -memberWeight 2 -replicatorEntry true]]' % (clustername,nodename,servername))
    else:
        sop(m,'Calling AdminTask.createClusterMember([-clusterName %s -memberConfig[-memberNode %s -memberName %s -memberWeight 2]])' % (clustername,nodename,servername))
        AdminTask.createClusterMember('[-clusterName %s -memberConfig[-memberNode %s -memberName %s -memberWeight 2]]' % (clustername,nodename,servername))

def isClusterStarted (clustername):
    m = "isClusterStarted"
    sop (m, "Entering %s function..." % m)

    sop(m, "Calling AdminControl.completeObjectName to get cluster %s's ObjectName" % clustername)
    cluster = AdminControl.completeObjectName('cell='+getCellName()+',type=Cluster,name='+clustername+',*')
    sop(m, "Returning from AdminControl.completeObjectName, ObjectName for %s is %s" % (clustername,cluster))

    if cluster == '' :
        raise "Exception getting ObjectName for cluster %s, it must not exist" % clustername
    #endif

    try:
        sop(m, "Calling AdminControl.getAttribute to get cluster %s's state" % clustername)
        output = AdminControl.getAttribute(cluster, 'state')
        sop(m, "Returning from AdminControl.getAttribute, the state of %s is %s" % (clustername, output))
    except:
        raise "Exception getting attribute for cluster %s's state" % clustername
    #endtry

    if output.find('running') != -1 :
        return 1
    else :
        return 0
    #endif

#endDef

def restartClusters():
    print("Restarting all found clusters...")

    for cluster in (clusterList):
        clusterName = AdminControl.completeObjectName('cell=' + targetCell + ',type=Cluster,name=' + cluster.split("(")[0] + ',*')

        print("Restarting cluster " + cluster + "...")
        print("Cluster " + cluster.split("(")[0] + " is currently: " + AdminControl.getAttribute(clusterName, "state" ).split(".")[2])
        
        AdminControl.invoke(clusterName, "stop")
        
        time.sleep(900)
        
        if (AdminControl.getAttribute(clusterName, "state" ).split(".")[2] == "stopped"):
            AdminControl.invoke(clusterName, "rippleStart")

            continue
        #endif
    #endfor
#enddef

def restartCluster(clusterName):
    for cluster in (clusterList):
        if (clusterName == cluster.split("(")[0]):
            for cluster in (clusterList):
                clusterName = AdminControl.completeObjectName('cell=' + targetCell + ',type=Cluster,name=' + cluster.split("(")[0] + ',*')

                print("Restarting cluster " + clusterName + "...")
                print("Cluster " + cluster.split("(")[0] + " is currently: " + AdminControl.getAttribute(clusterName, "state" ).split(".")[2])
                
                AdminControl.invoke(clusterName, "stop")
                
                time.sleep(900)
                
                if (AdminControl.getAttribute(clusterName, "state" ).split(".")[2] == "stopped"):
                    AdminControl.invoke(clusterName, "rippleStart")

                    continue
                #endif
            #endfor
        else:
            print("The provided cluster is not available on this system.")

            sys.exit(1)
        #endif
    #endfor
#enddef    

def printHelp():
    print("This script performs an application management.")
    print("Execution: wsadmin.sh -lang jython -f /path/to/clusterInstallApp.py <option> <appname> <binary path> <cluster name>")
    print("<option> - One of list, install, update, uninstall, change-weight, export.")
    print("<app path> - The path to the application to install or modify.")
    print("<cluster name> - The cluster to install or update the application into. Required if option is install or update.")
    print("<webserver node name> - The webserver node name as defined in the deployment manager for mapping. Required if option is install or update.")
    print("<webserver name> - The webserver name as defined in the deployment manager for mapping. Required if option is install or update.")
    print("<start weight> - Only required if option is change-weight.")
#enddef

##################################
# main
#################################
if (len(sys.argv) == 0):
    restartClusters()
else:
    restartCluster(sys.argv[0])
#endif
