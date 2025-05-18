#!/usr/bin/env bash
# TODO
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

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "appserver_name -> ${appserver_name}";
    fi

    if (( ${#} >= 3 )); then
        watch_type="${3}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_type -> ${watch_type}";
        fi

        case "${watch_type}" in
            "[Ff][Ii][Ll][Ee]")
                (( ${#} != 4 )) && return 3;

                watch_file="${4}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_file -> ${watch_file}";
                fi

                (( ${#} <= 4 )) && wait_time="${DEFAULT_WAS_WAIT}" || wait_time="${5}";
                (( ${#} <= 5 )) && wait_time="${DEFAULT_WAS_WAIT}" || wait_time="${6}";
                ;;
            "[Tt][Cc][Pp]|[Uu][Dd][Pp]")
                (( ${#} != 5 )) && return 3;

                watch_host="${4}";
                watch_port="${5}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_host -> ${watch_host}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "watch_port -> ${watch_port}";
                fi

                (( ${#} <= 5 )) && wait_time="${DEFAULT_WAS_WAIT}" || wait_time="${6}";
                (( ${#} <= 6 )) && wait_time="${DEFAULT_WAS_WAIT}" || wait_time="${7}";
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
                else
                        return_code=1;

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Unable to locate setupCmdLine.sh in ${PROFILE_ROOT}/${profile_name}. Cannot continue.";
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
#          NAME:  stopApplicationServer
#   DESCRIPTION:  Stops a provided WebSphere Application Server
#    PARAMETERS:  WAS Profile name, WAS Application Server name
#       RETURNS:  0 if no errors/timeouts occurred, otherwise dependent on variables
#==============================================================================
function stopApplicationServer()
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

    (( ${#} < 2 )) && return 3;

        profile_name="${1}";
        appserver_name="${2}";
    wait_time="${3}";
    retry_count="${4}";

    if [[ -z "${wait_time}" ]]; then wait_time="${DEFAULT_WAS_WAIT}"; retry_count="${DEFAULT_RETRY_COUNT}"; fi
    if [[ -n "${wait_time}" ]] && [[ -z "${retry_count}" ]]; then retry_count="${DEFAULT_WAS_WAIT}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "profile_name -> ${profile_name}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "appserver_name -> ${appserver_name}";
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
                                if [[ -n "${watch_for_file}" ]] && [[ "${watch_for_file}" == "${_TRUE}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: waitForProcessFile ${filewatch} ${wait_time} ${retry_count}";
                    fi

                    waitForProcessFile "${filewatch}" "${wait_time}" "${retry_count}";
                    ret_code="${?}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        return_code="${ret_code}";

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
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ${USER_INSTALL_ROOT}/bin/stopServer.sh ${appserver_name}";
                    fi

                    [[ -f "${tmpfile}" ]] && cat /dev/null >| ${tmpfile};

                    ${USER_INSTALL_ROOT}/bin/stopServer.sh "${appserver_name}" | tee ${tmpfile};
                    watchProvidedProcess ${!} ${wait_time} ${retry_count};
                    ret_code=${?};

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                    fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        return_code="${ret_code}";

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Return code from stopServer.sh was non-zero. Return code -> ${ret_code}";
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
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Server shutdown for ${appserver_name} timed out and was not successfully completed. Please review logs.";
                        fi
                    fi
                fi
                        else
                                return_code=1;

                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Variable USER_INSTALL_ROOT is null. Please verify the profile name provided.";
                                fi
            fi
                else
                        return_code=1;

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "Unable to locate setupCmdLine.sh in ${PROFILE_ROOT}/${profile_name}. Cannot continue.";
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
    [[ -n "${filewatch}"