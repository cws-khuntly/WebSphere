#==============================================================================
#
#          FILE:  configureDMGR.py
#         USAGE:  wsadmin.sh -lang jython -f configureDMGR.py
#     ARGUMENTS:  wasVersion
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
import zipfile

def getAppDisplayName(filePath):
    if (os.path.exists(filePath)):
        start_string = "<display-name>"
        end_string = "</display-name>"

        if (filePath.endswith(".war")) or (filePath.endswith(".ear")):
            zf = zipfile.ZipFile(filePath, "r")
            nl = zf.namelist()

            for name in nl:
                if (name.lower().find(("application.xml")) != -1):
                    appxml = zf.read(name)
                    start_index = appxml.find(start_string) + len(start_string)
                    end_index = appxml.find(end_string)

                    appDisplayName = appxml[start_index:end_index]
                elif (name.lower().find(("web.xml")) != -1):
                    webxml = zf.read(name)
                    start_index = webxml.find(start_string) + len(start_string)
                    end_index = webxml.find(end_string)

                    appDisplayName = webxml[start_index:end_index]
                #endif
            #endfor
        else:
            print ("An unsupported archive type was provided.")
        #endif
    #endif

    return appDisplayName
#enddef

def getAppModuleName(filePath):
    if (os.path.exists(filePath)):
        start_string = "<web-uri>"
        end_string = "</web-uri>"

        if (filePath.endswith(".ear")):
            zf = zipfile.ZipFile(filePath, "r")
            nl = zf.namelist()

            for name in nl:
                if (name.lower().find(("application.xml")) != -1):
                    appxml = zf.read(name)
                    start_index = appxml.find(start_string) + len(start_string)
                    end_index = appxml.find(end_string)

                    appModuleName = appxml[start_index:end_index]
                #endif
            #endfor
        else:
            print ("An unsupported archive type was provided.")
        #endif
    #endif

    return appModuleName
#enddef

def getAppWarName(filePath):
    if (os.path.exists(filePath)):
        start_string = "<web-uri>"
        end_string = "</web-uri>"

        if (filePath.endswith(".ear")):
            zf = zipfile.ZipFile(filePath, "r")
            nl = zf.namelist()

            for name in nl:
                if (name.lower().endswith(("war")) != -1):
                    appWarName = name.lower()
                #endif
            #endfor
        else:
            print ("An unsupported archive type was provided.")
        #endif
    #endif

    return appWarName
#enddef

def getFileNameFromPath(filePath):
    return os.path.basename(filePath).split('/')[-1]
#enddef

def hasExtraFileExtension(inString):
    if (not isinstance(inString, str)):
        raise TypeError("Input must be a string.")
    else:
        return bool(inString.endswith(".war.war"))
    #endif
#enddef

def removeExtraExtension(inString, removeNumber):
    if (not isinstance(inString, str)):
        raise TypeError("Input must be a string.")
    elif (not isinstance(removeNumber, int)):
        raise TypeError("Number of characters to remove must be an integer.")
    elif (removeNumber <= 0):
        raise ValueError("Number of characters to remove cannot be negative or 0.")
    else:
        if (hasExtraFileExtension(inString)):
            return inString[:-removeNumber]
        else:
            return inString
        #endif
    #endif
#enddef

def saveWorkspaceChanges():
    print('Saving configuration..')

    AdminConfig.save()
#enddef

def syncAllNodes(nodeList):
    print('Performing nodeSync...')

    AdminNodeManagement.syncActiveNodes()

    for node in nodeList:
        nodeRepo = AdminControl.completeObjectName('type=ConfigRepository,process=nodeagent,node=' + node + ',*')

        if (nodeRepo):
            AdminControl.invoke(nodeRepo, 'refreshRepositoryEpoch')
        #endif

        syncNode = AdminControl.completeObjectName('cell=' + targetCell + ',node=' + node + ',type=NodeSync,*')

        if (syncNode):
            AdminControl.invoke(syncNode, 'sync')
        #endif

        continue
    #endfor
#enddef
