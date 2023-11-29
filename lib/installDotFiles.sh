#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  deployFiles
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function buildPackage()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    function_name="${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> enter" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Provided arguments: ${*}" 2>/dev/null;
    fi

    if [[ -d "${DOTFILES_BASE_PATH}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Switching to ${DOTFILES_BASE_PATH} to generate package" 2>/dev/null; fi

        cd "${DOTFILES_BASE_PATH}";

        if [[ "${PWD}" == "${DOTFILES_BASE_PATH}" ]] && [[ -w "${DOTFILES_BASE_PATH}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: tar --exclude-vcs --exclude=README.md --exclude=LICENSE.md -cvf - * | ${ARCHIVE_PROGRAM} > ${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" 2>/dev/null; fi

            tar --exclude-vcs --exclude=README.md --exclude=LICENSE.md -cvf - ./* | ${ARCHIVE_PROGRAM} > "${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}";

            if [[ ! -s "${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" ]]; then
                (( error_count += 1 ))

                writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to generate source archive. Cannot continue." 2>/dev/null;
                writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to generate source archive. Cannot continue." 2>/dev/null;
            fi
        else
            (( error_count += 1 ))

            writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to switch into directory ${DOTFILES_BASE_PATH}. Please ensure the directory exists and can be written to." 2>/dev/null;
            writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to switch into directory ${DOTFILES_BASE_PATH}. Please ensure the directory exists and can be written to." 2>/dev/null;
        fi
    else
        (( error_count += 1 ))

        writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "The specified source directory ${DOTFILES_BASE_PATH} does not exist. Cannot continue." 2>/dev/null;
        writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "The specified source directory ${DOTFILES_BASE_PATH} does not exist. Cannot continue." 2>/dev/null;
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code=${error_count}; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "return_code -> ${return_code}" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> exit" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch=$(printf "%(%s)T");
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS" 2>/dev/null;
        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
}

#=====  FUNCTION  =============================================================
#          NAME:  deployAndInstall
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function copyKeysToTarget()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    function_name="${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> enter" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Provided arguments: ${*}" 2>/dev/null;
    fi

    target_user="${1}";
    target_host="${2}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "target_user -> ${target_user}" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "target_host -> ${target_host}" 2>/dev/null;
    fi

    if [[ -n "${SSH_KEY_LIST[*]}" ]] && (( ${#SSH_KEY_LIST[*]} != 0 )); then
        for keyfile in "${SSH_KEY_LIST[@]}"; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "keyfile -> ${keyfile}" 2>/dev/null; fi

            ## check if the file actually exists, if its not there just skip it
            if [[ -f "${keyfile}" ]] && [[ -r "${keyfile}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Copying public key ${keyfile}" 2>/dev/null;
                    writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: ssh-copy-id -i /home/${target_user}/.ssh/${keyfile}.pub ${target_host} > /home/${target_user}/.log/ssh-copy-id-${keyfile} 2>&1" 2>/dev/null;
                fi

                ssh-copy-id -i "${keyfile}" "${target_host}";
                ret_code=${?};

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}" 2>/dev/null; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ));

                    writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to copy SSH identity ${keyfile} to host ${target_host}" 2>/dev/null;
                    writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to copy SSH identity ${keyfile} to host ${target_host}" 2>/dev/null;
                else
                    writeLogEntry "INFO" "${CNAME}" "${function_name}" "${LINENO}" "SSH keyfile ${keyfile} applied to host ${target_host} as user ${target_user}" 2>/dev/null;
                fi
            else
                ## NOT incrementing an error counter here because im not sure we actually need it
                writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Unable to open keyfile ${keyfile}. Please ensure the file exists and can be read by the current user." 2>/dev/null;
                writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Unable to open keyfile ${keyfile}. Please ensure the file exists and can be read by the current user." 2>/dev/null;
            fi

            [[ -n "${ret_code}" ]] && unset -v ret_code;
            [[ -n "${keyfile}" ]] && unset -v keyfile;
        done
    fi

    [[ -n "${keyfile}" ]] && unset -v keyfile;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code=${error_count}; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "return_code -> ${return_code}" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> exit" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch=$(printf "%(%s)T");
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS" 2>/dev/null;
        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
}

#=====  FUNCTION  =============================================================
#          NAME:  deployFiles
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function copyFilesToTarget()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    function_name="${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> enter" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Provided arguments: ${*}" 2>/dev/null;
    fi

    target_user="${1}";
    target_host="${2}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "target_user -> ${target_user}" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "target_host -> ${target_host}" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Generate temporary file for SFTP batching...";
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: mktemp -p \"${TMPDIR-${USABLE_TMP_DIR}}\"";
    fi

    sftp_batch_file="$(mktemp -p "${TMPDIR-${USABLE_TMP_DIR}}")";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "sftp_batch_file -> ${sftp_batch_file}" 2>/dev/null; fi

    if [[ -z "${sftp_batch_file}" ]] || [[ ! -w "${sftp_batch_file}" ]]; then
        (( error_count += 1 ))

        writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to generate the SFTP batch file ${sftp_batch_file}. Please ensure the file exists and can be written to." 2>/dev/null;
        writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to generate the SFTP batch file ${sftp_batch_file}. Please ensure the file exists and can be written to." 2>/dev/null;
    else
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Generating SFTP batch file..." 2>/dev/null;
            writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: printf \"$%s %s %s\n\" \"put\" \"${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\" \"${DEPLOY_TO_DIR}\" >| \"${sftp_batch_file}\"" 2>/dev/null;
        fi

        printf "$%s %s %s\n" "put" "${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" "${DEPLOY_TO_DIR}" >| "${sftp_batch_file}";

        if [[ ! -s "${sftp_batch_file}" ]]; then
            (( error_count += 1 ))

            writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to populate the SFTP batch file ${sftp_batch_file}. Please ensure the file exists and can be written to." 2>/dev/null;
            writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to populate the SFTP batch file ${sftp_batch_file}. Please ensure the file exists and can be written to." 2>/dev/null;
        else
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: ssh -ql ${target_user} ${target_host} \"PATH=/bin:/sbin:/usr/bin:/usr/sbin; [[ -w ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} ]] && rm -f ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION};\"" 2>/dev/null; fi

            ssh -ql "${target_user}" -p "${SSH_PORT_NUMBER}" "${target_host}" "PATH=\"/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\"; [[ -w ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} ]] && rm -f ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION};";
            ret_code=${?};

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}" 2>/dev/null; fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "An error occurred during the SSH cleanup process. Please review logs." 2>/dev/null;
                writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "An error occurred during the SSH cleanup process. Please review logs." 2>/dev/null;
            else
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Sending package to host ${target_host} as user ${target_user}..." 2>/dev/null;
                    writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: sftp -b ${sftp_batch_file} -oPort=${SSH_PORT_NUMBER} ${target_user}@${target_host}" 2>/dev/null;
                fi

                sftp -b "${sftp_batch_file}" -oPort="${SSH_PORT_NUMBER}" "${target_user}@${target_host}";
                ret_code=${?};

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "An error occurred while transferring the dotfiles package. Please review logs." 2>/dev/null;
                    writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "An error occurred while transferring the dotfiles package. Please review logs." 2>/dev/null;
                else
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Validating file placement..." 2>/dev/null;
                        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: ssh -ql ${target_user} -p ${SSH_PORT_NUMBER} ${target_host} \"PATH=\"/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\"; [[ -w ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} ]] && rm -f ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\"" 2>/dev/null;
                    fi

                    ssh -ql "${target_user}" -p "${SSH_PORT_NUMBER}" "${target_host}" "PATH=\"/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin\"; [[ -w \"${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\" ]] && rm -f \"${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\";";
                    ret_code=${?};

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}" 2>/dev/null; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Package ${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} was not found on host ${target_host} in ${DEPLOY_TO_DIR}. Please review logs." 2>/dev/null;
                        writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Package ${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} was not found on host ${target_host} in ${DEPLOY_TO_DIR}. Please review logs." 2>/dev/null;
                    fi
                fi
            fi
        fi
    fi

    [[ -w "${sftp_batch_file}" ]] && rm -f "${sftp_batch_file}";

    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${sftp_batch_file}" ]] && unset -v sftp_batch_file;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code=${error_count}; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "return_code -> ${return_code}" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> exit" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch=$(printf "%(%s)T");
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS" 2>/dev/null;
        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
}

#=====  FUNCTION  =============================================================
#          NAME:  installFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function installFiles()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    function_name="${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> enter" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Provided arguments: ${*}" 2>/dev/null;
    fi

    if [[ -s "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" ]]; then
        ## extract the archive
        [[ ! -d "${DOTFILES_INSTALL_PATH}" ]] && mkdir -pv "${DOTFILES_INSTALL_PATH}";

        cd "${DOTFILES_INSTALL_PATH}";

        if [[ "${PWD}" == "${DOTFILES_INSTALL_PATH}" ]] && [[ -w "${DOTFILES_INSTALL_PATH}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | tar -xvf -" 2>/dev/null; fi

            ${UNARCHIVE_PROGRAM} -c "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" | tar -xvf -;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: find ${DOTFILES_INSTALL_PATH} -type d -exec chmod 755 {} \;" 2>/dev/null;
                writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: find ${DOTFILES_INSTALL_PATH} -type f -exec chmod 644 {} \;" 2>/dev/null;
            fi

            find "${DOTFILES_INSTALL_PATH}" -type d -exec chmod 755 {} \; ;
            find "${DOTFILES_INSTALL_PATH}" -type f -exec chmod 644 {} \; ;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: chmod 755 ${DOTFILES_INSTALL_PATH}/bin/*" 2>/dev/null;
                writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: chmod 600 ${DOTFILES_INSTALL_PATH}/m2/settings.xml ${DOTFILES_INSTALL_PATH}/etc/ldaprc ${DOTFILES_INSTALL_PATH}/etc/curlrc \
                    ${DOTFILES_INSTALL_PATH}/etc/netrc ${HOME}/.dotfiles/etc/wgetrc" 2>/dev/null;
            fi

            chmod 755 "${DOTFILES_INSTALL_PATH}/bin/*"; ## 755 on all files in bin
            chmod 600 "${DOTFILES_INSTALL_PATH}/m2/settings.xml" "${DOTFILES_INSTALL_PATH}/etc/ldaprc" "${DOTFILES_INSTALL_PATH}/etc/curlrc" "${DOTFILES_INSTALL_PATH}/etc/netrc" "${DOTFILES_INSTALL_PATH}/etc/wgetrc";

            ## switch to homedir
            cd "${HOME}";

            if [[ "${PWD}" == "${HOME}" ]] && [[ -w "${HOME}" ]]; then
                [[ ! -d "${HOME}/.ssh" ]] && mkdir -pv "${HOME}/.ssh";
                [[ ! -d "${HOME}/.gnupg" ]] && mkdir -pv "${HOME}/.gnupg";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "EXEC: chmod 700 ${HOME}/.ssh ${HOME}/.gnupg" 2>/dev/null;
                fi

                chmod 700 "${HOME}/.ssh" "${HOME}/.gnupg"; ## ssh/gpg wants 700

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Processing entries from ${INSTALL_CONF}" 2>/dev/null; fi

                if [[ -s "${INSTALL_CONF}" ]]; then
                    ## change the IFS
                    IFS="${MODIFIED_IFS}";

                    ## clean up home directory first
                    for entry in $(< "${INSTALL_CONF}")
                    do
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "entry -> ${entry}" 2>/dev/null; fi

                        [[ "${entry}" =~ ^\# ]] && continue;

                        entry_command="$(cut -d "|" -f 1 <<< "${entry}")";
                        entry_source="$(cut -d "|" -f 2 <<< "${entry}")";
                        entry_target="$(cut -d "|" -f 3 <<< "${entry}")";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "entry_command -> ${entry_command}" 2>/dev/null;
                            writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "entry_source -> ${entry_source}" 2>/dev/null;
                            writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "entry_target -> ${entry_target}" 2>/dev/null;
                        fi

                        case "${entry_command}" in
                            "mkdir")
                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "entry_command -> ${entry_command}" 2>/dev/null;
                                    writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Creating directory ${entry_source}" 2>/dev/null;
                                fi

                                [[ -d "${entry_source}" ]] && rmdir "${entry_source}";

                                mkdir -pv "${entry_source}";
                                ret_code=${?};

                                if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                                then
                                    (( error_count += 1 ));

                                    writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to create directory ${entry_source} on host ${HOSTNAME}" 2>/dev/null;
                                    writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to create directory ${entry_source} on host ${HOSTNAME}" 2>/dev/null;

                                    continue;
                                fi

                                writeLogEntry "INFO" "${CNAME}" "${function_name}" "${LINENO}" "Directory ${entry_source} created" 2>/dev/null;
                                ;;
                            "ln")
                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "entry_command -> ${entry_command}" 2>/dev/null;
                                    writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Removing symbolic link ${entry_target}" 2>/dev/null;
                                fi

                                [[ -L "${entry_target}" ]] && unlink "${entry_target}";
                                [[ -f "${entry_target}" ]] && rm -f "${entry_target}";

                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Creating symbolic link ${entry_source} -> ${entry_target}" 2>/dev/null; fi

                                ln -s "${entry_source}" "${entry_target}";
                                ret_code=${?};

                                if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                                then
                                    (( error_count += 1 ));

                                    writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to create symbolic link ${entry_target} with source ${entry_source} on host ${HOSTNAME}" 2>/dev/null;
                                    writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to create symbolic link ${entry_target} with source ${entry_source} on host ${HOSTNAME}" 2>/dev/null;

                                    continue;
                                fi

                                writeLogEntry "INFO" "${CNAME}" "${function_name}" "${LINENO}" "Symbolic link ${entry_source} -> ${entry_target} created." 2>/dev/null;
                                ;;
                            *)
                                writeLogEntry "INFO" "${CNAME}" "${function_name}" "${LINENO}" "Skipping entry ${entry_command}." 2>/dev/null;

                                continue;
                                ;;
                        esac

                        [[ -n "${ret_code}" ]] && unset -v ret_code;
                        [[ -n "${entry_command}" ]] && unset -v entry_command;
                        [[ -n "${entry_source}" ]] && unset -v entry_source;
                        [[ -n "${entry_target}" ]] && unset -v entry_target;
                        [[ -n "${entry}" ]] && unset -v entry;
                    done

                    ## restore the original ifs
                    IFS="${CURRENT_IFS}";
                else
                    (( error_count += 1 ));

                    writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user." 2>/dev/null;
                    writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user." 2>/dev/null;
                fi
            else
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to switch to ${HOME}. Please ensure the path exists and can be written to." 2>/dev/null;
                writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to switch to ${HOME}. Please ensure the path exists and can be written to." 2>/dev/null;
            fi
        else
            (( error_count += 1 ));

            writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to switch to ${DOTFILES_INSTALL_PATH}. Please ensure the path exists and can be written to." 2>/dev/null;
            writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "Failed to switch to ${DOTFILES_INSTALL_PATH}. Please ensure the path exists and can be written to." 2>/dev/null;
        fi
    else
        (( error_count += 1 ));

        writeLogEntry "ERROR" "${CNAME}" "${function_name}" "${LINENO}" "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} was not found on host ${HOSTNAME} as user ${LOGNAME}" 2>/dev/null;
        writeLogEntry "STDERR" "${CNAME}" "${function_name}" "${LINENO}" "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} was not found on host ${HOSTNAME} as user ${LOGNAME}" 2>/dev/null;
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code=${error_count}; fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${entry_command}" ]] && unset -v entry_command;
    [[ -n "${entry_source}" ]] && unset -v entry_source;
    [[ -n "${entry_target}" ]] && unset -v entry_target;
    [[ -n "${entry}" ]] && unset -v entry;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "return_code -> ${return_code}" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> exit" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch=$(printf "%(%s)T");
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS" 2>/dev/null;
        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
}

#=====  FUNCTION  =============================================================
#          NAME:  installFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function cleanupFiles()
{
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    function_name="${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> enter" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "Provided arguments: ${*}" 2>/dev/null;
    fi

    [[ -w "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" ]] && rm -f "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "return_code -> ${return_code}" 2>/dev/null;
        writeLogEntry "DEBUG" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} -> exit" 2>/dev/null;
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]]; then
        end_epoch=$(printf "%(%s)T");
        runtime=$(( start_epoch - end_epoch ));

        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS" 2>/dev/null;
        writeLogEntry "PERFORMANCE" "${CNAME}" "${function_name}" "${LINENO}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")" 2>/dev/null;
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
}
