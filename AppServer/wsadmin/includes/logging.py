def getSopTimestamp():
    """Returns the current system timestamp in a nice internationally-generic format."""
    # Assemble the formatting string in pieces, so that some code libraries do not interpret
    # the strings as special keywords and substitute them upon extraction.
    formatting_string = "[" + "%" + "Y-" + "%" + "m" + "%" + "d-" + "%" + "H" + "%" + "M-" + "%" + "S00]"
    return time.strftime(formatting_string)

DEBUG_SOP=0
def enableDebugMessages():
    """
    Enables tracing by making future calls to the sop() method actually print messages.
    A message will also be printed to notify the user that trace messages will now be printed.
    """
    global DEBUG_SOP
    DEBUG_SOP=1
    sop('enableDebugMessages', 'Verbose trace messages are now enabled; future debug messages will now be printed.')

def disableDebugMessages():
    """
    Disables tracing by making future calls to the sop() method stop printing messages.
    If tracing is currently enabled, a message will also be printed to notify the user that future messages will not be printed.
    (If tracing is currently disabled, no message will be printed and no future messages will be printed).
    """
    global DEBUG_SOP
    sop('enableDebugMessages', 'Verbose trace messages are now disabled; future debug messages will not be printed.')
    DEBUG_SOP=0

def sop(methodname,message):
    """Prints the specified method name and message with a nicely formatted timestamp.
    (sop is an acronym for System.out.println() in java)"""
    global DEBUG_SOP
    if(DEBUG_SOP):
        timestamp = getSopTimestamp()
        print "%s %s %s" % (timestamp, methodname, message)