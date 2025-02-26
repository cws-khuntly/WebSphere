#==============================================================================
#
#          FILE:  configureDMGR.py
#         USAGE:  wsadmin.sh -lang jython -f configureDMGR.py
#     ARGUMENTS:  wasVersion
#   DESCRIPTION:  Executes an scp connection to a pre-defined server
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

import os
import sys

configureLogging("../config/logging.xml")
logger = logging.getLogger(__name__)

lineSplit = java.lang.System.getProperty("line.separator")
serverName = "dmgr"
nodeName = "dmgrNode01"
targetCell = AdminControl.getCell()
nodeList = AdminTask.listManagedNodes().split(lineSplit)

def configureDeploymentManager(runAsUser="", runAsGroup=""):
    targetServer = AdminConfig.getid('/Server:' + serverName + '/')

    if (targetServer):
        print("Starting configuration for deployment manager " + serverName + "...")

        configureWebContainer(targetServer)
        setServerTrace(targetServer)
        setProcessExec(targetServer, runAsUser, runAsGroup)
        setJVMProperties(serverName, nodeName)

        saveWorkspaceChanges()
        syncAllNodes(nodeList, targetCell)

        print("Completed configuration for deployment manager %s") % (serverName)
    else:
        print("Deployment manager not found with server name %s") % (serverName)
    #endif
#enddef

def configureWebContainer(targetServer, defaultVhostName="default_host"):
    if (targetServer):
        print("Starting configuration for server %s") % (serverName)

        targetWebContainer = AdminConfig.list("WebContainer", targetServer)

        if (targetWebContainer):
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.extractHostHeaderPort"] [description ""] [value "true"] [required "false"]]')
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "trusthostheaderport"] [description ""] [value "true"] [required "false"]]')
            AdminConfig.create('Property', targetWebContainer, '[[validationExpression ""] [name "com.ibm.ws.webcontainer.invokefilterscompatibility"] [description ""] [value "true"] [required "false"]]')

            AdminConfig.modify(targetWebContainer, '[[defaultVirtualHostName %s]]') % (defaultVhostName)

            setServletCaching(targetServer)
            setPortletCaching(targetServer)
        else:
            raise ("Error configuring the web container for server %s.") % (targetServer)
        #endif
    else:
        raise ("No server was provided to configure.")
    #endif
#enddef

def configureHAManager(targetServer):
    if (targetServer):
        print("Starting configuration for server %s") % (serverName)

        haManager = AdminConfig.list("HAManagerService", targetServer)

        if (haManager):
            AdminConfig.modify(haManager, '[[enable "false"] [activateEnabled "true"] [isAlivePeriodSec "120"] [transportBufferSize "10"] [activateEnabled "true"]]')
        else:
            raise ("Error configuring HAManager for server %s.") % (targetServer)
        #endif
    else:
        raise ("No server was provided to configure.")
    #endif
#enddef

def setServerTrace(targetServer, traceSpec="*=info", outputType="SPECIFIED_FILE", maxBackupFiles=50, rolloverSize=50, traceFilename='$' + ' {LOG_ROOT}/' + '$' + '{SERVER}/trace.log'):
    if (targetServer):
        print("Starting configuration for server %s") % (serverName)

        targetTraceService = AdminConfig.list("TraceService", targetServer)

        if (targetTraceService):
            AdminConfig.modify(targetTraceService, [['startupTraceSpecification', traceSpec]] )
            AdminConfig.modify(targetTraceService, [['traceOutputType', outputType]] )
            AdminConfig.modify(targetTraceService, [['traceLog', [['fileName', traceFilename], ['maxNumberOfBackupFiles', '%d' % maxBackupFiles], ['rolloverSize', '%d' % rolloverSize ]]]] )
        else:
            raise ("Error configuring the web container for server %s") %(serverName)
        #endif
    else:
        raise ("No server was found with the provided name:  %s") %(serverName)
    #endif
#enddef

def setProcessExec(targetServer, runAsUser, runAsGroup):
    if ((targetServer)):
        processExec = AdminConfig.list("ProcessExecution", targetServer)

        if ((runAsUser) and (runAsGroup)):
            AdminConfig.modify(processExec, '[[runAsUser %s] [runAsGroup %s] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]') % (runAsUser, runAsGroup)
        elif (runAsUser):
            AdminConfig.modify(processExec, '[[runAsUser %s] [runInProcessGroup "0"] [processPriority "20"] [umask "022"]]') % (runAsUser)
        else:
            AdminConfig.modify(processExec, '[[runInProcessGroup "0"] [processPriority "20"] [umask "022"]]')
        #end if
    else:
        raise "No server was found with the provided name: " + serverName + "."
    #endif
#enddef

def setJVMProperties(serverName, nodeName, initialHeapSize=2048, maxHeapSize=2048):
    genericJvmArgs = ("-Dibm.stream.nio=true -Djava.io.tmpdir=${WAS_TEMP_DIR} -Xdump:stack:events=allocation,filter=#10m -Xgcpolicy:gencon "
        "-Dcom.ibm.websphere.alarmthreadmonitor.threshold.millis=40000 -Xshareclasses:none -Dsun.reflect.inflationThreshold=0 -Djava.security.egd=file:/dev/./urandom "
        "-Dcom.sun.jndi.ldap.connect.pool.maxsize=200 -Dcom.sun.jndi.ldap.connect.pool.prefsize=200 -Dcom.sun.jndi.ldap.connect.pool.timeout=3000 "
        "-Djava.net.preferIPv4Stack=true -Dsun.net.inetaddr.ttl=600 -Djava.awt.headless=true -Djava.compiler=NONE "
        "-Xnoagent -Xrunjdwp=dt_socket,server=y,suspend=n,address=7792 -Dcom.ibm.cacheLocalHost=true -Dcom.ibm.xml.xlxp.jaxb.opti.level=3")

    if ((serverName) and (nodeName)):
        AdminTask.setJVMProperties('[-serverName %s -nodeName %s -verboseModeGarbageCollection true -initialHeapSize %s -maximumHeapSize + %s -debugMode false -genericJvmArguments %s]') \
            % (serverName, nodeName, initialHeapSize, maxHeapSize)
    else:
        raise ("No server was found with the provided name: %s") % (serverName)
    #endif
#enddef

def printHelp():
    print("This script configures a deployment manager for optimal settings.")
    print("Execution: wsadmin.sh -lang jython -f configureDeploymentManager.py <runAsUser> <runAsGroup>")
    print("<runAsUser> - The operating system username to run the process as. The user must exist on the local machine. Optional, if not provided no user is configured.")
    print("<runAsGroup> - The operating system group to run the process as. The group must exist on the local machine. Optional, if not provided no group is configured.")
#enddef

##################################
# main
#################################


if (len(sys.argv) == 1):
    configureDeploymentManager(sys.argv[0])
elif (len(sys.argv) == 2):
    configureDeploymentManager(sys.argv[0], sys.argv[1])
else:
    configureDeploymentManager()
#endif
