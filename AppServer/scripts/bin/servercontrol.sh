#!/usr/bin/env bash

#==============================================================================
#          FILE:  applicationServerControl.sh
#         USAGE:  See usage section
#   DESCRIPTION:
#
#       OPTIONS:  See usage section
#  REQUIREMENTS:  bash 4+
#          BUGS:  ---
#         NOTES:
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  ---
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

trap 'set +v; set +x' INT TERM EXIT;

## Application constants
ARG_COUNTER=0;
ERROR_COUNT=0;
CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#startup";
SCRIPT_ROOT="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && printf "%s" "${PWD}")")";
DEFAULT_CONFIG_FILE="${SCRIPT_ROOT}/properties/servercontrol.properties";

## load the logger
if [[ -r "${SCRIPT_ROOT}/lib/system/logger.sh" ]] && [[ -s "${SCRIPT_ROOT}/lib/system/logger.sh" ]]; then
    source "${SCRIPT_ROOT}/lib/system/logger.sh"; ## if its here, override the above and use it
elif [[ -r "${HOME}/lib/system/logger.sh" ]] && [[ -s "${HOME}/lib/system/logger.sh" ]]; then
    source "${HOME}/lib/system/logger.sh"; ## if its here, override the above and use it
elif [[ -r "/usr/local/bin/logger.sh" ]] && [[ -s "/usr/local/bin/logger.sh" ]]; then
    source "/usr/local/bin/logger.sh"; ## if its here, use it
else
    printf "\e[00;31m%s\e[00;32m\n" "Unable to load logger. No logging enabled!" >&2;
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

