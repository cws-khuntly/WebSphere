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
if [[ -r "${SCRIPT_ROOT}/lib/system/logger.sh" ]] && [[ -s "${SCRIPT_ROOT}/lib/system/logger.sh" ]] && [[ -z "${LOGGING_LOADED}" ]]; then source "${SCRIPT_ROOT}/lib/system/logger.sh"; fi
if [[ -z "$(command -v "writeLogEntry" 2>/dev/null)" ]] || [[ -z "${LOGGING_LOADED}" ]] || [[ "${LOGGING_LOADED}" == "false" ]]; then printf "\e[00;31m%s\e[00;32m\n" "Failed to load logging configuration. No logging available!" >&2; LOGGING_LOADED="${_FALSE}"; fi;

if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

## Application constants
ARG_COUNTER=0;
ERROR_COUNT=0;
CNAME="$(basename "${BASH_SOURCE[0]}")";
FUNCTION_NAME="${CNAME}#startup";
SCRIPT_ROOT="$(dirname "$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && printf "%s" "${PWD}")")";
DEFAULT_PROFILE_NAME="AppSrv";
DEFAULT_SERVER_NAME="AppSrv01";

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

	(( ${#} != 2 )) && return 3;

    target_action="${1}";
    profile_name="${2}";
    server_name="${3}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "target_action -> ${target_action}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${server_name}" "profile_name -> ${server_name}";
    fi

    case "${target_action}" in
        [Ss][Tt][Aa][Rr][Tt][Uu][Pp]|[Ss][Tt][Aa][Rr][Tt])
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                 writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: startApplicationServer ${profile_name} ${server_name}";
            fi

            [[ -n "${CNAME}" ]] && unset -v CNAME;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            startApplicationServer "${profile_name}" "${server_name}";
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
                 writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: stopApplicationServer ${profile_name} ${server_name}";
            fi

            [[ -n "${CNAME}" ]] && unset -v CNAME;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            stopApplicationServer "${profile_name}" "${server_name}";
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
                writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "An unknown action was provided. TARGET_ACTION -> ${TARGET_ACTION}";
            fi
            ;;
    esac

    if [[ -z "${error_count}" ]] || (( error_count == 0 )); then
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${target_action} for server ${server_name} has completed successfully.";
            writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${target_action} for server ${server_name} has completed successfully.";
        fi
    else
        return_code="${error_count}"

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${target_action} for server ${server_name} failed. Please review logs.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${target_action} for server ${server_name} failed. Please review logs.";
        fi
    fi

    [[ -n "${profile_name}" ]] && unset -v profile_name;
    [[ -n "${server_name}" ]] && unset -v server_name;
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

	profile_name="${1}";
	appserver_name="${2}";

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

				tmpfile=$(mktemp);

				${USER_INSTALL_ROOT}/bin/startServer.sh ${appserver_name} | tee ${tmpfile};
                watchProvidedProcess ${!};
				ret_code=${?};

				if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
				fi

				if (( ret_code != 0 )); then
					(( error_count != 1 ));

					if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
						writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Return code from startServer.sh was non-zero. Return code -> ${ret_code}";
						writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Return code from startServer.sh was non-zero. Return code -> ${ret_code}";
					fi
				else
					if [[ -n $(grep ("ADMU0508I|STARTED") ${tmpfile}) ]]; then
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
				(( error_count != 1 ));

				if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
					writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
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

    if [[ -z "${error_count}" ]] || (( error_count == 0 )); then
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host ${TARGET_HOST} as user ${TARGET_USER} has completed successfully.";
            writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host ${TARGET_HOST} as user ${TARGET_USER} has completed successfully.";
        fi
    else
        return_code="${error_count}"

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "An error occurred while processing action ${TARGET_ACTION} on host ${TARGET_HOST} as user ${TARGET_USER}. Please review logs.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "An error occurred while processing action ${TARGET_ACTION} on host ${TARGET_HOST} as user ${TARGET_USER}. Please review logs.";
        fi
    fi

	[[ -f "${tmpfile}" ]] && rm -f "${tmpfile}";

	[[ -n "${profile_name}" ]] && unset -v profile_name;
	[[ -n "${appserver_name}" ]] && unset -v appserver_name;
	[[ -n "${tmpfile}" ]] && unset -v tmpfile;
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

	profile_name="${1}";
	appserver_name="${2}";

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
					writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: ${USER_INSTALL_ROOT}/bin/stopServer.sh ${appserver_name}";
				fi

				tmpfile=$(mktemp);

				${USER_INSTALL_ROOT}/bin/stopServer.sh ${appserver_name} | tee ${tmpfile};
                watchProvidedProcess ${!};
				ret_code=${?};

				if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
				fi

				if (( ret_code != 0 )); then
					(( error_count != 1 ));

					if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
						writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Return code from stopServer.sh was non-zero. Return code -> ${ret_code}";
						writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Return code from stopServer.sh was non-zero. Return code -> ${ret_code}";
					fi
				else
					if [[ -n $(grep ("ADMU0509I|STOPPED") ${tmpfile}) ]]; then
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
				(( error_count != 1 ));

				if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
					writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
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

    if [[ -z "${error_count}" ]] || (( error_count == 0 )); then
        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host ${TARGET_HOST} as user ${TARGET_USER} has completed successfully.";
            writeLogEntry "CONSOLE" "STDOUT" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "${TARGET_ACTION} on host ${TARGET_HOST} as user ${TARGET_USER} has completed successfully.";
        fi
    else
        return_code="${error_count}"

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "An error occurred while processing action ${TARGET_ACTION} on host ${TARGET_HOST} as user ${TARGET_USER}. Please review logs.";
            writeLogEntry "CONSOLE" "STDERR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "An error occurred while processing action ${TARGET_ACTION} on host ${TARGET_HOST} as user ${TARGET_USER}. Please review logs.";
        fi
    fi

	[[ -f "${tmpfile}" ]] && rm -f "${tmpfile}";

	[[ -n "${profile_name}" ]] && unset -v profile_name;
	[[ -n "${appserver_name}" ]] && unset -v appserver_name;
	[[ -n "${tmpfile}" ]] && unset -v tmpfile;
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
    printf "    %s: %s\n" "Optional" "--config | -c <configuration file>: The location to an alternative configuration file for this utility. Default configuration file -> ${CONFIG_FILE_LOCATION}" >&2;
    printf "        %s: %s\n" "NOTE" "While this is an optional argument, it MUST be the first positional parameter to this application in order to properly load the various configuration options." >&2;
    printf "    %s: %s\n" "Required" "--profilename | -p <profile>: The target WebSphere Application Server profile. Default value -> ${DEFAULT_WAS_PROFILE}." >&2;
    printf "    %s: %s\n" "Optional if a server name was provided, required otherwise" "--serverlist | -l <file>: A list of servers to action against." >&2;
    printf "        %s: %s\n" "Note" "If a server list is provided, the file must be formatted with each entry on a new line written as \"profile-name|target-server\"" >&2;
    printf "    %s: %s\n" "Optional if a server list was provided, required otherwise" "--servername | -s <server>: The WebSphere Application Server to action agaist." >&2;
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

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main ${TARGET_ACTION} ${PROFILE_NAME} ${SERVER_ENTRY}";
            fi

            main "${TARGET_ACTION}" "${PROFILE_NAME}" "${SERVER_ENTRY}";

            [[ -n "${SERVER_ENTRY}" ]] && unset -v SERVER_ENTRY;
        done
    else
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main ${TARGET_ACTION} ${PROFILE_NAME} ${TARGET_SERVER}";
        fi

        if [[ "${TARGET_SERVER}" =~ ":" ]]; then
            [[ -z "${PROFILE_NAME}" ]] && PROFILE_NAME="${DEFAULT_PROFILE_NAME}";
            mapfile -d ":" TARGET_SERVERS <<< "${TARGET_SERVER}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "PROFILE_NAME -> ${PROFILE_NAME}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_SERVERS -> ${TARGET_SERVERS}";
            fi

            for TARGET_SERVER in $(${TARGET_SERVERS[@]}); do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main ${TARGET_ACTION} ${PROFILE_NAME} ${TARGET_SERVER}";
                fi

                main "${TARGET_ACTION}" "${PROFILE_NAME}" "${TARGET_SERVER}";

                [[ -n "${TARGET_SERVER}" ]] && unset -v TARGET_SERVER;
            done
        else
            [[ -z "${PROFILE_NAME}" ]] && PROFILE_NAME="${DEFAULT_PROFILE_NAME}";
            [[ -z "${TARGET_SERVER}" ]] && TARGET_SERVER="${DEFAULT_SERVER_NAME}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "PROFILE_NAME -> ${PROFILE_NAME}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "TARGET_SERVER -> ${TARGET_SERVER}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "EXEC: main ${TARGET_ACTION} ${PROFILE_NAME} ${TARGET_SERVER}";
            fi

            main "${TARGET_ACTION}" "${PROFILE_NAME}" "${TARGET_SERVER}";
        fi
    fi

    RETURN_CODE=${?};

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${FUNCTION_NAME}" "RETURN_CODE -> ${RETURN_CODE}";
    fi

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi
fi

[[ -n "${TARGET_ACTION}" ]] && unset -v TARGET_ACTION;
[[ -n "${TARGET_SERVER}" ]] && unset -v TARGET_SERVER;
[[ -n "${TARGET_PROFILE}" ]] && unset -v TARGET_PROFILE;
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
