#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  uninstallFiles
#   DESCRIPTION:  Removes dotfiles as configured in the install.conf
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function uninstallFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="uninstallutils.sh";
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

    uninstall_mode="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";
    force_exec="${5}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "uninstall_mode -> ${uninstall_mode}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
    fi

    case "${uninstall_mode}" in
        "${UNINSTALL_LOCATION_LOCAL}")
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: installLocalFiles"; fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            uninstallLocalFiles;
            ret_code="${?}";

            cname="uninstallutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Local installation of package failed. Please review logs.";
            fi
            ;;
        "${UNINSTALL_LOCATION_REMOTE}")
            ## check if the host is alive
            if [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_FALSE}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Checking host availibility for ${refresh_host}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: validateHostAddress ${refresh_host} ${refresh_port}";
                fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                returnedHostInfo="$(validateHostAddress "${refresh_host}" "${refresh_port}")";
                ret_code="${?}";

                cname="uninstallutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "returnedHostInfo -> ${returnedHostInfo[*]}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}";
                fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred checking host availability for host ${refresh_host}. Please review logs.";
                fi
            fi

            if (( ${#returnedHostInfo[*]} != 0 )) && (( ret_code == 0 )) || [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_TRUE}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: uninstallRemoteFiles ${returnedHostInfo[0]} ${returnedHostInfo[1]:-${SSH_PORT_NUMBER}} ${target_user} "; fi

                [[ -n "${cname}" ]] && unset -v cname;
                [[ -n "${function_name}" ]] && unset -v function_name;
                [[ -n "${ret_code}" ]] && unset -v ret_code;

                uninstallRemoteFiles "${returnedHostInfo[0]}" "${returnedHostInfo[1]:-${SSH_PORT_NUMBER}}" "${target_user}";
                ret_code="${?}";

                cname="uninstallutils.sh";
                function_name="${cname}#${FUNCNAME[0]}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Local installation of package failed. Please review logs.";
                fi
            fi
            ;;
        *)
            (( error_count += 1 ));

            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An invalid installation mode was specified. uninstall_mode -> ${uninstall_mode}. Cannot continue.";
            ;;
    esac

    [[ -n "${uninstall_mode}" ]] && unset -v uninstall_mode;
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
function uninstallLocalFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="uninstallutils.sh";
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

    if [[ -s "${INSTALL_CONF}" ]]; then
        ## change the IFS
        IFS="${MODIFIED_IFS}";

        ## clean up home directory first
        for entry in $(< "${INSTALL_CONF}"); do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry -> ${entry}"; fi

            [[ -z "${entry}" ]] && continue;
            [[ "${entry}" =~ ^\# ]] && continue;

            entry_command="$(cut -d "|" -f 1 <<< "${entry}")";
            entry_source="$(cut -d "|" -f 2 <<< "${entry}")";
            entry_target="$(cut -d "|" -f 3 <<< "${entry}")";
            removable_entry="$(eval printf "%s" "${entry_target}")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_command -> ${entry_command}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_source -> ${entry_source}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_target -> ${entry_target}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "removable_entry -> ${removable_entry}";
            fi

            if [[ -z "${entry_command}" ]]; then
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry command from ${INSTALL_CONF} was empty. entry_command -> ${entry_command}";

                continue;
            elif [[ -z "${entry_target}" ]]; then
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry target from ${INSTALL_CONF} was empty. entry_target -> ${entry_target}";

                continue;
            elif [[ -z "${entry_source}" ]] && [[ "${entry_command}" == "ln" ]]; then
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry source from ${INSTALL_CONF} was empty. entry_source -> ${entry_source}";

                continue;
            elif [[ -z "${entry_target}" ]] && [[ "${entry_command}" == "ln" ]]; then
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry target from ${INSTALL_CONF} was empty. entry_target -> ${entry_target}";

                continue;
            fi

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Command -> ${entry_command}, Source -> ${entry_source}, target -> ${entry_target}"; fi

            if [[ "${entry_command}" == "ln" ]] && [[ -L "${removable_entry}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Removing symbolic link ${removable_entry}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: unlink ${removable_entry}";
                fi

                unlink "${removable_entry}";
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                then
                    (( error_count += 1 ));

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to unlink ${entry_target}.";

                    continue;
                else
                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "INFO" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Symbolic link ${entry_target} removed.";
                fi
            fi

            [[ -n "${ret_code}" ]] && unset -v ret_code;
            [[ -n "${entry_command}" ]] && unset -v entry_command;
            [[ -n "${entry_source}" ]] && unset -v entry_source;
            [[ -n "${entry_target}" ]] && unset -v entry_target;
            [[ -n "${removable_entry}" ]] && unset -v removable_entry;
            [[ -n "${entry}" ]] && unset -v entry;
        done

        ## restore the original ifs
        IFS="${CURRENT_IFS}";

        ## remove the installation directory
        if [[ -d "${DOTFILES_INSTALL_PATH}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Removing installation directory ${DOTFILES_INSTALL_PATH}";
                writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: rm -rf ${DOTFILES_INSTALL_PATH}";
            fi

            rm -rf ${DOTFILES_INSTALL_PATH};
            ret_code=${?};

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to remove dotfiles installation directory ${DOTFILES_INSTALL_PATH}.";
            else
                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "INFO" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Removed dotfiles installation directory ${DOTFILES_INSTALL_PATH}.";
            fi
        fi
    else
        (( error_count += 1 ));

        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user.";
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

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

#=====  FUNCTION  =============================================================
#          NAME:  installRemoteFiles
#   DESCRIPTION:  Re-loads existing dotfiles for use
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function uninstallRemoteFiles()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="uninstallutils.sh";
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
        writeLogEntry "FILE" "DEBUG" "    fi${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_port -> ${target_port}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_user -> ${target_user}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "force_exec -> ${force_exec}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Generating validation script...";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Getting SSH host keys for host ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: getHostKeys \"${target_host}\" \"${target_port}\"";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    getHostKeys "${returnedHostInfo[0]}" ${returnedHostInfo[1]};
    ret_code=${?};

    cname="uninstallutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred getting SSH host keys from host ${target_host}. Please review logs.";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "target_host -> ${target_host}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Generating file cleanup file...";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
    fi

    file_removal_script="$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}")";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "file_removal_script -> ${file_removal_script}"; fi

    if [[ ! -e "${file_removal_script}" ]] || [[ ! -w "${file_removal_script}" ]]; then
        (( error_count += 1 ))

        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to generate the file verification script ${file_removal_script}. Please ensure the file exists and can be written to.";
    else
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Processing entries from ${INSTALL_CONF}"; fi

        if [[ -s "${INSTALL_CONF}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Populating file verification script ${file_removal_script}..."; fi

            ## change the IFS
            IFS="${MODIFIED_IFS}";

            ## clean up home directory first
            for entry in $(< "${INSTALL_CONF}"); do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry -> ${entry}"; fi

                [[ -z "${entry}" ]] && continue;
                [[ "${entry}" =~ ^\# ]] && continue;

                entry_command="$(cut -d "|" -f 1 <<< "${entry}")";
                entry_source="$(cut -d "|" -f 2 <<< "${entry}")";
                entry_target="$(cut -d "|" -f 3 <<< "${entry}")";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_command -> ${entry_command}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_source -> ${entry_source}";
                    writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "entry_target -> ${entry_target}";
                fi

                if [[ -z "${entry_command}" ]]; then
                    (( error_count += 1 ));

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry command from ${INSTALL_CONF} was empty. entry_command -> ${entry_command}";

                    continue;
                elif [[ -z "${entry_source}" ]]; then
                    (( error_count += 1 ));

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry source from ${INSTALL_CONF} was empty. entry_source -> ${entry_source}";

                    continue;
                elif [[ -z "${entry_source}" ]] && [[ "${entry_command}" == "ln" ]]; then
                    (( error_count += 1 ));

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry source from ${INSTALL_CONF} was empty. entry_source -> ${entry_source}";

                    continue;
                elif [[ -z "${entry_target}" ]] && [[ "${entry_command}" == "ln" ]]; then
                    (( error_count += 1 ));

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided entry target from ${INSTALL_CONF} was empty. entry_target -> ${entry_target}";

                    continue;
                fi

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Command -> ${entry_command}, Source -> ${entry_source}, target -> ${entry_target}"; fi

                if [[ "${entry_command}" == "ln" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Entry command is ${entry_command}";
                        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: { printf \"%s %s\n\" \"unlink\" \"${entry_target}\"; } >> \"${file_removal_script}\"";
                    fi

                    { printf "%s %s %s\n" "-" "rm" "${entry_target}"; } >> "${file_removal_script}";
                fi

                [[ -n "${ret_code}" ]] && unset -v ret_code;
                [[ -n "${entry_command}" ]] && unset -v entry_command;
                [[ -n "${entry_source}" ]] && unset -v entry_source;
                [[ -n "${entry_target}" ]] && unset -v entry_target;
                [[ -n "${entry}" ]] && unset -v entry;
            done

            ## restore the original ifs
            IFS="${CURRENT_IFS}";

            if [[ ! -s "${file_removal_script}" ]]; then
                (( error_count += 1 ))

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to populate the file cleanup file ${file_removal_script}. Please ensure the file exists and can be written to.";
            else
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: ssh -ql "${target_user}" -p ${target_port} \"${target_host}\" \"cd ${DOTFILES_BASE_PATH}; for file in \$(find . -type f) printf \"%s %s %s\n\" \"-\" \"rm\" \"${file}\"; done; for file in \$(find . -type d) printf \"%s %s %s\n\" \"-\" \"rmdir\" \"${file}\"; done;\" >> \"${file_removal_script}\""; fi

                ## get the file listing from the remote host
                ssh -ql "${target_user}" -p ${target_port} "${target_host}" "cd ${DOTFILES_BASE_PATH}; for file in \$(find . -type f) printf \"%s %s %s\n\" \"-\" \"rm\" \"${file}\"; done; for file in \$(find . -type d) printf \"%s %s %s\n\" \"-\" \"rmdir\" \"${file}\"; done;" >> "${file_removal_script}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: sftp -b ${file_removal_script} -oPort=${target_port} ${target_user}@${target_host} > /dev/null 2>&1"; fi

                sftp -b "${file_removal_script}" -oPort="${target_port}" "${target_user}@${target_host}" > /dev/null 2>&1;
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

                if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                    (( error_count += 1 ))

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "An error occurred during the file removal process on host ${target_host} as user ${target_user}. Please review logs.";
                fi
            fi
        else
            (( error_count += 1 ));

            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user.";
        fi
    fi

    ## cleanup (local)
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="$(basename "${file_removal_script}")|${TMPDIR:-${USABLE_TMP_DIR}},";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "cleanup_list -> ${cleanup_list}";
        writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_list}";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_list}";
    ret_code="${?}";

    cname="uninstallutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "FILE" "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "ret_code -> ${ret_code}"; fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "FILE" "ERROR" "${$}" "${cname}" "${LINENO}" "${function_name}" "Failed to execute cleanupFiles with cleanup type of ${CLEANUP_LOCATION_LOCAL}. Please review logs.";
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
