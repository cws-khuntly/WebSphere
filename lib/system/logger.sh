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

## Application constants
CNAME="$(basename "${BASH_SOURCE[0]}")"; declare CNAME;

## get the available log config
if [[ -z "${LOGGING_LOADED}" ]] || [[ "${LOGGING_LOADED}" == "${_FALSE}" ]]
then
    if [[ -r "/usr/local/etc/logging.properties" ]]; then source "/usr/local/etc/logging.properties"; fi
fi

#=====  FUNCTION  =============================================================
#          NAME:  writeLogEntry
#   DESCRIPTION:  Cleans up the archived log directory
#    PARAMETERS:  Archive Directory, Logfile Name, Retention Time
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntry()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi
    if [[ -n "${ENABLE_LOGGER_VERBOSE}" ]] && [[ "${ENABLE_LOGGER_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_LOGGER_TRACE}" ]] && [[ "${ENABLE_LOGGER_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    ## create the directory if it doesn't already exist
    if [[ -n "${LOG_ROOT}" ]] && [[ ! -d "${LOG_ROOT}" ]]; then mkdir -p "${LOG_ROOT}"; fi

    set +o noclobber;
    write_to_log="${_TRUE}";

    if (( ${#} == 0 )) || (( ${#} != 5 ))
    then
        return_code=3;

        printf "\e[00;31m%s\e[00;32m\n" "${BASH_SOURCE[0]}#${FUNCNAME[0]} - Write a log message to stdout/err or to a logfile" >&2;
        printf "\e[00;31m%s\e[00;32m\n" "Usage: ${FUNCNAME[0]} [ <level> ] [ <class/script> ] [ <method> ] [ <line> ] [ <message> ]
                 -> The level to write for. Supported levels (not case-sensitive):
                     STDOUT
                     STDERR
                     PERFORMANCE
                     FATAL
                     ERROR
                     INFO
                     WARN
                     AUDIT
                     DEBUG
                 -> The class/script calling the logger
                 -> The method calling the logger
                 -> The line number making the call
                 -> The message to be printed.\n" >&2;

        return ${return_code};
    fi

    log_level="${1}";
    log_source="${2}";
    log_method="${3}";
    log_line="${4}";
    log_message="${5}";
	log_time=$(printf "%(%s)T");
	log_date="$(date -d "@${log_time}" +"${TIMESTAMP_OPTS}")";

    case "${log_level}" in
        [Ss][Tt][Dd][Oo][Uu][Tt]) printf "%s\n" "${log_message}" >&1; write_to_log="${_FALSE}" ;;
        [Ss][Tt][Dd][Ee][Rr][Rr]) printf "\e[00;31m%s\e[00;32m\n" "${log_message}" >&2; write_to_log="${_FALSE}" ;;
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

    if [[ "${write_to_log}" == "${_TRUE}" ]] && [[ -n "${log_file}" ]] && [[ -w "${LOG_ROOT}" ]]
    then
        printf "${CONVERSION_PATTERN}\n" "${log_date}" "${PPID}" "${log_file}" "${log_level}" "${log_source}" "${log_line}" "${log_method}" "${log_message}" >> "${LOG_ROOT}/${log_file}";
    fi

	[[ -n "${log_time}" ]] && unset -v log_time;
    [[ -n "${log_date}" ]] && unset -v log_date;
    [[ -n "${log_level}" ]] && unset -v log_level;
    [[ -n "${log_method}" ]] && unset -v log_method;
    [[ -n "${log_source}" ]] && unset -v log_source;
    [[ -n "${log_line}" ]] && unset -v log_line;
    [[ -n "${log_message}" ]] && unset -v log_message;
    [[ -n "${log_file}" ]] && unset -v log_file;
    [[ -n "${write_to_log}" ]] && unset -v write_to_log;

    if [[ -n "${ENABLE_LOGGER_VERBOSE}" ]] && [[ "${ENABLE_LOGGER_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_LOGGER_TRACE}" ]] && [[ "${ENABLE_LOGGER_TRACE}" == "${_TRUE}" ]]; then set +v; fi
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    return 0;
}

