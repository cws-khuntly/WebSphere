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

configureLogging("/home/wasadm/workspace/WebSphere/AppServer/wsadmin/config/logging.properties")
errorLogger = logging.getLogger("error-logger")
debugLogger = logging.getLogger("debug-logger")
infoLogger = logging.getLogger("info-logger")

def installApplicationModuleToCluster(appPath, appOptions):
    debugLogger.log(logging.DEBUG, "ENTER: applicationMaintenance#installApplicationModuleToCluster(appOptions)")
    debugLogger.log(logging.DEBUG, appPath)
    debugLogger.log(logging.DEBUG, appOptions)

    if (len(appOptions) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Executing command AdminApp.install()..")
            debugLogger.log(logging.DEBUG, "EXEC: AdminApp.install(appPath, appOptions)")

            AdminApp.install(appPath, appOptions)
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred performing the application install: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred performing the application install: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No application installation options were found. Cannot install application.")

        raise Exception("No application installation options were found. Cannot install application.")
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: applicationMaintenance#installApplicationModuleToCluster(appOptions)"))
#enddef

def updateApplicationModuleToCluster(appName, appOptions):
    debugLogger.log(logging.DEBUG, "ENTER: applicationMaintenance#updateApplicationModuleToCluster(appName, appOptions)")
    debugLogger.log(logging.DEBUG, appName)
    debugLogger.log(logging.DEBUG, appOptions)

    if ((len(appName) != 0) and (len(appOptions) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Executing command AdminApp.update()..")
            debugLogger.log(logging.DEBUG, "EXEC: AdminApp.update(appName, \"app\" appOptions)")

            AdminApp.update(appName, "app", appOptions)
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred performing the application update: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred performing the application update: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No application installation options were found. Cannot install application.")

        raise Exception("No application installation options were found. Cannot install application.")
    #endif

    debugLogger.log(logging.DEBUG, str("EXIT: applicationMaintenance#updateApplicationModuleToCluster(appName, appInstallOptions)"))
#enddef

def installEJBApplicationModuleToCluster(appPath, appOptions):
    debugLogger.log(logging.DEBUG, "ENTER: applicationMaintenance#installEJBApplicationModuleToCluster(appOptions)")
    debugLogger.log(logging.DEBUG, appPath)
    debugLogger.log(logging.DEBUG, appOptions)

    if (len(appOptions) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Executing command AdminApp.install()..")
            debugLogger.log(logging.DEBUG, "EXEC: AdminApp.install(appPath, appOptions)")

            AdminApp.install(appPath, appOptions)
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred performing the application install: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred performing the application install: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No application installation options were found. Cannot install application.")

        raise Exception("No application installation options were found. Cannot install application.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: applicationMaintenance#installEJBApplicationModuleToCluster(appOptions)")
#enddef

def updateEJBApplicationModuleToCluster(appName, appOptions):
    debugLogger.log(logging.DEBUG, "ENTER: applicationMaintenance#updateEJBApplicationModuleToCluster(appOptions)")
    debugLogger.log(logging.DEBUG, appName)
    debugLogger.log(logging.DEBUG, appOptions)

    if ((len(appName) != 0) and (len(appOptions) != 0)):
        try:
            debugLogger.log(logging.DEBUG, "Executing command AdminApp.update()...")
            debugLogger.log(logging.DEBUG, "EXEC: AdminApp.update(appName, \"app\", appInstallOptions)")

            AdminApp.update(appName, "app", appOptions)
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred performing the application update: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred performing the application update: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No application installation options were found. Cannot update application.")

        raise Exception("No application installation options were found. Cannot update application.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: applicationMaintenance#updateEJBApplicationModuleToCluster(appOptions)")
#enddef

def updateStartupWeightForApplication(appDeploymentObject, weight = 50):
    debugLogger.log(logging.DEBUG, "ENTER: applicationMaintenance#modifyStartupWeightForApplication(appDeploymentObject, weight)")
    debugLogger.log(logging.DEBUG, appDeploymentObject)
    debugLogger.log(logging.DEBUG, weight)

    if (len(appDeploymentObject) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Executing command AdminConfig.modify()...")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(appDeploymentObject, str(\"[[\"startingWeight\", \"{0}\"]]\").format(weight))")

            AdminConfig.modify(appDeploymentObject, str("[[\"startingWeight\", \"{0}\"]]").format(weight))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred changing the start weight for application {0}: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred changing the start weight for application {0}: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No application deployment was provided to modify.")

        raise Exception("No application deployment was provided to modify.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: applicationMaintenance#modifyStartupWeightForApplication(appDeploymentObject)")
#enddef

def changeStartupTypeForApplication(appTargetMapping, status = "true"):
    debugLogger.log(logging.DEBUG, "ENTER: applicationMaintenance#changeStartupTypeForApplication(appTargetMapping, status)")
    debugLogger.log(logging.DEBUG, appTargetMapping)
    debugLogger.log(logging.DEBUG, status)

    if (len(appTargetMapping) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Executing command AdminConfig.modify()...")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.modify(appTargetMapping, str(\"[[\"enable\", \"{0}\"]]\").format(status))")

            AdminConfig.modify(appTargetMapping, str("[[\"enable\", \"{0}\"]]").format(status))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred changing the start weight for application {0}: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred changing the start weight for application {0}: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        raise Exception("No application installation options were found. Cannot install application.")
    #endif

    debugLogger.log(logging.DEBUG,"EXIT: applicationMaintenance#changeStartupTypeForApplication(appDeploymentObject)")
#enddef

def removeInstalledApplication(appName):
    debugLogger.log(logging.DEBUG, "ENTER: applicationMaintenance#removeInstalledApplication(appName)")
    debugLogger.log(logging.DEBUG, appName)

    if (len(appName) != 0):
        try:
            debugLogger.log(logging.DEBUG, "Executing command AdminApp.uninstall()...")
            debugLogger.log(logging.DEBUG, "EXEC: AdminApp.uninstall(str(\"{0}\").format(appName))")

            AdminApp.uninstall(appName)
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred removing application {0}: {1} {2}.").format(str(exception), str(parms)))
            raise Exception(str("An error occurred removing application {0}: {1} {2}.").format(str(exception), str(parms)))
        #endtry
    else:
        raise Exception("No application was provided to remove.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: applicationMaintenance#removeInstalledApplication(appName)")
#enddef
