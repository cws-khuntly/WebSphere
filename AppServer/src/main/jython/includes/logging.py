#==============================================================================
#
#          FILE:  logging.py
#         USAGE:  Simple class to configure a logger
#     ARGUMENTS:  logConfigFile: The file to use for configuration options
#   DESCRIPTION:  Configures a logging subsystem based on a provided configuration file
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
import logging
import logging.config

def configureLogging(logConfigFile):
    defaultLogConfig = "../wsadmin/logging.properties"

    if (len(logConfigFile) != 0):
        if (os.path.exists(logConfigFile)) and (os.access(logConfigFile, os.R_OK)):
            try:
                logging.config.fileConfig(logConfigFile)
            except Exception as e:
                print(str("Failed to configure logging: {0}. No logging enabled!").format(str(e)))
            #endtry
        else:
            print("Unable to load logging configuration file. No logging enabled!")
        #endif
    elif (len(defaultLogConfig) == 0):
        if (os.path.exists(defaultLogConfig)) and (os.access(defaultLogConfig, os.R_OK)):
            try:
                logging.config.fileConfig(defaultLogConfig)
            except Exception as e:
                print(str("Failed to configure logging: {0}. No logging enabled!").format(str(e)))
            #endtry
        else:
            print("Unable to load default logging configuration file. No logging enabled!")
        #endif
    else:
        print("Unable to load default logging configuration file. No logging enabled!")
        #endif
#enddef
