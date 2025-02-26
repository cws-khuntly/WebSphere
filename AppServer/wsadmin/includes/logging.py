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
import xml.etree.ElementTree as ET

def configureLogging(logConfigFile):
    if (len(logConfigFile) != 0):
        if (os.path.exists(logConfigFile)) and (os.access(logConfigFile, os.R_OK)):
            try:
                tree = ET.parse(logConfigFile)
                root = tree.getroot()

                logging.config.dictConfig(convertXmlToDict(root))
            except Exception as e:
                print(f"Error configuring logging from XML: {e}")
            #endtry
        else:
            print ("Unable to load logging configuration file. No logging enabled!")
        #endif
    else:
        print ("No logging configuration file was provided. No logging enabled!")
    #endif
#enddef

def convertXmlToDict(element):
    result = {}

    for child in (element):
        if (len(child) != 0):
            tag = child.tag
            text = child.text.strip() if (child.text) else None

            if (len(child) > 0):
                result[tag] = convertXmlToDict(child)
            elif (len(text) != 0):
                result[tag] = text
            else:
                result[tag] = {}
            #endif
        #endif
    #endfor

    return result
#enddef
