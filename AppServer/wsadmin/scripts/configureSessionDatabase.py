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

import os
import sys

configureLogging("../config/logging.xml")
logger = logging.getLogger(__name__)

lineSplit = java.lang.System.getProperty("line.separator")
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def createJdbcProvider ( parent, name, classpath, nativepath, implementationClassName, description, providerType=None ):
    """Creates a JDBCProvider in the specified parent scope; removes existing objects with the same name"""
    attrs = []
    attrs.append( [ 'name', name ] )
    attrs.append( [ 'classpath', classpath ] )
    attrs.append( [ 'nativepath', nativepath ] )
    attrs.append( [ 'implementationClassName', implementationClassName ] )
    attrs.append( [ 'description', description ] )
    if providerType:
        attrs.append( [ 'providerType', providerType ] )
    return removeAndCreate('JDBCProvider', parent, attrs, ['name'])

def removeJdbcProvidersByName ( providerName ):
    """Removes all the JDBCProvider objects with the specified name.  Implicitly deletes underlying DataSource objects."""
    findAndRemove('JDBCProvider', [['name', providerName]])

def createDataSource ( jdbcProvider, datasourceName, datasourceDescription, datasourceJNDIName, statementCacheSize, authAliasName, datasourceHelperClassname ):
    """Creates a DataSource under the given JDBCProvider; removes existing objects with the same jndiName"""
    mapping = []
    mapping.append( [ 'authDataAlias', authAliasName ] )
    mapping.append( [ 'mappingConfigAlias', 'DefaultPrincipalMapping' ] )
    attrs = []
    attrs.append( [ 'name', datasourceName ] )
    attrs.append( [ 'description', datasourceDescription ] )
    attrs.append( [ 'jndiName', datasourceJNDIName ] )
    attrs.append( [ 'statementCacheSize', statementCacheSize ] )
    attrs.append( [ 'authDataAlias', authAliasName ] )
    attrs.append( [ 'datasourceHelperClassname', datasourceHelperClassname ] )
    attrs.append( [ 'mapping', mapping ] )
    datasourceID = removeAndCreate( 'DataSource', jdbcProvider, attrs, ['jndiName'])
    create('J2EEResourcePropertySet', datasourceID, [], 'propertySet')
    return datasourceID

