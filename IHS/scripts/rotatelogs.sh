#!/usr/bin/env bash

#==============================================================================
#          FILE:  rotatelogs
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

trap 'set +v; set +x' INT TERM EXIT;

PATH="${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin";

## Application constants
ARG_COUNTER=0;
CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#startup";
SCRIPT_ROOT="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && printf "%s" "${PWD}")")";
LOGGING_PROPERTIES="${SCRIPT_ROOT}/etc/logging.properties";
CONFIG_FILE_LOCATION="${SCRIPT_ROOT}/etc/rotatelogs.conf";

## load the logger
if [[ -r "${SCRIPT_ROOT}/lib/system/logger.sh" ]] && [[ -s "${SCRIPT_ROOT}/lib/system/logger.sh" ]] && [[ -z "${LOGGING_LOADED}" ]]; then source "${SCRIPT_ROOT}/lib/system/logger.sh"; fi
if [[ -z "$(command -v "writeLogEntry" 2>/dev/null)" ]] || [[ -z "${LOGGING_LOADED}" ]] || [[ "${LOGGING_LOADED}" == "false" ]]; then printf "\e[00;31m%s\e[00;32m\n" "Failed to load logging configuration. No logging available!" >&2; LOGGING_LOADED="${_FALSE}"; fi;

if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
    start_epoch="$(date +"%s")";

    writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
fi

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
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "METHOD_NAME -> ${METHOD_NAME}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SCRIPT_ROOT -> ${SCRIPT_ROOT}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "CONFIG_FILE_LOCATION -> ${CONFIG_FILE_LOCATION}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WORKING_CONFIG_FILE -> ${WORKING_CONFIG_FILE}";
fi

