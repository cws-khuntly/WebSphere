#
# PortalServer/scripts
#

Scripts utilized for the Portal server.

Directory structure:
 - bin: Primary entry point for the scripted process
 - lib: Function scripts utilized by the various processes

Note that the etc/ directory is missing here: It is housed within workspace/PortalServer/scripts:
 - etc: Configuration files for processing. Further broken down into the following:
  - ${PROCESS}: Configuration files for the given process
  - system: Configuration files used by all processes
