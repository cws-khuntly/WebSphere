#==============================================================================
#
#          FILE:  configureTargetServer.py
#         USAGE:  wsadmin.sh -lang jython -f configureTargetServer.py
#     ARGUMENTS:  wasVersion serverName clusterName vHostName (vHostAliases) (serverLogRoot)
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

import logging
import ConfigParser

configureLogging(str("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties"))
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")

def returnPropertyConfiguration(configFile, sectionName, valueName):
    debugLogger.log(logging.DEBUG, "ENTER: includes#returnPropertyConfiguration(configFile, sectionName, valueName)")
    debugLogger.log(logging.DEBUG, configFile)
    debugLogger.log(logging.DEBUG, sectionName)
    debugLogger.log(logging.DEBUG, valueName)

    configResponse = ""

    debugLogger.log(logging.DEBUG, configResponse)

    config = ConfigParser.ConfigParser()
    config.read(configFile)

    debugLogger.log(logging.DEBUG, config)

    if (len(config) != 0):
        configResponse = config.get(sectionName, valueName)
    else:
        errorLogger.log(logging.ERROR, str("Unable to locate value {0}, section {1} in file {3}").format(valueName, sectionName, configFile))

        raise Exception(str("Unable to locate value {0}, section {1} in file {3}").format(valueName, sectionName, configFile))
    #endif

    debugLogger.log(logging.DEBUG, configResponse)
    debugLogger.log(logging.DEBUG, "EXIT: includes#returnPropertyConfiguration(configFile, sectionName, valueName)")

    return configResponse
#enddef