if [[ -d "${SCRIPT_ROOT}/lib/system" ]]; then
    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Found library directory ${SCRIPT_ROOT}/lib/system";
    fi

    for SYSLIB in ${SCRIPT_ROOT}/lib/system/*.sh; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Library ${SYSLIB}";
        fi

        [[ -z "${SYSLIB}" ]] && continue;
        [[ "${SYSLIB}" =~ ^\# ]] && continue;

        if [[ -r "${SYSLIB}" ]] && [[ -s "${SYSLIB}" ]] && \
            [[ "$(basename "${SYSLIB}")" != "cws-profile.sh" ]] && [[ "$(basename "${SYSLIB}")" != "logger.sh" ]]; then
            source "${SYSLIB}";
        fi
    done
fi

if [[ -r "${DEFAULT_CONFIG_FILE}" ]]; then
    WORKING_CONFIG_FILE="${DEFAULT_CONFIG_FILE}";

    source "${WORKING_CONFIG_FILE}";
else
    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Unable to read base configuration file ${DEFAULT_CONFIG_FILE}. Please ensure the file exists and is readable, or specify an alternate configuration file using the --config/--c argument.";
        writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Unable to read base configuration file ${DEFAULT_CONFIG_FILE}. Please ensure the file exists and is readable, or specify an alternate configuration file using the --config/--c argument.";
    fi
fi

if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${CNAME} starting up... Process ID ${$}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} -> enter";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Provided arguments: ${*}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "CNAME -> ${CNAME}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "METHOD_NAME -> ${METHOD_NAME}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SCRIPT_ROOT -> ${SCRIPT_ROOT}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "DEFAULT_CONFIG_FILE -> ${DEFAULT_CONFIG_FILE}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WORKING_CONFIG_FILE -> ${WORKING_CONFIG_FILE}";
fi

#======  FUNCTION  ============================================================
#          NAME:  main
#   DESCRIPTION:  Rotates log files in logs directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function main()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    function_name="${CNAME}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

	(( ${#} < 4 )) && return 3;

    action_name="${1}";
    profile_name="${2}";
    server_name="${3}";
    server_type="${4}";
    watch_for_file="${5}";
    sleep_count="${6}";
    retry_count="${7}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "action_name -> ${action_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "server_name -> ${server_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "server_type -> ${server_type}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_for_file -> ${watch_for_file}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "sleep_count -> ${sleep_count}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "retry_count -> ${retry_count}";
    fi

    case "${action_name}" in
        [Ss][Tt][Aa][Rr][Tt][Uu][Pp]|[Ss][Tt][Aa][Rr][Tt])
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                 writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: startApplicationServer ${profile_name} ${server_name} ${watch_for_file} ${sleep_count} ${retry_count}";
            fi

            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            [[ "${server_type}" =~ [Dd][Mm][Gg][Rr] ]] && startDeploymentManager;
            [[ "${server_type}" =~ [Nn][Oo][Dd][Ee][Aa][Gg][Ee][Nn][Tt] ]] && startNodeAgent;
            [[ "${server_type}" =~ [Aa][Pp][Pp][Ll][Ii][Cc][Aa][Tt][Ii][Oo][Nn]_[Ss][Ee][Rr][Vv][Ee][Rr] ]] && startApplicationServer "${profile_name}" "${server_name}" "${watch_for_file}" "${sleep_count}" "${retry_count}";
            [[ "${server_type}" =~ [Pp][Oo][Rr][Tt][Aa][Ll]_[Ss][Ee][Rr][Vv][Ee][Rr] ]] && startApplicationServer "${profile_name}" "${server_name}" "${watch_for_file}" "${sleep_count}" "${retry_count}";
            ret_code="${?}";

            function_name="${CNAME}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Failed to start server ${server_name} in profile ${profile_name}. Please review logs.";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Failed to start server ${server_name} in profile ${profile_name}. Please review logs.";
                fi
            else
                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${server_name} in profile ${profile_name} was successfully started";
                    writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${server_name} in profile ${profile_name} was successfully started.";
                fi
            fi
            ;;
        [Ss][Hh][Uu][Tt][Dd][Oo][Ww][Nn]|[Ss][Tt][Oo][Pp])
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                 writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: stopApplicationServer ${profile_name} ${server_name} ${watch_for_file} ${sleep_count} ${retry_count}";
            fi

            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            [[ "${server_type}" =~ [Dd][Mm][Gg][Rr] ]] && stopDeploymentManager;
            [[ "${server_type}" =~ [Nn][Oo][Dd][Ee][Aa][Gg][Ee][Nn][Tt] ]] && stopNodeAgent;
            [[ "${server_type}" =~ [Aa][Pp][Pp][Ll][Ii][Cc][Aa][Tt][Ii][Oo][Nn][Ss][Ee][Rr][Vv][Ee][Rr] ]] && stopApplicationServer "${profile_name}" "${server_name}";
            ret_code="${?}";

            function_name="${CNAME}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                return_code="${ret_code}";

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Failed to stop server ${server_name} in profile ${profile_name}. Please review logs.";
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Failed to stop server ${server_name} in profile ${profile_name}. Please review logs.";
                fi
            else
                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${server_name} in profile ${profile_name} was successfully stopped";
                    writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${server_name} in profile ${profile_name} was successfully stopped.";
                fi
            fi
            ;;
        *)
            return_code=1;

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "An unknown action was provided. action_name -> ${action_name}";
            fi
            ;;
    esac

    [[ -n "${action_name}" ]] && unset -v action_name;
    [[ -n "${profile_name}" ]] && unset -v profile_name;
    [[ -n "${server_name}" ]] && unset -v server_name;
    [[ -n "${server_type}" ]] && unset -v server_type;
    [[ -n "${watch_for_file}" ]] && unset -v watch_for_file;
    [[ -n "${sleep_count}" ]] && unset -v sleep_count;
    [[ -n "${retry_count}" ]] && unset -v retry_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#======  FUNCTION  ============================================================
#          NAME:  usage
#   DESCRIPTION:  Provides usage parameters.
#    PARAMETERS:  None
#       RETURNS:  3.
#==============================================================================
function usage()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    function_name="${CNAME}#${FUNCNAME[0]}";
    return_code=3;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${function_name} -> enter";
    fi

    printf "%s %s\n" "${function_name}" "Start/stop or restart a given WebSphere Application Server instance." >&2;
    printf "%s %s\n" "Usage: ${function_name}" "[ options ]" >&2;
    printf "    %s: %s\n" "NOTE" "All configuration options are available in the configuration file, and may be overridden with the appropriate arguments." >&2;
    printf "    %s: %s\n" "Optional" "--config | -c <configuration file>: The location to an alternative configuration file for this utility. Default configuration file -> ${DEFAULT_CONFIG_FILE}" >&2;
    printf "        %s: %s\n" "NOTE" "While this is an optional argument, it MUST be the first positional parameter to this application in order to properly load the various configuration options." >&2;
    printf "    %s: %s\n" "Optional" "--serverlist <entry-list | /path/to/file> | -l <entry-list | /path/to/file>: A list of servers to action against. This value may be specified in the configuration file." >&2;
    printf "        %s: %s\n" "Formatting" "Multiple arguments must be separated with a space. The following formats are acceptible, and apply both to a list provided on the command line or contained within a file:" >&2;
    printf "            %s: %s\n" "profilename:servername" "The minimum required information to action against. Default value -> ${DEFAULT_PROFILE_NAME}:${DEFAULT_SERVER_NAME}" >&2;
    printf "            %s: %s\n" "profilename:servername:servertype" "Additionally specify the type of server. Default value -> ${DEFAULT_SERVER_TYPE}" >&2;
    printf "            %s: %s\n" "profilename:servername:servertype:waitfile" "Additionally specify a file to wait for. No default is provided." >&2;
    printf "            %s: %s\n" "profilename:servername:servertype:waitfile:sleep" "Additionally specify a time to sleep while waiting for the file. Only applicable if a file to wait for has been defined. Default value -> ${DEFAULT_SLEEP_TIME}" >&2;
    printf "            %s: %s\n" "profilename:servername:servertype:waitfile:sleep:retries" "Additionally specify a retry count while waiting for the file. Only applicable if a file to wait for has been defined. Default value -> ${DEFAULT_RETRY_COUNT}" >&2;
    printf "    %s: %s\n" "Required" "--action | -a <action>: The type of process to execute. One of the following:" >&2;
    printf "        %s: %s\n" "start / startServer" "Starts the provided WebSphere Application Server" >&2;
    printf "        %s: %s\n" "stop / stopServer" "Stops the provided WebSphere Application Server" >&2;
    printf "        %s: %s\n" "restart" "Restarts the provided WebSphere Application Server" >&2;
    printf "    %s: %s\n" "--help | -h | -?" "Show this help menu." >&2;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

if (( ${#} == 0 )); then usage; exit ${?}; fi

while (( ${#} > 0 )); do
    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Provided Argument -> ${1}";
    fi

    (( ARG_COUNTER == ${#} )) && break;

    ARGUMENT="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "ARGUMENT -> ${ARGUMENT}";
    fi

    case "${ARGUMENT}" in
        *=*)
            ARGUMENT_NAME="$(cut -d "=" -f 1 <<< "${ARGUMENT// }" | sed -e "s/--//g" -e "s/-//g")";
            ARGUMENT_VALUE="$(cut -d "=" -f 2 <<< "${ARGUMENT}")";

            shift 1;
            ;;
        *)
            ARGUMENT_NAME="$(cut -d "-" -f 2 <<< "${ARGUMENT}")";
            ARGUMENT_VALUE="${2}";

            shift 2;
            ;;
    esac

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "ARGUMENT_NAME -> ${ARGUMENT_NAME}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "ARGUMENT_VALUE -> ${ARGUMENT_VALUE}";
    fi

    case "${ARGUMENT_NAME}" in
        serverlist|l)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting SERVER_LIST";
            fi

            SERVER_LIST="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SERVER_LIST -> ${SERVER_LIST}";
            fi
            ;;
        action|a)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting TARGET_ACTION...";
            fi

            TARGET_ACTION="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_ACTION -> ${TARGET_ACTION}";
            fi
            ;;
        help|\?|h)
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            usage;
            RETURN_CODE="${?}";

            function_name="${CNAME}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "ret_code -> ${ret_code}";
            fi

            if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
            if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi
            ;;
        *)
            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "An invalid option has been provided and has been ignored. Option -> ${ARGUMENT_NAME}, Value -> ${ARGUMENT_VALUE}";
            fi
            ;;
    esac

    (( ARG_COUNTER += 1 ));
done

if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "PROFILE_NAME -> ${PROFILE_NAME}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SERVER_LIST -> ${SERVER_LIST}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SERVER_NAME -> ${SERVER_NAME}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_ACTION -> ${TARGET_ACTION}";
fi

if [[ -n "${RETURN_CODE}" ]] && (( RETURN_CODE != 0 )); then
    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "A non-zero return code has been detected prior to runtime. return_code -> ${return_code}, RETURN_CODE -> ${RETURN_CODE}";
    fi

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    if (( RETURN_CODE != 3 )); then
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Found a non-zero return code prior to execution. Please review logs and parameters.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Found a non-zero return code prior to execution. Please review logs and parameters.";
        fi
    fi
else
    ## bring in any library scripts
    for LIBENTRY in "${SCRIPT_ROOT}"/lib/$(basename "${CNAME}" ".sh")/*.sh; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "LIBENTRY -> ${LIBENTRY}";
        fi

        [[ -z "${LIBENTRY}" ]] && continue;

        if [[ -r "${LIBENTRY}" ]] && [[ -s "${LIBENTRY}" ]]; then source "${LIBENTRY}"; fi

        [[ -n "${LIBENTRY}" ]] && unset -v LIBENTRY;
    done

    if [[ -z "${SERVER_LIST}" ]]; then
        TARGET_ENTRIES=("${DEFAULT_PROFILE_NAME}:${DEFAULT_SERVER_NAME}:${DEFAULT_SERVER_TYPE}:${DEFAULT_WATCH_FILE}:${DEFAULT_SLEEP_TIME}:${DEFAULT_RETRY_COUNT}");
    else
        if [[ -f "${SERVER_LIST}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Loading data from ${SERVER_LIST}";
            fi

            mapfile -t TARGET_ENTRIES < "${SERVER_LIST}";
        else
            if [[ "${SERVER_LIST}" =~ | ]] && (( $(grep -o "|" <<< "${SERVER_LIST}" | wc -l) != 1 )); then
                mapfile -d "|" -t TARGET_ENTRIES <<< "${SERVER_LIST}";
            fi
        fi
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_ENTRIES -> ${TARGET_ENTRIES[*]}";
    fi

    for TARGET_ENTRY in "${TARGET_ENTRIES[@]}"; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_ENTRY -> ${TARGET_ENTRY}";
        fi

        [[ -z "${TARGET_ENTRY}" ]] && continue;
        [[ "${TARGET_ENTRY}" =~ ^\# ]] && continue;

        TARGET_PROFILE="$(cut -d ":" -f 1 <<< "${TARGET_ENTRY}")";
        TARGET_SERVER="$(cut -d ":" -f 2 <<< "${TARGET_ENTRY}")";
        SERVER_TYPE="$(cut -d ":" -f 3 <<< "${TARGET_ENTRY}")";
        WATCH_FOR_FILE="$(cut -d ":" -f 4 <<< "${TARGET_ENTRY}")";
        SLEEP_TIME="$(cut -d ":" -f 5 <<< "${TARGET_ENTRY}")";
        RETRY_COUNT="$(cut -d ":" -f 6 <<< "${TARGET_ENTRY}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_PROFILE -> ${TARGET_PROFILE}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_SERVER -> ${TARGET_SERVER}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WATCH_FOR_FILE -> ${WATCH_FOR_FILE}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SLEEP_TIME -> ${SLEEP_TIME}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETRY_COUNT -> ${RETRY_COUNT}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SERVER_TYPE -> ${SERVER_TYPE}";
        fi

        if [[ -n "${WATCH_FOR_FILE}" ]]; then
            [[ -z "${SLEEP_TIME}" ]] && SLEEP_TIME="${DEFAULT_SLEEP_TIME}";
            [[ -z "${RETRY_COUNT}" ]] && RETRY_COUNT="${DEFAULT_RETRY_COUNT}";
        fi

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SLEEP_TIME -> ${SLEEP_TIME}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETRY_COUNT -> ${RETRY_COUNT}";
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main ${TARGET_ACTION} ${PROFILE_NAME} ${SERVER_ENTRY} ${SERVER_TYPE} ${WATCH_FOR_FILE} ${SLEEP_TIME} ${RETRY_COUNT}";
        fi

        main "${TARGET_ACTION}" "${TARGET_PROFILE}" "${TARGET_SERVER}" "${SERVER_TYPE}" "${WATCH_FOR_FILE}" "${SLEEP_TIME}" "${RETRY_COUNT}";
        RET_CODE="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RET_CODE -> ${RET_CODE}";
        fi

        if [[ -z "${RET_CODE}" ]] || (( RET_CODE != 0 )); then (( ERROR_COUNT +=1 )); fi

        [[ -n "${TARGET_PROFILE}" ]] && unset -v TARGET_PROFILE;
        [[ -n "${TARGET_SERVER}" ]] && unset -v TARGET_SERVER;
        [[ -n "${WATCH_FOR_FILE}" ]] && unset -v WATCH_FOR_FILE;
        [[ -n "${SLEEP_TIME}" ]] && unset -v SLEEP_TIME;
        [[ -n "${RETRY_COUNT}" ]] && unset -v RETRY_COUNT;
        [[ -n "${SERVER_TYPE}" ]] && unset -v SERVER_TYPE;
        [[ -n "${TARGET_ENTRY}" ]] && unset -v TARGET_ENTRY;
    done

    RETURN_CODE=${ERROR_COUNT};

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETURN_CODE -> ${RETURN_CODE}";
    fi

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi
fi

[[ -n "${SERVER_ENTRY}" ]] && unset -v SERVER_ENTRY;
[[ -n "${SERVER_LIST}" ]] && unset -v SERVER_LIST;
[[ -n "${TARGET_PROFILE}" ]] && unset -v TARGET_PROFILE;
[[ -n "${TARGET_SERVER}" ]] && unset -v TARGET_SERVER;
[[ -n "${WATCH_FOR_FILE}" ]] && unset -v WATCH_FOR_FILE;
[[ -n "${SLEEP_TIME}" ]] && unset -v SLEEP_TIME;
[[ -n "${RETRY_COUNT}" ]] && unset -v RETRY_COUNT;
[[ -n "${TARGET_ACTION}" ]] && unset -v TARGET_ACTION;
[[ -n "${LIBENTRY}" ]] && unset -v LIBENTRY;
[[ -n "${USER_LIB_PATH}" ]] && unset -v USER_LIB_PATH;
[[ -n "${ARGUMENT_NAME}" ]] && unset -v ARGUMENT_NAME;
[[ -n "${ARGUMENT_VALUE}" ]] && unset -v ARGUMENT_VALUE;
[[ -n "${ARGUMENT}" ]] && unset -v ARGUMENT;
[[ -n "${DEFAULT_PROFILE_NAME}" ]] && unset -v DEFAULT_PROFILE_NAME;
[[ -n "${DEFAULT_SERVER_NAME}" ]] && unset -v DEFAULT_SERVER_NAME;
[[ -n "${SCRIPT_ROOT}" ]] && unset -v SCRIPT_ROOT;
[[ -n "${FUNCTION_NAME}" ]] && unset -v FUNCTION_NAME;
[[ -n "${CNAME}" ]] && unset -v CNAME;
[[ -n "${ERROR_COUNT}" ]] && unset -v ERROR_COUNT;
[[ -n "${ARG_COUNTER}" ]] && unset -v ARG_COUNTER;

exit ${RETURN_CODE};
