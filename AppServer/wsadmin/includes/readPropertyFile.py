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

errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")

def returnPropertyConfiguration(configFile, sectionName, valueName):
    debugLogger.log(logging.DEBUG, str("ENTER: includes#returnPropertyConfiguration(configFile, sectionName, valueName)"))
    debugLogger.log(logging.DEBUG, str(configFile))
    debugLogger.log(logging.DEBUG, str(sectionName))
    debugLogger.log(logging.DEBUG, str(valueName))

    configResponse = ""

    debugLogger.log(logging.DEBUG, str(configResponse))

    config = ConfigParser.ConfigParser()
    config.read(configFile)

    debugLogger.log(logging.DEBUG, str(config))

    if (len(config) != 0):
        configResponse = config.get(str(sectionName), str(valueName))
    else:
        errorLogger.log(logging.ERROR, str("Unable to locate value {0}, section {1} in file {3}").format(valueName, sectionName, configFile))
        raise Exception(str("Unable to locate value {0}, section {1} in file {3}").format(valueName, sectionName, configFile))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: includes#returnPropertyConfiguration(configFile, sectionName, valueName)"))

    return configResponse
#enddef
