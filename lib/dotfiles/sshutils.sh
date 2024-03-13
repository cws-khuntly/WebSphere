#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  generateSshKeys
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function generateSshKeys()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="sshutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "${function_name} -> enter";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Provided arguments: ${*}";
    fi

    if [[ ! -d "${TMPDIR:-${USABLE_TMP_DIR}}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Temporary directory ${TMPDIR:-${USABLE_TMP_DIR}} does not exist. Creating.";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mkdir -p ${TMPDIR:-${USABLE_TMP_DIR}}";
        fi

        mkdir -p "${TMPDIR:-${USABLE_TMP_DIR}}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Directory created: ${TMPDIR:-${USABLE_TMP_DIR}}";
        fi
    fi

    if [[ ! -d "${HOME}"/.ssh ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "SSH user configuration directory does not exist. Creating.";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mkdir -p ${HOME}/.ssh";
        fi

        mkdir -p "${HOME}"/.ssh;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Directory created: ${HOME}/.ssh;";
        fi
    fi

    for AVAILABLE_SSH_KEY_TYPE in "${SSH_KEY_TYPES[@]}"; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "AVAILABLE_SSH_KEY_TYPE -> ${AVAILABLE_SSH_KEY_TYPE}";
        fi

        SSH_KEY_TYPE="$(cut -d "," -f 1 <<< "${AVAILABLE_SSH_KEY_TYPE}")";
        SSH_KEY_SIZE="$(cut -d "," -f 2 <<< "${AVAILABLE_SSH_KEY_TYPE}")";
        SSH_KEY_FILENAME="id_${SSH_KEY_TYPE}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "SSH_KEY_TYPE -> ${SSH_KEY_TYPE}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "SSH_KEY_SIZE -> ${SSH_KEY_SIZE}";
        fi

        ## if it doesnt exist then make it. if it does exist skip it
        if [[ ! -f "${HOME}"/.ssh/"${SSH_KEY_FILENAME}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: ${SSH_KEYGEN_PROGRAM} -b ${SSH_KEY_SIZE} -t ${SSH_KEY_TYPE} -f ${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}";
            fi

            "${SSH_KEYGEN_PROGRAM}" -b "${SSH_KEY_SIZE}" -t "${SSH_KEY_TYPE}" -f "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}";
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "SSH keyfile generation for type ${SSH_KEY_TYPE} failed with return code ${ret_code}";
            else
                if [[ ! -f "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}" ]]; then
                    (( error_count += 1 ));

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "SSH keyfile generation for type ${SSH_KEY_TYPE} failed with return code ${ret_code}";
                else
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mv ${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME} ${HOME}/.ssh/${SSH_KEY_FILENAME}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mv ${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}.pub ${HOME}/.ssh/${SSH_KEY_FILENAME}.pub";
                    fi

                    ## relocate the keyfiles to the user home directory
                    mv "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}" "${HOME}/.ssh/${SSH_KEY_FILENAME}";
                    mv "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}.pub" "${HOME}/.ssh/${SSH_KEY_FILENAME}.pub";

                    ## make sure they exist
                    if [[ ! -f "${HOME}/.ssh/${SSH_KEY_FILENAME}" ]] || [[ ! -f "${HOME}/.ssh/${SSH_KEY_FILENAME}.pub" ]]; then
                        (( error_count += 1 ));

                        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "SSH keyfile generation for type ${SSH_KEY_TYPE} failed with return code ${ret_code}";
                    fi
                fi
            fi
        fi

        [[ -n "${SSH_KEY_TYPE}" ]] && unset -v SSH_KEY_TYPE;
        [[ -n "${SSH_KEY_SIZE}" ]] && unset -v SSH_KEY_SIZE;
        [[ -n "${SSH_KEY_FILENAME}" ]] && unset -v SSH_KEY_FILENAME;
    done
        
    [[ -n "${SSH_KEY_TYPE}" ]] && unset -v SSH_KEY_TYPE;
    [[ -n "${SSH_KEY_SIZE}" ]] && unset -v SSH_KEY_SIZE;
    [[ -n "${SSH_KEY_FILENAME}" ]] && unset -v SSH_KEY_FILENAME;
    [[ -n "${AVAILABLE_SSH_KEY_TYPE}" ]] && unset -v AVAILABLE_SSH_KEY_TYPE;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "return_code -> ${return_code}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch=$(printf "%(%s)T");
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  deployFiles
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function copyKeysToTarget()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="sshutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;
    continue_exec="${_TRUE}";

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "${function_name} -> enter";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Provided arguments: ${*}";
    fi

    target_host="${1}";
    target_port="${2}";
    target_user="${3}";
    force_push="${4}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_host -> ${target_host}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_port -> ${target_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_user -> ${target_user}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "force_push -> ${force_push}";
    fi

    if [[ -n "${force_push}" ]] && [[ "${force_push}" == "${_FALSE}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Checking host availibility for ${target_host}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: validateHostAddress ${target_host} ${target_port}";
        fi

        [[ -n "${cname}" ]] && unset -v functioncname_name;
        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        validateHostAddress "${target_host}" "${target_port}";
        ret_code="${?}";

        cname="sshutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            continue_exec="${_FALSE}";

            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred during the host availability check. Setting continue_exec to ${_FALSE}";
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred checking host availability for host ${target_host}. Please review logs.";
        fi
    fi

    if [[ -n "${continue_exec}" ]] && [[ "${continue_exec}" == "${_TRUE}" ]]; then
        if [[ -n "${SSH_KEY_LIST[*]}" ]] && (( ${#SSH_KEY_LIST[*]} != 0 )); then
            for keyfile in "${SSH_KEY_LIST[@]}"; do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "keyfile -> ${keyfile}"; fi

                [[ -z "${keyfile}" ]] && continue;

                ## check if the file actually exists, if its not there just skip it
                if [[ -f "${keyfile}" ]] && [[ -r "${keyfile}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Copying public key ${keyfile}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: ssh-copy-id -i ${keyfile} -oPort=${SSH_PORT_NUMBER} ${target_host} > /dev/null 2>&1";
                    fi

                    ssh-copy-id -i "${keyfile}" -oPort="${target_port}" "${target_host}" > /dev/null 2>&1;
                    ret_code="${?}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ));

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to copy SSH identity ${keyfile} to host ${target_host}";
                    else
                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "INFO" "${cname}" "${function_name}" "${LINENO}" "SSH keyfile ${keyfile} applied to host ${target_host} as user ${target_user}";
                    fi
                else
                    ## NOT incrementing an error counter here because im not sure we actually need it
                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Unable to open keyfile ${keyfile}. Please ensure the file exists and can be read by the current user.";
                fi

                [[ -n "${ret_code}" ]] && unset -v ret_code;
                [[ -n "${keyfile}" ]] && unset -v keyfile;
            done
        fi
    else
        (( error_count += 1 ));

        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Host ${target_host} does not appear to be available. Unable to continue processing.";
    fi

    [[ -n "${force_push}" ]] && unset -v force_push;
    [[ -n "${keyfile}" ]] && unset -v keyfile;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${target_port}" ]] && unset -v target_port;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${continue_exec}" ]] && unset -v continue_exec;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "return_code -> ${return_code}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch=$(printf "%(%s)T");
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