def createDataSource_ext ( scope, clusterName, nodeName, serverName_scope, jdbcProvider, datasourceName, datasourceDescription, datasourceJNDIName, statementCacheSize, authAliasName, datasourceHelperClassname, dbType, nonTransDS='', cmpDatasource='true', xaRecoveryAuthAlias=None, databaseName=None, serverName=None, portNumber=None, driverType=None, URL=None, informixLockModeWait=None, ifxIFXHOST=None ):
    """Creates a DataSource under the given JDBCProvider; removes existing objects with the same jndiName"""

    m = "createDataSource_ext"
    sop (m, "Entering createDataSource_ext...")
    mapping = []
    mapping.append( [ 'authDataAlias', authAliasName ] )
    mapping.append( [ 'mappingConfigAlias', 'DefaultPrincipalMapping' ] )
    attrs = []
    attrs.append( [ 'name', datasourceName ] )
    attrs.append( [ 'description', datasourceDescription ] )
    attrs.append( [ 'jndiName', datasourceJNDIName ] )
    attrs.append( [ 'statementCacheSize', statementCacheSize ] )
    attrs.append( [ 'authDataAlias', authAliasName ] )
    attrs.append( [ 'datasourceHelperClassname', datasourceHelperClassname ] )
    attrs.append( [ 'mapping', mapping ] )

    jdbcProviderType = getObjectAttribute (jdbcProvider, 'providerType')
    sop (m, "jdbcProviderType = %s" % jdbcProviderType)
    if jdbcProviderType:
        sop (m, "looking for 'XA' in providerType")
        if jdbcProviderType.find("XA") >= 0 and xaRecoveryAuthAlias:
            sop (m, "found 'XA' in providerType")
            attrs.append(['xaRecoveryAuthAlias', xaRecoveryAuthAlias])
        #endIf
    #endIf
    sop (m, "calling removeAndCreate to create datasource")
    datasourceID = removeAndCreate( 'DataSource', jdbcProvider, attrs, ['jndiName'])
    create('J2EEResourcePropertySet', datasourceID, [], 'propertySet')

    # Create properties for the datasource based on the specified database type

    sop (m, "Create properties for the datasource based on the specified database type")
    dsProps = []

    retcode = 0
    if dbType == 'DB2':
        if (databaseName == None or serverName == None or portNumber == None or driverType == None):
            sop (m, "All required properties for a DB2 datasource (databaseName, serverName, portNumber, driverType) were not specified.")
            retcode = 2
        else:
            dsProps.append( [ 'databaseName', 'java.lang.String',  databaseName ] )
            dsProps.append( [ 'serverName',   'java.lang.String',  serverName   ] )
            dsProps.append( [ 'portNumber',   'java.lang.Integer', portNumber   ] )
            dsProps.append( [ 'driverType',   'java.lang.Integer', driverType   ] )
    elif dbType == 'SQLServer-DD':
        if serverName == None:
            sop (m, "All required properties for a SQL Server (Data Direct) datasource (serverName) were not specified.")
            retcode = 3
        else:
            dsProps.append( [ 'serverName',   'java.lang.String',  serverName   ] )
            if databaseName:
                dsProps.append( [ 'databaseName', 'java.lang.String',  databaseName ] )
            if portNumber:
                dsProps.append( [ 'portNumber',   'java.lang.Integer', portNumber   ] )
    elif dbType == 'SQLServer-MS':
        if databaseName:
            dsProps.append( [ 'databaseName', 'java.lang.String',  databaseName ] )
        if serverName:
            dsProps.append( [ 'serverName',   'java.lang.String',  serverName   ] )
        if portNumber:
            dsProps.append( [ 'portNumber',   'java.lang.Integer', portNumber   ] )
    elif dbType == 'Oracle':
        if URL == None:
            sop (m, "All required properties for an Oracle datasource (URL) were not specified.")
            retcode = 4
        else:
            dsProps.append( [ 'URL', 'java.lang.String', URL ] )
    elif dbType == 'Sybase2':
        if (databaseName == None or serverName == None or portNumber == None):
            sop (m, "All required properties for a Sybase JDBC-2 datasource (databaseName, serverName, portNumber, driverType) were not specified.")
            retcode = 5
        else:
            dsProps.append( [ 'databaseName', 'java.lang.String',  databaseName ] )
            dsProps.append( [ 'serverName',   'java.lang.String',  serverName   ] )
            dsProps.append( [ 'portNumber',   'java.lang.Integer', portNumber   ] )
    elif dbType == 'Sybase3':
        if (databaseName == None or serverName == None or portNumber == None):
            sop (m, "All required properties for a Sybase JDBC-3 datasource (databaseName, serverName, portNumber, driverType) were not specified.")
            retcode = 6
        else:
            dsProps.append( [ 'databaseName', 'java.lang.String',  databaseName ] )
            dsProps.append( [ 'serverName',   'java.lang.String',  serverName   ] )
            dsProps.append( [ 'portNumber',   'java.lang.Integer', portNumber   ] )
    elif dbType == 'Informix':
        if (databaseName == None or serverName == None or informixLockModeWait == None):
            sop (m, "All required properties for an Informix datasource (databaseName, serverName, informixLockModeWait) were not specified.")
            retcode = 7
        else:
            dsProps.append( [ 'databaseName',         'java.lang.String',   databaseName         ] )
            dsProps.append( [ 'serverName',           'java.lang.String',   serverName           ] )
            dsProps.append( [ 'informixLockModeWait', 'java.lang.Integer',  informixLockModeWait ] )
            if portNumber:
                dsProps.append( [ 'portNumber', 'java.lang.Integer', portNumber ] )
            if ifxIFXHOST:
                dsProps.append( [ 'ifxIFXHOST', 'java.lang.String',  ifxIFXHOST ] )
    else:  # Invalid dbType specified
        sop (m, "Invalid dbType '%s' specified" % dbType)
        retcode = 8
    # end else

    if retcode == 0:
        if (nonTransDS != ""):
            dsProps.append( [ 'nonTransactionalDataSource', 'java.lang.Boolean', nonTransDS ] )
        #endif

        for prop in dsProps:
            propName  = prop[0]
            propType  = prop[1]
            propValue = prop[2]
            propDesc  = ""
            sop (m, "calling setJ2eeResourceProperty")
            setJ2eeResourceProperty (  \
                                        datasourceID,
                                        propName,
                                        propType,
                                        propValue,
                                        propDesc,
                                    )
            sop (m, "returned from calling setJ2eeResourceProperty")
        # endfor

        # Create CMP Connection Factory if this datasource will support Container Managed Persistence

        sop (m, "checking if cmpDatasource == 'true'")
        if cmpDatasource == 'true':
            sop(m, "calling createCMPConnectorFactory")
            createCMPConnectorFactory ( scope, clusterName, nodeName, serverName_scope, datasourceName, authAliasName, datasourceID )
            sop(m, "returned from calling createCMPConnectorFactory")
        #endIf

        return datasourceID
    else:
        return None
    #endif


