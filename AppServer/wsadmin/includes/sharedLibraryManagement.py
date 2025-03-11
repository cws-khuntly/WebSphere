#==============================================================================
#
#          FILE:  sharedLibraryManagement.py
#         USAGE:  wsadmin.sh -lang jython -f sharedLibraryManagement.py
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

import sys
import logging

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")

def createSharedLibrary(targetCell, targetLibraryName, targetLibraryClassPath):
    debugLogger.log(logging.DEBUG, "ENTER: sharedLibraryManagement#createSharedLibrary(targetCell, targetLibraryName, targetLibraryClassPath)")
    debugLogger.log(logging.DEBUG, targetCell)
    debugLogger.log(logging.DEBUG, targetLibraryName)
    debugLogger.log(logging.DEBUG, targetLibraryClassPath)

    if ((len(targetLibraryName) != 0) and (len(targetLibraryClassPath) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminConfig.create()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.create(\"Library\", targetCell, str(\"[[\"name\"', \"{0}\"], [\"classPath\", \"{1}\"]]\").format(targetLibraryName, targetLibraryClassPath)"))

            AdminConfig.create("Library", targetCell, str("[[\"name\"', \"{0}\"], [\"classPath\", \"{1}\"]]").format(targetLibraryName, targetLibraryClassPath))

            infoLogger.log(logging.INFO, str("Completed creating shared library {0} with classpath {1}.").format(targetLibraryName, targetLibraryClassPath))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred creating shared library {0}: {1} {2}").format(targetLibraryName, str(exception), str(parms)))

            raise Exception(str("An error occurred creating shared library {0}: {1} {2}").format(targetLibraryName, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No library name was provided or no classpath was provided."))

        raise Exception(str("No library name was provided or no classpath was provided."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: sharedLibraryManagement#createSharedLibrary(targetCell, targetLibrary, targetLibraryClassPath)"))
#enddef

def addSharedLibraryToServer(targetServer, targetLibraryName):
    """Creates a classloader on the specified appserver and associates it with a shared library"""
    m = "createSharedLibraryClassloader:"
    #sop(m,"Entry. Create shared library classloader. nodename=%s servername=%s libname=%s " % ( repr(nodename), repr(servername), repr(libname) ))
    server_id = getServerByNodeAndName(nodename, servername )
    #sop(m,"server_id=%s " % ( repr(server_id), ))
    appserver = AdminConfig.list('ApplicationServer', server_id)
    #sop(m,"appserver=%s " % ( repr(appserver), ))
    classloader = AdminConfig.create('Classloader', appserver, [['mode', 'PARENT_FIRST']])
    #sop(m,"classloader=%s " % ( repr(classloader), ))
    result = AdminConfig.create('LibraryRef', classloader, [['libraryName', libname], ['sharedClassloader', 'true']])
    #sop(m,"Exit. result=%s" % ( repr(result), ))
