#!/usr/bin/env bash

#======  FUNCTION  ============================================================
#          NAME:  startNodeAgent
#   DESCRIPTION:  Starts the nodeagent for a given WAS profile
#    PARAMETERS:  WAS Profile name
#       RETURNS:  0 if no errors/timeouts occurred, otherwise dependent on variables
#==============================================================================
function startNodeAgent()
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

    (( ${#} != 1 )) && return 3;

    profile_name="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
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
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
                fi

                tmpfile=$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}");

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "tmpfile -> ${tmpfile}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: ${USER_INSTALL_ROOT}/bin/startNode.sh";
                fi

                [[ -f "${tmpfile}" ]] && cat /dev/null >| ${tmpfile};

                ${USER_INSTALL_ROOT}/bin/startNode.sh | tee ${tmpfile};
                watchProvidedProcess ${!};
                ret_code=${?};

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    return_code="${ret_code}";

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "nodeagent startup timed out and was not successfully completed. Please review logs.";
                    fi
                else
                    if [[ -n "$(grep -E "(ADMU0508I|STARTED)" ${tmpfile})" ]]; then
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "nodeagent in profile ${profile_name} has been started successfully.";
                        fi
                    else
                        return_code=1;

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "nodeagent in profile ${profile_name} could not be started. Please review logs.";
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
#          NAME:  stopNodeAgent
#   DESCRIPTION:  Stops the nodeagent for a given WAS profile
#    PARAMETERS:  WAS Profile name
#       RETURNS:  0 if no errors/timeouts occurred, otherwise dependent on variables
#==============================================================================
function stopNodeAgent()
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

    (( ${#} != 1 )) && return 3;

    profile_name="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
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
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
                fi

                tmpfile=$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}");

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "tmpfile -> ${tmpfile}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "EXEC: ${USER_INSTALL_ROOT}/bin/stopNode.sh";
                fi

                [[ -f "${tmpfile}" ]] && cat /dev/null >| ${tmpfile};

                ${USER_INSTALL_ROOT}/bin/stopNode.sh | tee ${tmpfile};
                watchProvidedProcess ${!};
                ret_code=${?};

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    return_code="${ret_code}";

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "nodeagent shutdown timed out and was not successfully completed. Please review logs.";
                    fi
                else
                    if [[ -n "$(grep -E "(ADMU0508I|STARTED)" ${tmpfile})" ]]; then
                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "INFO" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "nodeagent in profile ${profile_name} has been stopped successfully.";
                        fi
                    else
                        return_code=1;

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${CNAME}" "${LINENO}" "${function_name}" "nodeagent in profile ${profile_name} could not be stopped. Please review logs.";
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
