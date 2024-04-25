#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  getHostKeys
#   DESCRIPTION:  Obtains and stores the public key for a remote SSH node
#    PARAMETERS:  Target host or private key to transform
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function getHostKeys()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="sshutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntryToFile "PERFORMANCE" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "${function_name} -> enter";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "Provided arguments: ${*}";
    fi

    remote_host="${1}";
    remote_port="${2}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "remote_host -> ${remote_host}";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "remote_port -> ${remote_port}";
    fi

    for keytype in ${SSH_HOST_KEYS[*]}; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "keytype -> ${keytype}";
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: ssh-keygen -F ${remote_host} 2>/dev/null | grep ${keytype}";
         fi

        does_key_exist="$(ssh-keygen -F "${remote_host}" 2>/dev/null | grep "${keytype}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "does_key_exist -> ${does_key_exist}"; fi

        if [[ -z "${does_key_exist}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then 
                writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: printf \"%s\n\" \"~\" | nc \"${remote_host}\" ${remote_port}";
                writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: ssh-keyscan -t \"${keytype}\" -p ${remote_port} -H \"${remote_host}\"";
            fi

            remote_ssh_version="$(printf "%s" "~" | nc "${remote_host}" ${remote_port} 2>/dev/null | head -1)";
            remote_ssh_key="$(ssh-keyscan -t "${keytype}" -p ${remote_port} -H "${remote_host}")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "remote_ssh_version -> ${remote_ssh_version}";
                writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "remote_ssh_key -> ${remote_ssh_key}";
            fi

            if [[ -n "${remote_ssh_key}" ]] && [[ -n "${remote_ssh_version}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "Found key ${remote_ssh_key} of type ${keytype}";
                    writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: printf \"# %s:%d %s\n\" \"${remote_host}\" \"${remote_port}\" \"${remote_ssh_version}\" >> \"${SSH_KNOWN_HOSTS}\"";
                    writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: printf \"%s\n\" \"${remote_ssh_key}\" >> \"${SSH_KNOWN_HOSTS}\"";
                fi

                printf "# %s:%d %s %s\n" "${remote_host}" "${remote_port}" "${keytype}" "${remote_ssh_version}" >> "${SSH_KNOWN_HOSTS}";
                printf "%s\n" "${remote_ssh_key}" >> "${SSH_KNOWN_HOSTS}";
            fi
        fi

        [[ -n "${keytype}" ]] && unset -v keytype;
        [[ -n "${does_key_exist}" ]] && unset -v does_key_exist;
        [[ -n "${remote_ssh_key}" ]] && unset -v remote_ssh_key;
    done

    [[ -n "${force_exec}" ]] && unset -v force_exec;
    [[ -n "${keytype}" ]] && unset -v keytype;
    [[ -n "${remote_ssh_version}" ]] && unset -v remote_ssh_version;
    [[ -n "${remote_ssh_key}" ]] && unset -v remote_ssh_key;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${remote_port}" ]] && unset -v remote_port;
    [[ -n "${remote_host}" ]] && unset -v remote_host;
    [[ -n "${hosts_to_process[*]}" ]] && unset -v hosts_to_process;
    [[ -n "${hostlist}" ]] && unset -v hostlist;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "return_code -> ${return_code}";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntryToFile "PERFORMANCE" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
        writeLogEntryToFile "PERFORMANCE" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

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
        start_epoch="$(date +"%s")";

        writeLogEntryToFile "PERFORMANCE" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "${function_name} -> enter";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "Provided arguments: ${*}";
    fi

    if [[ ! -d "${TMPDIR:-${USABLE_TMP_DIR}}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "Temporary directory ${TMPDIR:-${USABLE_TMP_DIR}} does not exist. Creating.";
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: mkdir -p ${TMPDIR:-${USABLE_TMP_DIR}}";
        fi

        mkdir -p "${TMPDIR:-${USABLE_TMP_DIR}}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "Directory created: ${TMPDIR:-${USABLE_TMP_DIR}}";
        fi
    fi

    if [[ ! -d "${HOME}"/.ssh ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "SSH user configuration directory does not exist. Creating.";
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: mkdir -p ${HOME}/.ssh";
        fi

        mkdir -p "${HOME}"/.ssh;

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "Directory created: ${HOME}/.ssh;";
        fi
    fi

    for AVAILABLE_SSH_KEY_TYPE in "${SSH_KEY_TYPES[@]}"; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "AVAILABLE_SSH_KEY_TYPE -> ${AVAILABLE_SSH_KEY_TYPE}";
        fi

        SSH_KEY_TYPE="$(cut -d "," -f 1 <<< "${AVAILABLE_SSH_KEY_TYPE}")";
        SSH_KEY_SIZE="$(cut -d "," -f 2 <<< "${AVAILABLE_SSH_KEY_TYPE}")";
        SSH_KEY_FILENAME="id_${SSH_KEY_TYPE}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "SSH_KEY_TYPE -> ${SSH_KEY_TYPE}";
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "SSH_KEY_SIZE -> ${SSH_KEY_SIZE}";
        fi

        ## if it doesnt exist then make it. if it does exist skip it
        if [[ ! -f "${HOME}"/.ssh/"${SSH_KEY_FILENAME}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: ${SSH_KEYGEN_PROGRAM} -b ${SSH_KEY_SIZE} -t ${SSH_KEY_TYPE} -f ${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}";
            fi

            "${SSH_KEYGEN_PROGRAM}" -b "${SSH_KEY_SIZE}" -t "${SSH_KEY_TYPE}" -f "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}";
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                writeLogEntryToFile "ERROR" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "SSH keyfile generation for type ${SSH_KEY_TYPE} failed with return code ${ret_code}";
            else
                if [[ ! -f "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}" ]]; then
                    (( error_count += 1 ));

                    writeLogEntryToFile "ERROR" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "SSH keyfile generation for type ${SSH_KEY_TYPE} failed with return code ${ret_code}";
                else
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: mv ${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME} ${HOME}/.ssh/${SSH_KEY_FILENAME}";
                        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: mv ${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}.pub ${HOME}/.ssh/${SSH_KEY_FILENAME}.pub";
                    fi

                    ## relocate the keyfiles to the user home directory
                    mv "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}" "${HOME}/.ssh/${SSH_KEY_FILENAME}";
                    mv "${TMPDIR:-${USABLE_TMP_DIR}}/${SSH_KEY_FILENAME}.pub" "${HOME}/.ssh/${SSH_KEY_FILENAME}.pub";

                    ## make sure they exist
                    if [[ ! -f "${HOME}/.ssh/${SSH_KEY_FILENAME}" ]] || [[ ! -f "${HOME}/.ssh/${SSH_KEY_FILENAME}.pub" ]]; then
                        (( error_count += 1 ));

                        writeLogEntryToFile "ERROR" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "SSH keyfile generation for type ${SSH_KEY_TYPE} failed with return code ${ret_code}";
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
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "return_code -> ${return_code}";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntryToFile "PERFORMANCE" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
        writeLogEntryToFile "PERFORMANCE" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
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
        start_epoch="$(date +"%s")";

        writeLogEntryToFile "PERFORMANCE" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "${function_name} -> enter";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "Provided arguments: ${*}";
    fi

    remote_host="${1}";
    target_port="${2}";
    target_user="${3}";
    force_exec="${4}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "remote_host -> ${remote_host}";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "target_port -> ${target_port}";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "target_user -> ${target_user}";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "force_exec -> ${force_exec}";
    fi

    if [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_FALSE}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "Checking host availibility for ${remote_host}";
            writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: validateHostAddress ${remote_host} ${target_port}";
        fi

        [[ -n "${cname}" ]] && unset -v functioncname_name;
        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        validateHostAddress "${remote_host}" "${target_port}";
        ret_code="${?}";

        cname="sshutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "ret_code -> ${ret_code}"; fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            continue_exec="${_FALSE}";

            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "An error occurred during the host availability check. Setting continue_exec to ${_FALSE}";
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "An error occurred checking host availability for host ${remote_host}. Please review logs.";
        fi
    fi

    if [[ -n "${continue_exec}" ]] && [[ "${continue_exec}" == "${_TRUE}" ]]; then
        if [[ -n "${SSH_KEY_LIST[*]}" ]] && (( ${#SSH_KEY_LIST[*]} != 0 )); then
            for keyfile in "${SSH_KEY_LIST[@]}"; do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "keyfile -> ${keyfile}"; fi

                [[ -z "${keyfile}" ]] && continue;

                ## check if the file actually exists, if its not there just skip it
                if [[ -f "${keyfile}" ]] && [[ -r "${keyfile}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "Copying public key ${keyfile}";
                        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "EXEC: ssh-copy-id -i ${keyfile} -oPort=${SSH_PORT_NUMBER} ${remote_host} > /dev/null 2>&1";
                    fi

                    ssh-copy-id -i "${keyfile}" -oPort="${target_port}" "${remote_host}" > /dev/null 2>&1;
                    ret_code="${?}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ));

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "Failed to copy SSH identity ${keyfile} to host ${remote_host}";
                    else
                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "INFO" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "SSH keyfile ${keyfile} applied to host ${remote_host} as user ${target_user}";
                    fi
                else
                    ## NOT incrementing an error counter here because im not sure we actually need it
                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "Unable to open keyfile ${keyfile}. Please ensure the file exists and can be read by the current user.";
                fi

                [[ -n "${ret_code}" ]] && unset -v ret_code;
                [[ -n "${keyfile}" ]] && unset -v keyfile;
            done
        fi
    else
        (( error_count += 1 ));

        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "Host ${remote_host} does not appear to be available. Unable to continue processing.";
    fi

    [[ -n "${force_exec}" ]] && unset -v force_exec;
    [[ -n "${keyfile}" ]] && unset -v keyfile;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${remote_host}" ]] && unset -v remote_host;
    [[ -n "${target_port}" ]] && unset -v target_port;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${continue_exec}" ]] && unset -v continue_exec;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "return_code -> ${return_code}";
        writeLogEntryToFile "DEBUG" "${CNAME}" "${FUNCTION_NAME}" "${$}" "${LINENO}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntryToFile "PERFORMANCE" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
        writeLogEntryToFile "PERFORMANCE" "${CNAME}" "${method_name}" "${$}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
