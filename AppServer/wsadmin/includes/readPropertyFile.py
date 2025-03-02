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

debugLogger = logging.getLogger("debug-logger")

def returnPropertyConfiguration(configFile, sectionName, valueName):
    debugLogger.log(logging.DEBUG, configFile)
    debugLogger.log(logging.DEBUG, sectionName)
    debugLogger.log(logging.DEBUG, valueName)

    config = ConfigParser.ConfigParser()
    config.read(configFile)

    debugLogger.log(logging.DEBUG, config)

    return config.get(sectionName, valueName)
#enddef
