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

## load the logger
if [[ -r "/usr/local/bin/logger.sh" ]] && [[ -s "/usr/local/bin/logger.sh" ]]; then
    source "/usr/local/bin/logger.sh"; ## if its here, use it
elif [[ -r "${HOME}/lib/system/logger.sh" ]] && [[ -s "${HOME}/lib/system/logger.sh" ]]; then
    source "${HOME}/lib/system/logger.sh"; ## if its here, override the above and use it
elif [[ -r "${SCRIPT_ROOT}/lib/system/logger.sh" ]] && [[ -s "${SCRIPT_ROOT}/lib/system/logger.sh" ]]; then
    source "${SCRIPT_ROOT}/lib/system/logger.sh"; ## if its here, override the above and use it
else 
    printf "\e[00;31m%s\e[00;32m\n" "Unable to load logger. No logging enabled!" >&2;
fi

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

## Application constants
ARG_COUNTER=0;
ERROR_COUNT=0;
CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#startup";
SCRIPT_ROOT="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && printf "%s" "${PWD}")")";
DEFAULT_CONFIG_FILE="${SCRIPT_ROOT}/properties/servercontrol.properties";

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

    set +o noclobber;
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

	(( ${#} < 2 )) && return 3;

    profile_name="${1}";
    server_name="${2}";
    action_name="${3}";
    watch_for_file="${4}";
    sleep_count="${5}";
    retry_count="${6}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "server_name -> ${server_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "action_name -> ${action_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_for_file -> ${watch_for_file}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "sleep_count -> ${sleep_count}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "retry_count -> ${retry_count}";
    fi

    case "${action_name}" in
        [Ss][Tt][Aa][Rr][Tt][Uu][Pp]|[Ss][Tt][Aa][Rr][Tt])
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                 writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: startApplicationServer ${profile_name} ${server_name} ${watch_for_file} ${sleep_count} ${retry_count}";
            fi

            [[ -n "${CNAME}" ]] && unset -v CNAME;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            startApplicationServer "${profile_name}" "${server_name}" "${watch_for_file}" "${sleep_count}" "${retry_count}";
            ret_code="${?}";

            CNAME="$(basename "${BASH_SOURCE[0]}")";
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

            [[ -n "${CNAME}" ]] && unset -v CNAME;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            stopApplicationServer "${profile_name}" "${server_name}" "${watch_for_file}" "${sleep_count}" "${retry_count}";
            ret_code="${?}";

            CNAME="$(basename "${BASH_SOURCE[0]}")";
            function_name="${CNAME}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

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
            (( error_count += 1 ));

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "An unknown action was provided. action_name -> ${action_name}";
            fi
            ;;
    esac

    (( error_count == 0 )) && return_code="${error_count}";

    [[ -n "${profile_name}" ]] && unset -v profile_name;
    [[ -n "${server_name}" ]] && unset -v server_name;
    [[ -n "${action_name}" ]] && unset -v action_name;
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
#          NAME:  startApplicationServer
#   DESCRIPTION:  Stops a provided WebSphere Application Server
#    PARAMETERS:  WAS Profile name, WAS Application Server name
#       RETURNS:  0 if no errors/timeouts occurred, otherwise dependent on variables
#==============================================================================
function startApplicationServer()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
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

    (( ${#} < 2 )) && return 3;

	profile_name="${1}";
	appserver_name="${2}";
    filewatch="${3}";

    if [[ -n "${filewatch}" ]] && [[ -z "${4}" ]]; then wait_time="${DEFAULT_WAIT_TIME}"; else wait_time="${4}"; fi
    if [[ -n "${filewatch}" ]] && [[ -z "${5}" ]]; then retry_count="${DEFAULT_RETRY_COUNT}"; else retry_count="${5}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "appserver_name -> ${appserver_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "filewatch -> ${filewatch}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "wait_time -> ${wait_time}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "retry_count -> ${retry_count}";
    fi

	if [[ -d "${PROFILE_ROOT}/${profile_name}" ]]; then
		if [[ -s "${PROFILE_ROOT}/${profile_name}/bin/setupCmdLine.sh" ]]; then
			if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: ${PROFILE_ROOT}/${profile_name}/bin/setupCmdLine.sh";
			fi

			source ${PROFILE_ROOT}/${profile_name}/bin/setupCmdLine.sh;

			if [[ -n "${USER_INSTALL_ROOT}" ]]; then
				if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: ${USER_INSTALL_ROOT}/bin/startServer.sh ${appserver_name}";
				fi

				if [[ -n "${filewatch}" ]]; then
                    waitForProcessFile "${filewatch}" "${wait_time}" "${retry_count}";
                    ret_code="${?}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Process execution failed, ${filewatch} was not found after ${wait_time} over number of tries ${retry_count}";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Process execution failed, ${filewatch} was not found after ${wait_time} over number of tries ${retry_count}";
                        fi

                        (( error_count += 1 ));
                    fi
                fi

                if [[ -z "${error_count}" ]] || (( error_count == 0 )); then
                    tmpfile=$(mktemp);

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    [[ -f "${tmpfile}" ]] && cat /dev/null >| ${tmpfile};

                    ${USER_INSTALL_ROOT}/bin/startServer.sh ${appserver_name} | tee ${tmpfile};
                    watchProvidedProcess ${!};
                    ret_code=${?};

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        return_code="${ret_code}";

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Return code from startServer.sh was non-zero. Return code -> ${ret_code}";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Return code from startServer.sh was non-zero. Return code -> ${ret_code}";
                        else
                            if [[ -n "$(grep -E "(ADMU0508I|STARTED)" ${tmpfile})" ]]; then
                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} has been started successfully.";
                                    writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} has been started successfully.";
                                fi
                            else
                                (( error_count != 1 ));

                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} could not be started.";
                                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} could not be started.";
                                fi
                            fi
                        fi
                    else
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server startup for ${appserver_name} timed out and was not successfully completed. Please review logs.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server startup for ${appserver_name} timed out and was not successfully completed. Please review logs.";
                        fi
                    fi
                fi
			else
				(( error_count != 1 ));

				if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
					writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
				fi
            fi
		else
			(( error_count += 1 ));

			if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Unable to locate setupCmdLine.sh in ${PROFILE_ROOT}/${profile_name}. Cannot continue.";
				writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Unable to locate setupCmdLine.sh in ${PROFILE_ROOT}/${profile_name}. Cannot continue.";
			fi
		fi
	else
		if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Provided profile ${profile_name} does not exist in ${PROFILE_ROOT}";
			writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Provided profile ${profile_name} does not exist in ${PROFILE_ROOT}";
		fi
	fi

	[[ -f "${tmpfile}" ]] && rm -f "${tmpfile}";

	[[ -n "${profile_name}" ]] && unset -v profile_name;
	[[ -n "${appserver_name}" ]] && unset -v appserver_name;
	[[ -n "${tmpfile}" ]] && unset -v tmpfile;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    (( error_count != 0 )) && return_code="${error_count}";

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
#          NAME:  stopApplicationServer
#   DESCRIPTION:  Stops a provided WebSphere Application Server
#    PARAMETERS:  WAS Profile name, WAS Application Server name
#       RETURNS:  0 if no errors/timeouts occurred, otherwise dependent on variables
#==============================================================================
function stopApplicationServer()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
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

    (( ${#} < 2 )) && return 3;

	profile_name="${1}";
	appserver_name="${2}";
    filewatch="${3}";

    if [[ -n "${filewatch}" ]] && [[ -z "${4}" ]]; then wait_time="${DEFAULT_WAIT_TIME}"; else wait_time="${4}"; fi
    if [[ -n "${filewatch}" ]] && [[ -z "${5}" ]]; then retry_count="${DEFAULT_RETRY_COUNT}"; else retry_count="${5}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "appserver_name -> ${appserver_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "filewatch -> ${filewatch}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "wait_time -> ${wait_time}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "retry_count -> ${retry_count}";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
		writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "appserver_name -> ${appserver_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
    fi

	if [[ -d "${PROFILE_ROOT}/${profile_name}" ]]; then
		if [[ -s "${PROFILE_ROOT}/${profile_name}/bin/setupCmdLine.sh" ]]; then
			if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: ${PROFILE_ROOT}/${profile_name}/bin/setupCmdLine.sh";
			fi

			source ${PROFILE_ROOT}/${profile_name}/bin/setupCmdLine.sh;

			if [[ -n "${USER_INSTALL_ROOT}" ]]; then
				if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: ${USER_INSTALL_ROOT}/bin/startServer.sh ${appserver_name}";
				fi

				if [[ -n "${watch_for_file}" ]] && [[ "${watch_for_file}" == "${_TRUE}" ]]; then
                    waitForProcessFile "${PROCESS_WATCH_FILE}" "${wait_time}" "${retry_count}";
                    ret_code="${?}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Process execution failed, ${PROCESS_WATCH_FILE} was not found after ${wait_time} over number of tries ${retry_count}";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Process execution failed, ${PROCESS_WATCH_FILE} was not found after ${wait_time} over number of tries ${retry_count}";
                        fi

                        (( error_count += 1 ));
                    fi
                fi

                if [[ -z "${error_count}" ]] || (( error_count == 0 )); then
                    tmpfile=$(mktemp);

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    [[ -f "${tmpfile}" ]] && cat /dev/null >| ${tmpfile};

                    ${USER_INSTALL_ROOT}/bin/stopServer.sh ${appserver_name} | tee ${tmpfile};
                    watchProvidedProcess ${!};
                    ret_code=${?};

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        return_code="${ret_code}";

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Return code from stopServer.sh was non-zero. Return code -> ${ret_code}";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Return code from stopServer.sh was non-zero. Return code -> ${ret_code}";
                        else
                            if [[ -n "$(grep -E "(ADMU0509I|STOPPED)" ${tmpfile})" ]]; then
                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} has been stopped successfully.";
                                    writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} has been stopped successfully.";
                                fi
                            else
                                (( error_count != 1 ));

                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} could not be stopped.";
                                    writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} could not be stopped.";
                                fi
                            fi
                        fi
                    else
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server shutdown for ${appserver_name} timed out and was not successfully completed. Please review logs.";
                            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server shutdown for ${appserver_name} timed out and was not successfully completed. Please review logs.";
                        fi
                    fi
                fi
			else
				(( error_count != 1 ));

				if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
					writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
				fi
            fi
		else
			(( error_count += 1 ));

			if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
				writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Unable to locate setupCmdLine.sh in ${PROFILE_ROOT}/${profile_name}. Cannot continue.";
				writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Unable to locate setupCmdLine.sh in ${PROFILE_ROOT}/${profile_name}. Cannot continue.";
			fi
		fi
	else
		if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
			writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Provided profile ${profile_name} does not exist in ${PROFILE_ROOT}";
			writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Provided profile ${profile_name} does not exist in ${PROFILE_ROOT}";
		fi
	fi

	[[ -f "${tmpfile}" ]] && rm -f "${tmpfile}";

	[[ -n "${profile_name}" ]] && unset -v profile_name;
	[[ -n "${appserver_name}" ]] && unset -v appserver_name;
	[[ -n "${tmpfile}" ]] && unset -v tmpfile;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    (( error_count != 0 )) && return_code="${error_count}";

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
    printf "    %s: %s\n" "Optional" "--profilename | -p <profile>: The target WebSphere Application Server profile. Default value -> ${DEFAULT_WAS_PROFILE}." >&2;
    printf "    %s: %s\n" "Optional, required if a server name was not provided" "--serverlist </path/to/file | -l </path/to/file>: A list of servers to action against." >&2;
    printf "            %s: %s\n" "server name" "The minimum required content, each server seperated by a newline." >&2;
    printf "                %s: %s\n" "profile name" "The profile for the provided server. Seperated by a colon (\":\") from the server name. If not provided the default value is ${DEFAULT_PROFILE_NAME}" >&2;
    printf "                %s: %s\n" "wait file" "A file to wait for prior to starting execution. Optional, if provided must be seperated by a colon (\":\") from the profile name. No default is provided" >&2;
    printf "                %s: %s\n" "sleep time" "If a wait file is provided, the time to sleep between iterations looking for the file. Optional, if provided must be seperated by a colon (\":\") from the wait file. If not provided the default is ${DEFAULT_SLEEP_TIME}" >&2;
    printf "                %s: %s\n" "retry count" "If a wait file is provided, the number of iterations to look for the file. Optional, if provided must be seperated by a colon (\":\") from the sleep count. If not provided the default is ${DEFAULT_RETRY_COUNT}" >&2;
    printf "    %s: %s\n" "Optional, required if a server list was not provided" "--servername <server> | -s <server>: The WebSphere Application Server to action against." >&2;
    printf "        %s: %s\n" "NOTE" "The argument for server name can be formatted in the following ways:" >&2;
    printf "            %s: %s\n" "server name" "The minimum required content, each server seperated by the pipe character (\"|\")" >&2;
    printf "                %s: %s\n" "profile name" "The profile for the provided server. Seperated by a colon (\":\") from the server name. If not provided the default value is ${DEFAULT_PROFILE_NAME}" >&2;
    printf "                %s: %s\n" "wait file" "A file to wait for prior to starting execution. Optional, if provided must be seperated by a colon (\":\") from the profile name. No default is provided" >&2;
    printf "                %s: %s\n" "sleep time" "If a wait file is provided, the time to sleep between iterations looking for the file. Optional, if provided must be seperated by a colon (\":\") from the wait file. If not provided the default is ${DEFAULT_SLEEP_TIME}" >&2;
    printf "                %s: %s\n" "retry count" "If a wait file is provided, the number of iterations to look for the file. Optional, if provided must be seperated by a colon (\":\") from the sleep count. If not provided the default is ${DEFAULT_RETRY_COUNT}" >&2;
    printf "    %s: %s\n" "Optional" "--wait </path/to/file> | -w </path/to/file>: Wait for a provided file to exist before executing the desired action." >&2;
    printf "    %s: %s\n" "Optional, required of a file was provided to wait for" "--sleep <time> | -s <time>: Time to wait for the wait file to appear." >&2;
    printf "    %s: %s\n" "Optional, required of a file was provided to wait for" "--retries <count> | -r <count>: How many times to check for the file." >&2;
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
        profilename|p)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting TARGET_PROFILE...";
            fi

            TARGET_PROFILE="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_PROFILE -> ${TARGET_PROFILE}";
            fi
            ;;
        serverlist|l)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting SERVER_LIST";
            fi

            SERVER_LIST="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SERVER_LIST -> ${SERVER_LIST}";
            fi
            ;;
        servername|s)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting TARGET_SERVER";
            fi

            TARGET_SERVER="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_SERVER -> ${TARGET_SERVER}";
            fi
            ;;
        wait|w)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting WATCH_FOR_FILE";
            fi

            WATCH_FOR_FILE="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WATCH_FOR_FILE -> ${WATCH_FOR_FILE}";
            fi
            ;;
        sleep|s)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting SLEEP_TIME";
            fi

            SLEEP_TIME="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SLEEP_TIME -> ${SLEEP_TIME}";
            fi
            ;;
        retries|r)
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Setting RETRY_COUNT";
            fi

            RETRY_COUNT="${ARGUMENT_VALUE}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETRY_COUNT -> ${RETRY_COUNT}";
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
    ## we have this here because of the possibility of a different config file other than the default being used
    if [[ -n "${USER_LIB_PATH}" ]] && [[ -d "${USER_LIB_PATH}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Found library directory ${USER_LIB_PATH}";
        fi

        for LIBENTRY in "${USER_LIB_PATH}"/*.sh; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "LIBENTRY -> ${LIBENTRY}";
            fi

            [[ -z "${LIBENTRY}" ]] && continue;

            if [[ -r "${LIBENTRY}" ]] && [[ -s "${LIBENTRY}" ]]; then source "${LIBENTRY}"; fi

            [[ -n "${LIBENTRY}" ]] && unset -v LIBENTRY;
        done
    fi

    if [[ -n "${SERVER_LIST}" ]] && [[ -s "${SERVER_LIST}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "Loading data from ${SERVER_LIST}";
        fi

        for SERVER_ENTRY in $(< "${SERVER_LIST}"); do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SERVER_ENTRY -> ${SERVER_ENTRY}";
            fi

            [[ -z "${SERVER_ENTRY}" ]] && continue;
            [[ "${SERVER_ENTRY}" =~ ^\# ]] && continue;

            TARGET_SERVER="$(cut -d ":" -f 1 <<< "${SERVER_ENTRY}")";
            TARGET_PROFILE="$(cut -d ":" -f 2 <<< "${SERVER_ENTRY}")";
            WATCH_FOR_FILE="$(cut -d ":" -f 3 <<< "${SERVER_ENTRY}")";
            SLEEP_TIME="$(cut -d ":" -f 4 <<< "${SERVER_ENTRY}")";
            RETRY_COUNT="$(cut -d ":" -f 5 <<< "${SERVER_ENTRY}")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_SERVER -> ${TARGET_SERVER}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_PROFILE -> ${TARGET_PROFILE}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WATCH_FOR_FILE -> ${WATCH_FOR_FILE}";
            fi

            [[ -z "${TARGET_SERVER}" ]] && TARGET_SERVER="${DEFAULT_SERVER_NAME}";
            [[ -z "${TARGET_PROFILE}" ]] && TARGET_PROFILE="${DEFAULT_PROFILE_NAME}";

            if [[ -n "${WATCH_FOR_FILE}" ]]; then
                [[ -z "${SLEEP_TIME}" ]] && SLEEP_TIME="${DEFAULT_SLEEP_TIME}";
                [[ -z "${RETRY_COUNT}" ]] && RETRY_COUNT="${DEFAULT_RETRY_COUNT}";
            fi

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SLEEP_TIME -> ${SLEEP_TIME}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETRY_COUNT -> ${RETRY_COUNT}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main ${TARGET_ACTION} ${PROFILE_NAME} ${SERVER_ENTRY} ${WATCH_FOR_FILE} ${SLEEP_TIME} ${RETRY_COUNT}";
            fi

            main "${TARGET_ACTION}" "${TARGET_PROFILE}" "${TARGET_SERVER}" "${WATCH_FOR_FILE}" "${SLEEP_TIME}" "${RETRY_COUNT}";
            RET_CODE="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RET_CODE -> ${RET_CODE}";
            fi

            if [[ -z "${RET_CODE}" ]] || (( RET_CODE != 0 )); then (( ERROR_COUNT +=1 )); fi

            [[ -n "${TARGET_SERVER}" ]] && unset -v TARGET_SERVER;
            [[ -n "${TARGET_PROFILE}" ]] && unset -v TARGET_PROFILE;
            [[ -n "${WATCH_FOR_FILE}" ]] && unset -v WATCH_FOR_FILE;
            [[ -n "${SLEEP_TIME}" ]] && unset -v SLEEP_TIME;
            [[ -n "${RETRY_COUNT}" ]] && unset -v RETRY_COUNT;
            [[ -n "${SERVER_ENTRY}" ]] && unset -v SERVER_ENTRY;
        done
    else
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main ${TARGET_ACTION} ${PROFILE_NAME} ${TARGET_SERVER}";
        fi

        if [[ "${TARGET_SERVER}" =~ "|" ]] && (( $(grep -o "|" <<< "${TARGET_SERVER}" | wc -l) != 1 )); then
            mapfile -d "|" SERVER_LIST <<< "${TARGET_SERVER}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SERVER_LIST -> ${SERVER_LIST}";
            fi

            for SERVER_ENTRY in $(${SERVER_LIST[@]}); do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SERVER_ENTRY -> ${SERVER_ENTRY}";
                fi

                TARGET_SERVER="$(cut -d ":" -f 1 <<< "${SERVER_ENTRY}")";
                TARGET_PROFILE="$(cut -d ":" -f 2 <<< "${SERVER_ENTRY}")";
                WATCH_FOR_FILE="$(cut -d ":" -f 3 <<< "${SERVER_ENTRY}")";
                SLEEP_TIME="$(cut -d ":" -f 4 <<< "${SERVER_ENTRY}")";
                RETRY_COUNT="$(cut -d ":" -f 5 <<< "${SERVER_ENTRY}")";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_SERVER -> ${TARGET_SERVER}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_PROFILE -> ${TARGET_PROFILE}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WATCH_FOR_FILE -> ${WATCH_FOR_FILE}";
                fi

                if [[ -n "${WATCH_FOR_FILE}" ]]; then
                    [[ -z "${SLEEP_TIME}" ]] && SLEEP_TIME="${DEFAULT_SLEEP_TIME}";
                    [[ -z "${RETRY_COUNT}" ]] && RETRY_COUNT="${DEFAULT_RETRY_COUNT}";
                fi

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SLEEP_TIME -> ${SLEEP_TIME}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETRY_COUNT -> ${RETRY_COUNT}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main ${TARGET_ACTION} ${PROFILE_NAME} ${TARGET_SERVER} ${WATCH_FOR_FILE} ${SLEEP_TIME} ${RETRY_COUNT}";
                fi

                main "${TARGET_ACTION}" "${PROFILE_NAME}" "${TARGET_SERVER}" "${WATCH_FOR_FILE}" "${SLEEP_TIME}" "${RETRY_COUNT}"
                RET_CODE="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RET_CODE -> ${RET_CODE}";
                fi

                if [[ -z "${RET_CODE}" ]] || (( RET_CODE != 0 )); then (( ERROR_COUNT +=1 )); fi

                [[ -n "${TARGET_SERVER}" ]] && unset -v TARGET_SERVER;
                [[ -n "${TARGET_PROFILE}" ]] && unset -v TARGET_PROFILE;
                [[ -n "${WATCH_FOR_FILE}" ]] && unset -v WATCH_FOR_FILE;
                [[ -n "${SLEEP_TIME}" ]] && unset -v SLEEP_TIME;
                [[ -n "${RETRY_COUNT}" ]] && unset -v RETRY_COUNT;
                [[ -n "${SERVER_ENTRY}" ]] && unset -v SERVER_ENTRY;
            done
        else
            TARGET_SERVER="$(cut -d ":" -f 1 <<< "${SERVER_ENTRY}")";
            TARGET_PROFILE="$(cut -d ":" -f 2 <<< "${SERVER_ENTRY}")";
            WATCH_FOR_FILE="$(cut -d ":" -f 3 <<< "${SERVER_ENTRY}")";
            SLEEP_TIME="$(cut -d ":" -f 4 <<< "${SERVER_ENTRY}")";
            RETRY_COUNT="$(cut -d ":" -f 5 <<< "${SERVER_ENTRY}")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_SERVER -> ${TARGET_SERVER}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_PROFILE -> ${TARGET_PROFILE}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "WATCH_FOR_FILE -> ${WATCH_FOR_FILE}";
            fi

            if [[ -n "${WATCH_FOR_FILE}" ]]; then
                [[ -z "${SLEEP_TIME}" ]] && SLEEP_TIME="${DEFAULT_SLEEP_TIME}";
                [[ -z "${RETRY_COUNT}" ]] && RETRY_COUNT="${DEFAULT_RETRY_COUNT}";
            fi

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "SLEEP_TIME -> ${SLEEP_TIME}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETRY_COUNT -> ${RETRY_COUNT}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main ${TARGET_ACTION} ${PROFILE_NAME} ${TARGET_SERVER} ${WATCH_FOR_FILE} ${SLEEP_TIME} ${RETRY_COUNT}";
            fi

            main "${TARGET_ACTION}" "${PROFILE_NAME}" "${TARGET_SERVER}" "${WATCH_FOR_FILE}" "${SLEEP_TIME}" "${RETRY_COUNT}"
            RET_CODE="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RET_CODE -> ${RET_CODE}";
            fi

            if [[ -z "${RET_CODE}" ]] || (( RET_CODE != 0 )); then (( ERROR_COUNT +=1 )); fi

            [[ -n "${TARGET_SERVER}" ]] && unset -v TARGET_SERVER;
            [[ -n "${TARGET_PROFILE}" ]] && unset -v TARGET_PROFILE;
            [[ -n "${WATCH_FOR_FILE}" ]] && unset -v WATCH_FOR_FILE;
            [[ -n "${SLEEP_TIME}" ]] && unset -v SLEEP_TIME;
            [[ -n "${RETRY_COUNT}" ]] && unset -v RETRY_COUNT;
            [[ -n "${SERVER_ENTRY}" ]] && unset -v SERVER_ENTRY;
        fi
    fi

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
