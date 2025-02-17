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

import sys
import platform
import time

sys.path.append(os.path.expanduser('~') + '/lib/wasadmin/')

import includes

lineSplit = java.lang.System.getProperty("line.separator")

targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

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
    syncAllNodes(nodeList)
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
    syncAllNodes(nodeList)
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