def configureDSConnectionPool (scope, clustername, nodename, servername, jdbcProviderName, datasourceName, connectionTimeout, minConnections, maxConnections, additionalParmsList=[]):
    """ This function configures the Connection Pool for the specified datasource for
        the specified JDBC Provider.

        Input parameters:

        scope - the scope of the datasource.  Valid values are 'cell', 'node', 'cluster', and 'server'.
        clustername - name of the cluster for the datasource.  Required if scope = 'cluster'.
        nodename - the name of the node for the datasource.  Required if scope = 'node' or 'server'.
        servername - the name of the server for the datasource.  Required if scope = 'server'.
        jdbcProviderName - the name of the JDBC Provider for the datasource
        datasourceName - the name of the datasource whose connection pool is to be configured.
        connectionTimeout - Specifies the interval, in seconds, after which a connection request times out.
                            Valid range is 0 to the maximum allowed integer.
        minConnections - Specifies the minimum number of physical connections to maintain.  Valid
                         range is 0 to the maximum allowed integer.
        maxConnections - Specifies the maximum number of physical connections that you can create in this
                         pool.  Valid range is 0 to the maximum allowed integer.
        additionalParmsList - A list of name-value pairs for other Connection Pool parameters.  Each
                              name-value pair should be specified as a list, so this parameter is
                              actually a list of lists.  The following additional parameters can be
                              specified:
                              - 'reapTime' - Specifies the interval, in seconds, between runs of the
                                             pool maintenance thread.  Valid range is 0 to the maximum
                                             allowed integer.
                              - 'unusedTimeout' - Specifies the interval in seconds after which an unused
                                                  or idle connection is discarded.  Valid range is 0 to
                                                  the maximum allowed integer.
                              - 'agedTimeout' - Specifies the interval in seconds before a physical
                                                connection is discarded.  Valid range is 0 to the maximum
                                                allowed integer.
                              - 'purgePolicy' - Specifies how to purge connections when a stale
                                                connection or fatal connection error is detected.
                                                Valid values are EntirePool and FailingConnectionOnly.
                              - 'numberOfSharedPoolPartitions' - Specifies the number of partitions that
                                                                 are created in each of the shared pools.
                                                                 Valid range is 0 to the maximum allowed
                                                                 integer.
                              - 'numberOfFreePoolPartitions' - Specifies the number of partitions that
                                                               are created in each of the free pools.
                                                               Valid range is 0 to the maximum allowed
                                                               integer.
                              - 'freePoolDistributionTableSize' - Determines the distribution of Subject
                                                                  and CRI hash values in the table that
                                                                  indexes connection usage data.
                                                                  Valid range is 0 to the maximum allowed
                                                                  integer.
                              - 'surgeThreshold' - Specifies the number of connections created before
                                                   surge protection is activated.  Valid range is -1 to
                                                   the maximum allowed integer.
                              - 'surgeCreationInterval' - Specifies the amount of time between connection
                                                          creates when you are in surge protection mode.
                                                          Valid range is 0 to the maximum allowed integer.
                              - 'stuckTimerTime' - This is how often, in seconds, the connection pool
                                                   checks for stuck connections.  Valid range is 0 to the
                                                   maximum allowed integer.
                              - 'stuckTime' - The stuck time property is the interval, in seconds, allowed
                                              for a single active connection to be in use to the backend
                                              resource before it is considered to be stuck.  Valid range
                                              is 0 to the maximum allowed integer.
                              - 'stuckThreshold' - The stuck threshold is the number of connections that
                                                   need to be considered stuck for the pool to be in stuck
                                                   mode.  Valid range is 0 to the maximum allowed integer.

        Here is an example of how the 'additionalParmsList" argument could be built by the caller:

        additionalParmsList = []
        additionalParmsList.append( [ 'unusedTimeout', '600' ] )
        additionalParmsList.append( [ 'agedTimeout', '600' ] )

        Outputs - No return values.  If an error is detected, an exception will be thrown.
    """

    m = "configureDSConnectionPool:"
    sop (m, "Entering function...")

    if scope == 'cell':
        sop (m, "Calling getCellName()")
        cellname = getCellName()
        sop (m, "Returned from getCellName(); cellname = %s." % cellname)
        dsStringRep = '/Cell:%s/JDBCProvider:%s/DataSource:%s/' % (cellname, jdbcProviderName, datasourceName)
    elif scope == 'cluster':
        dsStringRep = '/ServerCluster:%s/JDBCProvider:%s/DataSource:%s/' % (clustername, jdbcProviderName, datasourceName)
    elif scope == 'node':
        dsStringRep = '/Node:%s/JDBCProvider:%s/DataSource:%s/' % (nodename, jdbcProviderName, datasourceName)
    elif scope == 'server':
        dsStringRep = '/Node:%s/Server:%s/JDBCProvider:%s/DataSource:%s/' % (nodename, servername, jdbcProviderName, datasourceName)
    else:
        raise 'Invalid scope specified: %s' % scope
    #endif

    sop (m, "Calling AdminConfig.getid with the following name: %s." % dsStringRep)
    dsID = AdminConfig.getid(dsStringRep)
    sop (m, "Returned from AdminConfig.getid; returned dsID = %s" % dsID)

    if dsID == '':
        raise 'Could not get config ID for name = %s' % dsStringRep
    else:
        sop (m, "Calling AdminConfig.showAttribute to get the connectionPool config ID")
        cpID = AdminConfig.showAttribute(dsID,'connectionPool')
        sop (m, "Returned from AdminConfig.showAttribute; returned cpID = %s" % cpID)
        if cpID == '':
            raise 'Could not get connectionPool config ID'
        else:
            attrs = []
            attrs.append( [ 'connectionTimeout', connectionTimeout ] )
            attrs.append( [ 'minConnections', minConnections ] )
            attrs.append( [ 'maxConnections', maxConnections ] )

            if additionalParmsList != []:
                attrs = attrs + additionalParmsList

            sop (m, "Calling AdminConfig.modify with the following parameters: %s" % attrs)
            AdminConfig.modify (cpID, attrs)
            sop (m, "Returned from AdminConfig.modify")
        #endif
    #endif

    sop (m, "Exiting function...")
