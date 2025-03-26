#==============================================================================
#
#          FILE:  serverManagement.py
#         USAGE:  Include file containing various wsadmin functions
#     ARGUMENTS:  N/A
#
#   DESCRIPTION:  Various useful wsadmin functions
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
import time
import logging

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")

targetCell = AdminControl.getCell()
lineSplit = java.lang.System.getProperty("line.separator")

def replaceDefaultCertificateForCell(targetNames, targetIPAddresses):
    debugLogger.log(logging.DEBUG, "ENTER: sslManagement#replaceDefaultCertificateForCell(targetNames, targetIPAddresses")
    debugLogger.log(logging.DEBUG, targetNames)
    debugLogger.log(logging.DEBUG, targetIPAddresses)

    if (len(targetNames) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminTask.genAndReplaceCertificates()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminTask.genAndReplaceCertificates(\
                str(\"[-keyStoreName CellDefaultKeyStore -certificateAlias default -extendedKeyUsage ServerAuth_Id,ClientAuth_Id -sanDNSName {0} -sanIPAddress {1} -keyStoreScope (cell):{2}]\").format(targetNames, targetIPAddresses, targetCell))")

            AdminTask.genAndReplaceCertificates(
                str("[-keyStoreName CellDefaultKeyStore -certificateAlias default -extendedKeyUsage ServerAuth_Id,ClientAuth_Id -sanDNSName {0} -sanIPAddress {1} -keyStoreScope (cell):{2}]").format(targetNames, targetIPAddresses, targetCell))

            debugLogger.log(logging.DEBUG, str("Certificate for cell {0} has been REPLACED.").format(targetCell))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred regenerating certificates for cell {0}: {1} {2}").format(targetCell, str(exception), str(parms)))

            raise Exception(str("An error occurred regenerating certificates for cell {0}: {1} {2}").format(targetCell, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No DNS names were provided.")

        raise Exception("No DNS names were provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: sslManagement#replaceDefaultCertificateForCell(targetNames, targetIPAddresses)")
#enddef


def replaceDefaultCertificateForNode(targetNode, targetNames, targetIPAddresses):
    debugLogger.log(logging.DEBUG, "ENTER: sslManagement#replaceDefaultCertificateForNode(targetNode, targetNames, targetIPAddresses")
    debugLogger.log(logging.DEBUG, targetNode)
    debugLogger.log(logging.DEBUG, targetNames)
    debugLogger.log(logging.DEBUG, targetIPAddresses)

    if ((len(targetNode) != 0) and (len(targetNames) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Calling AdminTask.genAndReplaceCertificates()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminTask.genAndReplaceCertificates(\
                str(\"[-keyStoreName NodeDefaultKeyStore -certificateAlias default -extendedKeyUsage ServerAuth_Id,ClientAuth_Id -sanDNSName {0} -sanIPAddress {1} -keyStoreScope (cell):{2}:(node):{3}]\").format(targetNames, targetIPAddresses, targetCell, targetNode))")

            AdminTask.genAndReplaceCertificates(
                str("[-keyStoreName NodeDefaultKeyStore -certificateAlias default -extendedKeyUsage ServerAuth_Id,ClientAuth_Id -sanDNSName {0} -sanIPAddress {1} -keyStoreScope (cell):{2}:(node):{3}]").format(targetNames, targetIPAddresses, targetCell, targetNode))

            debugLogger.log(logging.DEBUG, str("Certificate for node {0} in cell {1} has been REPLACED.").format(targetNode, targetCell))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred regenerating certificates for node {0}: {1} {2}").format(targetNode, str(exception), str(parms)))

            raise Exception(str("An error occurred regenerating certificates for node {0}: {1} {2}").format(targetNode, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No node was provided or no DNS names were provided.")

        raise Exception("No node was provided or no DNS names were provided.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: sslManagement#replaceDefaultCertificateForNode(targetNode, targetNames, targetIPAddresses)")
#enddef
