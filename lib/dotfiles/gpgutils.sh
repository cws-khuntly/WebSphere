#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  captureGpgData
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function captureGpgData()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="gpgutils.sh";
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

    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "STDOUT" "${cname}" "${function_name}" "${LINENO}" "Further information is required to generate GPG keys.";
    [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntry "STDOUT" "${cname}" "${function_name}" "${LINENO}" "Please provide the requested information:";

    while true; do
        while true; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Capture user input:";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: read -p \"Desired key algorithm: \" key_algo";
            fi

            read -p "Desired key algorithm: " key_algo;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "key_algo -> ${key_algo}";
            fi

            if [[ -n"${key_algo}" ]]; then
                break;
            fi

            continue;
        done

        while true; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Capture user input:";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: read -p \"Desired key bitsize: \" key_bits";
            fi

            read -p "Desired key length: " key_bits;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "key_bits -> ${key_bits}";
            fi

            if [[ -n"${key_bits}" ]]; then
                break;
            fi

            continue;
        done

        while true; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Capture user input:";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: read -p \"Desired subkey type: \" subkey_type";
            fi

            read -p "Desired subkey type: " subkey_type;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "subkey_type -> ${subkey_type}";
            fi

            if [[ -n"${subkey_type}" ]]; then
                break;
            fi

            continue;
        done

        while true; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Capture user input:";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: read -p \"Desired subkey length: \" subkey_length";
            fi

            read -p "Desired subkey length: " subkey_length;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "subkey_length -> ${subkey_length}";
            fi

            if [[ -n"${subkey_length}" ]]; then
                break;
            fi

            continue;
        done

        while true; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Capture user input:";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: read -p \"Provide your real name: \" real_name";
            fi

            read -p "Provide your name: " real_name;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "real_name -> ${real_name}";
            fi

            if [[ -n"${real_name}" ]]; then
                break;
            fi

            continue;
        done

        while true; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Capture user input:";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: read -p \"Provide your email address: \" email_address";
            fi

            read -p "Provide your email address: " email_address;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "email_address -> ${email_address}";
            fi

            if [[ -n"${email_address}" ]]; then
                break;
            fi

            continue;
        done

        while true; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Capture user input:";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: read -p \"Desired key lifetime: \" key_lifetime";
            fi

            read -p "Desired key lifetime: " key_lifetime;

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "key_lifetime -> ${key_lifetime}";
            fi

            if [[ -n"${key_lifetime}" ]]; then
                break;
            fi

            continue;
        done

        while true; do
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Capture user input:";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: read -p \"Desired key passphrase: \" key_passphrase";
            fi

            stty -echo;
            read -p "Desired key passphrase: " key_passphrase;
            stty echo;

            if [[ -n"${key_passphrase}" ]]; then
                break;
            fi

            continue;
        done

		break;
    done

	## at this point we should have enough information to populate the file
	sed -e "s/&key-algo/${key_algo}/" -e "s/&key-bits/${key_bits}/" -e "s/&key-type/${subkey_type}/" \
		"s/&key-length/${subkey_length}/" -e "s/&real-name/${real_name}/" -e "s/&emailaddr/${email_address}/" \
		"s/&expiry/${key_lifetime}/" -e "s/&passphrase/${key_passphrase}/" "${GPG_OPTION_TEMPLATE}" >| "${TMPDIR:-${USABLE_TMP_DIR}}/$(basename "${GPG_OPTION_TEMPLATE}")";

	if [[ ! -s "${TMPDIR:-${USABLE_TMP_DIR}}/$(basename "${GPG_OPTION_TEMPLATE}")" ]]; then
		## looks like something happened creating the file
		(( error_count += 1 ));

		writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while transferring the input to the answer file.";
	elif (( $(grep -c "&" "${TMPDIR:-${USABLE_TMP_DIR}}/$(basename "${GPG_OPTION_TEMPLATE}")") != 0 )); then
		(( error_count += 1 ));

		writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while transferring the input to the answer file.";
	fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${key_algo}" ]] && unset -v key_algo;
    [[ -n "${key_length}" ]] && unset -v key_length;
    [[ -n "${subkey_type}" ]] && unset -v subkey_type;
    [[ -n "${subkey_length}" ]] && unset -v subkey_length;
    [[ -n "${real_name}" ]] && unset -v real_name;
    [[ -n "${email_address}" ]] && unset -v email_address;
    [[ -n "${key_lifetime}" ]] && unset -v key_lifetime;
    [[ -n "${key_passphrase}" ]] && unset -v key_passphrase;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

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
    cname="gpgutils.sh";
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

    [[ -n "${ret_code}" ]] && unset -v ret_code;

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

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