#endDef

def testDataSourcesByJndiName ( jndiName ):
    """Tests DataSource connectivity for all DataSource objects with a matching JNDI name.  If any AdminControl.testConnection fails, an exception is raised."""
    m = "testDataSourcesByJndiName:"
    dataSources = getFilteredTypeList('DataSource', [['jndiName', jndiName]])
    for dataSource in dataSources:
        sop(m, 'AdminControl.testConnection(%s)' % ( repr(dataSource) ) )
        try:
            sop(m, "  "+AdminControl.testConnection(dataSource) )
        except:
            # sometimes the error message is cryptic, so it's good to explicitly state the basic cause of the problem
            sop(m, "  Unable to establish a connection with DataSource %s" % (dataSource)  )
            raise Exception("Unable to establish a connection with DataSource %s" % (dataSource))


def addOracleSessionDatabase(driverPath, oracleURL, entryName):
    ## add oracle jdbc driver
    print("Adding ORACLE_JDBC_DRIVER_PATH variable to cell " + targetCell + "..")

    AdminTask.setVariable('[-variableName ORACLE_JDBC_DRIVER_PATH -variableValue ' + driverPath + ' -scope Cell=' + targetCell +']')

    ## add session jdbc provider
    print("Adding JDBC Provider ..")
    AdminTask.createJDBCProvider('[-scope Cell=' + targetCell + ' -databaseType Oracle ' +
        '-providerType "Oracle JDBC Driver" -implementationType "Connection pool data source" ' +
        '-name "Oracle JDBC Driver" -description "Oracle JDBC Driver" -classpath [${ORACLE_JDBC_DRIVER_PATH}/ojdbc6.jar]]')

    ## add session jdbc entry
    print("Adding JDBC Entry..")
    AdminTask.createDatasource(AdminConfig.list("JDBCProvider", "*Oracle*cells/" + targetCell + "|*"),
        '[-name ' + entryName + ' -jndiName jdbc/' + entryName + ' -dataStoreHelperClassName com.ibm.websphere.rsadapter.Oracle11gDataStoreHelper ' +
        '-containerManagedPersistence true -configureResourceProperties [[URL java.lang.String ' + oracleURL + ']]]')

    print("Modifying JDBC entry..")
    AdminConfig.modify(AdminConfig.list("ConnectionPool", "*cells/" + targetCell + "|*"), '[[connectionTimeout "60"] [maxConnections "10"] [unusedTimeout "300"] [minConnections "1"]' '[purgePolicy "FailingConnectionOnly"] [agedTimeout "1800"] [reapTime "180"]]')

    saveWorkspaceChanges()
    syncAllNodes(nodeList, targetCell)
