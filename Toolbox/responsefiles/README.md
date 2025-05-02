#
# AppServer/responsefiles
#

IBM Installation Manager response files to install WebSphere Customization Toolbox, skeleton response file for the WCT interface

Usage for IBM Installation Manager (example):

```
/opt/IBM/IIM/eclipse/tools/imcl input /nfs/software/WebSphere/Toolbox/responsefiles/wct-base.xml -nosplash -acceptLicense -showProgress
```

Usage (WCT interface):

```
/opt/IBM/WebSphere/Toolbox/WCT/wct.sh -tool pct -defLocPathName /opt/IBM/WebSphere/Plugins -defLocName ${DEFINITION_NAME} -createDefinition -response /nfs/software/WebSphere/Toolbox/responsefiles/${IHS_INSTANCE}-response.txt
```
