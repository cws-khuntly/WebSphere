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
    continue_exec="${_TRUE}";

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "${function_name} -> enter";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Provided arguments: ${*}";
    fi

    operating_mode="${1}";
    files_to_process="${2}";
    target_host="${3}";
    target_port="${4}";
    target_user="${5}";
    force_push="${6}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "operating_mode -> ${operating_mode}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "files_to_process -> ${files_to_process}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_host -> ${target_host}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_port -> ${target_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_user -> ${target_user}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "force_push -> ${force_push}";
    fi

    if [[ -n "${files_to_process}" ]]; then
        case "${operating_mode}" in
            "${TRANSFER_LOCATION_LOCAL}")
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cleanupLocalFiles ${cleanup_file_list}"; fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                transferLocalFiles "${files_to_process}";
                ret_code="${?}";

                cname="transferutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred during the host availability check. Setting resume_cleanup to ${_FALSE}";
                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred checking host availability for host ${target_host}. Please review logs.";
                fi
                ;;
            "${TRANSFER_LOCATION_REMOTE}")
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "files_to_process -> ${files_to_process}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_host -> ${target_host}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_port -> ${target_port}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_user -> ${target_user}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "force_push -> ${force_push}";
                fi

                if [[ -n "${force_push}" ]] && [[ "${force_push}" == "${_FALSE}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Checking host availibility for ${target_host}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: validateHostAddress ${target_host} ${target_port}";
                    fi

                    [[ -n "${cname}" ]] && unset -v cname;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    validateHostAddress "${target_host}" "${target_port}";
                    ret_code="${?}";

                    cname="transferutils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        continue_exec="${_FALSE}";

                        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred during the host availability check. Setting continue_exec to ${_FALSE}";
                        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred checking host availability for host ${target_host}. Please review logs.";
                    fi
                fi

                if [[ -n "${continue_exec}" ]] && [[ "${continue_exec}" == "${_TRUE}" ]]; then
                    ## housekeeping
                    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

                    cleanup_list="${files_to_process}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_list -> ${cleanup_list}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_REMOTE} ${cleanup_list} ${target_host} ${target_port} ${target_user} ${force_push}";
                    fi

                    [[ -n "${cname}" ]] && unset -v cname;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    cleanupFiles "${CLEANUP_LOCATION_REMOTE}" "${cleanup_list}" "${target_host}" "${target_port}" "${target_user}" "${force_push}";
                    ret_code="${?}";

                    cname="transferutils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to execute remote file cleanup. Please review logs.";
                    else
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: transferRemoteFiles ${files_to_process} ${target_host} ${target_port} ${target_user}"; fi

                        [[ -n "${cname}" ]] && unset -v cname;
                        [[ -n "${function_name}" ]] && unset -v function_name;
                        [[ -n "${ret_code}" ]] && unset -v ret_code;

                        transferRemoteFiles "${files_to_process}" "${target_host}" "${target_port}" "${target_user}";
                        ret_code="${?}";

                        cname="transferutils.sh";
                        function_name="${cname}#${FUNCNAME[0]}";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                            (( error_count += 1 ))

                            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to execute remote file transfer. Please review logs.";
                        fi
                    fi
                else
                    (( error_count += 1 ));

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred checking host availability for host ${target_host}. Please review logs.";
                fi
                ;;
            *)
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An invalid operation mode was specified. operating_mode -> ${operating_mode}. Cannot continue.";
                ;;
        esac
    else
        (( error_count += 1 ));

        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "The list of files to operate against appears to be empty. Cannot continue.";
    fi

    [[ -n "${continue_exec}" ]] && unset -v continue_exec;
    [[ -n "${force_push}" ]] && unset -v force_push;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${target_port}" ]] && unset -v target_port;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${files_to_process}" ]] && unset -v files_to_process;
    [[ -n "${operating_mode}" ]] && unset -v operating_mode;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch=$(printf "%(%s)T");
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
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

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "${function_name} -> enter";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Provided arguments: ${*}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: readarray -td , files_to_process <<< ${file_list}";
    fi

    readarray -td "," files_to_process <<< "${file_list}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "files_to_process -> ${files_to_process[*]}"; fi

    for eligibleFile in "${files_to_process[@]}"; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "eligibleFile -> ${eligibleFile}";
        fi

        targetFile="$(awk -F "|" '{print $1}' <<< "${eligibleFile}")";
        targetDir="$(awk -F "|" '{print $2}' <<< "${eligibleFile}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetFile -> ${targetFile}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetDir -> ${targetDir}";
        fi

        if [[ -n "${targetDir}" ]] && [[ -n "${targetFile}" ]]; then
            if [[ -r "${targetFile}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cp ${targetFile} ${targetDir}"; fi

                cp "${targetFile}" "${targetDir}";
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to copy source file ${targetFile} to ${targetDir}. Please review logs.";
                fi
            else
                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "targetFile ${targetFile} is not readable. Skipping entry.";
            
                continue;
            fi
        else
            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "targetFile ${targetDir}/${targetFile} was null or empty. Skipping entry.";
        
            continue;
        fi

        [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
        [[ -n "${targetFile}" ]] && unset -v targetFile;
        [[ -n "${targetDir}" ]] && unset -v targetDir;
    done

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
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
    continue_exec="${_TRUE}";

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "${function_name} -> enter";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Provided arguments: ${*}";
    fi

    file_list="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";
    force_push="${5}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "file_list -> ${file_list}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_host -> ${target_host}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_port -> ${target_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_user -> ${target_user}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "force_push -> ${force_push}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Performing cleanup of any remote orphaned files...";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Generating sFTP batch send file...";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mktemp -p \"${TMPDIR:-${USABLE_TMP_DIR}}\"";
    fi

    sftp_send_file="$(mktemp -p "${TMPDIR:-${USABLE_TMP_DIR}}")";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "sftp_send_file -> ${sftp_send_file}"; fi

    if [[ ! -e "${sftp_send_file}" ]] || [[ ! -w "${sftp_send_file}" ]]; then
        (( error_count += 1 ))

        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to generate the sFTP batch send file ${sftp_send_file}. Please ensure the file exists and can be written to.";
    else
        readarray -td "," files_to_process <<< "${file_list}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Populating batch file ${sftp_send_file}..."; fi

        for eligibleFile in "${files_to_process[@]}"; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "eligibleFile -> ${eligibleFile}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Check if file ${eligibleFile} exists and removing if necessary";
            fi

            targetFile="$(awk -F "|" '{print $1}' <<< "${eligibleFile}")";
            targetDir="$(awk -F "|" '{print $2}' <<< "${eligibleFile}")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetFile -> ${targetFile}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetDir -> ${targetDir}";
            fi

            if [[ -n "${targetDir}" ]] && [[ -n "${targetFile}" ]]; then
                if (( file_counter == 0 )); then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: printf \"%s %s %s\n\" \"-\" \"rm\" \"${targetDir:?}/${targetFile}\" >| ${file_cleanup_file}"; fi

                    { printf "%s %s %s\n" "put" "${targetFile}" "${targetDir:?}"; } >| "${sftp_send_file}";

                    (( file_counter += 1 ));
                else
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: printf \"%s %s %s\n\" \"-\" \"rm\" \"${targetDir:?}/${targetFile}\" >> ${file_cleanup_file}"; fi

                    { printf "%s %s %s\n" "put" "${targetFile}" "${targetDir:?}"; } >> "${sftp_send_file}";
                fi
            else
                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "targetFile ${targetDir}/${targetFile} was null or empty. Skipping entry.";
            
                continue;
            fi

            [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
            [[ -n "${targetFile}" ]] && unset -v targetFile;
            [[ -n "${targetDir}" ]] && unset -v targetDir;
        done

        if [[ ! -s "${sftp_send_file}" ]]; then
            (( error_count += 1 ))

            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to populate the sFTP batch send file ${sftp_send_file}. Please ensure the file exists and can be written to.";
        else
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Sending package files to host ${target_host} as user ${target_user}...";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: sftp -b ${sftp_send_file} -P ${SSH_PORT_NUMBER} ${target_user}@${target_host}";
            fi

            sftp -b "${sftp_send_file}" -P "${SSH_PORT_NUMBER}" "${target_user}@${target_host}" > /dev/null 2>&1;
            ret_code=0;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while transferring the dotfiles package. Please review logs.";
            else
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Generating validation script...";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mktemp -p ${TMPDIR:-${USABLE_TMP_DIR}}";
                fi

                file_verification_script="$(mktemp -p "${TMPDIR:-${USABLE_TMP_DIR}}")";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "file_verification_script -> ${file_verification_script}"; fi

                if [[ ! -e "${file_verification_script}" ]] || [[ ! -w "${file_verification_script}" ]]; then
                    (( error_count += 1 ))

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to generate the file verification script ${file_verification_script}. Please ensure the file exists and can be written to.";
                else
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Populating file verification script ${file_verification_script}..."; fi

                    ## set script header
                    {
                        printf "%s\n\n" "#!/usr/bin/env bash";
                        printf "%s\n" "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;";
                        printf "%s\n\n" "error_counter=0;";
                    } >| "${file_verification_script}";

                    for eligibleFile in "${file_list[@]}"; do
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "eligibleFile -> ${eligibleFile}"; fi

                        targetFile="$(awk -F "|" '{print $1}' <<< "${eligibleFile}")";
                        targetDir="$(awk -F "|" '{print $2}' <<< "${eligibleFile}")";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetFile -> ${targetFile}";
                            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetDir -> ${targetDir}";
                        fi

                        if [[ -n "${targetDir}" ]] && [[ -n "${targetFile}" ]]; then
                            {
                                printf "%s\n" "if [[ ! -e ${targetDir}/${targetFile} ]] || [[ ! -r ${targetDir}/${targetFile} ]]; then (( error_counter += 1 )); fi;";
                            } >> "${file_verification_script}";
                        else
                            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "targetFile ${targetDir}/${targetFile} was null or empty. Skipping entry.";
                        
                            continue;
                        fi

                        {
                            printf "%s\n\n" "\"printf \"\%s\" \${error_count}\"";
                        } >> "${file_verification_script}";

                        [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
                        [[ -n "${targetFile}" ]] && unset -v targetFile;
                        [[ -n "${targetDir}" ]] && unset -v targetDir;
                    done

                    if [[ ! -s "${file_verification_script}" ]]; then
                        (( error_count += 1 ))

                        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to populate the file verification script ${file_verification_script}. Please ensure the file exists and can be written to.";
                    else
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: ssh -ql ${target_user} -p ${SSH_PORT_NUMBER} ${target_host} \"bash -s\" < ${file_verification_script}"; fi

                        ssh_response=$(ssh -ql "${target_user}" -p "${SSH_PORT_NUMBER}" "${target_host}" "bash -s" < "${file_verification_script}");
                        ret_code="${?}";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ssh_response -> ${ssh_response}";
                            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}";
                        fi

                        if [[ -z "${ssh_response}" ]] || (( ssh_response != 0 )) || [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                            (( error_count += 1 ))

                            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while performing file verification. Please review logs.";
                        fi
                    fi
                fi
            fi
        fi
    fi

    [[ -n "${sftp_delete_file}" ]] && cleanup_list="${sftp_delete_file},";
    [[ -n "${sftp_send_file}" ]] && cleanup_list+="${sftp_send_file},";
    [[ -n "${file_verification_script}" ]] && cleanup_list+="${file_verification_script}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_list -> ${cleanup_list}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_list}";
    fi

    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_list}";
    ret_code="${?}";

    set +o noclobber;
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to perform cleanup on local host. Please review logs.";
    fi

    [[ -n "${force_push}" ]] && unset -v force_push;
    [[ -n "${continue_exec}" ]] && unset -v continue_exec;
    [[ -n "${ssh_response}" ]] && unset -v ssh_response;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${target_port}" ]] && unset -v target_port;
    [[ -n "${sftp_delete_file}" ]] && unset -v sftp_delete_file;
    [[ -n "${sftp_send_file}" ]] && unset -v sftp_send_file;
    [[ -n "${file_verification_script}" ]] && unset -v file_verification_script;
    [[ -n "${ssh_response}" ]] && unset -v ssh_response;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
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
