#!/usr/bin/env bash

#==============================================================================
#          FILE:  getSessionStats.sh
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

PATH="${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin";

## Application constants
ARG_COUNTER=0;
CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#startup";
CONFIG_FILE_LOCATION="${HOME}/workspace/WebSphere/PortalServer/properties/getSessionStats.properties";

## load the logger
if [[ -r "${SCRIPT_ROOT}/lib/system/logger.sh" ]] && [[ -s "${SCRIPT_ROOT}/lib/system/logger.sh" ]] && [[ -z "${LOGGING_LOADED}" ]]; then source "${SCRIPT_ROOT}/lib/system/logger.sh"; fi
if [[ -z "$(command -v "writeLogEntry" 2>/dev/null)" ]] || [[ -z "${LOGGING_LOADED}" ]] || [[ "${LOGGING_LOADED}" == "false" ]]; then printf "\e[00;31m%s\e[00;32m\n" "Failed to load logging configuration. No logging available!" >&2; LOGGING_LOADED="${_FALSE}"; fi;

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

if [[ -r "${CONFIG_FILE_LOCATION}" ]]; then
    WORKING_CONFIG_FILE="${CONFIG_FILE_LOCATION}";

    source "${WORKING_CONFIG_FILE}";
else
    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Unable to read base configuration file ${CONFIG_FILE_LOCATION}. Please ensure the file exists and is readable, or specify an alternate configuration file using the --config/--c argument.";
        writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Unable to read base configuration file ${CONFIG_FILE_LOCATION}. Please ensure the file exists and is readable, or specify an alternate configuration file using the --config/--c argument.";
    fi
fi

if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${CNAME} starting up... Process ID ${$}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} -> enter";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Provided arguments: ${*}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "CNAME -> ${CNAME}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "FUNCTION_NAME -> ${FUNCTION_NAME}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "CONFIG_FILE_LOCATION -> ${CONFIG_FILE_LOCATION}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WORKING_CONFIG_FILE -> ${WORKING_CONFIG_FILE}";
fi

