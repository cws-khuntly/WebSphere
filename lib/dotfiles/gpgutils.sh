#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  generateGpgKeys
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function generateGpgKeys()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="sshutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
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

    if [[ ! -d "${HOME}"/.gpg ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "SSH user configuration directory does not exist. Creating.";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mkdir -p ${HOME}/.gpg";
        fi

        mkdir -p "${HOME}"/.gpg;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Directory created: ${HOME}/.gpg;";
        fi
    fi

    for AVAILABLE_SSH_KEY_TYPE in ${SSH_KEY_TYPES[@]}; do
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
            ssh-keygen -b "${SSH_KEY_SIZE}" -t "${SSH_KEY_TYPE}" -f "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}";
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "SSH keyfile generation for type ${SSH_KEY_TYPE} failed with return code ${ret_code}";
            else
                if [[ ! -f "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_TYPE}" ]]; then
                    (( error_count += 1 ));

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "SSH keyfile generation for type ${SSH_KEY_TYPE} failed with return code ${ret_code}";
                else
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mv ${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME} ${HOME}/.ssh/${SSH_KEY_FILENAME}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mv ${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}.pub ${HOME}/.ssh/${SSH_KEY_FILENAME}.pub";
                    fi

                    ## relocate the keyfiles to the user home directory
                    mv "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}" "${HOME}"/.ssh/"${SSH_KEY_FILENAME}";
                    mv "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}.pub" "${HOME}"/.ssh/"${SSH_KEY_FILENAME}.pub";

                    ## make sure they exist
                    if [[ ! -f "${HOME}"/.ssh/"${SSH_KEY_FILENAME}" ]] || [[ ! -f "${HOME}"/.ssh/"${SSH_KEY_FILENAME}.pub" ]]; then
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

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
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
