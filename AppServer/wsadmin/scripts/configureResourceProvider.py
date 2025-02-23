def createREProviders ( proName, description, scope ):
    """Creates a Resource Environment Provider in the specified parent scope"""
    m = "createREProviders:"

    for ob in _splitlines(AdminConfig.list('ResourceEnvironmentProvider',scope)):
        name = AdminConfig.showAttribute(ob, "name")
        if (name == proName):
            sop(m, "The %s Resource Environment Provider already exists." % proName)
            return

    attrs = []
    attrs.append( [ 'name', proName ] )
    attrs.append( [ 'description', description ] )
    return create('ResourceEnvironmentProvider', scope, attrs)

def createREProviderReferenceable ( factoryClassname, classname, proid ):
    """Creates a Resource Environment Provider Referenceable """
    m = "createREProviderReferenceable:"

    for ob in _splitlines(AdminConfig.list('Referenceable',proid)):
        name = AdminConfig.showAttribute(ob, "factoryClassname")
        if (name == factoryClassname):
            sop(m, "The %s Resource Environment Provider Referenceable already exists." % factoryClassname)
            return

    attrs = []
    attrs.append( [ 'factoryClassname', factoryClassname ] )
    attrs.append( [ 'classname', classname ] )
    return create('Referenceable', proid, attrs)

def createREProviderResourceEnvEntry ( entryName, jndiName, refid, proid ):
    """Creates a Resource Environment Provider ResourceEnvEntry """
    m = "createREProviderResourceEnvEntry:"

    for ob in _splitlines(AdminConfig.list('ResourceEnvEntry',proid)):
        name = AdminConfig.showAttribute(ob, "name")
        if (name == entryName):
            sop(m, "The %s Resource Environment Provider ResourceEnvEntry already exists." % entryName)
            return

    attrs = []
    attrs.append( [ 'name', entryName ] )
    attrs.append( [ 'jndiName', jndiName ] )
    attrs.append( [ 'referenceable', refid ] )
    return create('ResourceEnvEntry', proid, attrs)

def createREProviderProperties ( propName, propValue, proid ):
    """Creates a Resource Environment Provider Custom Property """
    m = "createREProviderProperties:"

    propSet = AdminConfig.showAttribute(proid, 'propertySet')
    if(propSet == None):
        propSet = create('J2EEResourcePropertySet',proid,[])

    for ob in _splitlines(AdminConfig.list('J2EEResourceProperty',proid)):
        name = AdminConfig.showAttribute(ob, "name")
        if (name == propName):
            sop(m, "The %s Resource Environment Provider Custom Property already exists." % propName)
            return

    attrs = []
    attrs.append( [ 'name', propName ] )
    attrs.append( [ 'value', propValue ] )
    return create('J2EEResourceProperty', propSet, attrs)