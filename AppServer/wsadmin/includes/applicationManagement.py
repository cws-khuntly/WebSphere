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

import sys
import logging

configureLogging(str("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties"))
errorLogger = logging.getLogger(str("error-logger"))
debugLogger = logging.getLogger(str("debug-logger"))
infoLogger = logging.getLogger(str("info-logger"))

def installApplicationModuleToCluster(appInstallOptions):
    debugLogger.log(logging.DEBUG, str("ENTER: applicationMaintenance#installApplicationModuleToCluster(appInstallOptions)"))
    debugLogger.log(logging.DEBUG, str(appInstallOptions))

    if (len(appInstallOptions) != 0):
        try:
            debugLogger.log(logging.DEBUG, str("Executing command AdminApp.install()..."))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminApp.install(appPath, str(appInstallOptions).strip(\"()\"))"))

            AdminApp.install(appPath, str(appInstallOptions).strip("()"))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred performing the application install: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred performing the application install: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        raise Exception(str("No application installation options were found. Cannot install application."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: applicationMaintenance#installApplicationModuleToCluster(appInstallOptions)"))
#enddef

def updateApplicationModuleToCluster(appName, appInstallOptions):
    debugLogger.log(logging.DEBUG, str("ENTER: applicationMaintenance#updateApplicationModuleToCluster(appName, appInstallOptions)"))
    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(appInstallOptions))

    if ((len(appName) != 0) and (len(appInstallOptions) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Executing command AdminApp.update()..."))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminApp.update(appName, \"app\" str(appInstallOptions).strip(\"()\"))"))

            AdminApp.update(appName, "app", str(appInstallOptions).strip("()"))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred performing the application update: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred performing the application update: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        raise Exception(str("No application installation options were found. Cannot install application."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: applicationMaintenance#updateApplicationModuleToCluster(appName, appInstallOptions)"))
#enddef

def installEJBApplicationModuleToCluster(appInstallOptions):
    debugLogger.log(logging.DEBUG, str("ENTER: applicationMaintenance#installEJBApplicationModuleToCluster(appInstallOptions)"))
    debugLogger.log(logging.DEBUG, str(appInstallOptions))

    if (len(appInstallOptions) != 0):
        try:
            debugLogger.log(logging.DEBUG, str("Executing command AdminApp.install()..."))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminApp.install(appPath, str(appInstallOptions).strip(\"()\"))"))

            AdminApp.install(appPath, str(appInstallOptions).strip("()"))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred performing the application install: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred performing the application install: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        raise Exception(str("No application installation options were found. Cannot install application."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: applicationMaintenance#installEJBApplicationModuleToCluster(appInstallOptions)"))
#enddef

def updateEJBApplicationModuleToCluster(appName, appInstallOptions):
    debugLogger.log(logging.DEBUG, str("ENTER: applicationMaintenance#updateEJBApplicationModuleToCluster(appInstallOptions)"))
    debugLogger.log(logging.DEBUG, str(appName))
    debugLogger.log(logging.DEBUG, str(appInstallOptions))

    if ((len(appName) != 0) and (len(appInstallOptions) != 0)):
        try:
            debugLogger.log(logging.DEBUG, str("Executing command AdminApp.update()..."))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminApp.update(appName, \"app\" str(appInstallOptions).strip(\"()\"))"))

            AdminApp.update(appName, "app", str(appInstallOptions).strip("()"))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred performing the application update: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred performing the application update: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        raise Exception(str("No application installation options were found. Cannot install application."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: applicationMaintenance#updateEJBApplicationModuleToCluster(appInstallOptions)"))
#enddef

def updateStartupWeightForApplication(appDeploymentObject, weight = 50):
    debugLogger.log(logging.DEBUG, str("ENTER: applicationMaintenance#modifyStartupWeightForApplication(appDeploymentObject, weight)"))
    debugLogger.log(logging.DEBUG, str(appDeploymentObject))
    debugLogger.log(logging.DEBUG, str(weight))

    if (len(appDeploymentObject) != 0):
        try:
            debugLogger.log(logging.DEBUG, str("Executing command AdminConfig.modify()..."))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(appDeploymentObject, [[\"startingWeight\", \"{0}\"]]).format(weight)"))

            AdminConfig.modify(appDeploymentObject, [["startingWeight", "{0}"]]).format(weight)
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred changing the start weight for application {0}: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred changing the start weight for application {0}: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        raise Exception(str("No application installation options were found. Cannot install application."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: applicationMaintenance#modifyStartupWeightForApplication(appDeploymentObject)"))
#enddef

def changeStartupTypeForApplication(appTargetMapping, status = "true"):
    debugLogger.log(logging.DEBUG, str("ENTER: applicationMaintenance#changeStartupTypeForApplication(appTargetMapping, status)"))
    debugLogger.log(logging.DEBUG, str(appTargetMapping))
    debugLogger.log(logging.DEBUG, str(status))

    if (len(appTargetMapping) != 0):
        try:
            debugLogger.log(logging.DEBUG, str("Executing command AdminConfig.modify()..."))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminConfig.modify(appTargetMapping, [[\"enable\", \"{0}\"]]).format(status)"))

            AdminConfig.modify(appTargetMapping, [["enable", "{0}"]]).format(status)
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred changing the start weight for application {0}: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred changing the start weight for application {0}: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        raise Exception(str("No application installation options were found. Cannot install application."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: applicationMaintenance#changeStartupTypeForApplication(appDeploymentObject)"))
#enddef

def removeInstalledApplication(appName):
    debugLogger.log(logging.DEBUG, str("ENTER: applicationMaintenance#removeInstalledApplication(appName)"))
    debugLogger.log(logging.DEBUG, str(appName))

    if (len(appName) != 0):
        try:
            debugLogger.log(logging.DEBUG, str("Executing command AdminApp.uninstall()..."))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminApp.uninstall(str(\"{0}\").format(appName))"))

            AdminApp.uninstall(str("{0}").format(appName))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred removing application {0}: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred removing application {0}: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        raise Exception(str("No application was provided to remove."))
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: applicationMaintenance#removeInstalledApplication(appName)"))
#enddef
