def createWebserver(serverName, nodeName, templateName = "IHS", webPort = 8080, webInstallRoot = "/opt/IBM/HTTPServer", pluginInstallRoot = "/opt/IBM/WebSphere/Plugins",
                    mapApplications = "ALL", adminPort = 8008, adminUserID = "ihsadm", adminPasswd = ""):
    debugLogger.log(logging.DEBUG, str(serverName))
    debugLogger.log(logging.DEBUG, str(nodeName))
    debugLogger.log(logging.DEBUG, str(templateName))
    debugLogger.log(logging.DEBUG, str(webPort))
    debugLogger.log(logging.DEBUG, str(webInstallRoot))
    debugLogger.log(logging.DEBUG, str(pluginInstallRoot))
    debugLogger.log(logging.DEBUG, str(mapApplications))
    debugLogger.log(logging.DEBUG, str(adminPort))
    debugLogger.log(logging.DEBUG, str(adminUserID))
    debugLogger.log(logging.DEBUG, str(adminPasswd))
    
    if (len(configFile) != 0):
        webserverNodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name")) or nodeName
        webserverName = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-server-name")) or serverName
        webserverTemplateName = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-template-name")) or templateName
        webserverListenPort = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-listen-port")) or webPort
        webserverInstallRoot = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-install-root")) or webInstallRoot
        webserverPluginRoot = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-plugin-root")) or pluginInstallRoot
        webserverMapApplications = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-map-applications")) or mapApplications
        webserverAdminPort = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-admin-port")) or adminPort
        webserverAdminUser = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-admin-user")) or adminUserID
        webserverAdminPass = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-admin-password")) or adminPasswd

        debugLogger.log(logging.DEBUG, str(webserverName))
        debugLogger.log(logging.DEBUG, str(webserverNodeName))
        debugLogger.log(logging.DEBUG, str(webserverTemplateName))
        debugLogger.log(logging.DEBUG, str(webserverListenPort))
        debugLogger.log(logging.DEBUG, str(webserverInstallRoot))
        debugLogger.log(logging.DEBUG, str(webserverPluginRoot))
        debugLogger.log(logging.DEBUG, str(webserverMapApplications))
        debugLogger.log(logging.DEBUG, str(webserverAdminPort))
        debugLogger.log(logging.DEBUG, str(webserverAdminUser))
        debugLogger.log(logging.DEBUG, str(webserverName))

        try:
            debugLogger.log(logging.DEBUG, str("Calling AdminTask.createWebServer()"))
            debugLogger.log(logging.DEBUG, str("EXEC: AdminTask.createWebServer(str(\"{0}", "[-name {1} -templateName {2}} \
                                        -serverConfig [-webPort {3}] -serviceName -webInstallRoot {4} \
                                        -webProtocol HTTP -configurationFile -errorLogfile -accessLogfile \
                                        -pluginInstallRoot {5} -webMapping {6}] -remoteServerConfig \
                                        [-adminPort {7} -adminUserID {8} -adminPasswd {9} HTTP]\").format(webserverNodeName, webserverName, webserverTemplateName, \
                                                                                        webserverListenPort, webserverInstallRoot, webserverPluginRoot, \
                                                                                            webserverMapApplications, webserverAdminPort, webserverAdminUser, webserverAdminPass))"))

            AdminTask.createWebServer(str("{0}", "[-name {1} -templateName {2}} \
                                        -serverConfig [-webPort {3}] -serviceName -webInstallRoot {4} \
                                        -webProtocol HTTP -configurationFile -errorLogfile -accessLogfile \
                                        -pluginInstallRoot {5} -webMapping {6}] -remoteServerConfig \
                                        [-adminPort {7} -adminUserID {8} -adminPasswd {9} HTTP]").format(webserverNodeName, webserverName, webserverTemplateName, \
                                                                                        webserverListenPort, webserverInstallRoot, webserverPluginRoot, \
                                                                                            webserverMapApplications, webserverAdminPort, webserverAdminUser, webserverAdminPass))
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred creating webserver {0} on node {1}: {2} {3}").format(webserverName, webserverNodeName, str(exception), str(parms)))
            consoleErrorLogger.log(logging.ERROR, str("An error occurred creating webserver {0} on node {1}. Please review logs.").format(webserverName, webserverNodeName))
        finally:
            debugLogger.log(logging.DEBUG, str("Saving workspace changes and synchronizing the cell.."))

            saveWorkspaceChanges()
            syncAllNodes(nodeList, targetCell)

            infoLogger.log(logging.INFO, str("Workspace changes have been saved and the cell has been synchronized."))
            consoleInfoLogger.log(logging.INFO, str("Workspace changes have been saved and the cell has been synchronized."))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif
#enddef

