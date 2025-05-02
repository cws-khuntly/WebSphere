#
# AppServer/wsadmin
#

Jython scripts for server management using the wsadmin command.

Directory structure:
 - Base: Configuration files used by wsadmin. Currently contains wsadmin.properties, specifying additional options for the wsadmin environment
 - config: Used primarily for the logger
 - includes: Various python/jython files to allow all scripts to utilize common functions
 - properties: Property files that can be read into the scripts, providing values necessary for variables used within
 - scripts: The entry point for various management functions

Usage (example):

```
/opt/IBM/WebSphere/AppServer/bin/wsadmin.sh -p /nfs/software/WebSphere/AppServer/wsadmin/wsadmin.properties -profileName ${PROFILE_NAME} -lang jython -f /path/to/script
```
