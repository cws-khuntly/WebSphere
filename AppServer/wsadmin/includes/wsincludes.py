#==============================================================================
#
#          FILE:  configureSessionDatabase.py
#         USAGE:  wsadmin.sh -lang jython -f configureSessionDatabase.py
#     ARGUMENTS:  databaseType
#                     Oracle: <driver path> <jdbc url> <jndi entry>
#                     DB2: <driver path> <database name> <server name> <port number> <jndi entry>
#
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

def setWebSphereVariable ( name, value, nodeName=None, serverName=None, clusterName=None ):
    """Creates a VariableSubstitutionEntry at the specified scope, removing any previously existing entry in the process"""
    map = getVariableMap(nodeName, serverName, clusterName)
    attrs = []
    attrs.append( [ 'symbolicName', name ] )
    attrs.append( [ 'value', value ] )
    return removeAndCreate('VariableSubstitutionEntry', map, attrs, ['symbolicName'])

def saveWorkspaceChanges():
    print('Saving configuration..')

    AdminConfig.save()
#enddef

def syncAllNodes(nodeList, cellName):
    if (len(nodeList) != 0):
        print("Performing nodeSync..")

        AdminNodeManagement.syncActiveNodes()

        for node in (nodeList):
            nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=%s,*') % (node)

            if (nodeRepo):
                AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')
            #endif

            syncNode = AdminControl.completeObjectName('cell=%s,node=%s,type=NodeSync,*') % (cellName, node)

            if (syncNode):
                AdminControl.invoke(syncNode, 'sync')
            #endif

            continue
        #endfor
    #endif
#enddef