#=====  FUNCTION  =============================================================
#          NAME:  rotateLogsOnLocalFilesystem
#   DESCRIPTION:  Rotates IHS logs on a local filesystem
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function rotateLogsOnLocalFilesystem()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="rotatelogs.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    for ihs_instance in (${IHS_INSTANCES[*]}); do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ihs_instance -> ${ihs_instance}";
        fi

        file_list=$(find ${IHS_LOGS_BASE}/${ihs_instance}/ -type f -mtime +${MAX_LOCAL_AGE});

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_list -> ${file_list}";
        fi

        for file_entry in ${file_list[*]}; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_entry -> ${file_entry}";
            fi

            file_name="$(basename "${file_entry}")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_name -> ${file_name}";
            fi

            tar -C /opt/IBM/HTTPServer/logs/${instance} -cvf - ./${file_name} | gzip > /opt/IBM/backups/${file_name}.tar.gz

            [[ -n "${file_name}" ]] && unset -v file_name;
            [[ -n "${file_entry}" ]] && unset -v file_entry;
        done

        [[ -n "${instance}" ]] && unset instance;
        [[ -n "${file_list}" ]] && unset file_list;
    done

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    [[ -n "${file_name}" ]] && unset -v file_name
    [[ -n "${file_entry}" ]] && unset -v file_entry
    [[ -n "${file_list}" ]] && unset -v file_list
    [[ -n "${ihs_instance}" ]] && unset -v ihs_instance

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  rotateLogsOnLocalFilesystem
#   DESCRIPTION:  Rotates IHS logs on a remote mounted filesystem
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function rotateLogsOnRemoteFilesystem()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="rotatelogs.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    ## TODO
    for instance in (instance-list); do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "instance -> ${instance}";
        fi

        file_list=$(find /opt/IBM/HTTPServer/logs/${instance}/ -type f -mtime +7);

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_list -> ${file_list}";
        fi

        for file_entry in ${file_list[*]}; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_entry -> ${file_entry}";
            fi

            file_name="$(basename "${file_entry}")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_name -> ${file_name}";
            fi

            tar -C /opt/IBM/HTTPServer/logs/${instance} -cvf - ./${file_name} | gzip > /opt/IBM/backups/${file_name}.tar.gz

            [[ -n "${file_name}" ]] && unset -v file_name;
            [[ -n "${file_entry}" ]] && unset -v file_entry;
        done

        [[ -n "${instance}" ]] && unset instance;
        [[ -n "${file_list}" ]] && unset file_list;
    done

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

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
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

    printf "%s %s\n" "${function_name}" "Rotate IHS logs on both local and remote filesystems." >&2;
    printf "%s %s\n" "Usage: ${function_name}" "[ options ]" >&2;
    printf "    %s: %s\n" "NOTE" "All configuration options are available in the configuration file, and may be overridden with the appropriate arguments." >&2;
    printf "    %s: %s\n" "--config | -c <configuration file>" "(Optional) Te location to an alternative configuration file for this utility. Default configuration file -> ${CONFIG_FILE_LOCATION}" >&2;
    printf "        %s: %s\n" "NOTE" "While this is an optional argument, it MUST be the first positional parameter to this application in order to properly load the various configuration options." >&2;
    printf "    %s: %s\n" "--instance-name | -i <instance>" "The IHS instance to rotate logs for. Required, no default value is provided." >&2;
    printf "    %s: %s\n" "--rotation-type | -c <rotation type>" "The type of rotation to perform. One of \"local\", \"remote\", or \"both\" Default value -> ${DEFAULT_ROTATION_TYPE}." >&2;
    printf "    %s: %s\n" "--max-age-on-local | -l <days>" "The maximum number of days to keep archive files on the local filesystem. Default value -> ${DEFAULT_LOCAL_MAX_AGE}" >&2;
    printf "    %s: %s\n" "--max-age-on-remote | -r <days>" "The maximum number of days to keep archive files on the remote filesystem. Default value -> ${DEFAULT_REMOTE_MAX_AGE}" >&2;
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
        instance-name|i)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting TARGET_INSTANCE...";
            fi

            TARGET_INSTANCE="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_INSTANCE -> ${TARGET_INSTANCE}";
            fi
            ;;
        rotation-type|r)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting TARGET_INSTANCE...";
            fi

            ROTATION_TYPE="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_INSTANCE -> ${TARGET_INSTANCE}";
            fi
            ;;
        max-age-on-local|l)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting MAX_LOCAL_AGE";
            fi

            MAX_LOCAL_AGE=${ARGUMENT_VALUE};

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "MAX_LOCAL_AGE -> ${MAX_LOCAL_AGE}";
            fi
            ;;
        max-age-on-remote|r)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting MAX_REMOTE_AGE...";
            fi

            MAX_REMOTE_AGE=${ARGUMENT_VALUE};

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "MAX_REMOTE_AGE -> ${MAX_REMOTE_AGE}";
            fi
            ;;
        help|\?|h)
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            usage;
            RETURN_CODE="${?}";

            set +o noclobber;
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
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_INSTANCE -> ${TARGET_INSTANCE}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "ROTATION_TYPE -> ${ROTATION_TYPE}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "MAX_LOCAL_AGE -> ${MAX_LOCAL_AGE}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "MAX_REMOTE_AGE -> ${MAX_REMOTE_AGE}";
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
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Unable to find and/or read the configuration file supplied. Please ensure the file exists and can be read by the executing user.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Unable to find and/or read the configuration file supplied. Please ensure the file exists and can be read by the executing user.";
        fi

        if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
        if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi
    else
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main";
        fi

        if [[ -z "${TARGET_INSTANCE}" ]]; then
            ## error out, we need an instance to rotate for
            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "No instance was provided and no default is available.";
                writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "No instance was provided and no default is available.";
            fi

            ret_code=1;
        else
            [[ -z "${ROTATION_TYPE}" ]] && ROTATION_TYPE="${ROTATION_TYPE_DEFAULT}";
            [[ -z "${MAX_LOCAL_AGE}" ]] && MAX_LOCAL_AGE="${DEFAULT_LOCAL_MAX_AGE}";
            [[ -z "${MAX_REMOTE_AGE}" ]] && MAX_REMOTE_AGE="${DEFAULT_REMOTE_MAX_AGE}";

            case "${ROTATION_TYPE}" in
                "${ROTATION_TYPE_LOCAL}")
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Starting rotation type ${ROTATION_TYPE_LOCAL}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: rotateLogsOnLocalFilesystem";
                    fi

                    [[ -n "${CNAME}" ]] && unset -v CNAME;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    rotateLogsOnLocalFilesystem;
                    ret_code="${?}";

                    CNAME="$(basename "${BASH_SOURCE[0]}")";
                    function_name="${CNAME}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_LOCAL} FAILED. Please review logs.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_LOCAL} FAILED. Please review logs.";
                        fi
                    else
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_LOCAL} has completed successfully.";
                            writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_LOCAL} has completed successfully.";
                        fi
                    fi
                    ;;
                "${ROTATION_TYPE_REMOTE}")
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Starting rotation type ${ROTATION_TYPE_REMOTE}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: rotateLogsOnRemoteFilesystem";
                    fi

                    [[ -n "${CNAME}" ]] && unset -v CNAME;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    rotateLogsOnRemoteFilesystem;
                    ret_code="${?}";

                    CNAME="$(basename "${BASH_SOURCE[0]}")";
                    function_name="${CNAME}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_REMOTE} FAILED. Please review logs.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_REMOTE} FAILED. Please review logs.";
                        fi
                    else
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_REMOTE} has completed successfully.";
                            writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_REMOTE} has completed successfully.";
                        fi
                    fi
                    ;;
                "${ROTATION_TYPE_BOTH}")
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Starting rotation type ${ROTATION_TYPE_LOCAL}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: rotateLogsOnLocalFilesystem";
                    fi

                    [[ -n "${CNAME}" ]] && unset -v CNAME;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    rotateLogsOnLocalFilesystem;
                    ret_code="${?}";

                    CNAME="$(basename "${BASH_SOURCE[0]}")";
                    function_name="${CNAME}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_LOCAL} FAILED. Please review logs.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_LOCAL} FAILED. Please review logs.";
                        fi
                    else
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_LOCAL} has completed successfully.";
                            writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_LOCAL} has completed successfully.";
                        fi
                    fi

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Starting rotation type ${ROTATION_TYPE_REMOTE}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: rotateLogsOnRemoteFilesystem";
                    fi

                    [[ -n "${CNAME}" ]] && unset -v CNAME;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    rotateLogsOnRemoteFilesystem;
                    ret_code="${?}";

                    CNAME="$(basename "${BASH_SOURCE[0]}")";
                    function_name="${CNAME}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_REMOTE} FAILED. Please review logs.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_REMOTE} FAILED. Please review logs.";
                        fi
                    else
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_REMOTE} has completed successfully.";
                            writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Execution of ${ROTATION_TYPE_REMOTE} has completed successfully.";
                        fi
                    fi
                    ;;
                *)
                    (( error_count += 1 ));

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "No rotation type was specified.";
                        writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "No rotation type was specified.";
                    fi
                    ;;
            esac
        fi
    fi
