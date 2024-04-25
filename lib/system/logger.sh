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

declare PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin";

## get the available log config
if [[ -z "${LOGGING_LOADED}" ]] || [[ "${LOGGING_LOADED}" == "${_FALSE}" ]]
then
    if [[ -r "/usr/local/etc/logging.properties" ]]; then source "/usr/local/etc/logging.properties"; fi
fi

## create the directory if it doesn't already exist
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
    printf "    %s: %s\n" "Calling script" "The script calling the method to write the log entry." >&2;
    printf "    %s: %s\n" "Calling function" "The method within the script calling the method to write the log entry." >&2;
    printf "    %s: %s\n" "Line number" "The line on which the message was produced." >&2;
    printf "    %s: %s\n" "Message" "The data to write to the logfile." >&2;

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  writeLogEntry
#   DESCRIPTION:  Cleans up the archived log directory
#    PARAMETERS:  Archive Directory, Logfile Name, Retention Time
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntryToStdWriter()
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
#          NAME:  writeLogEntryToFile
#   DESCRIPTION:  Cleans up the archived log directory
#    PARAMETERS:  Archive Directory, Logfile Name, Retention Time
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntryToFile()
(
    set +o noclobber;
    log_level="${1}";
    log_pid="${2}";
    log_source="${3}";
    log_line="${4}";
    log_method="${5}";
    log_message="${6}";
    log_date="$(date -d @"$(date +"%s")" +"${TIMESTAMP_OPTS}")";

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

    if [[ "${write_to_log}" == "${_TRUE}" ]] && [[ -n "${log_file}" ]] && [[ -w "${LOG_ROOT}" ]]; then
        printf "${CONVERSION_PATTERN}\n" "${log_date}" "${log_file}" "${log_level}" "${log_pid}" "${log_source}" "${log_line}" "${log_method}" "${log_message}" >> "${LOG_ROOT}/${log_file}";
    fi

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
