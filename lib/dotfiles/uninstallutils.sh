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
    continue_exec="${_TRUE}";

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "${function_name} -> enter";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Provided arguments: ${*}";
    fi

    uninstall_mode="${1}";
    target_host="${2}";
    target_port="${3}";
    target_user="${4}";
    force_exec="${5}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "uninstall_mode -> ${uninstall_mode}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_host -> ${target_host}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_port -> ${target_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_user -> ${target_user}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "force_exec -> ${force_exec}";
    fi

    case "${uninstall_mode}" in
        "${UNINSTALL_LOCATION_LOCAL}")
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: installLocalFiles"; fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            uninstallLocalFiles;
            ret_code="${?}";

            cname="uninstallutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Local installation of package failed. Please review logs.";
            fi
            ;;
        "${UNINSTALL_LOCATION_REMOTE}")
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: installLocalFiles"; fi

            [[ -n "${cname}" ]] && unset -v cname;
            [[ -n "${function_name}" ]] && unset -v function_name;
            [[ -n "${ret_code}" ]] && unset -v ret_code;

            uninstallRemoteFiles "${target_host}" "${target_port}" "${target_user}" "${force_exec}";
            ret_code="${?}";

            cname="uninstallutils.sh";
            function_name="${cname}#${FUNCNAME[0]}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ))

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Local installation of package failed. Please review logs.";
            fi
            ;;
        *)
            (( error_count += 1 ));

            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An invalid installation mode was specified. uninstall_mode -> ${uninstall_mode}. Cannot continue.";
            ;;
    esac

    [[ -n "${uninstall_mode}" ]] && unset -v uninstall_mode;
    [[ -n "${target_host}" ]] && unset -v target_host;
    [[ -n "${target_user}" ]] && unset -v target_user;
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
        start_epoch=$(printf "%(%s)T");

        writeLogEntry "PERFORMANCE" "${cname}" "${function_name}" "${LINENO}" "${function_name} START: $(date -d "@${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "${function_name} -> enter";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Provided arguments: ${*}";
    fi

    if [[ -s "${INSTALL_CONF}" ]]; then
        ## change the IFS
        IFS="${MODIFIED_IFS}";

        ## clean up home directory first
        for entry in $(< "${INSTALL_CONF}"); do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry -> ${entry}"; fi

            [[ -z "${entry}" ]] && continue;
            [[ "${entry}" =~ ^\# ]] && continue;

            entry_command="$(cut -d "|" -f 1 <<< "${entry}")";
            entry_source="$(cut -d "|" -f 2 <<< "${entry}")";
            entry_target="$(cut -d "|" -f 3 <<< "${entry}")";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_command -> ${entry_command}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_source -> ${entry_source}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_target -> ${entry_target}";
            fi

            if [[ -z "${entry_command}" ]]; then
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Provided entry command from ${INSTALL_CONF} was empty. entry_command -> ${entry_command}";

                continue;
            elif [[ -z "${entry_source}" ]] && [[ "${entry_command}" == "ln" ]]; then
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Provided entry source from ${INSTALL_CONF} was empty. entry_source -> ${entry_source}";

                continue;
            elif [[ -z "${entry_target}" ]] && [[ "${entry_command}" == "ln" ]]; then
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Provided entry target from ${INSTALL_CONF} was empty. entry_target -> ${entry_target}";

                continue;
            fi

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Command -> ${entry_command}, Source -> ${entry_source}, target -> ${entry_target}"; fi

            case "${entry_command}" in
                "mkdir")
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Creating directory ${entry_target}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mkdir -p ${entry_target}";
                    fi

                    mkdir -p "$(eval printf "%s" "${entry_target}")";
                    ret_code="${?}";

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                    then
                        (( error_count += 1 ));

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to create directory ${entry_target}.";

                        continue;
                    fi

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "INFO" "${cname}" "${function_name}" "${LINENO}" "Directory ${entry_target} created";
                    ;;
                "ln")
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Removing symbolic link ${entry_target} if exists...";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC:
                            [[ -L \$(eval printf \"%s\" ${entry_target}) ]] && unlink \$(eval printf \"%s\" ${entry_target})
                            [[ -f \$(eval printf \"%s\" ${entry_target}) ]] && rm -f \$(eval printf \"%s\" ${entry_target})";
                    fi

                    [[ -L "$(eval printf "%s" "${entry_target}")" ]] && unlink "$(eval printf "%s" "${entry_target}")";
                    [[ -f "$(eval printf "%s" "${entry_target}")" ]] && rm -f "$(eval printf "%s" "${entry_target}")";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Creating symbolic link ${entry_source} -> ${entry_target}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: ln -s eval printf \"%s\" ${entry_source} eval printf \"%s\" ${entry_target}";
                    fi

                    ln -s "$(eval printf "%s" "${entry_source}")" "$(eval printf "%s" "${entry_target}")";
                    ret_code="${?}";

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 ))
                    then
                        (( error_count += 1 ));

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to create symbolic link ${entry_target} with source ${entry_source}.";

                        continue;
                    fi

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "INFO" "${cname}" "${function_name}" "${LINENO}" "Symbolic link ${entry_source} -> ${entry_target} created.";
                    ;;
                *)
                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "INFO" "${cname}" "${function_name}" "${LINENO}" "Skipping entry ${entry_command}.";

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

        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user.";
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${entry_command}" ]] && unset -v entry_command;
    [[ -n "${entry_source}" ]] && unset -v entry_source;
    [[ -n "${entry_target}" ]] && unset -v entry_target;
    [[ -n "${entry}" ]] && unset -v entry;

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
    force_exec="${4}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_host -> ${target_host}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_port -> ${target_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_user -> ${target_user}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "force_exec -> ${force_exec}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Generating validation script...";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
    fi

    if [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_FALSE}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Checking host availibility for ${target_host}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: validateHostAddress ${target_host} ${target_port}";
        fi

        [[ -n "${cname}" ]] && unset -v cname;
        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        validateHostAddress "${target_host}" "${target_port}";
        ret_code="${?}";

        cname="uninstallutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred during the host availability check. Setting continue_exec to ${_FALSE}";
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred checking host availability for host ${target_host}. Please review logs.";
        fi
    fi

    if [[ -n "${force_exec}" ]] && [[ "${force_exec}" == "${_TRUE}" ]] || [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Getting SSH host keys for host ${target_host}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: getHostKeys \"${target_host}\" \"${target_port}\"";
        fi

        [[ -n "${cname}" ]] && unset -v cname;
        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        getHostKeys "${target_host}" ${target_port};
        ret_code=${?};

        cname="uninstallutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

        if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred getting SSH host keys from host ${target_host}. Please review logs.";
        fi

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "target_host -> ${target_host}";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Generating file cleanup file...";
            writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: mktemp --tmpdir=${TMPDIR:-${USABLE_TMP_DIR}}";
        fi

        file_removal_script="$(mktemp --tmpdir="${TMPDIR:-${USABLE_TMP_DIR}}")";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "file_removal_script -> ${file_removal_script}"; fi

        if [[ ! -e "${file_removal_script}" ]] || [[ ! -w "${file_removal_script}" ]]; then
            (( error_count += 1 ))

            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to generate the file verification script ${file_removal_script}. Please ensure the file exists and can be written to.";
        else
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Processing entries from ${INSTALL_CONF}"; fi

            if [[ -s "${INSTALL_CONF}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Populating file verification script ${file_removal_script}...";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC:
                        printf \"%s\n\n\" #!/usr/bin/env bash
                        printf \"%s\n\" PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;
                        printf \"%s\n\n\" error_count=0;";
                fi

                ## set script header
                {
                    printf "%s\n\n" "#!/usr/bin/env bash";
                    printf "%s\n" "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin;";
                    printf "%s\n\n" "error_count=0;";
                } >| "${file_removal_script}";
                
                ## change the IFS
                IFS="${MODIFIED_IFS}";

                ## clean up home directory first
                for entry in $(< "${INSTALL_CONF}"); do
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry -> ${entry}"; fi

                    [[ -z "${entry}" ]] && continue;
                    [[ "${entry}" =~ ^\# ]] && continue;

                    entry_command="$(cut -d "|" -f 1 <<< "${entry}")";
                    entry_source="$(cut -d "|" -f 2 <<< "${entry}")";
                    entry_target="$(cut -d "|" -f 3 <<< "${entry}")";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_command -> ${entry_command}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_source -> ${entry_source}";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry_target -> ${entry_target}";
                    fi

                    if [[ -z "${entry_command}" ]]; then
                        (( error_count += 1 ));

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Provided entry command from ${INSTALL_CONF} was empty. entry_command -> ${entry_command}";

                        continue;
                    elif [[ -z "${entry_source}" ]] && [[ "${entry_command}" == "ln" ]]; then
                        (( error_count += 1 ));

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Provided entry source from ${INSTALL_CONF} was empty. entry_source -> ${entry_source}";

                        continue;
                    elif [[ -z "${entry_target}" ]] && [[ "${entry_command}" == "ln" ]]; then
                        (( error_count += 1 ));

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Provided entry target from ${INSTALL_CONF} was empty. entry_target -> ${entry_target}";

                        continue;
                    fi

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Command -> ${entry_command}, Source -> ${entry_source}, target -> ${entry_target}"; fi

                    case "${entry_command}" in
                        "mkdir")
                            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Entry command is ${entry_command}";
                                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: { printf \"%s %s %s\n\" \"-\" \"rm\" \"${entry_target}\"; } >> \"${file_removal_script}\"";
                            fi

                            { printf "%s %s %s\n" "-" "rm" "${entry_target}"; } >> "${file_removal_script}";
                            ;;
                        "ln")
                            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Entry command is ${entry_command}";
                                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: { printf \"%s %s %s\n\" \"-\" \"unlink\" \"${entry_target}\"; } >> \"${file_removal_script}\"";
                            fi

                            { printf "%s %s %s\n" "-" "unlink" "${entry_target}"; } >> "${file_removal_script}";
                            ;;
                        *)
                            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "INFO" "${cname}" "${function_name}" "${LINENO}" "Skipping entry ${entry_command}.";

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

                if [[ ! -s "${file_removal_script}" ]]; then
                    (( error_count += 1 ))

                    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to populate the file cleanup file ${file_removal_script}. Please ensure the file exists and can be written to.";
                else
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: sftp -b ${file_removal_script} -oPort=${target_port} ${target_user}@${target_host} > /dev/null 2>&1"; fi

                    sftp -b "${file_removal_script}" -oPort="${target_port}" "${target_user}@${target_host}" > /dev/null 2>&1;
                    ret_code="${?}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                        (( error_count += 1 ))

                        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred during the file removal process on host ${target_host} as user ${target_user}. Please review logs.";
                    fi
                fi
            else
                (( error_count += 1 ));

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Installation configuration file ${INSTALL_CONF} not found or cannot be read. Please ensure the file exists and can be read by the current user.";
            fi
        fi
    fi

    ## cleanup (local)
    [[ -n "${cleanup_list}" ]] && unset -v cleanup_list;

    cleanup_list="$(basename "${file_removal_script}")|${TMPDIR:-${USABLE_TMP_DIR}},";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "cleanup_list -> ${cleanup_list}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: cleanupFiles ${CLEANUP_LOCATION_LOCAL} ${cleanup_list}";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    cleanupFiles "${CLEANUP_LOCATION_LOCAL}" "${cleanup_list}";
    ret_code="${?}";

    cname="uninstallutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

    if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Failed to execute cleanupFiles with cleanup type of ${CLEANUP_LOCATION_LOCAL}. Please review logs.";
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${entry_command}" ]] && unset -v entry_command;
    [[ -n "${entry_source}" ]] && unset -v entry_source;
    [[ -n "${entry_target}" ]] && unset -v entry_target;
    [[ -n "${entry}" ]] && unset -v entry;

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
