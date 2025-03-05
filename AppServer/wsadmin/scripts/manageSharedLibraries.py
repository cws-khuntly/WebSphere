def createSharedLibrary(libname, jarfile):
    """Creates a shared library on the specified cell with the given name and jarfile"""
    m = "createSharedLibrary:"
    #sop(m,"Entry. Create shared library. libname=%s jarfile=%s" % (repr(libname), repr(jarfile) ))
    cellname = getCellName()
    cell_id = getCellId(cellname)
    #sop(m,"cell_id=%s " % ( repr(cell_id), ))
    result = AdminConfig.create('Library', cell_id, [['name', libname], ['classPath', jarfile]])
    #sop(m,"Exit. result=%s" % ( repr(result), ))

def createSharedLibraryClassloader(nodename, servername, libname):
    """Creates a classloader on the specified appserver and associates it with a shared library"""
    m = "createSharedLibraryClassloader:"
    #sop(m,"Entry. Create shared library classloader. nodename=%s servername=%s libname=%s " % ( repr(nodename), repr(servername), repr(libname) ))
    server_id = getServerByNodeAndName(nodename, servername )
    #sop(m,"server_id=%s " % ( repr(server_id), ))
    appserver = AdminConfig.list('ApplicationServer', server_id)
    #sop(m,"appserver=%s " % ( repr(appserver), ))
    classloader = AdminConfig.create('Classloader', appserver, [['mode', 'PARENT_FIRST']])
    #sop(m,"classloader=%s " % ( repr(classloader), ))
    result = AdminConfig.create('LibraryRef', classloader, [['libraryName', libname], ['sharedClassloader', 'true']])
    #sop(m,"Exit. result=%s" % ( repr(result), ))

def createReplicationDomain(domainname, numberofreplicas):
    """Creates a replication domain with the specified name and replicas.
    Set number of replicas to -1 for whole-domain replication.
    Returns the config id of the DataReplicationDomain object."""
    m = "createReplicationDomain:"
    #sop(m,"Entry. Create replication domain. domainname=%s numberofreplicas=%s " % (repr(domainname), repr(numberofreplicas) ))
    cell_id = getCellId()
    #sop(m,"cell_id=%s " % ( repr(cell_id), ))
    domain = AdminConfig.create('DataReplicationDomain', cell_id, [['name', domainname]])
    #sop(m,"domain=%s " % ( repr(domain), ))
    domainsettings = AdminConfig.create('DataReplication', domain, [['numberOfReplicas', numberofreplicas]])
    #sop(m,"domainsettings=%s " % ( repr(domainsettings), ))
    #sop(m,"Exit. ")
    return domain