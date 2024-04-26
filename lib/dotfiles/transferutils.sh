#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  transferFiles
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function transferFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="transferutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    operating_mode="${1}";
    files_to_process="${2}";
    remote_host="${3}";
    remote_port="${4}";
    target_user="${5}";
    force_exec="${6}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "operating_mode -> ${operating_mode}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "files_to_process -> ${files_to_process}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_host -> ${remote_host}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_port -> ${remote_port}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
    fi

    if [[ -n "${files_to_process}" ]]; then
        case "${operating_mode}" in
            "${TRANSFER_LOCATION_LOCAL}")
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferLocalFiles ${files_to_process}"; fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                transferLocalFiles "${files_to_process}";
                ret_code="${?}";

                cname="transferutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "An error occurred while transferring files on the local system. Please review logs.";
                fi
                ;;
            "${TRANSFER_LOCATION_REMOTE}")
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "files_to_process -> ${files_to_process}";
                    writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_host -> ${remote_host}";
                    writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_port -> ${remote_port}";
                    writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
                    writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
                fi

                if [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_FALSE}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Checking host availibility for ${remote_host}";
                        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: validateHostAddress ${remote_host} ${remote_port}";
                    fi

                    [[ -n "${cname}" ]] && unset -v cname;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    validateHostAddress "${remote_host}" "${remote_port}";
                    ret_code="${?}";

                    cname="transferutils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ));

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "An error occurred checking host availability for host ${remote_host}. Please review logs.";
                    fi
                fi

                if [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_TRUE}" ]] || [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferRemoteFiles ${files_to_process} ${remote_host} ${remote_port} ${target_user}"; fi

                    [[ -n "${cname}" ]] && unset -v cname;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    transferRemoteFiles "${files_to_process}" "${remote_host}" "${remote_port}" "${target_user}";
                    ret_code="${?}";

                    cname="transferutils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "An error occurred while transferring files on the remote system. Please review logs.";
                    fi
                fi
                ;;
            *)
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "An invalid operation mode was specified. operating_mode -> ${operating_mode}. Cannot continue.";
                ;;
        esac
    else
        (( error_count += 1 ));

        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "The list of files to operate against appears to be empty. Cannot continue.";
    fi

    [[ -n "${continue_exec}" ]] && unset -v continue_exec;
    [[ -n "${force_exec}" ]] && unset -v force_exec;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${remote_port}" ]] && unset -v remote_port;
    [[ -n "${remote_host}" ]] && unset -v remote_host;
    [[ -n "${files_to_process}" ]] && unset -v files_to_process;
    [[ -n "${operating_mode}" ]] && unset -v operating_mode;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  transferLocalFiles
