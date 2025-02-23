def createVirtualHost(virtualhostname, templatename="default_host"):
    """Create a virtual host and return its ID.
    templatename might be e.g. "default_host" """
    m = "createVirtualHost:"
    sop(m,"virtualhostname=%s templatename=%s" % (virtualhostname,templatename))
    x = AdminConfig.listTemplates('VirtualHost')
    sop(m,"x=%s" % repr(x))
    templates = _splitlines(x)
    sop(m,"templates=%s" % repr(templates))
    # templates look like 'default_host(templates/default:virtualhosts.xml#VirtualHost_1)'
    template_id = None
    for t in templates:
        if t.startswith(templatename + "("):
            template_id = t
            break
    if template_id == None:
        raise "Cannot locate VirtualHost template named %s" % templatename

    sop(m,"template_id = %s" % template_id)
    return AdminConfig.createUsingTemplate('VirtualHost', getCellId(getCellName()), [['name', virtualhostname]], template_id)

def hostAliasExists( virtualhostname, aliashostname, port ):
    """Return true if the specified host alias already exists"""
    host_id = getVirtualHostByName( virtualhostname )
    if host_id == None:
        return 0   # can't exist, no such virtual host
    port = "%d" % int(port)   # force port to be a string
    aliases = AdminConfig.showAttribute( host_id, 'aliases' )
    #sop(m,"aliases=%s" % ( repr(aliases) ))
    aliases = aliases[1:-1].split( ' ' )
    #sop(m,"after split, aliases=%s" % ( repr(aliases) ))
    for alias in aliases:
        #sop(m,"alias=%s" % ( repr(alias) ))
        if alias != None and alias != '':
            # Alias is a HostAlias object
            h = AdminConfig.showAttribute( alias, 'hostname' )
            p = AdminConfig.showAttribute( alias, 'port' )
            if ( aliashostname, port ) == ( h, p ):
                # We're good - found what we need
                return 1
    return 0

def addHostAlias( virtualhostname, aliashostname, port ):
    """Add new host alias"""
    # Force port to be a string - could be string or int on input
    port = "%d" % int( port )

    print "adding host alias on %s: %s %s" % (virtualhostname, aliashostname, port)
    host_id = getVirtualHostByName(virtualhostname)
    if host_id == None:
        host_id = createVirtualHost(virtualhostname)
    new_alias = AdminConfig.create( 'HostAlias', host_id, [['hostname', aliashostname], ['port', port]] )
    print "alias added for virtualhost %s hostname %s port %s" % (virtualhostname,aliashostname,port)

    configured_port = getObjectAttribute(new_alias, 'port')
    if configured_port != port:
        raise "ERROR: requested host alias port %s but got %s" % (port,configured_port)
    else:
        print "wsadmin says the configured port is %s" % configured_port

    if not hostAliasExists(virtualhostname, aliashostname, port):
        raise "ERROR: host alias does not exist after creating it"