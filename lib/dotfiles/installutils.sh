#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  installFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function installFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="installutils.sh";
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

    install_mode="${1}";
    install_host="${2}";
    install_port="${3}";
    install_user="${4}";
    force_push="${5}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_mode -> ${install_mode}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_host -> ${install_host}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_port -> ${install_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_user -> ${install_user}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "force_push -> ${force_push}";
    fi

    case "${install_mode}" in
        "${INSTALL_LOCATION_LOCAL}")
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: installLocalFiles"; fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            installLocalFiles;
            ret_code="${?}";

            cname="installutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to execute local file cleanup. Please review logs.";
            fi

            [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

            cleanup_list="${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION},";
            cleanup_list+="${TMPDIR:-${USABLE_TMP_DIR}}/$(basename "${WORKING_CONFIG_FILE}"),";
            cleanup_list+="${TMPDIR:-${USABLE_TMP_DIR}}/$(basename "${INSTALL_CONF}")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_list -> ${cleanup_list}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_list}";
            fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_list}";
            ret_code="${?}";

            cname="installutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to perform cleanup on local host. Please review logs.";
            fi
            ;;
        "${INSTALL_LOCATION_REMOTE}")
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_host -> ${install_host}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_user -> ${install_user}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "force_push -> ${force_push}";
            fi

            if [[ -n "${force_push}" ]] && [[ "${force_push}" == "${_FALSE}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Checking host availibility for ${install_host}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: validateHostAddress ${install_host} ${install_port}";
                fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                validateHostAddress "${install_host}" "${install_port}";
                ret_code="${?}";

                cname="installutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    continue_exec="${_FALSE}";

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred during the host availability check. Setting continue_exec to ${_FALSE}";
                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred checking host availability for host ${install_host}. Please review logs.";
                fi
            fi

            if [[ -n "${continue_exec}" ]] && [[ "${continue_exec}" == "${_TRUE}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: installRemoteFiles ${install_host} ${install_port} ${install_user}"; fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                installRemoteFiles "${install_host}" "${install_port}" "${install_user}";
                ret_code="${?}";

                cname="installutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to execute local file cleanup. Please review logs.";
                fi

                [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

                cleanup_list="${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION},";
                cleanup_list+="${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}"),";
                cleanup_list+="${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}")";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_list -> ${cleanup_list}";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_REMOTE} ${cleanup_list}";
                fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                cleanupFiles "${CLEANUP_LOCATION_REMOTE}" "${cleanup_list}" "${install_host}" "${install_user}" "${force_push}";
                ret_code="${?}";

                cname="installutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to perform cleanup on remote host ${install_host} as user ${install_user}. Please review logs.";
                fi
            else
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to perform cleanup on remote host ${install_host} as user ${install_user} - continue_exec is ${continue_exec}, indicating an error has occurred. Please review logs.";
            fi
            ;;
        *)
            (( error_count += 1 ));

            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An invalid installation mode was specified. install_mode -> ${install_mode}. Cannot continue.";
            ;;
    esac

    [[ -n "${install_mode}" ]] && unset -v install_mode;
    [[ -n "${install_host}" ]] && unset -v install_host;
    [[ -n "${install_user}" ]] && unset -v install_user;
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;
    [[ -n "${continue_exec}" ]] && unset -v continue_exec;

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
#          NAME:  installFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function installLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="installutils.sh";
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
    fi

    if [[ -s "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" ]]; then
        ## extract the archive
        [[ ! -d "${DOTFILES_INSTALL_PATH}" ]] && mkdir -p "${DOTFILES_INSTALL_PATH}";

        cd "${DOTFILES_INSTALL_PATH}";

        if [[ "${PWD}" == "${DOTFILES_INSTALL_PATH}" ]] && [[ -w "${DOTFILES_INSTALL_PATH}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | tar -xvf -"; fi

            ${UNARCHIVE_PROGRAM} -c "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" | tar -xf -;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: find ${DOTFILES_INSTALL_PATH} -type d -exec chmod 755 {} \;";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: find ${DOTFILES_INSTALL_PATH} -type f -exec chmod 644 {} \;";
            fi

            find "${DOTFILES_INSTALL_PATH}" -type d -exec chmod 755 {} \; ;
            find "${DOTFILES_INSTALL_PATH}" -type f -exec chmod 644 {} \; ;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: chmod 755 ${DOTFILES_INSTALL_PATH}/bin/*";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: chmod 600 ${DOTFILES_INSTALL_PATH}/m2/settings.xml ${DOTFILES_INSTALL_PATH}/etc/ldaprc ${DOTFILES_INSTALL_PATH}/etc/curlrc \
                    ${DOTFILES_INSTALL_PATH}/etc/netrc ${HOME}/.dotfiles/etc/wgetrc";
            fi

            chmod 755 "${DOTFILES_INSTALL_PATH}/bin/*"; ## 755 on all files in bin
            chmod 600 "${DOTFILES_INSTALL_PATH}/m2/settings.xml" "${DOTFILES_INSTALL_PATH}/etc/ldaprc" "${DOTFILES_INSTALL_PATH}/etc/curlrc" "${DOTFILES_INSTALL_PATH}/etc/netrc" "${DOTFILES_INSTALL_PATH}/etc/wgetrc";

            ## switch to homedir
            cd "${HOME}";

            if [[ "${PWD}" == "${HOME}" ]] && [[ -w "${HOME}" ]]; then
                [[ ! -d "${HOME}/.ssh" ]] && mkdir -p "${HOME}/.ssh";
                [[ ! -d "${HOME}/.gnupg" ]] && mkdir -p "${HOME}/.gnupg";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: chmod 700 ${HOME}/.ssh ${HOME}/.gnupg";
                fi

                chmod 700 "${HOME}/.ssh" "${HOME}/.gnupg"; ## ssh/gpg wants 700

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Processing entries from ${INSTALL_CONF}"; fi

                if [[ -s "${INSTALL_CONF}" ]]; then
                    ## change the IFS
                    IFS="${MODIFIED_IFS}";

                    ## clean up home directory first
                    for entry in $(< "${INSTALL_CONF}")
                    do
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry -> ${entry}"; fi

                        [[ "${entry}" =~ ^\# ]] && continue;

                        entry_command="$(cut -d "|" -f 1 <<< "${entry}")";
                        entry_source="$(cut -d "|" -f 2 <<< "${entry}")";
                        entry_target="$(cut -d "|" -f 3 <<< "${entry}")";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_command -> ${entry_command}";
                            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_source -> ${entry_source}";
                            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_target -> ${entry_target}";
                        fi

                        case "${entry_command}" in
                            "mkdir")
                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_command -> ${entry_command}";
                                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Creating directory ${entry_source}";
                                fi

                                [[ -d "${entry_source}" ]] && rmdir "${entry_source}";

                                mkdir -p "${entry_source}";
                                ret_code="${?}";

                                if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                                then
                                    (( error_count += 1 ));

                                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to create directory ${entry_source} on host ${HOSTNAME}";

                                    continue;
                                fi

                                writeLogEntry "INFO" "${cname}" "${function_name}" "${LINENO}" "Directory ${entry_source} created";
                                ;;
                            "ln")
                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_command -> ${entry_command}";
                                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Removing symbolic link ${entry_target}";
                                fi

                                [[ -L "${entry_target}" ]] && unlink "${entry_target}";
                                [[ -f "${entry_target}" ]] && rm -f "${entry_target}";

                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Creating symbolic link ${entry_source} -> ${entry_target}"; fi

                                ln -s "${entry_source}" "${entry_target}";
                                ret_code="${?}";

                                if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                                then
                                    (( error_count += 1 ));

                                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to create symbolic link ${entry_target} with source ${entry_source} on host ${HOSTNAME}";

                                    continue;
                                fi

                                writeLogEntry "INFO" "${cname}" "${function_name}" "${LINENO}" "Symbolic link ${entry_source} -> ${entry_target} created.";
                                ;;
                            *)
                                writeLogEntry "INFO" "${cname}" "${function_name}" "${LINENO}" "Skipping entry ${entry_command}.";

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

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user.";
                fi
            else
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to switch to ${HOME}. Please ensure the path exists and can be written to.";
            fi
        else
            (( error_count += 1 ));

            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to switch to ${DOTFILES_INSTALL_PATH}. Please ensure the path exists and can be written to.";
        fi
    else
        (( error_count += 1 ));

        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} was not found on host ${HOSTNAME} as user ${LOGNAME}";
    fi
    

    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}";

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
        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to clean temporary files. Please remove manually.";
    fi

    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}";

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
        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to clean temporary files. Please remove manually.";
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${entry_command}" ]] && unset -v entry_command;
    [[ -n "${entry_source}" ]] && unset -v entry_source;
    [[ -n "${entry_target}" ]] && unset -v entry_target;
    [[ -n "${entry}" ]] && unset -v entry;

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
#          NAME:  installFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function installRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="installutils.sh";
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
    fi

    install_to_host="${1}";
    install_to_port="${2}";
    install_as_user="${3}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_to_host -> ${install_to_host}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_to_port -> ${install_to_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_as_user -> ${install_as_user}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: 
            ssh -ql ${install_as_user} ${install_to_host} \"PATH=${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin; \
            [[ -d ${DOTFILES_INSTALL_PATH} ]] && rm -rf ${DOTFILES_INSTALL_PATH}; mkdir ${DOTFILES_INSTALL_PATH} > /dev/null 2>&1; \
            cd ${DOTFILES_INSTALL_PATH}; ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | tar -xvf -; \
            ${DOTFILES_INSTALL_PATH}/bin/installDotFiles --config=${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") --action=installFiles; printf %s \${?}";
    fi

    ## ok, files should be out there. lets go
    install_resp="$(ssh -ql "${install_as_user}" -p "${install_to_port}" "${install_to_host}" "PATH=${PATH}:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin; \
        [[ -d ${DOTFILES_INSTALL_PATH} ]] && rm -rf ${DOTFILES_INSTALL_PATH}; mkdir ${DOTFILES_INSTALL_PATH} > /dev/null 2>&1; \
        cd ${DOTFILES_INSTALL_PATH}; ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | tar -xvf -; \
        ${DOTFILES_INSTALL_PATH}/bin/installDotFiles --config=${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") --action=installFiles; printf \"%s\" \"\${?}\"")";
    ret_code="${?}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "install_resp -> ${install_resp}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) || [[ -z "${install_resp}" ]] || (( install_resp != 0 )); then
        (( error_count += 1 ))

        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while performing installation on remote host ${install_to_host}.";
    else
        ## done
        writeLogEntry "INFO" "${cname}" "${function_name}" "${LINENO}" "dotfiles successfully installed to host ${install_to_host}";
    fi

    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_list -> ${cleanup_list}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_REMOTE} ${cleanup_list} ${install_to_host} ${install_to_port}";
    fi

    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_REMOTE}" "${cleanup_list}" "${install_to_host}" "${install_to_port}";
    ret_code="${?}";

    set +o noclobber;
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to clean temporary files. Please remove manually.";
    fi

    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}";

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
        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to clean temporary files. Please remove manually.";
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${entry_command}" ]] && unset -v entry_command;
    [[ -n "${entry_source}" ]] && unset -v entry_source;
    [[ -n "${entry_target}" ]] && unset -v entry_target;
    [[ -n "${entry}" ]] && unset -v entry;

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