fi

if [[ -n "${error_count}" ]] && (( error_count != 0 )); then RETURN_CODE="${error_count}"; fi

if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETURN_CODE -> ${RETURN_CODE}";
    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} -> exit";
fi

if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
    end_epoch="$(date +"%s")"
    runtime=$(( end_epoch - start_epoch ));

    writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
    writeLogEntry "FILE" "PERFORMANCE" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "${FUNCTION_NAME} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

[[ -n "${CNAME}" ]] && unset -v CNAME;
[[ -n "${SCRIPT_ROOT}" ]] && unset -v SCRIPT_ROOT;
[[ -n "${METHOD_NAME}" ]] && unset -v METHOD_NAME;
[[ -n "${CONFIG_FILE_LOCATION}" ]] && unset -v CONFIG_FILE_LOCATION;
[[ -n "${WORKING_CONFIG_FILE}" ]] && unset -v WORKING_CONFIG_FILE;
[[ -n "${ARGUMENT}" ]] && unset -v ARGUMENT;
[[ -n "${ARGUMENT_NAME}" ]] && unset -v ARGUMENT_NAME;
[[ -n "${ARGUMENT_VALUE}" ]] && unset -v ARGUMENT_VALUE;
[[ -n "${PROVIDED_CONFIG_FILE}" ]] && unset -v PROVIDED_CONFIG_FILE;
[[ -n "${RETURN_CODE}" ]] && unset -v RETURN_CODE;
[[ -n "${TARGET_INSTANCE}" ]] && unset -v TARGET_INSTANCE;
[[ -n "${SSH_PORT_NUMBER}" ]] && unset -v SSH_PORT_NUMBER;
[[ -n "${MAX_LOCAL_AGE}" ]] && unset -v MAX_LOCAL_AGE;
[[ -n "${MAX_REMOTE_AGE}" ]] && unset -v MAX_REMOTE_AGE;

exit ${RETURN_CODE};
