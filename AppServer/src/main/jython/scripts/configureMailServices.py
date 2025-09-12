def createMailProvider ( scope, nodeName, serverName, clusterName, providerName, providerDesc):
    """Creates a mail provider resource in set scope
    Should return error 99 if creation fails, otherwise if provider already exists, no error
    Returns the provider object it just created or already found
    """

    global AdminConfig

    m = "createMailProvider:"
    sop(m, "Create Mail Provider "+providerName+", if it does not exist")

    # Check if mail provider already exists
    provider = getCfgItemId (scope, clusterName, nodeName, serverName, 'MailProvider', providerName)

    if (provider != ''):
        sop (m, "Provider "+providerName+" already exists!!")
        return provider
    #endif

    parentId = getScopeId (scope, serverName, nodeName, clusterName)

    attrs = []
    attrs.append(["name", providerName])
    attrs.append(["description", providerDesc])

    provider = AdminConfig.create("MailProvider", parentId, attrs )

    if provider == '':
        sop (m, "Caught Exception creating Mail Provider "+provider)
        return 99

    sop (m, "Created "+providerName+" successfully.") 
    return provider

#endDef

def createMailSession( scope, nodeName, serverName, clusterName, provName, name, jndiName, desc, category, mailTransHost, mailTransProto, mailTransUserId, mailTransPasswd, enableParse, mailFrom, mailStoreHost, mailStoreProto, mailStoreUserId, mailStorePasswd, enableDebug ):
    """ 
    
    This function creates a JavaMail MailSession under the specified Provider Name. 

        Input parameters:

        scope               - The scope of the MailProvider. Valid values are (in order of preecendence): 'cell', 'node', 'cluster' and 'server'.
                              Note: The scope of 'cell' is not valid for the createMailSession function. 
        nodeName            - The name of the node of the MailProvider. Required if scope = 'node' or 'server'.
        serverName          - The name of the server of the MailProvider. Required if scope = 'server'.
        clusterName         - The name of the cluster of the MailProvider. Required if scope = 'cluster'.
        provName            - The name of the MailProvider. Typical value: "Built-in Mail Provider".
        name                - The required display name of the MailSession to be created.
        jndiName            - The required JNDI of the MailSession to be created. 
        desc                - An optional description of this MailSession.
        category            - An optional category string to use when classifying or grouping the MailSession to be created. 
        mailTransHost       - Specifies the server to connect to when sending mail.
        mailTransProto      - Specifies the transport protocol to use when sending mail. Actual protocol values are defined in the protocol
                              providers that you configured for the current mail provider.
                              Typical Value: "builtin_smtp".
        mailTransUserId     - Specifies the user id to use when the mail transport host requires authentication.
        mailTransPasswd     - Specifies the password to use when the mail transport host requires authentication.
        enableParse         - Enable strict internet address parsing. Set to "true" to enforce the RFC 822 syntax rules for parsing Internet addresses when sending mail.
                              Valid values: "true" or "false". 
        mailFrom            - Specifies the Internet e-mail address that is displayed in messages as the mail originator. Typical value: "".
        mailStoreHost       - Specifies the mail account host, or domain name. Typical value: "".
        mailStoreProto      - Specifies the protocol to use when receiving mail. Actual protocol values are defined in the protocol providers
                              that you configured for the current mail provider.
                              Typical Value: "builtin_pop3" or "builtin_imap".
        mailStoreUserId     - Specifies the user ID of the mail account. Typical value: "".
        mailStorePasswd     - Specifies the password of the mail account. Typical value: "".
        enableDebug         - Enable debug information which shows interaction between the mail application and the mail servers,
                              as well as the properties of this mail session. to be sent to the SystemOut.log file. 
                              Valid values: "true" or "false". 

        Return Value:
            The newly created MailSession.  If an error occurs, an exception will be thrown.
    """

    m = "createMailSession:"
    sop(m, "Create Mail Session " + name + ", if it does not exist.")

    haveTransportProtocol = False
    haveStoreProtocol = False

    mailProvider = getCfgItemId(scope, clusterName, nodeName, serverName, 'MailProvider', provName)
    sop(m, "MailProvider = " + repr(mailProvider))

    # Check if mail provider exists
    if (mailProvider == ''):
        sop (m, "Provider doesn't exist!!")
        return None
    #endif

    protocolProviders = getObjectsOfType('ProtocolProvider', mailProvider)
    sop(m, "ProtocolProviders = " + repr(protocolProviders))

    # Iterate through the list (horrible way to do it, but...) looking for matching mail transport and store protocols.
    for protocolProvider in protocolProviders:
        sop(m, "Iterating through protocolProviders. protocolProvider = " + repr(protocolProvider))
        if -1 != protocolProvider.find(mailTransProto):
            sop(m, "Matched Transport Provider: " + repr(mailTransProto) + " with " + repr(protocolProvider))
            haveTransportProtocol = True
            mailTransportProtocol = protocolProvider
        if -1 != protocolProvider.find(mailStoreProto):
            sop(m, "Matched Store Provider: " + repr(mailStoreProto) + " with " + repr(protocolProvider))
            haveStoreProtocol = True
            mailStoreProtocol = protocolProvider

    # Now build the attribute list.
    attrs = []
    attrs.append(["name", name])
    attrs.append(["jndiName", jndiName])
    attrs.append(["description", desc])
    attrs.append(["category", category])
    attrs.append(["mailTransportHost", mailTransHost])
    if haveTransportProtocol:
        attrs.append(["mailTransportProtocol", mailTransportProtocol])
    attrs.append(["mailTransportUser", mailTransUserId])
    attrs.append(["mailTransportPassword", mailTransPasswd])
    attrs.append(["strict", enableParse])
    attrs.append(["mailFrom", mailFrom])
    attrs.append(["mailStoreHost", mailStoreHost])
    if haveStoreProtocol:
        attrs.append(["mailStoreProtocol", mailStoreProtocol])
    attrs.append(["mailStoreUser", mailStoreUserId])
    attrs.append(["mailStorePassword", mailStorePasswd])
    attrs.append(["debug", enableDebug])

    sop (m, "Creating mail session: " + repr(name) + " as a child of: " + repr(mailProvider) + " using attributes: " + repr(attrs)) 
    mSession = AdminConfig.create("MailSession", mailProvider, attrs)

    sop (m, "Creation of mail session " + name + " was successful! session = " + repr(mSession) )
    return mSession
