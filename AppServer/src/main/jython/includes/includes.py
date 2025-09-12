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
import logging
import zipfile

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")

def getAppDisplayName(filePath):
    debugLogger.log(logging.DEBUG, "ENTER: includes#getAppDisplayName(filePath)")
    debugLogger.log(logging.DEBUG, filePath)

    if (os.path.exists(filePath)):
        startPoint = "<display-name>"
        endPoint = "</display-name>"

        debugLogger.log(logging.DEBUG, startPoint)
        debugLogger.log(logging.DEBUG, endPoint)

        if (filePath.endswith(".war")) or (filePath.endswith(".ear")):
            zipFile = zipfile.ZipFile(filePath, "r")
            nameListing = zipFile.namelist()

            debugLogger.log(logging.DEBUG, zipFile)
            debugLogger.log(logging.DEBUG, nameListing)

            for nameEntry in (nameListing):
                debugLogger.log(logging.DEBUG, nameEntry)

                if (filePath.endswith(".ear")):
                    if (nameEntry.lower().find(("application.xml")) != -1):
                        debugLogger.log(logging.DEBUG, "Found application.xml")

                        appxml = zipFile.read(nameEntry)
                        startIndex = appxml.find(startPoint) + len(startPoint)
                        endIndex = appxml.find(endPoint)

                        debugLogger.log(logging.DEBUG, appxml)
                        debugLogger.log(logging.DEBUG, startIndex)
                        debugLogger.log(logging.DEBUG, endIndex)

                        appDisplayName = appxml[startIndex:endIndex]

                        debugLogger.log(logging.DEBUG, str(appDisplayName))
                    else:
                        errorLogger.log(logging.ERROR, str("No application.xml file was found in archive {0}.").format(filePath))

                        raise Exception(str("No application.xml file was found in archive {0}.").format(filePath))
                    #endif
                elif (filePath.endswith(".war")):
                    if (nameEntry.lower().find(("web.xml")) != -1):
                        debugLogger.log(logging.DEBUG, "Found web.xml")

                        webxml = zipFile.read(nameEntry)
                        startIndex = webxml.find(startPoint) + len(startPoint)
                        endIndex = webxml.find(endPoint)

                        debugLogger.log(logging.DEBUG, webxml)
                        debugLogger.log(logging.DEBUG, startIndex)
                        debugLogger.log(logging.DEBUG, endIndex)

                        appDisplayName = webxml[startIndex:endIndex]

                        debugLogger.log(logging.DEBUG, appDisplayName)
                    else:
                        errorLogger.log(logging.ERROR, str("No web.xml file was found in archive {0}.").format(filePath))

                        raise Exception(str("No web.xml file was found in archive {0}.").format(filePath))
                    #endif
                else:
                    errorLogger.log(logging.ERROR, str("Unsupported archive type: {0}.").format(filePath))

                    raise Exception(str("Unsupported archive type: {0}.").format(filePath))
                #endif
            #endfor
        else:
            errorLogger.log(logging.ERROR, str("Unsupported archive: {0}.").format(filePath))

            raise Exception(str("Unsupported archive: {0}.").format(filePath))
        #endif
    #endif

    debugLogger.log(logging.DEBUG, appDisplayName)
    debugLogger.log(logging.DEBUG, "EXIT: includes#getAppDisplayName(filePath)")

    return appDisplayName
#enddef

def getAppModuleName(filePath):
    debugLogger.log(logging.DEBUG, "ENTER: includes#getAppModuleName(filePath)")
    debugLogger.log(logging.DEBUG, filePath)

    if (os.path.exists(filePath)):
        startPoint = "<web-uri>"
        endPoint = "</web-uri>"

        debugLogger.log(logging.DEBUG, startPoint)
        debugLogger.log(logging.DEBUG, endPoint)

        if (filePath.endswith(".ear")):
            zipFile = zipfile.ZipFile(filePath, "r")
            nameListing = zipFile.namelist()

            debugLogger.log(logging.DEBUG, zipFile)
            debugLogger.log(logging.DEBUG, nameListing)

            for nameEntry in (nameListing):
                if (nameEntry.lower().find(("application.xml")) != -1):
                    debugLogger.log(logging.DEBUG, "Found application.xml")

                    appxml = zipFile.read(nameEntry)
                    startIndex = appxml.find(startPoint) + len(startPoint)
                    endIndex = appxml.find(endPoint)

                    debugLogger.log(logging.DEBUG, appxml)
                    debugLogger.log(logging.DEBUG, startIndex)
                    debugLogger.log(logging.DEBUG, endIndex)

                    appModuleName = appxml[startIndex:endIndex]

                    debugLogger.log(logging.DEBUG, appModuleName)
                else:
                    errorLogger.log(logging.ERROR, str("No application.xml file was found in archive {0}.").format(filePath))

                    raise Exception(str("No application.xml file was found in archive {0}.").format(filePath))
                #endif
            #endfor
        else:
            errorLogger.log(logging.ERROR, str("Unsupported archive: {0}.").format(filePath))

            raise Exception(str("Unsupported archive: {0}.").format(filePath))
        #endif
    #endif

    debugLogger.log(logging.DEBUG, appModuleName)
    debugLogger.log(logging.DEBUG, "EXIT: includes#getAppModuleName(filePath)")

    return appModuleName
