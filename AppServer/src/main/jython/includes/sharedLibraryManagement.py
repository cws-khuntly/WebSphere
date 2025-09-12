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

lineSplit = java.lang.System.getProperty("line.separator")

def createSharedLibraryClasspathVariable(targetScope, targetVariableName, targetVariableValue):
    debugLogger.log(logging.DEBUG, "ENTER: sharedLibraryManagement#createSharedLibraryClasspathVariable(targetScope, targetVariableName, targetVariableValue)")
    debugLogger.log(logging.DEBUG, targetScope)
    debugLogger.log(logging.DEBUG, targetVariableName)
    debugLogger.log(logging.DEBUG, targetVariableValue)

    createdVariable = ""

    debugLogger.log(logging.DEBUG, createdVariable)

    if ((len(targetVariableName) != 0) and (len(targetVariableValue) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.list(\"VariableSubstitutionEntry\", targetScope)")

            clusterName = AdminConfig.getid(str("/ServerCluster:{0}/").format("AppServicesCluster"))

            variableList = AdminConfig.list("VariableSubstitutionEntry", clusterName).split(lineSplit)

            debugLogger.log(logging.DEBUG, variableList)

            infoLogger.log(logging.INFO, variableList)

            if (len(variableList) != 0):
                for variableEntry in (variableList):
                    debugLogger.log(logging.DEBUG, variableEntry)
                    debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.showAttribute(variableEntry, \"symbolicName\")")

                    existingVariableEntryName = AdminConfig.showAttribute(variableEntry, "symbolicName")

                    debugLogger.log(logging.DEBUG, existingVariableEntryName)

                    if ((len(existingVariableEntryName) != 0) and (existingVariableEntryName == targetVariableName)):
                        errorLogger.log(logging.ERROR, str("A variable with name {0} in scope {1} already exists.").format(targetVariableName, targetScope))

                        raise Exception(str("A variable with name {0} in scope {1} already exists.").format(targetVariableName, targetScope))
                    #endif
                #endfor
            #endif

            debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.showAttribute(variableEntry, \"symbolicName\")")

            createdVariable = AdminConfig.create("VariableSubstitutionEntry", targetScope, str("[[symbolicName \"{0}\"] [description \"\"] [value \"{1}\"]]").format(targetVariableName, targetVariableValue))

            debugLogger.log(logging.DEBUG, createdVariable)
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred creating WebSphere variable {0} in scope {1}: {2} {3}").format(targetVariableName, targetScope, str(exception), str(parms)))

            raise Exception(str("An error occurred creating WebSphere variable {0} in scope {1}: {2} {3}").format(targetVariableName, targetScope, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No variable name was provided or no value was provided.")

        raise Exception("No variable name was provided or no value was provided.")
    #endif

    debugLogger.log(logging.DEBUG, createdVariable)
    debugLogger.log(logging.DEBUG, "EXIT: sharedLibraryManagement#createSharedLibraryClasspathVariable(targetScope, targetVariableName, targetVariableValue)")

    return createdVariable
#enddef

def createSharedLibrary(targetScope, targetLibraryName, targetLibraryClassPath):
    debugLogger.log(logging.DEBUG, "ENTER: sharedLibraryManagement#createSharedLibrary(targetScope, targetLibraryName, targetLibraryClassPath)")
    debugLogger.log(logging.DEBUG, targetScope)
    debugLogger.log(logging.DEBUG, targetLibraryName)
    debugLogger.log(logging.DEBUG, targetLibraryClassPath)

    if ((len(targetLibraryName) != 0) and (len(targetLibraryClassPath) != 0)):
        debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.list(\"Library\", AdminConfig.getid(targetScope))")

        existingSharedLibraries = AdminConfig.list("Library", AdminConfig.getid(targetScope))

        if (len(existingSharedLibraries) != 0):
            for existingSharedLibrary in (existingSharedLibraries):
                debugLogger.log(logging.DEBUG, existingSharedLibrary)
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.showAttribute(variableEntry, \"symbolicName\")")

                existingSharedLibraryName = AdminConfig.showAttribute(targetLibraryName, "name")

                debugLogger.log(logging.DEBUG, existingSharedLibraryName)

                if ((len(existingSharedLibraryName) != 0) and (existingSharedLibraryName == targetLibraryName)):
                    errorLogger.log(logging.ERROR, str("A shared library with name {0} in scope {1} already exists.").format(targetLibraryName, targetScope))

                    raise Exception(str("A shared library with name {0} in scope {1} already exists.").format(targetLibraryName, targetScope))
                #endif
            #endfor
        #endif

        debugLogger.log(logging.DEBUG, "Calling createSharedLibraryClasspathVariable")
        debugLogger.log(logging.DEBUG, "EXEC: createSharedLibraryClasspathVariable()")

        try:
            createSharedLibraryClasspathVariable = AdminConfig.create("VariableSubstitutionEntry", targetScope, str("[[symbolicName \"{0}\"] [description \"\"] [value \"{1}\"]]").format(targetVariableName, targetVariableValue))

            debugLogger.log(logging.DEBUG, createSharedLibraryClasspathVariable)

            if (len(createSharedLibraryClasspathVariable) != 0):
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.showAttribute(variableEntry, \"symbolicName\")")

                try:
                    AdminConfig.create("Library", targetScope, str("[[nativePath \"\"] [name \"{0}\"] [isolatedClassLoader false] [description \"\"] [classPath \"{1}\"]]").format(targetLibraryName, str("$\{{0}\}").format(targetLibraryClassPath)))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred creating shared library {0} in scope {1}: {2} {3}").format(targetLibraryName, targetScope, str(exception), str(parms)))

                    raise Exception(str("An error occurred creating shared library {0} in scope {1}: {2} {3}").format(targetLibraryName, targetScope, str(exception), str(parms)))
                #endtry
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred creating WebSphere variable {0} in scope {1}: {2} {3}").format(targetLibraryName, targetScope, str(exception), str(parms)))

            raise Exception(str("An error occurred creating WebSphere variable {0} in scope {1}: {2} {3}").format(targetLibraryName, targetScope, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No variable name was provided or no value was provided.")

        raise Exception("No variable name was provided or no value was provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: sharedLibraryManagement#createSharedLibrary(targetScope, targetLibraryName, targetLibraryClassPath)")
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