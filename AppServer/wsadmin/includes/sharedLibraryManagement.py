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
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"Library\", targetCell, str(\"[[\"name\"', \"{0}\"], [\"classPath\", \"{1}\"]]\").format(targetLibraryName, targetLibraryClassPath)")

            AdminConfig.create("Library", targetCell, str("[[\"name\"', \"{0}\"], [\"classPath\", \"{1}\"]]").format(targetLibraryName, targetLibraryClassPath))

            infoLogger.log(logging.INFO, str("Completed creating shared library {0} with classpath {1}.").format(targetLibraryName, targetLibraryClassPath))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred creating shared library {0}: {1} {2}").format(targetLibraryName, str(exception), str(parms)))

            raise Exception(str("An error occurred creating shared library {0}: {1} {2}").format(targetLibraryName, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No library name was provided or no classpath was provided.")

        raise Exception("No library name was provided or no classpath was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: sharedLibraryManagement#createSharedLibrary(targetCell, targetLibrary, targetLibraryClassPath)")
#enddef

def addSharedLibraryToServer(targetServer, targetLibraryName):
    debugLogger.log(logging.DEBUG, "ENTER: sharedLibraryManagement#addSharedLibraryToServer(targetServer, targetLibraryName)")
    debugLogger.log(logging.DEBUG, targetServer)
    debugLogger.log(logging.DEBUG, targetLibraryName)

    if ((len(targetServer) != 0) and (len(targetLibraryName) != 0)):
        try:
            existingClassLoader = AdminConfig.list("ClassLoader", targetServer)

            debugLogger.log(logging.DEBUG, existingClassLoader)

            if (len(existingClassLoader) == 0):
                debugLogger.log(logging.DEBUG, "No existing classloader definition found. Creating a new classloader.")
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"Classloader\", targetServer, \"[[mode PARENT_LAST]]\")")

                existingClassLoader = AdminConfig.create("Classloader", targetServer, "[[mode PARENT_LAST]]")

                debugLogger.log(logging.DEBUG, existingClassLoader)
            #endif

            debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"LibraryRef\", existingClassLoader, \"[[libraryName \"{0}\"]]\")")

            AdminConfig.create("LibraryRef", existingClassLoader, str("[[libraryName \"{0}\"], [sharedClassloader \"true\"]]").format(targetLibraryName))

            infoLogger.log(logging.INFO, str("Completed adding shared library {0} to server {1}.").format(targetLibraryName, targetServer))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred adding shared library {0} to server {1}: {2} {3}").format(targetLibraryName, targetServer, str(exception), str(parms)))

            raise Exception(str("An error occurred adding shared library {0} to server {1}: {2} {3}").format(targetLibraryName, targetServer, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No library name was provided or no server was provided."))

        raise Exception(str("No library name was provided or no server was provided."))
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: sharedLibraryManagement#addSharedLibraryToServer(targetServer, targetLibraryName)")
#enddef