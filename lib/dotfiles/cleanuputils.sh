#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  cleanupFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="cleanuputils.sh";
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

    operating_mode="${1}";
    cleanup_file_list="${2}";
    cleanup_host="${3}";
    cleanup_port="${4}";
    cleanup_user="${5}";
    force_push="${6}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "operating_mode -> ${operating_mode}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_file_list -> ${cleanup_file_list}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_host -> ${cleanup_host}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_port -> ${cleanup_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_user -> ${cleanup_user}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "force_push -> ${force_push}";
    fi

    if [[ -n "${cleanup_file_list}" ]]; then
        case "${operating_mode}" in
            "${CLEANUP_LOCATION_LOCAL}")
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cleanupLocalFiles ${cleanup_file_list}"; fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                cleanupLocalFiles "${cleanup_file_list}";
                ret_code="${?}";

                cname="cleanuputils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred during the host availability check. Setting resume_cleanup to ${_FALSE}";
                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred checking host availability for host ${cleanup_host}. Please review logs.";
                fi
                ;;
            "${CLEANUP_LOCATION_REMOTE}")
                if [[ -n "${force_push}" ]] && [[ "${force_push}" == "${_FALSE}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Checking host availibility for ${cleanup_host}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: validateHostAddress ${cleanup_host} ${cleanup_port}";
                    fi

                    [[ -n "${cname}" ]] && unset -v cname;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    validateHostAddress "${cleanup_host}" "${cleanup_port}";
                    ret_code="${?}";

                    cname="cleanuputils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        continue_exec="${_FALSE}";

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred during the host availability check. Setting continue_exec to ${_FALSE}";
                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred checking host availability for host ${cleanup_host}. Please review logs.";
                    fi
                fi

                if [[ -n "${continue_exec}" ]] && [[ "${continue_exec}" == "${_TRUE}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cleanupRemoteFiles ${cleanup_file_list} ${cleanup_host} ${cleanup_user}"; fi

                    [[ -n "${cname}" ]] && unset -v cname;
                    [[ -n "${function_name}" ]] && unset -v function_name;
                    [[ -n "${ret_code}" ]] && unset -v ret_code;

                    cleanupRemoteFiles "${cleanup_file_list}" "${cleanup_host}" "${cleanup_port}" "${cleanup_user}";
                    ret_code="${?}";

                    cname="cleanuputils.sh";
                    function_name="${cname}#${FUNCNAME[0]}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to execute remote file cleanup. Please review logs.";
                    fi
                else
                    (( error_count += 1 ));

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to perform cleanup on remote host ${cleanup_host} as user ${cleanup_port} - resume_cleanup is ${resume_cleanup}, indicating an error has occurred. Please review logs.";
                fi
                ;;
            *)
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An invalid operation mode was specified. operating_mode -> ${operating_mode}. Cannot continue.";
                ;;
        esac
    else
        (( error_count += 1 ));

        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "The list of files to operate against appears to be empty. Cannot continue.";
    fi

    [[ -n "${cleanup_user}" ]] && unset -v cleanup_user;
    [[ -n "${cleanup_host}" ]] && unset -v cleanup_host;
    [[ -n "${cleanup_port}" ]] && unset -v cleanup_port;
    [[ -n "${force_push}" ]] && unset -v force_push;
    [[ -n "${cleanup_file_list}" ]] && unset -v cleanup_file_list;
    [[ -n "${operating_mode}" ]] && unset -v operating_mode;
    [[ -n "${continue_exec}" ]] && unset -v continue_exec;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
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
#          NAME:  cleanupLocalFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="cleanuputils.sh";
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
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: readarray -td \",\" files_to_process <<< \"${1}\"";
    fi

    requested_files="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "requested_files -> ${requested_files[*]}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: readarray -td , files_to_process <<< ${requested_files}";
    fi

    readarray -td "," files_to_process <<< "${requested_files}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "files_to_process -> ${files_to_process[*]}"; fi

    for eligibleFile in "${files_to_process[@]}"; do
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "eligibleFile -> ${eligibleFile}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Check if file ${eligibleFile} exists and removing if necessary";
        fi

        [[ -z "${eligibleFile}" ]] && continue;

        targetFile="$(awk -F "|" '{print $1}' <<< "${eligibleFile}")";
        targetDir="$(awk -F "|" '{print $2}' <<< "${eligibleFile}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetFile -> ${targetFile}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetDir -> ${targetDir}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Check if file ${targetDir}/${targetFile} exists and removing if necessary";
        fi

        if [[ -n "${targetFile}" ]] && [[ -n "${targetDir}" ]]; then
            if [[ -d "${targetDir}/${targetFile}" ]] && [[ -w "${targetDir}/${targetFile}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Removing directory ${targetDir}/${targetFile}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: rm -rf ${targetDir}/${targetFile}";
                fi

                rm -rf "${targetDir:?}/${targetFile}";
            elif [[ -e "${targetDir}/${targetFile}" ]] && [[ -w "${targetDir}/${targetFile}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Removing file ${targetDir}/${targetFile}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: rm -f ${targetDir}/${targetFile}";
                fi

                rm -f "${targetDir:?}/${targetFile}";
            fi

            if [[ -e "${targetDir}/${targetFile}" ]] || [[ -w "${targetDir}/${targetFile}" ]]; then
                (( error_count += 1 ))

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to remove target file ${targetDir}/${targetFile}. Please remove the file manually.";
            fi
        else
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "targetFile ${targetDir}/${targetFile} was null or empty. Skipping entry.";
        
            continue;
        fi

        [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
        [[ -n "${targetFile}" ]] && unset -v targetFile;
    done

    [[ -n "${targetFile}" ]] && unset -v targetFile;
    [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
    [[ -n "${files_to_process[*]}" ]] && unset -v files_to_process;
    [[ -n "${requested_files}" ]] && unset -v requested_files;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
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
#          NAME:  cleanupRemoteFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="cleanuputils.sh";
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

    requested_files="${1}";
    remote_host="${2}";
    remote_port="${3}";
    remote_user="${4}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "requested_files -> ${requested_files}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "remote_host -> ${remote_host}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "remote_port -> ${remote_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "remote_user -> ${remote_user}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: readarray -td , files_to_process <<< ${requested_files}";
    fi

    readarray -td "," files_to_process <<< "${requested_files}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "files_to_process -> ${files_to_process[*]}"; fi

    if [[ -n "${remote_host}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "remote_host -> ${remote_host}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Generating file cleanup file...";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mktemp -p ${TMPDIR:-${USABLE_TMP_DIR}}";
        fi

        file_cleanup_file="$(mktemp -p "${TMPDIR:-${USABLE_TMP_DIR}}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "file_cleanup_file -> ${file_cleanup_file}"; fi

        if [[ ! -e "${file_cleanup_file}" ]] || [[ ! -w "${file_cleanup_file}" ]]; then
            (( error_count += 1 ))

            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to generate the file cleanup file ${file_cleanup_file}. Please ensure the file exists and can be written to.";
        else
            file_counter=0;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "file_counter -> ${file_counter}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Populating file cleanup file ${file_cleanup_file}...";
            fi

            for eligibleFile in "${files_to_process[@]}"; do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "eligibleFile -> ${eligibleFile}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Check if file ${eligibleFile} exists and removing if necessary";
                fi

                [[ -z "${eligibleFile}" ]] && continue;

                targetFile="$(awk -F "|" '{print $1}' <<< "${eligibleFile}")";
                targetDir="$(awk -F "|" '{print $2}' <<< "${eligibleFile}")";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetFile -> ${targetFile}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "targetDir -> ${targetDir}";
                fi

                if [[ -n "${targetDir}" ]] && [[ -n "${targetFile}" ]]; then
                    if (( file_counter == 0 )); then
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: printf \"%s %s %s\n\" \"-\" \"rm\" \"${targetDir:?}/${targetFile}\" >| ${file_cleanup_file}"; fi

                        { printf "%s %s %s\n" "-" "rm" "${targetDir:?}/${targetFile}"; } >| "${file_cleanup_file}";

                        (( file_counter += 1 ));
                    else
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: printf \"%s %s %s\n\" \"-\" \"rm\" \"${targetDir:?}/${targetFile}\" >> ${file_cleanup_file}"; fi

                        { printf "%s %s %s\n" "-" "rm" "${targetDir:?}/${targetFile}"; } >> "${file_cleanup_file}";
                    fi
                else
                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "targetFile ${targetDir}/${targetFile} was null or empty. Skipping entry.";
                
                    continue;
                fi

                [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;
                [[ -n "${targetFile}" ]] && unset -v targetFile;
                [[ -n "${targetDir}" ]] && unset -v targetDir;
            done

            if [[ ! -s "${file_cleanup_file}" ]]; then
                (( error_count += 1 ))

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to populate the file cleanup file ${file_cleanup_file}. Please ensure the file exists and can be written to.";
            else
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: sftp -b ${file_cleanup_file} -oPort=${remote_port} ${remote_user}@${remote_host} > /dev/null 2>&1"; fi

                sftp -b "${file_cleanup_file}" -oPort="${remote_port}" "${remote_user}@${remote_host}" > /dev/null 2>&1;
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred during the file cleanup process on host ${remote_host} as user ${remote_user}. Please review logs.";
                fi
            fi
        fi
    else
        (( error_count += 1 ))

        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "A target host was not provided to execute against - remote_host is set to ${remote_host}. Cannot continue.";
    fi

    [[ -w "${file_cleanup_file}" ]] && rm -f "${file_cleanup_file}";
    [[ -n "${targetFile}" ]] && unset -v targetFile;
    [[ -n "${targetDir}" ]] && unset -v targetDir;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${requested_files}" ]] && unset -v requested_files;
    [[ -n "${remote_host}" ]] && unset -v remote_host;
    [[ -n "${remote_port}" ]] && unset -v remote_port;
    [[ -n "${remote_user}" ]] && unset -v remote_user;
    [[ -n "${file_counter}" ]] && unset -v file_counter;
    [[ -n "${eligibleFile}" ]] && unset -v eligibleFile;

    [[ -n "${file_cleanup_file}" ]] && unset -v file_cleanup_file;
    [[ -n "${files_to_process[*]}" ]] && unset -v files_to_process;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
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
