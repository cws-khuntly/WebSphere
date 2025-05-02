#
# PortalServer/properties
#

Property files for Portal installation and configuration for the Portal profile, Configuration Engine, and Configuration Wizard.

Directory structure:
 - Base: Common files that are used by all available processes
 - ${ENVIRONMENT}/ConfigEngine: Configuration Engine property files, per environment
 - ${ENVIRONMENT}/ConfigWizard: Configuration Wizard property files. Currently only contains the relevant soap.client.props
 - ${ENVIRONMENT}/PortalProfile: Contains property files relative to the Portal server instance profile