def generatePluginConfig(nodeName, configurationDirectory = "/opt/IBM/WebSphere/config"):
    debugLogger.log(logging.DEBUG, str(nodeName))
    debugLogger.log(logging.DEBUG, str(configurationDirectory))

    if (len(configFile) != 0):
        dmgrNodeName = returnPropertyConfiguration(configFile, str("server-information"), str("node-name")) or nodeName
        configDirectory = returnPropertyConfiguration(configFile, str("server-information"), str("user-install-root")) or str(os.path.join(getWebSphereVariable("USER_INSTALL_ROOT", dmgrNodeName)))
        webserverNodeName = returnPropertyConfiguration(configFile, str("web-server-information"), str("web-node-name")) or nodeName
        pluginGenerator = AdminControl.queryNames("type=PluginCfgGenerator,*")
        platformOS = AdminTask.getNodePlatformOS(str("[-nodeName {0}]").format(nodeName))

        debugLogger.log(logging.DEBUG, str(dmgrNodeName))
        debugLogger.log(logging.DEBUG, str(configDirectory))
        debugLogger.log(logging.DEBUG, str(webserverNodeName))
        debugLogger.log(logging.DEBUG, str(pluginGenerator))
        debugLogger.log(logging.DEBUG, str(platformOS))

        if (platformOS == "windows"):
            configDirectory = configDirectory.replace('/','\\')
        #endif

        debugLogger.log(logging.DEBUG, str(configDirectory))

        try:
            AdminControl.invoke(pluginGenerator, "generate", \
                                str("[{0} {1} {2} {3} true]").format(configDirectory, getCellName(), webserverNodeName, servername)), \
                                    str("[java.lang.String java.lang.String java.lang.String java.lang.String java.lang.Boolean]")
        except:
            (exception, parms, tback) = sys.exc_info()

            errorLogger.log(logging.ERROR, str("An error occurred generating the plugin for {0} on node {1}: {2} {3}").format(webserverNodeName, dmgrNodeName, str(exception), str(parms)))
            consoleErrorLogger.log(logging.ERROR, str("An error occurred generating the plugin for {0} on node {1}. Please review logs.").format(webserverNodeName, dmgrNodeName))
        finally:
            debugLogger.log(logging.DEBUG, str("Saving workspace changes and synchronizing the cell.."))

            saveWorkspaceChanges()
            syncAllNodes(nodeList, targetCell)

            infoLogger.log(logging.INFO, str("Workspace changes have been saved and the cell has been synchronized."))
            consoleInfoLogger.log(logging.INFO, str("Workspace changes have been saved and the cell has been synchronized."))
        #endtry
    else:
        errorLogger.log(logging.ERROR, str("No configuration file was provided."))
        consoleErrorLogger.log(logging.ERROR, str("No configuration file was provided."))
    #endif
#enddef

def setServerIOTimeout(servername, nodename, timeout):
    '''sets the ServerIOTimeout property for the specified appserver'''
    m = "setServerIOTimeout:"
    #sop(m,"Entry. ")
    appserver = getServerByNodeAndName(nodename, servername)
    #sop(m,"webserver=%s " % webserver)
    plgProps = AdminConfig.list('WebserverPluginSettings', appserver)
    #sop(m,"plgProps=%s " % plgProps)
    AdminConfig.modify(plgProps, [['ServerIOTimeout', timeout ]])
    #sop(m,"Exit. ")

def setConnectTimeout(servername, nodename, timeout):
    '''sets the ConnectTimeout property for the specified appserver'''
    m = "setConnectTimeout:"
    #sop(m,"Entry. ")
    appserver = getServerByNodeAndName(nodename, servername)
    #sop(m,"webserver=%s " % webserver)
    plgProps = AdminConfig.list('WebserverPluginSettings', appserver)
    #sop(m,"plgProps=%s " % plgProps)
    AdminConfig.modify(plgProps, [['ConnectTimeout', timeout ]])
    #sop(m,"Exit. ")

def setRetryInterval(servername, nodename, retryInterval):
    '''sets the RetryInterval property for the cluster of the specified appserver'''
    m = "setRetryInterval:"
    #sop(m,"Entry. ")
    webserver = getServerByNodeAndName(nodename, servername)
    #sop(m,"webserver=%s " % webserver)
    plgClusterProps = AdminConfig.list('PluginServerClusterProperties', webserver)
    #sop(m,"plgProps=%s " % plgProps)
    AdminConfig.modify(plgClusterProps, [['RetryInterval', retryInterval ]])
    #sop(m,"Exit. ")

def setRefreshInterval(servername, nodename, interval):
    '''sets the RefreshInterval property for the webserver plugin'''
    m = "setRefreshInterval:"
    #sop(m,"Entry. ")
    webserver = getServerByNodeAndName(nodename, servername)
    #sop(m,"webserver=%s " % webserver)
    plgProps = AdminConfig.list('PluginProperties', webserver)
    AdminConfig.modify(plgProps, [['RefreshInterval', interval]])
    #sop(m,"plgProps=%s " % plgProps)
    #sop(m,"Exit. ")