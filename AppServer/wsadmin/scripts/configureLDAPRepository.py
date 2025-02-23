def _doLDAPUserRegistry(ldapServerId,
                        ldapPassword,
                        ldapServer,
                        ldapPort,
                        baseDN,
                        primaryAdminId,
                        bindDN,
                        bindPassword,
                        type = "IBM_DIRECTORY_SERVER",
                        searchFilter = None,
                        sslEnabled = None,
                        sslConfig = None,
                        ):
    m = "_doLDAPUserRegistry:"
    sop(m,"ENTRY")

    attrs2 = [["primaryAdminId", primaryAdminId],
              ["realm", ldapServer+":"+ldapPort],
              ["type", type],
              ["baseDN", baseDN],
              ["reuseConnection", "true"],
              ["hosts", [[["host", ldapServer],
                          ["port", ldapPort]]]]]

    if ldapServerId == None:
        # Use automatically generated server ID
        attrs2.extend( [["serverId", ""],
                        ["serverPassword","{xor}"],
                        ["useRegistryServerId","false"],
                        ] )
    else:
        # use specified server id
        attrs2.extend([["serverId", ldapServerId],
                       ["serverPassword", ldapPassword],
                       ["useRegistryServerId","true"],
                      ])
    if bindDN != None:
        attrs2.append( ["bindDN", bindDN] )
    if bindPassword != None:
        attrs2.append( ["bindPassword", bindPassword] )

    if sslEnabled != None:
        attrs2.append( ["sslEnabled", sslEnabled] )
    if sslConfig != None:
        attrs2.append( ["sslConfig", sslConfig] )

    ldapUserRegistryId = _getLDAPUserRegistryId()
    if len(ldapUserRegistryId) > 0:
        try:
            hostIdList = AdminConfig.showAttribute(ldapUserRegistryId, "hosts")
            sop(m, "hostIdList=%s" % repr(hostIdList))
            if len(hostIdList) > 0:
                hostIdLists = stringListToList(hostIdList)
                sop(m, "hostIdLists=%s" % repr(hostIdLists))
                for hostId in hostIdLists:
                    sop(m, "Removing hostId=%s" % repr(hostId))
                    AdminConfig.remove(hostId)
                    sop(m, "Removed hostId %s\n" % hostId)
            try:
                sop(m,"about to modify ldapuserregistry: %s" % repr(attrs2))
                AdminConfig.modify(ldapUserRegistryId, attrs2)
            except:
                sop(m, "AdminConfig.modify(%s,%s) caught an exception\n" % (ldapUserRegistryId,repr(attrs2)))
                raise
            # update search filter if necessary
            if searchFilter != None:
                try:
                    origSearchFilter = AdminConfig.showAttribute(ldapUserRegistryId,"searchFilter")
                except:
                    sop(m, "AdminConfig.showAttribute(%s, 'searchFilter') caught an exception" % ldapUserRegistryId)
                    raise
                try:
                    updatedValues = dictToList(searchFilter)
                    sop(m,"About to update searchFilter: %s" % repr(updatedValues))
                    AdminConfig.modify(origSearchFilter, updatedValues)
                except:
                    sop(m, "AdminConfig.modify(%s,%s) caught an exception\n" % (origSearchFilter,repr(updatedValues)))
                    raise
        except:
            sop(m, "AdminConfig.showAttribute(%s, 'hosts') caught an exception" % ldapUserRegistryId)
            raise
    else:
        sop(m, "LDAPUserRegistry ConfigId was not found\n")
    return