#enddef

def addDB2SessionDatabase(driverPath, databaseName, serverName, portNumber, entryName):
    ## add oracle jdbc driver
    print("Adding DB2UNIVERSAL_JDBC_DRIVER_PATH..")
    AdminTask.setVariable('[-variableName DB2UNIVERSAL_JDBC_DRIVER_PATH -variableValue ' + driverPath + ' -scope Cell=' + targetCell + ']')

    ## add session jdbc provider
    print("Adding JDBC Provider..")
    AdminTask.createJDBCProvider('[-scope Cell=' + targetCell + ' -databaseType DB2 ' +
        '-providerType "DB2 Universal JDBC Driver Provider" -implementationType "Connection pool data source" ' +
        '-name "DB2 Universal JDBC Driver Provider" -description "DB2 Universal JDBC Provider" ' +
        '-classpath [${DB2UNIVERSAL_JDBC_DRIVER_PATH}/db2jcc.jar ${DB2UNIVERSAL_JDBC_DRIVER_PATH}/db2jcc_license_cu.jar ' +
        '${DB2UNIVERSAL_JDBC_DRIVER_PATH}/db2jcc_license_cisuz.jar ] -nativePath [${DB2UNIVERSAL_JDBC_DRIVER_NATIVEPATH} ] ]')

    ## add session jdbc entry
    print("Adding JDBC entry..")
    AdminTask.createDatasource(AdminConfig.list("JDBCProvider", "*DB2*cells/" + targetCell + "|*"), '[-name ' + entryName + ' -jndiName jdbc/' + entryName + ' -dataStoreHelperClassName com.ibm.websphere.rsadapter.DB2UniversalDataStoreHelper -containerManagedPersistence true -componentManagedAuthenticationAlias -configureResourceProperties [[databaseName java.lang.String ' + databaseName + '] [driverType java.lang.Integer 4] [serverName java.lang.String ' + serverName + '] [portNumber java.lang.Integer ' + portNumber + ']]]')

    print("Modifying JDBC entry..")
    AdminConfig.modify(AdminConfig.list("ConnectionPool", "*cells/" + targetCell + "|*"), '[[connectionTimeout "60"] [maxConnections "10"] [unusedTimeout "300"] [minConnections "1"] [purgePolicy "FailingConnectionOnly"] [agedTimeout "1800"] [reapTime "180"]]')

    saveWorkspaceChanges()
    syncAllNodes(nodeList, targetCell)
#enddef

def printHelp():
    print("This script applies session database information to the cell")
    print("Format is configureSessionDatabase (oracle|db2) <args>")
    print("For an Oracle session database, the path to the JDBC driver, the JDBC URL and the JNDI entry name is required.")
    print("For a DB2 session database, the path to the JDBC driver, the database name, server name, port number and JNDI entry name are required")
#enddef

##################################
# main
##################################
if(len(sys.argv) != 0):
    # get node name and process name from the command line
    if (sys.argv[0] == "oracle"):
        if (len(sys.argv) != 4):
            printHelp()
        else:
            addOracleSessionDatabase(sys.argv[1], sys.argv[2], sys.argv[3])
        #endif
    elif (sys.argv[0] == "db2"):
        if (len(sys.argv) != 6):
            printHelp()
        else:
            addDB2SessionDatabase(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
        #endif
    else:
        printHelp()
    #endif
else:
    printHelp()
#endif