#=====  FUNCTION  =============================================================
#          NAME:  getSessionStats
#   DESCRIPTION:  Gets session statistics for a WebSphere Portal Server
#    PARAMETERS:  None
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function collectSessionStats()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    cname="getSessionStats.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;
    ret_code=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    #======  FUNCTION  ============================================================
    #          NAME:  usage
    #   DESCRIPTION:
    #    PARAMETERS:  None
    #       RETURNS:  0 regardless of result.
    #==============================================================================
    function usage()
    (
        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

        cname="getSessionStats.sh";
        function_name="${cname}#${FUNCNAME[1]}";
        return_code=3;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        fi

        printf "%s %s\n" "${FUNCNAME[1]}" "Collect session statistics for provided WebSphere Portal server instances." >&2;
        printf "%s %s\n" "Usage: ${FUNCNAME[1]}" "[ start/end date ]" >&2;
        printf "    %s: %s\n" "<start/end date>" "The date(s) to collect session statistics for." >&2;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
        fi

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        return ${return_code};
    )

    if (( ${#} == 0 )); then usage; return ${?}; fi

    start_end_date="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "start_end_date -> ${start_end_date}";
    fi

    session_reporting_jar="$(grep session-reporting-jar "${WORKING_CONFIG_FILE}" | cut -d "=" -f 2 | sed -e "s/ //g")"
    exclude_address_file="$(grep exclude-address-file "${WORKING_CONFIG_FILE}" | cut -d "=" -f 2 | sed -e "s/ //g")"
    portal_server_list="$(grep portal-server-list "${WORKING_CONFIG_FILE}" | cut -d "=" -f 2 | sed -e "s/ //g")"
    access_log_file="$(grep portal-access-log "${WORKING_CONFIG_FILE}" | cut -d "=" -f 2 | sed -e "s/ //g")"
    java_cmd="java -jar ${session_reporting_jar}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "session_reporting_jar -> ${session_reporting_jar}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "exclude_address_file -> ${exclude_address_file}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "portal_server_list -> ${portal_server_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "access_log_file -> ${access_log_file}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "java_cmd -> ${java_cmd}";
    fi

    if [[ -n "${portal_server_list}" ]]; then
        for portal_server in "${portal_server_list[@]}"; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "portal_server -> ${portal_server}";
            fi

            portal_server_profile="$(cut -d "|" -f 1 <<< "${portal_server}")"
            portal_server_name="$(cut -d "|" -f 2 <<< "${portal_server}")"

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "portal_server_profile -> ${portal_server_profile}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "portal_server_name -> ${portal_server_name}";
            fi

            if [[ -n "${exclude_address_file}" ]]; then
                java_cmd="${java_cmd}+=${portal_server_profile}/logs/${portal_server_name}/${access_log_file} -excludeIPFilePath ${exclude_address_file} ${start_end_date} ${start_end_date}";
            else
                java_cmd="${java_cmd}+=${portal_server_profile}/logs/${portal_server_name}/${access_log_file}";
            fi

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "java_cmd -> ${java_cmd}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ${java_cmd} > ${HOME}/log/session-report-${portal_server_name}.${start_end_date}.log 2>&1;";
            fi

            ${java_cmd} > ${HOME}/log/session-report-${portal_server_name}.${start_end_date}.log 2>&1;
            ret_code=${?};

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute command ${java_cmd}, return code -> ${ret_code}";
                fi
            fi

            [[ -n "${ret_code}" ]] && unset -v ret_code;
            [[ -n "${java_cmd}" ]] && unset -v java_cmd;
            [[ -n "${portal_server_name}" ]] && unset -v portal_server_name;
            [[ -n "${portal_server_profile}" ]] && unset -v portal_server_profile;
            [[ -n "${portal_server}" ]] && unset -v portal_server;
        done
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${java_cmd}" ]] && unset -v java_cmd;
    [[ -n "${portal_server_name}" ]] && unset -v portal_server_name;
    [[ -n "${portal_server_profile}" ]] && unset -v portal_server_profile;
    [[ -n "${portal_server}" ]] && unset -v portal_server;
    [[ -n "${access_log_file}" ]] && unset -v access_log_file;
    [[ -n "${start_end_date}" ]] && unset -v start_end_date;
    [[ -n "${portal_server_list}" ]] && unset -v portal_server_list;
    [[ -n "${exclude_address_file}" ]] && unset -v exclude_address_file;
    [[ -n "${session_reporting_jar}" ]] && unset -v session_reporting_jar;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code}
)

#======  FUNCTION  ============================================================
#          NAME:  usage
#   DESCRIPTION:  Rotates log files in logs directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
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

    printf "%s %s\n" "${function_name}" "Collect session statistics using the HCL User Session Reporting tool." >&2;
    printf "%s %s\n" "Usage: ${function_name}" "[ options ]" >&2;
    printf "    %s: %s\n" "NOTE" "All configuration options are available in the configuration file, and may be overridden with the appropriate arguments." >&2;
    printf "    %s: %s\n" "--config | -c <configuration file>" "(Optional) Te location to an alternative configuration file for this utility. Default configuration file -> ${CONFIG_FILE_LOCATION}" >&2;
    printf "        %s: %s\n" "NOTE" "While this is an optional argument, it MUST be the first positional parameter to this application in order to properly load the various configuration options." >&2;
    printf "    %s: %s\n" "--collection-date | -c" "(Optional) The date to collect statistics for. Default value -> $(date -d "1 day ago" +"%Y-%m-%d")." >&2;
    printf "        %s: %s\n" "NOTE" "Date MUST be formatted YYYY-MM-DD." >&2;
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
        config|c)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "ARGUMENT_VALUE -> ${ARGUMENT_VALUE}";
            fi

            PROVIDED_CONFIG_FILE="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "PROVIDED_CONFIG_FILE -> ${PROVIDED_CONFIG_FILE}";
            fi

            ## make the selected config active and continue forward
            if [[ -n "${PROVIDED_CONFIG_FILE}" ]] && [[ "${PROVIDED_CONFIG_FILE}" != "${CONFIG_FILE_LOCATION}" ]] && [[ -r "${PROVIDED_CONFIG_FILE}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting WORKING_CONFIG_FILE...";
                fi

                WORKING_CONFIG_FILE="${PROVIDED_CONFIG_FILE}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WORKING_CONFIG_FILE -> ${WORKING_CONFIG_FILE}";
                fi

                if [[ -n "${WORKING_CONFIG_FILE}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Loading configuration file ${WORKING_CONFIG_FILE}";
                    fi

                    source "${WORKING_CONFIG_FILE}";
                else
                    RETURN_CODE=2;

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Unable to load provided configuration file ${PROVIDED_CONFIG_FILE}.";
                    fi
                fi
            fi
            ;;
        collection-date|c)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting TARGET_HOST...";
            fi

            COLLECTION_DATE="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_HOST -> ${TARGET_HOST}";
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
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "PROVIDED_CONFIG_FILE -> ${PROVIDED_CONFIG_FILE}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WORKING_CONFIG_FILE -> ${WORKING_CONFIG_FILE}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "COLLECTION_DATE -> ${COLLECTION_DATE}";
fi

if [[ -n "${RETURN_CODE}" ]] && (( RETURN_CODE != 0 )); then
    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "A non-zero return code has been detected prior to runtime. return_code -> ${return_code}, RETURN_CODE -> ${RETURN_CODE}";
    fi

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    if (( RETURN_CODE != 3 )); then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Found a non-zero return code prior to execution. Please review logs and parameters.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Found a non-zero return code prior to execution. Please review logs and parameters.";
        fi
    fi
else
    if [[ -z "${WORKING_CONFIG_FILE}" ]] || [[ ! -r "${WORKING_CONFIG_FILE}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Unable to find and/or read the configuration file supplied. Please ensure the file exists and can be read by the executing user.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Unable to find and/or read the configuration file supplied. Please ensure the file exists and can be read by the executing user.";
        fi

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

        RETURN_CODE="1";
    else
        if [[ -z "${COLLECTION_DATE}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Collection date not specified. Defaulting to $(date -d "1 day ago" +"%Y-%m-%d")";
            fi

            COLLECT_FOR_DATE="$(date -d "1 day ago" +"%Y-%m-%d")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "COLLECT_FOR_DATE -> ${COLLECT_FOR_DATE}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: collectSessionStats ${COLLECT_FOR_DATE}";
            fi

            collectSessionStats ${COLLECT_FOR_DATE};
        else
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: collectSessionStats ${COLLECTION_DATE}";
            fi

            collectSessionStats ${COLLECTION_DATE};
        fi

        RETURN_CODE="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETURN_CODE -> ${RETURN_CODE}";
        fi

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi
    fi
fi

[[ -n "${COLLECT_FOR_DATE}" ]] && unset -v COLLECT_FOR_DATE;
[[ -n "${COLLECTION_DATE}" ]] && unset -v COLLECTION_DATE;
[[ -n "${WORKING_CONFIG_FILE}" ]] && unset -v WORKING_CONFIG_FILE;
[[ -n "${PROVIDED_CONFIG_FILE}" ]] && unset -v PROVIDED_CONFIG_FILE;
[[ -n "${ARGUMENT_VALUE}" ]] && unset -v ARGUMENT_VALUE;
[[ -n "${ARGUMENT_NAME}" ]] && unset -v ARGUMENT_NAME;
[[ -n "${ARGUMENT}" ]] && unset -v ARGUMENT;
[[ -n "${ARG_COUNTER}" ]] && unset -v ARG_COUNTER;
[[ -n "${CNAME}" ]] && unset -v CNAME;
[[ -n "${FUNCTION_NAME}" ]] && unset -v FUNCTION_NAME;
[[ -n "${CONFIG_FILE_LOCATION}" ]] && unset -v CONFIG_FILE_LOCATION;

exit ${RETURN_CODE};
