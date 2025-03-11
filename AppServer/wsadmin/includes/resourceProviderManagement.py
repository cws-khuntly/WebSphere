#==============================================================================
#
#          FILE:  objectCacheManagement.py
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

def createResourceProvider(providerName, targetScope):
    debugLogger.log(logging.DEBUG, "ENTER: resourceProviderMaintenance#createResourceProvider(providerName, targetScope)")
    debugLogger.log(logging.DEBUG, providerName)
    debugLogger.log(logging.DEBUG, targetScope)

    if (len(targetScope) != 0):
        currentEntries = AdminConfig.list("ResourceEnvironmentProvider", targetScope).split(lineSplit)

        debugLogger.log(logging.DEBUG, currentEntries)

        for entry in (currentEntries):
            debugLogger.log(logging.DEBUG, entry)

            entryName = AdminConfig.showAttribute(entry, "name")

            debugLogger.log(logging.DEBUG, entryName)

            if (entryName == providerName):
                errorLogger.log(logging.ERROR, str("Resource environment provider {0} already exists in scope {1}.").format(providerName, targetScope))

                raise Exception(str("Resource environment provider {0} already exists in scope {1}.").format(providerName, targetScope))
            #endif

            continue
        #endfor

        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"ResourceEnvironmentProvider\", targetScope " +
                    str("[[classpath \"\"] [name \"{0}\"] [isolatedClassLoader \"false\"] [nativepath \"\"] [description \"\"]]\").format(providerName))"))

            AdminConfig.create("ResourceEnvironmentProvider", targetScope,
                               str("[[classpath \"\"] [name \"{0}\"] [isolatedClassLoader \"false\"] [nativepath \"\"] [description \"\"]]").format(providerName))

            infoLogger.log(logging.INFO, str("Created resource provider {0} in scope {1}.").format(providerName, targetScope))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred creating resource provider {0} in scope {1}: {2} {3}").format(providerName, targetScope, str(exception), str(parms)))

            raise Exception(str("An error occurred creating resource provider {0} in scope {1}: {2} {3}").format(providerName, targetScope, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No scope was provided to add the resource provider to.")

        raise Exception("No scope was provided to add the resource provider to.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: resourceProviderMaintenance#createResourceProvider(providerName, targetScope)")
#enddef

def createResourceProviderFactory(providerEntry, factoryClassName, implementationClassName):
    debugLogger.log(logging.DEBUG, "ENTER: resourceProviderMaintenance#createResourceProviderFactory(providerEntry, factoryClassName, implementationClassName)")
    debugLogger.log(logging.DEBUG, providerEntry)
    debugLogger.log(logging.DEBUG, factoryClassName)
    debugLogger.log(logging.DEBUG, implementationClassName)

    if (len(providerEntry) != 0):
        debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.list(\"Referenceable\", providerEntry).split(lineSplit)")

        currentEntries = AdminConfig.list("Referenceable", providerEntry).split(lineSplit)

        debugLogger.log(logging.DEBUG, currentEntries)

        for entry in (currentEntries):
            debugLogger.log(logging.DEBUG, entry)
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.showAttribute()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.showAttribute(entry, \"factoryClassname\")")

            entryName = AdminConfig.showAttribute(entry, "factoryClassname")

            debugLogger.log(logging.DEBUG, entryName)

            if (entryName == factoryClassName):
                errorLogger.log(logging.ERROR, str("Resource environment factory {0} already exists in resource provider {1}.").format(factoryClassName, providerEntry))

                raise Exception(str("Resource environment factory {0} already exists in resource provider {1}.").format(factoryClassName, providerEntry))
            #endif

            continue
        #endfor

        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"Referenceable\", providerEntry, str(\"[[factoryClassname \"{0}\"] [classname \"{1}\"]]\").format(factoryClassName, implementationClassName)")

            AdminConfig.create("Referenceable", providerEntry, str("[[factoryClassname \"{0}\"] [classname \"{1}\"]]").format(factoryClassName, implementationClassName))

            infoLogger.log(logging.INFO, str("Created resource provider referenceable {0} in scope {1}.").format(factoryClassName, providerEntry))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred creating resource provider referenceable {0} in provider {1}: {2} {3}").format(factoryClassName, providerEntry, str(exception), str(parms)))

            raise Exception(str("An error occurred creating resource provider referenceable {0} in provider {1}: {2} {3}").format(factoryClassName, providerEntry, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No resource provider was provided to add the referenceable to.")

        raise Exception("No resource provider was provided to add the referenceable to.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: resourceProviderMaintenance#createResourceProviderFactory(providerEntry, factoryClassName, implementationClassName)")
#enddef

def createResourceProviderEnvironmentEntry(providerEntry, providerReferenceable, entryDisplayName, entryJNDIName):
    debugLogger.log(logging.DEBUG, "ENTER: resourceProviderMaintenance#createResourceProviderEnvironmentEntry(providerEntry, providerReferenceable, entryDisplayName, entryJNDIName)")
    debugLogger.log(logging.DEBUG, providerEntry)
    debugLogger.log(logging.DEBUG, providerReferenceable)
    debugLogger.log(logging.DEBUG, entryDisplayName)
    debugLogger.log(logging.DEBUG, entryJNDIName)

    if (len(providerEntry) != 0):
        debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.list(\"ResourceEnvEntry\", providerEntry).split(lineSplit)")

        currentEntries = AdminConfig.list("ResourceEnvEntry", providerEntry).split(lineSplit)

        debugLogger.log(logging.DEBUG, currentEntries)

        for entry in (currentEntries):
            debugLogger.log(logging.DEBUG, entry)
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.showAttribute()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.showAttribute(entry, \"name\")")

            entryName = AdminConfig.showAttribute(entry, "name")

            debugLogger.log(logging.DEBUG, entryName)

            if (entryName == entryDisplayName):
                errorLogger.log(logging.ERROR, str("Resource environment entry {0} already exists in resource provider {1}.").format(entryDisplayName, providerEntry))

                raise Exception(str("Resource environment factory {0} already exists in resource provider {1}.").format(entryDisplayName, providerEntry))
            #endif

            continue
        #endfor

        try:
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"ResourceEnvEntry\", providerEntry, " +
                "str([[referenceable \"{0}\"] [name \"{1}\"] [description \"\"] [category \"\"] [jndiName \"{2}\"]]'.format(providerReferenceable, entryDisplayName, entryJNDIName))")

            AdminConfig.create("ResourceEnvEntry", providerEntry,
                               str("[[referenceable \"{0}\"] [name \"{1}\"] [description \"\"] [category \"\"] [jndiName \"{2}\"]]").format(providerReferenceable, entryDisplayName, entryJNDIName))

            infoLogger.log(logging.INFO, str("Created resource provider environment entry {0} in provider {1}.").format(entryDisplayName, providerEntry))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred creating environment entry {0} in provider {1}: {2} {3}").format(entryDisplayName, providerEntry, str(exception), str(parms)))

            raise Exception(str("An error occurred creating environment entry {0} in provider {1}: {2} {3}").format(entryDisplayName, providerEntry, str(exception), str(parms)))
        #endtry
    else:
        errorLogger.log(logging.ERROR, "No resource provider was provided to add the referenceable to.")

        raise Exception("No resource provider was provided to add the referenceable to.")
    #endif

    debugLogger.log(logging.DEBUG, "EXIT: resourceProviderMaintenance#createResourceProviderEnvironmentEntry(providerEntry, providerReferenceable, entryDisplayName, entryJNDIName)")
#enddef

def createResourceProviderEnvironmentEntryProperty(targetProvider, targetResourceEnvironmentEntry, targetPropertyName, targetPropertyValue):
    debugLogger.log(logging.DEBUG, "ENTER: resourceProviderMaintenance#createResourceProviderEnvironmentEntryProperty(targetProvider, targetResourceEnvironmentEntry, targetPropertyName, targetPropertyValue)")
    debugLogger.log(logging.DEBUG, targetProvider)
    debugLogger.log(logging.DEBUG, targetResourceEnvironmentEntry)
    debugLogger.log(logging.DEBUG, targetPropertyName)
    debugLogger.log(logging.DEBUG, targetPropertyValue)

    if (len(targetProvider) != 0):
        debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
        debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.list(str(\"ResourceEnvEntry\"), targetProvider).split(lineSplit)")

        providerResourceEnvironmentEntries = AdminConfig.list("ResourceEnvEntry", targetProvider).split(lineSplit)

        debugLogger.log(logging.DEBUG, providerResourceEnvironmentEntries)

        for resourceEnvironmentEntry in (providerResourceEnvironmentEntries):
            debugLogger.log(logging.DEBUG, resourceEnvironmentEntry)
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.showAttribute()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.list(resourceEnvironmentEntry, str(\"name\")).split(lineSplit)")

            resourceEnvironmentEntryName = AdminConfig.list(resourceEnvironmentEntry, "name").split(lineSplit)

            debugLogger.log(logging.DEBUG, resourceEnvironmentEntryName)

            if (resourceEnvironmentEntryName == targetResourceEnvironmentEntry):
                debugLogger.log(logging.DEBUG, str("Found Resource Environment Entry {0}. Setting foundEntry to {1}.").format(targetResourceEnvironmentEntry, str("{0}").format(True)))

                foundEntry = True

                break
            #endif

            continue
        #endfor

        if (foundEntry):
            debugLogger.log(logging.DEBUG, "Calling AdminConfig.showAttribute()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.showAttribute(resourceEnvironmentEntry, \"propertySet\").split(lineSplit)")

            currentPropertySet = AdminConfig.showAttribute(resourceEnvironmentEntry, "propertySet").split(lineSplit)

            debugLogger.log(logging.DEBUG, currentPropertySet)

            if (currentPropertySet == "None"):
                debugLogger.log(logging.DEBUG, str("No property sets were found in Resource Environment Entry {0}. Creating.").format(resourceEnvironmentEntry))
                debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
                debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourcePropertySet\", str(\"{0}\").format(resourceEnvironmentEntry), [])")

                try:
                    currentPropertySet = AdminConfig.create("J2EEResourcePropertySet", resourceEnvironmentEntry, [])

                    debugLogger.log(logging.DEBUG, str("Created Resource Property Set {0} in ResourceEnvironmentEntry {1}").format(currentPropertySet, resourceEnvironmentEntry))
                except:
                    (exception, parms, tback) = sys.exc_info()

                    errorLogger.log(logging.ERROR, str("An error occurred creating a new resource property set in Resource Environment Entry {0}: {1} {2}").format(resourceEnvironmentEntry, str(exception), str(parms)))

                    raise Exception(str("An error occurred creating a new resource property set in Resource Environment Entry {0}: {2} {3}").format(resourceEnvironmentEntry, str(exception), str(parms)))
                #endtry
            #endif

            debugLogger.log(logging.DEBUG, "Calling AdminConfig.list()")
            debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.list(\"J2EEResourceProperty\", resourceEnvironmentEntry).split(lineSplit)")

            resourceProperties = AdminConfig.list("J2EEResourceProperty", resourceEnvironmentEntry).split(lineSplit)

            debugLogger.log(logging.DEBUG, resourceProperties)

            if (len(resourceProperties) != 0):
                for resourceProperty in (resourceProperties):
                    debugLogger.log(logging.DEBUG, resourceProperty)

                    if (len(resourceProperty) != 0):
                        propertyName = AdminConfig.showAttribute(resourceProperty, "name")

                        debugLogger.log(logging.DEBUG, propertyName)

                        if (propertyName == targetPropertyName):
                            errorLogger.log(logging.ERROR, str("The property {0} already exists in Resource Environment Entry {1}.").format(targetPropertyName, resourceEnvironmentEntry))

                            raise Exception(str("The property {0} already exists in Resource Environment Entry {1}.").format(targetPropertyName, resourceEnvironmentEntry))
                        #endif
                    #endif
                #endfor
            #endif
        else:
            errorLogger.log(logging.ERROR, str("The resource environment entry {0} does not exist within Resource Provider {1}.").format(targetResourceEnvironmentEntry, targetProvider))

            raise Exception(str("The resource environment entry {0} does not exist within Resource Provider {1}.").format(targetResourceEnvironmentEntry, targetProvider))
        #endif
    else:
        errorLogger.log(logging.ERROR, "No resource provider was provided to add the resource environment property to.")

        raise Exception("No resource provider was provided to add the resource environment property to.")
    #endif

    debugLogger.log(logging.DEBUG, "Calling AdminConfig.create()")
    debugLogger.log(logging.DEBUG, "EXEC: AdminConfig.create(\"J2EEResourceProperty\", currentPropertySet, " +
        "str(\"[[name \"{0}\"] [type \"java.lang.String\"] [description \"\"] [value \"{1}\"] [required \"false\"]]\").format(targetPropertyName, targetPropertyValue))")

    try:
        AdminConfig.create("J2EEResourceProperty", currentPropertySet,
            str("[[name \"{0}\"] [type \"java.lang.String\"] [description \"\"] [value \"{1}\"] [required \"false\"]]").format(targetPropertyName, targetPropertyValue))
    except:
        (exception, parms, tback) = sys.exc_info()

        errorLogger.log(logging.ERROR, str("An error occurred creating a new resource property {0} in property set {1}, Resource Environment Entry {2}: {3} {4}").format(targetPropertyName, currentPropertySet, resourceEnvironmentEntry, str(exception), str(parms)))

        raise Exception(str("An error occurred creating a new resource property {0} in property set {1}, Resource Environment Entry {2}: {3} {4}").format(targetPropertyName, currentPropertySet, resourceEnvironmentEntry, str(exception), str(parms)))
    #endtry

    debugLogger.log(logging.DEBUG, "EXIT: resourceProviderMaintenance#createResourceProviderEnvironmentEntryProperty(targetProvider, targetResourceEnvironmentEntry, targetPropertyName, targetPropertyValue)")
#enddef