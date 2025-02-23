def createJAAS(auth_alias, auth_username, auth_password):
    """ This method encapsulates the actions needed to create a J2C authentication data entry.

    Parameters:
        auth_alias - Alias to identify authentication entry in String format
        auth_username - Name of user in authentication entry in String format
        auth_password - User password in authentication entry in String format
    Returns:
        JAAS object
    """
    #---------------------------------------------------------
    # Check if the alias already exists
    #---------------------------------------------------------
    auth = _splitlines(AdminConfig.list("JAASAuthData"))

    for autItem in auth:
        if (auth_alias == AdminConfig.showAttribute(autItem, "alias")):
            sop("createJAAS", "The %s Resource Environment Provider already exists." % auth_alias)
            return autItem  # return the object
        #endIf
    #endFor
    #---------------------------------------------------------
    # Get the config id for the Cell's Security object
    #---------------------------------------------------------
    cell = AdminControl.getCell()
    sec = AdminConfig.getid('/Cell:%s/Security:/' % cell)

    #---------------------------------------------------------
    # Create a JAASAuthData object for authentication
    #---------------------------------------------------------
    alias_attr = ["alias", auth_alias]
    desc_attr = ["description", "authentication information"]
    userid_attr = ["userId", auth_username]
    password_attr = ["password", auth_password]
    attrs = [alias_attr, desc_attr, userid_attr, password_attr]
    appauthdata = AdminConfig.create("JAASAuthData", sec, attrs)
    return appauthdata # return the object

    #--------------------------------------------------------------
    # Save all the changes
    #--------------------------------------------------------------
    # AdminConfig.save()   # Joey commented out
#endDef

def getJAAS(auth_alias):
    """ This method encapsulates the actions needed to retrieve a J2C authentication data entry.

    Parameters:
        auth_alias - Alias to identify authentication entry in String format
    Returns:
        j2c object
    """
    #---------------------------------------------------------
    # Get JAASAuthDat object
    #---------------------------------------------------------
    auth = _splitlines(AdminConfig.list("JAASAuthData"))

    for autItem in auth:
        if (auth_alias == AdminConfig.showAttribute(autItem, "alias")):
            return autItem
            break
        #endIf
    #endFor
#endDef