def createWebserver(servername, nodename, webPort, webInstallRoot, pluginInstallRoot,
                    configurationFile, webAppMapping, adminPort, adminUserID, adminPasswd):
    '''creates a Webserver using the specified parameters'''
    m = "createWebserver:"
    #sop(m,"Entry. ")
    creationString = '[-name %s -templateName IHS -serverConfig [-webPort %s -webInstallRoot %s -pluginInstallRoot %s -configurationFile %s -webAppMapping %s] -remoteServerConfig [-adminPort %s -adminUserID %s -adminPasswd %s]]' % (servername, webPort, webInstallRoot, pluginInstallRoot, configurationFile, webAppMapping, adminPort, adminUserID, adminPasswd)
    #sop(m,"creationString=%s " % creationString)
    AdminTask.createWebServer(nodename, creationString)
    #sop(m,"Exit. ")

def generatePluginCfg(servername, nodename):
    '''generates and propogates the webserver plugin for the specified webserver'''
    m = "generatePluginCfg:"
    #sop(m,"Entry. ")
    plgGen = AdminControl.queryNames('type=PluginCfgGenerator,*')
    #sop(m,"plgGen=%s " % plgGen)
    ihsnode = nodename
    nodename = getDmgrNodeName()
    configDir = os.path.join(getWasProfileRoot(nodename), 'config')
    if getNodePlatformOS(nodename) == 'windows':
        configDir = configDir.replace('/','\\')
    #sop(m,"configDir=%s " % configDir)
    AdminControl.invoke(plgGen, 'generate', '[%s %s %s %s true]' % (
                       configDir, getCellName(), ihsnode, servername),
                       '[java.lang.String java.lang.String java.lang.String java.lang.String java.lang.Boolean]')
    #sop(m,"Exit. ")

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