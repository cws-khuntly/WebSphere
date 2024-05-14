#!/usr/bin/env bash

#==============================================================================
#          FILE:  installDotFiles
#         USAGE:  See usage section
#   DESCRIPTION:
#
#       OPTIONS:  See usage section
#  REQUIREMENTS:  bash 4+
#          BUGS:  ---
#         NOTES:
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  CaspersBox Web Services
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin";

## get the available log config and load it
if [[ -z "${LOGGING_PROPERTIES}" ]]; then
    if [[ -r "/usr/local/etc/logging.properties" ]] && [[ -s "/usr/local/etc/logging.properties" ]]; then LOGGING_PROPERTIES="/usr/local/etc/logging.properties"; fi ## if its here, use it
    if [[ -r "${HOME}/etc/system/logging.properties" ]] && [[ -s "${HOME}/etc/system/logging.properties" ]]; then LOGGING_PROPERTIES="${HOME}/etc/system/logging.properties"; fi ## if its here, override the above and use it
fi

if [[ -n "${LOGGING_PROPERTIES}" ]] && [[ -r "${LOGGING_PROPERTIES}" ]] && [[ -s "${LOGGING_PROPERTIES}" ]]; then source "${LOGGING_PROPERTIES}"; fi
if [[ -n "${LOG_ROOT}" ]] && [[ ! -d "${LOG_ROOT}" ]]; then mkdir -p "${LOG_ROOT}"; fi

#======  FUNCTION  ============================================================
#          NAME:  usage
#   DESCRIPTION:  Rotates log files in logs directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function usage()
(
    function_name="${CNAME}#${FUNCNAME[0]}";
    return_code=3;

    printf "%s %s\n" "${function_name}" "Write a log message to stdout/err or to a logfile" >&2;
    printf "%s %s\n" "Usage: ${function_name}" "[ <options> ]" >&2;
    printf "    %s: %s\n" "The level to write for." "Supported levels (not case-sensitive):" >&2;
    printf "        %s: %s\n" "STDOUT" "Write the provided data to standard output - commonly a terminal screen." >&2;
    printf "        %s: %s\n" "STDERR" "Write the provided data to standard error - commonly a terminal screen." >&2;
    printf "        %s: %s\n" "PERFORMANCE" "Write performance metrics as provided by the scripting." >&2;
    printf "        %s: %s\n" "FATAL" "Errors that cannot be recovered from." >&2;
    printf "        %s: %s\n" "ERROR" "Errors that are handled within the application." >&2;
    printf "        %s: %s\n" "INFO" "Informational messages about runtime processing." >&2;
    printf "        %s: %s\n" "WARN" "Warning messages usually related to configuration." >&2;
    printf "        %s: %s\n" "AUDIT" "Performs an audit log write." >&2; ## TODO: This should also be able to send email, write to a db, etc
    printf "        %s: %s\n" "DEBUG" "Messaging related to immediate runtime actions or configurations." >&2;
    printf "    %s: %s\n" "Process IDentifier (PID)" "The process ID of the running instance." >&2;
    printf "    %s: %s\n" "Calling script" "The script calling the method to write the log entry." >&2;
    printf "    %s: %s\n" "Line number" "The line on which the message was produced." >&2;
    printf "    %s: %s\n" "Calling function" "The method within the script calling the method to write the log entry." >&2;
    printf "    %s: %s\n" "Message" "The data to write to the logfile." >&2;

    return ${return_code};
)

#======  FUNCTION  ============================================================
#          NAME:  main
#   DESCRIPTION:  Rotates log files in logs directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntry()
(
    set +o noclobber;
    function_name="${CNAME}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    action="${1}";

    case "${action}" in
        [Ll][Oo][Gg][Tt][Oo][Ff][Ii][Ll][Ee])
            writeLogEntry "${2}" "${3}" "${4}" "${5}" "${6}" "${7}" "$(date -d @"$(date +"%s")" +"${TIMESTAMP_OPTS}")";
            ;;
        [Ll][Oo][Gg][Tt][Oo][Cc][Oo][Nn][Ss][Oo][Ll][Ee])
            writeLogEntryToConsole "${2}" "${3}";
            ;;
        *)
            (( error_count += 1 ));
            ;;
    esac

    [[ -n "${transfer_file_list}" ]] && unset -v transfer_file_list;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  writeLogEntry
#   DESCRIPTION:  Cleans up the archived log directory
#    PARAMETERS:  Archive Directory, Logfile Name, Retention Time
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntryToConsole()
(
    set +o noclobber;
    log_level="${1}";
    log_message="${2}";

    case "${log_level}" in
        [Ss][Tt][Dd][Oo][Uu][Tt]) printf "%s\n" "${log_message}" >&1; ;;
        [Ss][Tt][Dd][Ee][Rr][Rr]) printf "\e[00;31m%s\e[00;32m\n" "${log_message}" >&2; ;;
    esac
    [[ -n "${log_level}" ]] && unset -v log_level;
    [[ -n "${log_message}" ]] && unset -v log_message;

    return 0;
)

#=====  FUNCTION  =============================================================
#          NAME:  writeLogEntry
#   DESCRIPTION:  Cleans up the archived log directory
#    PARAMETERS:  Archive Directory, Logfile Name, Retention Time
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntry()
(
    set +o noclobber;
    log_level="${1}";
    log_pid="${2}";
    log_source="${3}";
    log_line="${4}";
    log_method="${5}";
    log_message="${6}";
    log_date="${7}";

    case "${log_level}" in
        [Pp][Ee][Rr][Ff][Oo][Rr][Mm][Aa][Nn][Cc][Ee]) log_file="${PERF_LOG_FILE}"; ;;
        [Ff][Aa][Tt][Aa][Ll]) log_file="${FATAL_LOG_FILE}"; ;;
        [Ee][Rr][Rr][Oo][Rr]) log_file="${ERROR_LOG_FILE}"; ;;
        [Ww][Aa][Rr][Nn]) log_file="${WARN_LOG_FILE}"; ;;
        [Ii][Nn][Ff][Oo]) log_file="${INFO_LOG_FILE}"; ;;
        [Aa][Uu][Dd][Ii][Tt]) log_file="${AUDIT_LOG_FILE}"; ;;
        [Dd][Ee][Bb][Uu][Gg]) log_file="${DEBUG_LOG_FILE}"; ;;
        [Mm][Oo][Nn][Ii][Tt][Oo][Rr]) log_file="${MONITOR_LOG_FILE}"; ;;
        *) log_file="${DEFAULT_LOG_FILE}"; ;;
    esac

    printf "${CONVERSION_PATTERN}\n" "${log_date}" "${log_file}" "${log_level}" "${log_pid}" "${log_source}" "${log_line}" "${log_method}" "${log_message}" >> "${LOG_ROOT}/${log_file}";

    [[ -n "${log_date}" ]] && unset -v log_date;
    [[ -n "${log_level}" ]] && unset -v log_level;
    [[ -n "${log_method}" ]] && unset -v log_method;
    [[ -n "${log_source}" ]] && unset -v log_source;
    [[ -n "${log_line}" ]] && unset -v log_line;
    [[ -n "${log_message}" ]] && unset -v log_message;
    [[ -n "${log_file}" ]] && unset -v log_file;
    [[ -n "${write_to_log}" ]] && unset -v write_to_log;

    return 0;
)
