#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  validateHostAvailability
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive
#    PARAMETERS:  Target host, port number (optional)
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function validateHostAddress()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="networkutils.sh";
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

    provided_hostname="${1}";
    provided_port="${2}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "provided_hostname -> ${provided_hostname}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "provided_port -> ${provided_port}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: checkForValidHost ${provided_hostname}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: checkForValidAddress ${provided_hostname}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: checkForValidPort ${provided_port}";
    fi

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${ret_code}" ]] && unset -v ret_code;

    validatedHostName="$(checkForValidHost "${provided_hostname}")";
    validatedHostAddress="$(checkForValidAddress "${provided_hostname}")";
    validatedPortNumber="$(checkForValidPort "${provided_port}")";

    cname="networkutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "validatedHostName -> ${validatedHostName}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "validatedHostAddress -> ${validatedHostAddress}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "validatedPortNumber -> ${validatedPortNumber}";
    fi

    if [[ -n "${validatedHostName}" ]] && [[ -n "${validatedPortNumber}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: checkIfHostIsAlive ${validatedHostName} ${validatedPortNumber}"; fi

        [[ -n "${cname}" ]] && unset -v cname;
        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        checkIfHostIsAlive "${validatedHostName}" "${validatedPortNumber}";
        ret_code="${?}";

        cname="networkutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi
    elif [[ -n "${validatedHostAddress}" ]] && [[ -n "${validatedPortNumber}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: checkIfHostIsAlive ${validatedHostAddress} ${validatedPortNumber}"; fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        checkIfHostIsAlive "${validatedHostAddress}" "${validatedPortNumber}";
        ret_code="${?}";

        cname="networkutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi
    elif [[ -n "${validatedHostName}" ]] && [[ -z "${validatedPortNumber}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: checkIfHostIsAlive ${validatedHostName}"; fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        checkIfHostIsAlive "${validatedHostName}";
        ret_code="${?}";

        cname="networkutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi
    elif [[ -n "${validatedHostAddress}" ]] && [[ -z "${validatedPortNumber}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: checkIfHostIsAlive ${validatedHostAddress}"; fi

        [[ -n "${function_name}" ]] && unset -v function_name;
        [[ -n "${ret_code}" ]] && unset -v ret_code;

        checkIfHostIsAlive "${validatedHostAddress}";
        ret_code="${?}";

        cname="networkutils.sh";
        function_name="${cname}#${FUNCNAME[0]}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi
    else
        (( error_count += 1 ));

        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An invalid hostname was provided. Cannot continue.";
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${validatedPortNumber}" ]] && unset -v validatedPortNumber;
    [[ -n "${validatedHostAddress}" ]] && unset -v validatedHostAddress;
    [[ -n "${validatedHostName}" ]] && unset -v validatedHostName;
    [[ -n "${provided_port}" ]] && unset -v provided_port;
    [[ -n "${provided_hostname}" ]] && unset -v provided_hostname;

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

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${random_generator}" ]] && unset -v random_generator;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  isValidHost
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive
#    PARAMETERS:  Target host, port number (optional)
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function checkForValidHost()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="networkutils.sh";
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

    checkForHostname="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "checkForHostname -> ${checkForHostname}"; fi

    if [[ -n "${checkForHostname}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: grep -qE \"^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$\" <<< ${checkForHostname}"; fi

        grep -qE "^([a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\.)+[a-zA-Z]{2,}$" <<< "${checkForHostname}";
        ret_code="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

        if [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: host -N 0 ${checkForHostname} > /dev/null 2>&1"; fi

            host -N 0 "${checkForHostname}" > /dev/null 2>&1;
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

            if [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Setting returnedHostname to ${checkForHostname}"; fi

                returnedHostname="${checkForHostname}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "returnedHostname -> ${returnedHostname}"; fi
            else
                ## host not found in dns, lets see if its in the hosts table
                ## NOTE: this assumes a properly formatted host entry in the form of <IP address> <FQDN> <alias(es)>
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Entry ${checkForHostname} was not found in DNS. Checking for entries in /etc/hosts...";
                    writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: grep -m 1 ${checkForHostname} /etc/hosts | awk '{print $2}'";
                fi

                searchForNameInHosts="$(grep -m 1 "${checkForHostname}" "/etc/hosts" | awk '{print $2}')";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "searchForNameInHosts -> ${searchForNameInHosts}"; fi

                ## entry found in /etc/hosts
                if [[ -n "${searchForNameInHosts}" ]]; then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Setting returnedHostname to ${searchForNameInHosts}"; fi

                    returnedHostname="${searchForNameInHosts}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "returnedHostname -> ${returnedHostname}"; fi
                else
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Looping through found search suffixes in /etc/resolv.conf"; fi

                    ## loop through all the possible domain names in /etc/resolv.conf
                    grep "search" < "/etc/resolv.conf" | while read -r resolver_entry; do
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "resolver_entry -> ${resolver_entry}"; fi

                        [[ "${resolver_entry}" == "search" ]] && continue;
                        [[ "${resolver_entry}" =~ ^\# ]] && continue;

                        ## check if in DNS...
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: host -N 0 ${checkForHostname}.${resolver_entry} > /dev/null 2>&1"; fi

                        host -N 0 "${checkForHostname}.${resolver_entry}" > /dev/null 2>&1;
                        ret_code="${?}";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                        if [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
                            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Setting returnedHostname to ${checkForHostname}.${resolver_entry}"; fi

                            returnedHostname="${checkForHostname}.${resolver_entry}";

                            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "returnedHostname -> ${returnedHostname}"; fi

                            [[ -n "${ret_code}" ]] && unset -v ret_code;
                            [[ -n "${resolver_entry}" ]] && unset -v resolver_entry;

                            break;
                        fi

                        [[ -n "${ret_code}" ]] && unset -v ret_code;
                        [[ -n "${resolver_entry}" ]] && unset -v resolver_entry;
                    done
                fi
            fi
        else
            (( error_count += 1 ));

            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "The provided information failed validation.";
        fi
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${searchForNameInHosts}" ]] && unset -v searchForNameInHosts;
    [[ -n "${checkForHostname}" ]] && unset -v checkForHostname;

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

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${error_count}" ]] && unset -v error_count;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    [[ -n "${returnedHostname}" ]] && printf "%s" "${returnedHostname}";
    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  isValidHost
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive
#    PARAMETERS:  Target host, port number (optional)
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function checkForValidAddress()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="networkutils.sh";
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

    checkForAddress="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "checkForAddress -> ${checkForAddress}"; fi

    if [[ -n "${checkForAddress}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: grep -qE \"^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$\" <<< ${checkForAddress}"; fi

        grep -qE "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" <<< "${checkForAddress}";
        ret_code="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

        if [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
            split_up=("${checkForAddress//./ }");

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "split_up -> ${split_up[*]}"; fi

            for entry in "${split_up[@]}"; do
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "entry -> ${entry}"; fi

                [[ -z "${entry}" ]] && continue;

                if [[ ${entry} =~ ^([0-9]){1,3}$ ]] && (( entry <= 254 )); then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Entry ${entry} is numeric."; fi
                else
                    (( counter += 1 ));

                    writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "Entry ${entry} is not numeric.";
                fi

                [[ -n "${entry}" ]] && unset -v entry;
            done

            if [[ -z "${counter}" ]] || (( counter == 0 )); then isValidAddress="${_TRUE}"; fi

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "isValidAddress -> ${isValidAddress}"; fi

            if [[ -n "${isValidAddress}" ]] && [[ "${isValidAddress}" == "${_TRUE}" ]]; then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: host -N 0 ${checkForAddress} > /dev/null 2>&1"; fi

                host -N 0 "${checkForAddress}" > /dev/null 2>&1;
                ret_code="${?}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

                if [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Setting checkForAddress to ${checkForAddress}"; fi

                    returnedHostAddress="${checkForAddress}";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "checkForAddress -> ${checkForAddress}"; fi
                else
                    ## host not found in dns, lets see if its in the hosts table
                    ## NOTE: this assumes a properly formatted host entry in the form of <IP address> <FQDN> <alias(es)>
                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Entry ${checkForAddress} was not found in DNS. Checking for entries in /etc/hosts...";
                        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: grep -m 1 ${checkForAddress} /etc/hosts | awk '{print $2}'";
                    fi

                    searchForAddressInHosts="$(grep -m 1 "${checkForAddress}" "/etc/hosts" | awk '{print $2}')";

                    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "searchForAddressInHosts -> ${searchForAddressInHosts}"; fi

                    ## entry found in /etc/hosts
                    if [[ -n "${searchForAddressInHosts}" ]]; then
                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Setting returnedHostAddress to ${searchForAddressInHosts}"; fi

                        returnedHostAddress="${searchForAddressInHosts}";

                        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "returnedHostAddress -> ${returnedHostAddress}"; fi
                    fi
                fi
            fi
        else
            (( error_count += 1 ));

            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "The provided information failed validation.";
        fi
    fi

    [[ -n "${isValidAddress}" ]] && unset -v isValidAddress;
    [[ -n "${searchForAddressInHosts}" ]] && unset -v searchForAddressInHosts;
    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${checkForAddress}" ]] && unset -v checkForAddress;

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

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${error_count}" ]] && unset -v error_count;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    [[ -n "${returnedHostAddress}" ]] && printf "%s" "${returnedHostAddress}";
    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  isValidHost
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive
#    PARAMETERS:  Target host, port number (optional)
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function checkForValidPort()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="networkutils.sh";
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

    checkPortNumber="${1}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "checkPortNumber -> ${checkPortNumber}"; fi

    if [[ -n "${checkPortNumber}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: grep -qE \"^[0-9]{1,5}$\" <<< ${checkPortNumber}"; fi

        grep -qE "^[0-9]{1,5}$" <<< "${checkPortNumber}";
        ret_code="${?}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

        if [[ -n "${ret_code}" ]] && (( ret_code == 0 )); then
            if (( provided_port > 0 )) && (( provided_port <= 65535 )); then
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "Setting returnedPortNumber to ${checkPortNumber}"; fi

                returnedPortNumber="${checkPortNumber}";

                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "returnedPortNumber -> ${returnedPortNumber}"; fi
            fi
        else
            (( error_count += 1 ));

            writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "The provided information failed validation.";
        fi
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${checkPortNumber}" ]] && unset -v checkPortNumber;

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

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${error_count}" ]] && unset -v error_count;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    [[ -n "${returnedPortNumber}" ]] && printf "%s" "${returnedPortNumber}";
    return ${return_code};
)

#=====  FUNCTION  =============================================================
#          NAME:  isValidHost
#   DESCRIPTION:  Validates that a given host exists in DNS and is alive
#    PARAMETERS:  Target host, port number (optional)
#       RETURNS:  0 if success, 1 otherwise
#==============================================================================
function checkIfHostIsAlive()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="networkutils.sh";
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

    checkNetworkName="${1}";
    checkNetworkPort="${2}";

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "checkNetworkName -> ${checkNetworkName}";
        writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "checkNetworkPort -> ${checkNetworkPort}";
    fi

    if [[ -n "${checkNetworkName}" ]] && [[ -n "${checkNetworkPort}" ]]; then
        if [[ -n "$(shopt -u expand_aliases; command -v nc; shopt -s expand_aliases)" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: nc -w ${REQUEST_TIMEOUT:-10} -z ${checkNetworkName} ${checkNetworkPort} > /dev/null 2>&1"; fi

            nc -w "${REQUEST_TIMEOUT:-10}" -z "${checkNetworkName}" "${checkNetworkPort}" > /dev/null 2>&1;
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

            if [[ -n "${ret_code}" ]] && (( ret_code != 0 )); then (( error_count += 1 )); fi
        elif [[ -n "$(shopt -u expand_aliases; command -v nmap; shopt -s expand_aliases)" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: nmap ${checkNetworkName} -PN -p ${validatedPortNumber} 2> /dev/null | grep \open | awk '{print $2}'"; fi

            isHostAvailable="$(nmap "${checkNetworkName}" -PN -p "${checkNetworkPort}" 2> /dev/null | grep "open")";
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "isHostAvailable -> ${isHostAvailable}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] && (( ret_code != 0 )); then
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while checking host availability via nmap - no return code/a non-zero return code was received.";
            elif [[ -z "${isHostAvailable}" ]] || [[ "${isHostAvailable}" != "open" ]]; then
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while checking host availability via nmap - no open port response was received.";
            else
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "nmap test for host ${checkNetworkName} and port ${checkNetworkPort} was successful"; fi
            fi
        else
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: timeout ${REQUEST_TIMEOUT:-10} bash -c \"cat < /dev/null > /dev/tcp/${checkNetworkName}/${checkNetworkPort}\""; fi

            timeout "${REQUEST_TIMEOUT:-10}" bash -c "cat < /dev/null > /dev/tcp/${checkNetworkName}/${checkNetworkPort}";
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}"; fi

            if [[ -z "${ret_code}" ]] || (( ret_code != 0 )); then
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while checking host availability via bash - no open port response was received.";
            fi
        fi
    elif [[ -n "${checkNetworkName}" ]] && [[ -z "${checkNetworkPort}" ]]; then
        if [[ -n "$(shopt -u expand_aliases; command -v nmap; shopt -s expand_aliases)" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "EXEC: nmap -sn ${checkNetworkName} 2> /dev/null | grep \"Host is up\""; fi

            isHostAvailable="$(nmap -sn "${checkNetworkName}" 2> /dev/null | grep "Host is up")";
            ret_code="${?}";

            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "isHostAvailable -> ${isHostAvailable}";
                writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "ret_code -> ${ret_code}";
            fi

            if [[ -z "${ret_code}" ]] && (( ret_code != 0 )); then
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while checking host availability via nmap - no return code/a non-zero return code was received.";
            elif [[ -z "${isHostAvailable}" ]] || [[ "${isHostAvailable}" != "Host is up" ]]; then
                (( error_count += 1 ));

                writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "An error occurred while checking host availability via nmap - no host up response was received.";
            else
                if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]]; then writeLogEntry "DEBUG" "${cname}" "${function_name}" "${LINENO}" "nmap test for host ${checkNetworkName} and port ${checkNetworkPort} was successful"; fi
            fi
        fi
    else
        (( error_count += 1 ));

        writeLogEntry "ERROR" "${cname}" "${function_name}" "${LINENO}" "No valid host entry was provided";
    fi

    [[ -n "${ret_code}" ]] && unset -v ret_code;
    [[ -n "${isHostAvailable}" ]] && unset -v isHostAvailable;
    [[ -n "${checkNetworkPort}" ]] && unset -v checkNetworkPort;
    [[ -n "${checkNetworkName}" ]] && unset -v checkNetworkName;

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

    [[ -n "${cname}" ]] && unset -v cname;
    [[ -n "${function_name}" ]] && unset -v function_name;
    [[ -n "${error_count}" ]] && unset -v error_count;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
