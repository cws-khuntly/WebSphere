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

def getAppNameFromArchive(earFile):
    if (os.path.exists(earFile)):
        start_string = "<display-name>"
        end_string = "</display-name>"

        if (earFile.endswith(".war")) or (earFile.endswith(".ear")):
            # read the zipfile
            zf = zipfile.ZipFile(filepath, "r")

            #Get the list of files in the zipfile
            nl = zf.namelist()

            for name in nl:
                if (name.lower().find(("application.xml")) != -1):
                    appxml = zf.read(name)
                    start_index = appxml.find(start_string) + len(start_string)
                    end_index = appxml.find(end_string)

                    appname = appxml[start_index:end_index]
                elif (name.lower().find(("web.xml")) != -1):
                    webxml = zf.read(name)
                    start_index = webxml.find(start_string) + len(start_string)
                    end_index = webxml.find(end_string)

                    appname = webxml[start_index:end_index]
                #endif
            #endfor
        #endif
    #endif

    return appname
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
