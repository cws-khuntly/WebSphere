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

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    install_mode="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";
    force_exec="${5}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "install_mode -> ${install_mode}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
    fi

    case "${install_mode}" in
        "${INSTALL_LOCATION_LOCAL}")
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installLocalFiles";
            fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            installLocalFiles;
            ret_code="${?}";

            cname="installutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Local installation of package failed. Please review logs.";
                fi
            fi
            ;;
        "${INSTALL_LOCATION_REMOTE}")
            ## check if the host is alive
            if [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_FALSE}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Checking host availibility for ${target_host}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: validateHostAddress ${target_host} ${target_port}";
                fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                returnedHostInfo="$(validateHostAddress "${target_host}" "${target_port}")";
                ret_code="${?}";

                cname="installutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returnedHostInfo -> ${returnedHostInfo}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred checking host availability for host ${target_host} Please review logs.";
                    fi
                fi
            fi

            if [[ -n "${returnedHostInfo}" ]] && (( ret_code == 0 )) || [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_TRUE}" ]]; then
                returned_hostname="$(cut -d ":" -f 1 <<< "${returnedHostInfo}")";
                returned_port="$(cut -d ":" -f 2 <<< "${returnedHostInfo}")";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returned_hostname -> ${returned_hostname}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returned_port -> ${returned_port}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installRemoteFiles ${returned_hostname} ${returned_port:-SSH_PORT_NUMBER} ${target_user} ${force_exec}";
                fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                installRemoteFiles "${returned_hostname}" "${returned_port:-SSH_PORT_NUMBER}" "${target_user}";
                ret_code="${?}";

                cname="installutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Remote installation of package failed. Please review logs.";
                    fi
                fi
            fi
            ;;
        *)
            (( error_count += 1 ));

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid installation mode was specified. install_mode -> ${install_mode}. Cannot continue.";
            fi
            ;;
    esac

    [[ -f "${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" ]] && rm -f "${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}";

    [[ -n "${install_mode}" ]] && unset -v install_mode;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${target_user}" ]] && unset -v target_user;
    [[ -n "${continue_exec}" ]] && unset -v continue_exec;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  installLocalFiles
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
    ret_code=0;
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    if [[ ! -d "${DOTFILES_INSTALL_PATH}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mkdir \"${DOTFILES_INSTALL_PATH}\"";
        fi

        mkdir "${DOTFILES_INSTALL_PATH}";
    fi

    if [[ -w "${DOTFILES_INSTALL_PATH}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Switch into ${DOTFILES_INSTALL_PATH}...";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cd ${DOTFILES_INSTALL_PATH}";
        fi

        ## extract the archive to the appropriate place
        cd "${DOTFILES_INSTALL_PATH}" || (( error_count += 1 ));

        if [[ "${PWD}" == "${DOTFILES_INSTALL_PATH}" ]]; then
            "${UNARCHIVE_PROGRAM}" -c "${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" | tar -xf -;

            ## switch to homedir
            cd "${HOME}" || (( error_count += 1 ));

            if [[ "${PWD}" == "${HOME}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Processing entries from ${INSTALL_CONF}";
                fi

                if [[ -s "${INSTALL_CONF}" ]]; then
                    ## change the IFS
                    IFS="${MODIFIED_IFS}";

                    ## clean up home directory first
                    for entry in $(< "${INSTALL_CONF}"); do
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry -> ${entry}";
                        fi

                        [[ -z "${entry}" ]] && continue;
                        [[ "${entry}" =~ ^\# ]] && continue;

                        entry_command="$(cut -d "|" -f 1 <<< "${entry}")";
                        entry_source="$(cut -d "|" -f 2 <<< "${entry}")";
                        entry_target="$(cut -d "|" -f 3 <<< "${entry}")";
                        entry_permissions="$(cut -d "|" -f 4 <<< "${entry}")";
                        recurse_permissions="$(cut -d "|" -f 4 <<< "${entry}")";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_command -> ${entry_command}";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_source -> ${entry_source}";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_target -> ${entry_target}";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_permissions -> ${entry_permissions}";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "recurse_permissions -> ${recurse_permissions}";
                        fi

                        if [[ -z "${entry_command}" ]]; then
                            (( error_count += 1 ));

                            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry command from ${INSTALL_CONF} was empty. entry_command -> ${entry_command}";
                            fi

                            continue;
                        elif [[ -z "${entry_source}" ]] && [[ "${entry_command}" == "ln" ]]; then
                            (( error_count += 1 ));

                            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry source from ${INSTALL_CONF} was empty. entry_source -> ${entry_source}";
                            fi

                            continue;
                        elif [[ -z "${entry_target}" ]] && [[ "${entry_command}" == "ln" ]]; then
                            (( error_count += 1 ));

                            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry target from ${INSTALL_CONF} was empty. entry_target -> ${entry_target}";
                            fi

                            continue;
                        fi

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Command -> ${entry_command}, Source -> ${entry_source}, target -> ${entry_target}";
                        fi

                        case "${entry_command}" in
                            "mkdir")
                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Creating directory ${entry_target}";
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mkdir -p ${entry_target}";
                                fi

                                mkdir -p "$(eval printf "%s" "${entry_target}")";
                                ret_code="${?}";

                                if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                                then
                                    (( error_count += 1 ));

                                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to create directory ${entry_target}.";
                                    fi

                                    continue;
                                fi

                                if [[ -n "${recurse_permissions}" ]] && [[ "${recurse_permissions}" == "${_TRUE}" ]]; then
                                    chmod -R "${entry_permissions}" "$(eval printf "%s" "${entry_target}")";
                                else
                                    chmod "${entry_permissions}" "$(eval printf "%s" "${entry_target}")";
                                fi

                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "INFO" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Directory ${entry_target} created";
                                fi
                                ;;
                            "ln")
                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Removing symbolic link ${entry_target} if exists...";
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC:
                                        [[ -L \$(eval printf \"%s\" ${entry_target}) ]] && unlink \$(eval printf \"%s\" ${entry_target})
                                        [[ -f \$(eval printf \"%s\" ${entry_target}) ]] && rm -f \$(eval printf \"%s\" ${entry_target})";
                                fi

                                [[ -L "$(eval printf "%s" "${entry_target}")" ]] && unlink "$(eval printf "%s" "${entry_target}")";
                                [[ -f "$(eval printf "%s" "${entry_target}")" ]] && rm -f "$(eval printf "%s" "${entry_target}")";

                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Creating symbolic link ${entry_source} -> ${entry_target}";
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ln -s eval printf \"%s\" ${entry_source} eval printf \"%s\" ${entry_target}";
                                fi

                                ln -s "$(eval printf "%s" "${entry_source}")" "$(eval printf "%s" "${entry_target}")";
                                ret_code="${?}";

                                if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                                then
                                    (( error_count += 1 ));

                                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to create symbolic link ${entry_target} with source ${entry_source}.";
                                    fi

                                    continue;
                                fi

                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Symbolic link ${entry_source} -> ${entry_target} created.";
                                fi
                                ;;
                            "cp")
                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Copying file ${entry_source} to ${entry_target}";
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cp -p ${entry_source} ${entry_target}";
                                fi

                                cp -p "$(eval printf "%s" "${entry_source}")" "$(eval printf "%s" "${entry_target}")";
                                ret_code="${?}";

                                if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                                then
                                    (( error_count += 1 ));

                                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to copy file ${entry_source} to ${entry_target}.";
                                    fi

                                    continue;
                                fi

                                chmod "${entry_permissions}" "$(eval printf "%s" "${entry_target}")"

                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "INFO" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "File ${entry_source} copied to ${entry_target}.";
                                fi
                                ;;
                            *)
                                (( error_count += 1 ));

                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Skipping entry ${entry_command}.";
                                fi

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

                    ## generate SSH keys if not already present
                    if [[ -n "${GENERATE_SSH_KEYS}" ]] && [[ "${GENERATE_SSH_KEYS}" == "${_TRUE}" ]]; then
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "SSH key generation has been selected. Generating keys...";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: generateSshKeys";
                        fi

                        [[ -n "${cname}" ]] && unset -v cname;
                        [[ -n "${function_name}" ]] && unset -v function_name;
                        [[ -n "${ret_code}" ]] && unset -v ret_code;

                        generateSshKeys;
                        ret_code="${?}";

                        cname="installutils.sh";
                        function_name="${cname}#${FUNCNAME[0]}";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                        fi

                        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "WARN" "${$}" "${cname}" "${LINENO}" "${function_name}" "SSH key file generation failed. Please generate keys manually.";                            fi
                        fi
                    fi

                    ## generate GPG keys if not already present
                    if [[ -n "${GENERATE_GPG_KEYS}" ]] && [[ "${GENERATE_GPG_KEYS}" == "${_TRUE}" ]]; then
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "GPG key generation has been selected. Generating keys...";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: generateGpgKeys";
                        fi

                        [[ -n "${cname}" ]] && unset -v cname;
                        [[ -n "${function_name}" ]] && unset -v function_name;
                        [[ -n "${ret_code}" ]] && unset -v ret_code;

                        generateGpgKeys;
                        ret_code="${?}";

                        cname="installutils.sh";
                        function_name="${cname}#${FUNCNAME[0]}";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                        fi

                        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "WARN" "${$}" "${cname}" "${LINENO}" "${function_name}" "GPG key file generation failed. Please generate keys manually.";
                            fi
                        fi
                    fi
                else
                    (( error_count += 1 ));

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user.";
                    fi
                fi
            else
                (( error_count += 1 ));

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to switch to ${HOME}. Please ensure the path exists and can be written to.";
                fi
            fi
        else
            (( error_count += 1 ));

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to switch to ${DOTFILES_INSTALL_PATH}. Please ensure the path exists and can be read from.";
            fi
        fi
    else
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Package appears to be missing: DOTFILES_INSTALL_PATH -> ${DOTFILES_INSTALL_PATH} - directory is either missing or unwriteable. ";
        fi
    fi

    ## cleanup
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${TMPDIR:-${USABLE_TMP_DIR}}\n";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_list -> ${cleanup_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_list}";
    fi

    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_list}";
    ret_code="${?}";

    set +o noclobber;
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute cleanupFiles with cleanup type of ${CLEANUP_LOCATION_LOCAL}. Please review logs.";
        fi
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${entry_command}" ]] && unset -v entry_command;
    [[ -n "${entry_source}" ]] && unset -v entry_source;
    [[ -n "${entry_target}" ]] && unset -v entry_target;
    [[ -n "${entry_permissions}" ]] && unset -v entry_permissions;
    [[ -n "${entry}" ]] && unset -v entry;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  installRemoteFiles
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

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    target_host="${1}";
    target_port="${2}";
    target_user="${3}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Getting SSH host keys for host ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: getHostKeys \"${target_host}\" \"${target_port}\"";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    getHostKeys "${target_host}" ${target_port};
    ret_code=${?};

    cname="installutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred getting SSH host keys from host ${target_host}. Please review logs.";
        fi
    fi

    file_verification_script="$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}")";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_verification_script -> ${file_verification_script}";
    fi

    if [[ ! -e "${file_verification_script}" ]] || [[ ! -w "${file_verification_script}" ]]; then
        (( error_count += 1 ))

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the file verification script ${file_verification_script}. Please ensure the file exists and can be written to.";
        fi
    else
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating file verification script ${file_verification_script}...";
            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC:
                printf \"%s\n\n\" #!/usr/bin/env bash
                printf \"%s\n\" PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;
                printf \"%s\n\n\" error_count=0;
                printf \"%s\n\" if [[ ! -e ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} ]] || [[ ! -r ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} ]]; then (( error_count += 1 )); fi;
                printf \"%s\n\" if [[ ! -e ${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") ]] || [[ ! -r ${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") ]]; then (( error_count += 1 )); fi;
                printf \"%s\n\n\" if [[ ! -e ${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}") ]] || [[ ! -r ${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}") ]]; then (( error_count += 1 )); fi;
                printf \"%s\n\n\" printf \"%s\" \${error_count}";
        fi

        ## set script header
        {
            printf "%s\n\n" "#!/usr/bin/env bash";
            printf "%s\n" "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;";
            printf "%s\n\n" "error_count=0;";
            printf "%s\n" "if [[ ! -e \"${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\" ]] || [[ ! -r \"${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}\" ]]; then (( error_count += 1 )); fi;";
            printf "%s\n" "if [[ ! -e \"${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}")\" ]] || [[ ! -r \"${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}")\" ]]; then (( error_count += 1 )); fi;";
            printf "%s\n\n" "if [[ ! -e \"${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}")\" ]] || [[ ! -r \"${DEPLOY_TO_DIR}/$(basename "${INSTALL_CONF}")\" ]]; then (( error_count += 1 )); fi;";
            printf "%s\n\n" "printf \"%s\" \${error_count}";
        } >| "${file_verification_script}";

        if [[ ! -s "${file_verification_script}" ]]; then
            (( error_count += 1 ))

            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the file verification script ${file_verification_script}. Please ensure the file exists and can be written to.";
            fi
        else
            [[ -n "${transfer_file_list}" ]] && unset -v transfer_file_list;

            transfer_file_list="${file_verification_script}|${DEPLOY_TO_DIR}/$(basename "${file_verification_script}")\n";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}"
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Sending file verification script ${transfer_file_list} to host ${target_host} as user ${target_user}...";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${transfer_file_list} ${target_host} ${target_port} ${target_user} ${target_user} ${force_exec}";
            fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            transferFiles "${TRANSFER_LOCATION_REMOTE}" "${transfer_file_list}" "${target_host}" "${target_port}" "${target_user}" "${target_user} ${force_exec}";
            ret_code="${?}";

            cname="installutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute transferFiles with transfer type of ${TRANSFER_LOCATION_REMOTE}. Please review logs.";
                fi
            else
                ## verify files have been transferred
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ssh -ql ${target_user} -p ${target_port} ${target_host} \"bash -s\" < \"${DEPLOY_TO_DIR}/$(basename "${file_verification_script}")\"";
                fi

                verify_response=$(ssh -ql "${target_user}" -p "${target_port}" "${target_host}" "bash -s" < "${DEPLOY_TO_DIR}/$(basename "${file_verification_script}")");
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "verify_response -> ${verify_response}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )) && [[ -z "${verify_response}" ]] || (( verify_response != 0 )); then
                    return_code="${error_count}";

                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while verifying files on remote host ${target_host}.";
                    fi
                else
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
                    fi
                
                    installation_script="$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}")";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "installation_script -> ${installation_script}";
                    fi

                    if [[ ! -e "${installation_script}" ]] || [[ ! -w "${installation_script}" ]]; then
                        (( error_count += 1 ))

                        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the installation script ${installation_script}. Please ensure the file exists and can be written to.";
                        fi
                    else
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating installation script ${installation_script}...";
                            writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC:
                                printf \"%s\n\n\" #!/usr/bin/env bash
                                printf \"%s\n\n\" PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;
                                printf \"%s\n\" umask 022;
                                printf \"%s\n\" [[ -d ${DOTFILES_INSTALL_PATH} ]] && rm -rf ${DOTFILES_INSTALL_PATH}; mkdir ${DOTFILES_INSTALL_PATH} > /dev/null 2>&1;
                                printf \"%s\n\" cd ${DOTFILES_INSTALL_PATH}; ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | tar -xf -
                                printf \"%s\n\n\" ${DOTFILES_INSTALL_PATH}/bin/installDotFiles --config=${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") --action=installFiles --servername=${target_host}
                                printf \"%s\n\n\" printf \"%s\" \${?}";
                        fi

                        ## build the install script
                        {
                            printf "%s\n\n" "#!/usr/bin/env bash";
                            printf "%s\n" "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;";
                            printf "%s\n\n" "error_counter=0;";
                            printf "%s\n" "umask 022";
                            printf "%s\n" "[[ -d ${DOTFILES_INSTALL_PATH} ]] && rm -rf ${DOTFILES_INSTALL_PATH}; mkdir ${DOTFILES_INSTALL_PATH} > /dev/null 2>&1;";
                            printf "%s\n" "cd ${DOTFILES_INSTALL_PATH}; ${UNARCHIVE_PROGRAM} -c ${DEPLOY_TO_DIR}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION} | tar -xf -;";
                            printf "%s\n\n" "${DOTFILES_INSTALL_PATH}/bin/installDotFiles --config=${DEPLOY_TO_DIR}/$(basename "${WORKING_CONFIG_FILE}") --action=installFiles --servername=${target_host}";
                            printf "%s\n\n" "printf \"%s\" \${?}";
                        } >| "${installation_script}";

                        if [[ ! -s "${installation_script}" ]]; then
                            (( error_count += 1 ))

                            if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the installation script ${installation_script}. Please ensure the file exists and can be written to.";
                            fi
                        else
                            [[ -n "${transfer_file_list}" ]] && unset -v transfer_file_list;

                            transfer_file_list="${installation_script}|${DEPLOY_TO_DIR}/$(basename "${installation_script}")\n";

                            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "transfer_file_list -> ${transfer_file_list}"
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Sending installation script ${installation_script} to host ${target_host} as user ${target_user}...";
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: transferFiles ${TRANSFER_LOCATION_REMOTE} ${transfer_file_list} ${target_host} ${target_port} ${target_user} ${target_user} ${force_exec}";
                            fi

                            [[ -n "${cname}" ]] && unset -v cname;
                            [[ -n "${function_name}" ]] && unset -v function_name;
                            [[ -n "${ret_code}" ]] && unset -v ret_code;

                            transferFiles "${TRANSFER_LOCATION_REMOTE}" "${transfer_file_list}" "${target_host}" "${target_port}" "${target_user}" "${target_user} ${force_exec}";
                            ret_code="${?}";

                            cname="installutils.sh";
                            function_name="${cname}#${FUNCNAME[0]}";

                            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                            fi

                            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                                (( error_count += 1 ))

                                if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute transferFiles with transfer type of ${TRANSFER_LOCATION_REMOTE}. Please review logs.";
                                fi
                            else
                                ## ok, files should be out there. lets go
                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ssh -ql ${target_user} -p ${target_port} ${target_host} \"bash -s\" < \"${DEPLOY_TO_DIR}/$(basename "${installation_script}")\"";
                                fi

                                install_response=$(ssh -ql "${target_user}" -p "${target_port}" "${target_host}" "bash -s" < "${DEPLOY_TO_DIR}/$(basename "${installation_script}")");
                                ret_code="${?}";

                                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "install_response -> ${install_response}";
                                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                                fi

                                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                                    return_code="${ret_code}";

                                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred while performing installation on remote host ${target_host}. install_response -> ${install_response}";
                                    fi
                                else
                                    if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                        writeLogEntry "FILE" "INFO" "${$}" "${cname}" "${LINENO}" "${function_name}" "dotfiles successfully installed to host ${target_host} as user ${target_user}";
                                    fi
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi

    ## cleanup (remote)
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${DEPLOY_TO_DIR}\n";
    cleanup_list+="$(basename "${WORKING_CONFIG_FILE}")|${DEPLOY_TO_DIR}\n";
    cleanup_list+="$(basename "${INSTALL_CONF}")|${DEPLOY_TO_DIR}\n";
    cleanup_list+="$(basename "${file_verification_script}")|${DEPLOY_TO_DIR}\n";
    cleanup_list+="$(basename "${installation_script}")|${DEPLOY_TO_DIR}\n";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_list -> ${cleanup_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_REMOTE} ${cleanup_list} ${target_host} ${target_port} ${target_user}";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_REMOTE}" "${cleanup_list}" "${target_host}" "${target_port}" "${target_user}";
    ret_code="${?}";

    cname="installutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute cleanupFiles with cleanup type of ${CLEANUP_LOCATION_REMOTE}. Please review logs.";
        fi
    fi

    ## cleanup (local)
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}|${TMPDIR:-${USABLE_TMP_DIR}}\n";
    cleanup_list+="$(basename "${file_verification_script}")|${TMPDIR:-${USABLE_TMP_DIR}}\n";
    cleanup_list+="$(basename "${installation_script}")|${TMPDIR:-${USABLE_TMP_DIR}}\n";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_list -> ${cleanup_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_list}";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_list}";
    ret_code="${?}";

    cname="installutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
    fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        (( error_count += 1 ));

        if [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute cleanupFiles with cleanup type of ${CLEANUP_LOCATION_LOCAL}. Please review logs.";
        fi
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${entry_command}" ]] && unset -v entry_command;
    [[ -n "${entry_source}" ]] && unset -v entry_source;
    [[ -n "${entry_target}" ]] && unset -v entry_target;
    [[ -n "${entry}" ]] && unset -v entry;

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntry "FILE" "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
