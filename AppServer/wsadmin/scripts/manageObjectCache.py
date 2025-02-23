def createObjectCache(scopeobjectid, name, jndiname):
    """Create a dynacache object cache instance.

    The scope object ID should be the object ID of the config object
    at the desired scope of the new cache instance.  For example,
    for cell scope, pass the Cell object; for node scope, the Node
    object; for cluster scope, the Cluster object, etc. etc.

    Name & jndiname seem to be arbitrary strings.  Name must be
    unique, or at least not the same as another object cache in the
    same scope, not sure which.

    Returns the new object cache instance's config id."""

    cacheprovider = _getCacheProviderAtScope(scopeobjectid)
    if None == cacheprovider:
        raise Exception("COULD NOT FIND CacheProvider at the same scope as %s" % scopeobjectid)

    return AdminTask.createObjectCacheInstance(cacheprovider, ["-name", name,"-jndiName", jndiname])