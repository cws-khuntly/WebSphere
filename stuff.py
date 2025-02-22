def setDeploymentAutoStart(deploymentname, enabled, deploymenttargetname=None):
    """Sets an application to start automatically, when the server starts.
    Specify enabled as a lowercase string, 'true' or 'false'.
    For example, setDeploymentAutoStart('commsvc', 'false')
    Returns the number of deployments which were found and set successfully.
    Raises exception if application is not found.

    You may optionally specify an explicit deployment target name, such as a server or cluster name.
    For example, setDeploymentAutoStart('commsvc', 'true',  deploymenttargetname='cluster1')
                 setDeploymentAutoStart('commsvc', 'false', deploymenttargetname='server1')
    If the deployment target name is not specified, autostart is set on all instances of the deployment.

    Ultimately, this method changes the 'enable' value in a deployment.xml file.  For example,
    <targetMappings xmi:id="DeploymentTargetMapping_1262640302437" enable="true" target="ClusteredTarget_1262640302439"/>
    """
    m = "setDeploymentAutoStart:"
    sop(m,"Entry. deploymentname=%s enabled=%s deploymenttargetname=%s" % ( deploymentname, repr(enabled), deploymenttargetname ))

    # Check arg
    if 'true' != enabled and 'false' != enabled:
        raise "Invocation Error. Specify enabled as 'true' or 'false'. enabled=%s" % ( repr(enabled) )

    numSet = 0
    deployments = AdminConfig.getid("/Deployment:%s/" % ( deploymentname ))
    if (len(deployments) > 0) :
        deploymentObj = AdminConfig.showAttribute(deployments, 'deployedObject')
        sop(m,"deploymentObj=%s" % ( repr(deploymentObj) ))

        # First get the Target Mappings.  These are the objects where we set enabled/disabled.
        rawTargetMappings = AdminConfig.showAttribute(deploymentObj, 'targetMappings')
        # Convert the single string to a real python list containing strings.
        targetMappingList = stringListToList(rawTargetMappings)
        sop(m, "targetMappingList=%s" % ( repr(targetMappingList) ))

        # Next get the Deployment Targets. These are the objects from which we determine the deployment target name.
        rawDeploymentTargets = AdminConfig.showAttribute(deployments, 'deploymentTargets')
        # Convert the single string to a real python list containing strings.
        deploymentTargetList = stringListToList(rawDeploymentTargets)
        sop(m, "deploymentTargetList=%s" % ( repr(deploymentTargetList) ))

        # Handle each target mapping...
        for targetMapping in targetMappingList:
            attr_target = getObjectAttribute(targetMapping,"target")
            sop(m,"targetMapping=%s attr_target=%s" % ( targetMapping, attr_target ))

            # Find the associated deployment target object.
            for deploymentTarget in deploymentTargetList:
                current_deployment_target_name = getNameFromId(deploymentTarget)
                sop(m,"deploymentTarget=%s current_deployment_target_name=%s" % ( deploymentTarget, current_deployment_target_name ))
                if -1 != deploymentTarget.find(attr_target):
                    sop(m,"Found associated deployment target.")
                    # Check whether this is the desired deployment target.
                    if None == deploymenttargetname or current_deployment_target_name == deploymenttargetname:
                        valueString = '[[enable "%s"]]' % ( enabled )
                        sop(m,"Setting autostart on desired deployment target. target_mapping=%s and value=%s" % ( targetMapping, valueString ))
                        AdminConfig.modify(targetMapping, valueString)
                        numSet += 1
                    else:
                        sop(m,"Not a desired deployment target.")
                else:
                    sop(m,"Deployment target does not match.")
    else:
        sop(m, "No deployments found.")

    sop(m,"Exit. Set %i deployments." % ( numSet ))
    return numSet

def restartServer( nodename, servername, maxwaitseconds, ):
    """Restarts a server or proxy JVM

    This is useful to restart standalone servers after they have been configured.
    Raises an exception if the server is not already running.
    Waits up to the specified max number of seconds for the server to stop and restart.
    Returns True or False to indicate whether the server is running"""
    m = "restartServer: "
    sop(m,"Entry. nodename=%s servername=%s maxwaitseconds=%d" % (nodename, servername, maxwaitseconds, ))

    if not isServerRunning( nodename, servername ):
        raise m + "ERROR: Server is not already running. nodename=%s servername=%s" % (nodename, servername, )
    sop(m,"Server %s is running." % ( servername, ))

    # Get the server mbean
    serverObjectName = AdminControl.completeObjectName('type=Server,node=%s,process=%s,*' % ( nodename, servername ,))
    sop(m,"Invoking restart on server. serverObjectName=%s" % ( serverObjectName, ))

    # Restart the server.
    AdminControl.invoke(serverObjectName, 'restart')

    # Wait up to a max timeout if requested by the caller.
    elapsedtimeseconds = 0
    if maxwaitseconds > 0:
        sleeptimeseconds = 5

        # Phase 1 - Wait for server to stop (This can take 30 seconds on a reasonably fast linux intel box)
        isRunning = isServerRunning( nodename, servername )
        while isRunning and elapsedtimeseconds < maxwaitseconds:
            sop(m,"Waiting %d of %d seconds for %s to stop. isRunning=%s" % ( elapsedtimeseconds, maxwaitseconds, servername, isRunning, ))
            time.sleep( sleeptimeseconds )
            elapsedtimeseconds = elapsedtimeseconds + sleeptimeseconds
            isRunning = isServerRunning( nodename, servername )

        # Phase 2 - Wait for server to start (This can take another minute)
        while not isRunning and elapsedtimeseconds < maxwaitseconds:
            sop(m,"Waiting %d of %d seconds for %s to restart. isRunning=%s" % ( elapsedtimeseconds, maxwaitseconds, servername, isRunning, ))
            time.sleep( sleeptimeseconds )
            elapsedtimeseconds = elapsedtimeseconds + sleeptimeseconds
            isRunning = isServerRunning( nodename, servername )

    isRunning = isServerRunning( nodename, servername )
    sop(m,"Exit. nodename=%s servername=%s maxwaitseconds=%d elapsedtimeseconds=%d Returning isRunning=%s" % (nodename, servername, maxwaitseconds, elapsedtimeseconds, isRunning ))
    return isRunning


def setServerAutoRestart( nodename, servername, autorestart ):
    """Sets whether the nodeagent will automatically restart a failed server.

    Specify autorestart='true' or 'false' (as a string)"""
    m = "setServerAutoRestart:"
    sop(m,"Entry. nodename=%s servername=%s autorestart=%s" % ( nodename, servername, autorestart ))
    if autorestart != "true" and autorestart != "false":
        raise m + " Invocation Error: autorestart must be 'true' or 'false'. autorestart=%s" % ( autorestart )
    server_id = getServerId(nodename,servername)
    if server_id == None:
        raise " Error: Could not find server. servername=%s nodename=%s" % (nodename,servername)
    sop(m,"server_id=%s" % server_id)
    monitors = getObjectsOfType('MonitoringPolicy', server_id)
    sop(m,"monitors=%s" % ( repr(monitors)) )
    if len(monitors) == 1:
        setObjectAttributes(monitors[0], autoRestart = "%s" % (autorestart))
    else:
        raise m + "ERROR Server has an unexpected number of monitor object(s). monitors=%s" % ( repr(monitors) )
    sop(m,"Exit.")