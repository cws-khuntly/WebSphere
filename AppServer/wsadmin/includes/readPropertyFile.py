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

import configparser

def readConfigurationFile(configFile, separator="=", comment="#"):
    properties = {}

    with (open(configFile, "r")) as propFile:
        if (propFile):
            for entry in (propFile):
                if (entry):
                    line = entry.strip()

                    if ((line) and not (line.startswith(comment))):
                        keyValue = line.split(separator)
                        keyName = keyValue[0].strip()
                        returnValue = separator.join(keyValue[1:]).strip().strip('"')

                        properties[keyName] = returnValue
                    #endif
                #endif
            #endfor
        #endif
    #endwhile
#enddef

def readConfigurationFileSection(configFile, sectionName):
    properties = {}

    with (open(configFile, "r")) as propFile:
        if (propFile):
            config = configparser.ConfigParser()

            if (config):
                try:
                    config.read(configFile)

                    for keyName, keyValue in (config[sectionName].items()):
                        properties[keyName] = keyValue
                    #endfor
                except:
                    raise ("An error occurred while parsing the provided configuration file.")
                #endtry
            #endif
        else:
            raise ("Unable to read the provided configuration file.")
        #endif
    #endwhile

    return properties
#enddef