#
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function transferLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="transferutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    file_listing="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_listing -> ${file_listing}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: readarray -td \",\" files_to_process <<< \"${file_listing}\"";
    fi

    #readarray -td "," files_to_process <<< "${file_listing}";
    files_to_process=( $(printf "%s" "${file_listing}" | tr "," "\n") );

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "files_to_process -> ${files_to_process[*]}"; fi

    for eligibleFile in "${files_to_process[@]}"; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "eligibleFile -> ${eligibleFile}";
        fi

        [[ -z "${eligibleFile}" ]] && continue;

        targetFile="$(awk -F "|" '{print $1}' <<< "${eligibleFile}")";
        targetDir="$(awk -F "|" '{print $2}' <<< "${eligibleFile}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetFile -> ${targetFile}";
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetDir -> ${targetDir}";
        fi

        if [[ -n "${targetDir}" ]] && [[ -n "${targetFile}" ]]; then
            if [[ -r "${targetFile}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cp ${targetFile} ${targetDir}"; fi

                if [[ ! -f "${targetFile}" ]]; then
                    cp "${targetFile}" "${targetDir}";
                    ret_code="${?}";
                
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "Failed to copy source file ${targetFile} to ${targetDir}. Please review logs.";
                    fi
                fi
            else
                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "targetFile ${targetFile} is not readable. Skipping entry.";
            
                continue;
            fi
        else
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "targetFile ${targetDir}/${targetFile} was null or empty. Skipping entry.";
        
            continue;
        fi

        [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
        [[ -n "${targetFile}" ]] && unset -v targetFile;
        [[ -n "${targetDir}" ]] && unset -v targetDir;
    done

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  transferRemoteFiles
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function transferRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="transferutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    file_list="${1}";
    remote_host="${2}";
    remote_port="${3}";
    target_user="${4}";
    force_exec="${5}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_list -> ${file_list}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_host -> ${remote_host}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_port -> ${remote_port}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Generating sFTP batch send file...";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=\"${TMPDIR:-${USABLE_TMP_DIR}}\"";
    fi

    if [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_FALSE}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Checking host availibility for ${remote_host}";
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: validateHostAddress ${remote_host} ${remote_port}";
        fi

        [[ -n "${cname}" ]] && unset -v cname;
        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        validateHostAddress "${remote_host}" "${remote_port}";
        ret_code="${?}";

        cname="cleanuputils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "An error occurred during the host availability check. Setting continue_exec to ${_FALSE}";
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "An error occurred checking host availability for host ${remote_host}. Please review logs.";
        fi
    fi

    if [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_TRUE}" ]] || [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Getting SSH host keys for host ${remote_host}";
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: getHostKeys \"${remote_host}\" \"${remote_port}\"";
        fi

        [[ -n "${cname}" ]] && unset -v cname;
        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        getHostKeys "${remote_host}" ${remote_port};
        ret_code=${?};

        cname="transferutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "An error occurred getting SSH host keys from host ${remote_host}. Please review logs.";
        fi

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "remote_host -> ${remote_host}";
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Generating file cleanup file...";
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
        fi

        sftp_send_file="$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "sftp_send_file -> ${sftp_send_file}"; fi

        if [[ ! -e "${sftp_send_file}" ]] || [[ ! -w "${sftp_send_file}" ]]; then
            (( error_count += 1 ))

            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "Failed to generate the sFTP batch send file ${sftp_send_file}. Please ensure the file exists and can be written to.";
        else
            #readarray -td "," files_to_process <<< "${file_list}";
            requested_files=( $(printf "%s" "${requested_files}" | tr "," "\n") );

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating batch file ${sftp_send_file}..."; fi

            for eligibleFile in "${files_to_process[@]}"; do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "eligibleFile -> ${eligibleFile}"; fi

                [[ -z "${eligibleFile}" ]] && continue;

                targetFile="$(awk -F "|" '{print $1}' <<< "${eligibleFile}")";
                targetDir="$(awk -F "|" '{print $2}' <<< "${eligibleFile}")";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetFile -> ${targetFile}";
                    writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "targetDir -> ${targetDir}";
                fi

                if [[ -n "${targetDir}" ]] && [[ -n "${targetFile}" ]]; then
                    if (( file_counter == 0 )); then
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s %s %s\n\" put ${targetFile} ${targetDir:?} >| ${sftp_send_file}"; fi

                        { printf "%s %s %s\n" "put" "${targetFile}" "${targetDir:?}"; } >| "${sftp_send_file}";

                        (( file_counter += 1 ));
                    else
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: printf \"%s %s %s\n\" put ${targetFile} ${targetDir:?} >> ${sftp_send_file}"; fi

                        { printf "%s %s %s\n" "put" "${targetFile}" "${targetDir:?}"; } >> "${sftp_send_file}";
                    fi
                else
                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "targetFile ${targetDir}/${targetFile} was null or empty. Skipping entry.";
                
                    continue;
                fi

                [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
                [[ -n "${targetFile}" ]] && unset -v targetFile;
                [[ -n "${targetDir}" ]] && unset -v targetDir;
            done

            if [[ ! -s "${sftp_send_file}" ]]; then
                (( error_count += 1 ))

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "Failed to populate the sFTP batch send file ${sftp_send_file}. Please ensure the file exists and can be written to.";
            else
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Sending requested files to host ${remote_host} as user ${target_user}...";
                    writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: sftp -b ${sftp_send_file} -P ${remote_port} ${target_user}@${remote_host}";
                fi

                sftp -b "${sftp_send_file}" -P "${remote_port}" "${target_user}@${remote_host}" > /dev/null 2>&1;
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "An error occurred while transferring the dotfiles package. Please review logs.";
                fi
            fi
        fi
    fi

    ## cleanup
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="$(basename "${sftp_send_file}")|${TMPDIR:-${USABLE_TMP_DIR}},";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_list -> ${cleanup_list}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_list}";
    fi

    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_list}";
    ret_code="${?}";

    set +o noclobber;
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "Failed to execute cleanupFiles with cleanup type of ${CLEANUP_LOCATION_LOCAL}. Please review logs.";
    fi

    [[ -n "${force_exec}" ]] && unset -v force_exec;
    [[ -n "${continue_exec}" ]] && unset -v continue_exec;
    [[ -n "${ssh_response}" ]] && unset -v ssh_response;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${remote_host}" ]] && unset -v remote_host;
    [[ -n "${remote_port}" ]] && unset -v remote_port;
    [[ -n "${sftp_delete_file}" ]] && unset -v sftp_delete_file;
    [[ -n "${sftp_send_file}" ]] && unset -v sftp_send_file;
    [[ -n "${file_verification_script}" ]] && unset -v file_verification_script;
    [[ -n "${ssh_response}" ]] && unset -v ssh_response;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