#enddef

def getAppWarName(filePath):
    debugLogger.log(logging.DEBUG, "ENTER: includes#getAppWarName(filePath)")
    debugLogger.log(logging.DEBUG, filePath)

    if (os.path.exists(filePath)):
        startPoint = "<web-uri>"
        endPoint = "</web-uri>"

        debugLogger.log(logging.DEBUG, startPoint)
        debugLogger.log(logging.DEBUG, endPoint)

        if (filePath.endswith(".ear")):
            zipFile = zipfile.ZipFile(filePath, "r")
            nameListing = zipFile.namelist()

            debugLogger.log(logging.DEBUG, zipFile)
            debugLogger.log(logging.DEBUG, nameListing)

            for nameEntry in (nameListing):
                if (nameEntry.lower().endswith((".war"))):
                    debugLogger.log(logging.DEBUG, str("Found war file {0}").format(nameEntry))

                    appWarName = nameEntry.lower()

                    debugLogger.log(logging.DEBUG, str(appWarName))
                else:
                    errorLogger.log(logging.ERROR, str("No WAR files were found in archive {0}.").format(filePath))

                    raise Exception(str("No WAR files were found in archive {0}.").format(filePath))
                #endif
            #endfor
        else:
            errorLogger.log(logging.ERROR, str("Unsupported archive: {0}.").format(filePath))

            raise Exception(str("Unsupported archive: {0}.").format(filePath))
        #endif
    #endif

    debugLogger.log(logging.DEBUG, appWarName)
    debugLogger.log(logging.DEBUG, "EXIT: includes#getAppWarName(filePath)")

    return appWarName
#enddef

def getFileNameFromPath(filePath):
    debugLogger.log(logging.DEBUG, "ENTER: includes#getFileNameFromPath(appTargetMapping, status)")

    fileName = ""

    debugLogger.log(logging.DEBUG, fileName)

    if (not isinstance(filePath, str)):
        fileName = os.path.basename(filePath).split("/")[-1]
    else:
        errorLogger.log(logging.ERROR, str("Unsupported input type: {0}.").format(filePath))
        raise Exception(str("Unsupported input type: {0}.").format(filePath))
    #endif

    debugLogger.log(logging.DEBUG, fileName)
    debugLogger.log(logging.DEBUG, "EXIT: includes#getFileNameFromPath(appTargetMapping, status)")

    return fileName
#enddef

def hasExtraFileExtension(fileName, extension):
    debugLogger.log(logging.DEBUG, "ENTER: includes#hasExtraFileExtension(fileName, extension)")

    hasExtraFileExtension = bool(False)

    debugLogger.log(logging.DEBUG, hasExtraFileExtension)

    if (not isinstance(fileName, str)):
        hasExtraFileExtension = bool(fileName.endswith(str("{0}.{0}").format(extension, extension)))

        debugLogger.log(logging.DEBUG, hasExtraFileExtension)
    else:
        errorLogger.log(logging.ERROR, str("Unsupported input type: {0}.").format(fileName))
        raise Exception(str("Unsupported input type: {0}.").format(fileName))
    #endif

    debugLogger.log(logging.DEBUG, hasExtraFileExtension)
    debugLogger.log(logging.DEBUG, "EXIT: includes#hasExtraFileExtension(fileName, extension)")

    return hasExtraFileExtension
#enddef

def removeExtraExtension(fileName, removeNumber):
    debugLogger.log(logging.DEBUG, "ENTER: includes#removeExtraExtension(fileName, removeNumber)")

    responseString = ""

    debugLogger.log(logging.DEBUG, responseString)

    if ((not isinstance(fileName, str)) and (not isinstance(removeNumber, int))):
        errorLogger.log(logging.ERROR, str("Unsupported input types: {0} {1}.").format(fileName, removeNumber))
        raise Exception(str("Unsupported input type: {0} {1}.").format(fileName, removeNumber))
    else:
        if (removeNumber <= 0):
            errorLogger.log(logging.ERROR, str("Characters to remove cannot be equal to or less than 0: {0}.").format(removeNumber))
            raise Exception(str("Characters to remove cannot be equal to or less than 0: {0}.").format(removeNumber))
        else:
            if (hasExtraFileExtension(fileName)):
                responseString = fileName[:-removeNumber]
            #endif
        #endif
    #endif

    debugLogger.log(logging.DEBUG, responseString)
    debugLogger.log(logging.DEBUG, "EXIT: includes#removeExtraExtension(fileName, removeNumber)")

    return responseString
#enddef

