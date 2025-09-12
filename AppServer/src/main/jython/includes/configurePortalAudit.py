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

lineSplit = java.lang.System.getProperty("line.separator")

def setPortalAuditing(targetScope, isEnabled = "false"):
    debugLogger.log(logging.DEBUG, "ENTER: portalAudit#setPortalAuditing(targetScope, isEnabled = \"false\")")
    debugLogger.log(logging.DEBUG, targetScope)
    debugLogger.log(logging.DEBUG, isEnabled)

    resourceEnvironmentProviderName = "WP AuditService"

    debugLogger.log(logging.DEBUG, resourceEnvironmentProviderName)

    if ((len(isEnabled) != 0) and (isEnabled == "true")):
        currentEntries = AdminConfig.list("ResourceEnvironmentProvider", targetScope).split(lineSplit)

        debugLogger.log(logging.DEBUG, currentEntries)

        for entry in (currentEntries):
            debugLogger.log(logging.DEBUG, entry)

            entryName = AdminConfig.showAttribute(entry, "name")

            debugLogger.log(logging.DEBUG, entryName)

            if (entryName == resourceEnvironmentProviderName):
                try:
                    debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, str(\"[[name \"audit.service.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\").format(isEnabled))")

                    AdminConfig.create("J2EEResourceProperty", entry, str("[[name \"audit.service.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]").format(isEnabled))

                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.service.enable", isEnabled, resourceEnvironmentProviderName))

                    break
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating resource provider {0} in scope {1}: {2} {3}").format(resourceEnvironmentProviderName, targetScope, str(exception), str(parms)))

                    raise Exception(str("An error occurred updating resource provider {0} in scope {1}: {2} {3}").format(resourceEnvironmentProviderName, targetScope, str(exception), str(parms)))
                #endtry
            #endif
        #endfor
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: portalAudit#setPortalAuditing(targetScope, isEnabled = \"false\")")
#enddef

def configurePortalAuditing(targetScope, auditLogFileName = "${SERVER_LOG_ROOT}/audit.log"):
    debugLogger.log(logging.DEBUG, "ENTER: portalAudit#configurePortalAuditing(targetScope, auditLogFileName = \"${SERVER_LOG_ROOT}/audit.log\")")
    debugLogger.log(logging.DEBUG, targetScope)
    debugLogger.log(logging.DEBUG, auditLogFileName)

    resourceEnvironmentProviderName = "WP AuditService"

    debugLogger.log(logging.DEBUG, resourceEnvironmentProviderName)

    if ((len(targetScope) != 0) and (len(auditLogFileName) != 0)):
        currentEntries = AdminConfig.list("ResourceEnvironmentProvider", targetScope).split(lineSplit)

        debugLogger.log(logging.DEBUG, currentEntries)

        for entry in (currentEntries):
            debugLogger.log(logging.DEBUG, entry)

            entryName = AdminConfig.showAttribute(entry, "name")

            debugLogger.log(logging.DEBUG, entryName)

            if (entryName == resourceEnvironmentProviderName):
                try:
                    debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.logging.class\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, str(\"[[name \"audit.logFileName\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\").format(auditLogFileName)))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.showTransactionID.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.projects.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.groupEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.userEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.portletEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.roleEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.roleBlockEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.ownerEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.resourceEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.externalizationEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.userInGroupEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.webModuleEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.domainAdminDataEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.designerDeployServiceEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.impersonationEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.taggingEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.ratingEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.projectPublishEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.customevents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")
                    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", entry, \"[[name \"audit.vanityURLEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"{0}\"] [required \"false\"]]\"))")

                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.logging.class\"] [type \"java.lang.String\"] [description \"\"] [value \"com.ibm.wps.services.audit.logging.impl.AuditLoggingImpl\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, str("[[name \"audit.logFileName\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]").format(auditLogFileName))
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.showTransactionID.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.projects.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.groupEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.userEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.portletEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.roleEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.roleBlockEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.ownerEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.resourceEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.externalizationEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.userInGroupEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.webModuleEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.domainAdminDataEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.designerDeployServiceEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.impersonationEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.taggingEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.ratingEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.projectPublishEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.customevents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")
                    AdminConfig.create("J2EEResourceProperty", entry, "[[name \"audit.vanityURLEvents.enable\"] [type \"java.lang.String\"] [description \"\"] [value \"true\"] [required \"false\"]]")

                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.logging.class", "com.ibm.wps.services.audit.logging.impl.AuditLoggingImpl", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.logFileName", auditLogFileName, resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.showTransactionID.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.groupEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.userEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.portletEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.roleEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.roleBlockEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.ownerEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.resourceEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.externalizationEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.userInGroupEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.webModuleEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.domainAdminDataEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.designerDeployServiceEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.impersonationEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.taggingEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.ratingEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.projectPublishEvents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.customevents.enable", "true", resourceEnvironmentProviderName))
                    infoLogger.log(logging.INFO, str("Created resource provider custom property {0} with value {1} in resource provider {2}.").format("audit.vanityURLEvents.enable", "true", resourceEnvironmentProviderName))

                    break
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred updating resource provider {0} in scope {1}: {2} {3}").format(resourceEnvironmentProviderName, targetScope, str(exception), str(parms)))

                    raise Exception(str("An error occurred updating resource provider {0} in scope {1}: {2} {3}").format(resourceEnvironmentProviderName, targetScope, str(exception), str(parms)))
                #endtry
            #endif
        #endfor
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: portalAudit#configurePortalAuditing(targetScope, auditLogFileName = \"${SERVER_LOG_ROOT}/audit.log\")")
#enddef
