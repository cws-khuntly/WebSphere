#!/usr/bin/env bash

#======  FUNCTION  ============================================================
#          NAME:  startPortalServer
#   DESCRIPTION:  Stops a provided WebSphere Portal Server
#    PARAMETERS:  WPS Profile name, WPS Application Server name
#       RETURNS:  0 if no errors/timeouts occurred, otherwise dependent on variables
#==============================================================================
function startPortalServer()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="servercontrol.sh";
    local function_name="${CNAME}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local profile_name;
    local appserver_name;
    local watch_data;
    local watch_type;
    local watch_host;
    local watch_port;
    local wait_time;
    local retry_count;

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

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "appserver_name -> ${appserver_name}";
    fi

    if (( ${#} >= 3 )); then
        watch_data="${3}";
        watch_type="$(cut -d ":" -f 1 <<< "${watch_data}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_type -> ${watch_type}";
        fi

        case "${watch_type}" in
            "[Ff][Ii][Ll][Ee]")
                (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) != 2 )) && return 3;

                watch_file="$(cut -d ":" -f 2 <<< "${watch_data}")";

                (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 3 )) && wait_time="$(cut -d ":" -f 3 <<< "${wait_data}")" || wait_time="${DEFAULT_WPS_WAIT}";
                (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 4 )) && retry_count="$(cut -d ":" -f 4 <<< "${wait_data}")" || retry_count="${DEFAULT_RETRY_COUNT}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_file -> ${watch_file}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "wait_time -> ${wait_time}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "retry_count -> ${retry_count}";
                fi
                ;;
            "[Tt][Cc][Pp]|[Uu][Dd][Pp]")
                (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) != 3 )) && return 3;

                watch_host="$(cut -d ":" -f 2 <<< "${watch_data}")";
                watch_port="$(cut -d ":" -f 3 <<< "${watch_data}")";

                (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 3 )) && wait_time="$(cut -d ":" -f 3 <<< "${wait_data}")" || wait_time="${DEFAULT_WPS_WAIT}";
                (( $(tr ":" "\n" <<< "${watch_data}" | wc -l) >= 4 )) && retry_count="$(cut -d ":" -f 4 <<< "${wait_data}")" || retry_count="${DEFAULT_RETRY_COUNT}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_file -> ${watch_host}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_port -> ${watch_port}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "wait_time -> ${wait_time}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "retry_count -> ${retry_count}";
                fi
                ;;
        esac
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
                        return_code=1;

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Process execution failed, ${filewatch} was not found after ${wait_time} over number of tries ${retry_count}";
                        fi
                    fi
                fi

                if [[ -z "${return_code}" ]] || (( return_code == 0 )); then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
                    fi

                    tmpfile=$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}");

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "tmpfile -> ${tmpfile}";
                    fi

                    [[ -f "${tmpfile}" ]] && cat /dev/null >| ${tmpfile};

                    ${USER_INSTALL_ROOT}/bin/startServer.sh "${appserver_name}" | tee ${tmpfile};
                    watchProcessID ${!} ${wait_time} ${retry_count};
                    ret_code=${?};

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        return_code="${ret_code}";

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server startup for ${appserver_name} timed out and was not successfully completed. Please review logs.";
                        fi
                    else
                        if [[ -n "$(grep -E "(ADMU0508I|STARTED)" ${tmpfile})" ]]; then
                            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} has been started successfully.";
                            fi
                        else
                            return_code=1;

                            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} could not be started.";
                            fi
                        fi
                    fi
                fi
            else
                return_code=1;

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
                fi
            fi
        fi
    else
        return_code=1;

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Provided profile ${profile_name} does not exist in ${PROFILE_ROOT}";
        fi
    fi

    [[ -f "${tmpfile}" ]] && rm -f "${tmpfile}";

    [[ -n "${profile_name}" ]] && unset -v profile_name;
    [[ -n "${appserver_name}" ]] && unset -v appserver_name;
    [[ -n "${filewatch}" ]] && unset -v filewatch;
    [[ -n "${wait_time}" ]] && unset -v wait_time;
    [[ -n "${retry_count}" ]] && unset -v retry_count;
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
#          NAME:  stopPortalServer
#   DESCRIPTION:  Stops a provided WebSphere Portal Server
#    PARAMETERS:  WPS Profile name, WPS Application Server name
#       RETURNS:  0 if no errors/timeouts occurred, otherwise dependent on variables
#==============================================================================
function stopPortalServer()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    local cname="servercontrol.sh";
    local function_name="${CNAME}#${FUNCNAME[0]}";
    local return_code=0;
    local error_count=0;
    local profile_name;
    local appserver_name;
    local wait_time;
    local retry_count;

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

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "appserver_name -> ${appserver_name}";
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

				if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
				fi

				tmpfile=$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}");

				if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "tmpfile -> ${tmpfile}";
				fi

				[[ -f "${tmpfile}" ]] && cat /dev/null >| ${tmpfile};

				${USER_INSTALL_ROOT}/bin/stopServer.sh "${appserver_name}" | tee ${tmpfile};
				watchProcessID ${!} ${wait_time} ${retry_count};
				ret_code=${?};

				if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
					writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
				fi

				if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
					return_code="${ret_code}";

					if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
						writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server shutdown for ${appserver_name} timed out and was not successfully completed. Please review logs.";
					fi
				else
					if [[ -n "$(grep -E "(ADMU0509I|STOPPED)" ${tmpfile})" ]]; then
						if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
							writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} has been stopped successfully.";
						fi
					else
						return_code=1;

						if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
							writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server ${appserver_name} could not be stopped.";
						fi
					fi
                fi
            else
                return_code=1;

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
                fi
            fi
        fi
    else
        return_code=1;

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Provided profile ${profile_name} does not exist in ${PROFILE_ROOT}";
        fi
    fi

    [[ -f "${tmpfile}" ]] && rm -f "${tmpfile}";

    [[ -n "${profile_name}" ]] && unset -v profile_name;
    [[ -n "${appserver_name}" ]] && unset -v appserver_name;
    [[ -n "${filewatch}" ]] && unset -v filewatch;
    [[ -n "${wait_time}" ]] && unset -v wait_time;
    [[ -n "${retry_count}" ]] && unset -v retry_count;
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
