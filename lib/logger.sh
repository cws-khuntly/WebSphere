#!/usr/bin/env bash

#======  FUNCTION  ============================================================
#          NAME:  rotateArchiveLogs
#   DESCRIPTION:  Rotates log files in archive directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function rotateArchiveLogs()
{
    set +o noclobber;
    typeset SCRIPT_NAME="logging.sh";
    typeset FUNCTION_NAME="${FUNCNAME[0]}";
    typeset -i COUNTER=${LOG_RETENTION_PERIOD};
    typeset -i RETURN_CODE=0;

    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} START: $(/usr/bin/env date +"${TIMESTAMP_OPTS}")";
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i START_EPOCH=$(/usr/bin/env date +"%s");

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "Provided arguments: ${*}";

    for LOG_FILE in $(/usr/bin/env | /usr/bin/env grep "LOG_FILE" | /usr/bin/env cut -d "=" -f 2)
    do
        [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "LOG_FILE -> ${LOG_FILE}";

        for ARCHIVE_FILE in $(/usr/bin/env ls -ltr ${ARCHIVE_LOG_ROOT} | /usr/bin/env grep "$(/usr/bin/env cut -d "." -f 1 <<< "${LOG_FILE}")" | /usr/bin/env awk '{print $NF}')
        do
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "ARCHIVE_FILE -> ${ARCHIVE_FILE}";

            typeset -i FILE_COUNT="$(/usr/bin/env awk -F "." '{print $NF}' <<< "${ARCHIVE_FILE}")";
            typeset -i NEW_FILE_COUNT=$(( FILE_COUNT + 1 ));
            typeset BASE_FILE_NAME="$(/usr/bin/env basename $(/usr/bin/env awk 'BEGIN{FS=OFS="."}{$NF=""; NF--; print}' <<< ${ARCHIVE_FILE}))";

            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "FILE_COUNT -> ${FILE_COUNT}";
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "NEW_FILE_COUNT -> ${NEW_FILE_COUNT}";
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "BASE_FILE_NAME -> ${BASE_FILE_NAME}";

            case ${FILE_COUNT} in
                ${LOG_RETENTION_PERIOD})
                    ## delete
                    /usr/bin/env rm -f ${ARCHIVE_FILE};

                    [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
                    [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
                    [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
                    [ ! -z "${ARCHIVE_FILE}" ] && unset -v ARCHIVE_FILE;

                    continue;
                    ;;
                *)
                    /usr/bin/env cat ${ARCHIVE_FILE} >| ${ARCHIVE_LOG_ROOT}/${BASE_FILE_NAME}.${NEW_FILE_COUNT};
                    ;;
            esac

            [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
            [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
            [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
            [ ! -z "${ARCHIVE_FILE}" ] && unset -v ARCHIVE_FILE;
        done

        [ ! -z "${LOG_FILE}" ] && unset -v LOG_FILE;
    done

    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} -> exit";

    [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
    [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
    [ ! -z "${ARCHIVE_FILE}" ] && unset -v ARCHIVE_FILE;
    [ ! -z "${FUNCNAME}" ] && unset -v FUNCNAME;
    [ ! -z "${COUNTER}" ] && unset -v COUNTER;

    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i END_EPOCH=$(/usr/bin/env date +"%s");
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i RUNTIME=$(( START_EPOCH - END_EPOCH ));
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} TOTAL RUNTIME: $(( RUNTIME / 60)) MINUTES, TOTAL ELAPSED: $(( RUNTIME % 60)) SECONDS";
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} END: $(/usr/bin/env date +"${TIMESTAMP_OPTS}")";

    [ ! -z "${FUNCTION_NAME}" ] && unset -v FUNCTION_NAME;
    [ ! -z "${SCRIPT_NAME}" ] && unset -v SCRIPT_NAME;

    return ${RETURN_CODE};
}

#======  FUNCTION  ============================================================
#          NAME:  rotateLogs
#   DESCRIPTION:  Rotates log files in logs directory
#    PARAMETERS:  None
#       RETURNS:  0 regardless of result.
#==============================================================================
function rotateLogs()
{
    set +o noclobber;
    typeset SCRIPT_NAME="logging.sh";
    typeset FUNCTION_NAME="${FUNCNAME[0]}";
    typeset -i COUNTER=${LOG_RETENTION_PERIOD};
    typeset -i RETURN_CODE=0;

    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} START: $(/usr/bin/env date +"${TIMESTAMP_OPTS}")";
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i START_EPOCH=$(/usr/bin/env date +"%s");

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "Provided arguments: ${*}";

    ## rotate archive logs first
    rotateArchiveLogs;

    for LOG_FILE in $(/usr/bin/env | /usr/bin/env grep "LOG_FILE" | /usr/bin/env cut -d "=" -f 2)
    do
        [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "LOG_FILE -> ${LOG_FILE}";

        for FILE in $(/usr/bin/env ls -ltr ${LOG_ROOT} | /usr/bin/env grep "$(/usr/bin/env cut -d "." -f 1 <<< "${LOG_FILE}")" | /usr/bin/env awk '{print $NF}')
        do
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "FILE -> ${FILE}";

            typeset -i FILE_COUNT="$(/usr/bin/env awk -F "." '{print $NF}' <<< "${FILE}")";
            typeset -i NEW_FILE_COUNT=$(( FILE_COUNT + 1 ));
            typeset BASE_FILE_NAME="$(/usr/bin/env basename $(/usr/bin/env awk 'BEGIN{FS=OFS="."}{$NF=""; NF--; print}' <<< ${FILE}))";

            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "FILE_COUNT -> ${FILE_COUNT}";
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "NEW_FILE_COUNT -> ${NEW_FILE_COUNT}";
            [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "BASE_FILE_NAME -> ${BASE_FILE_NAME}";

            case ${FILE_COUNT} in
                ${LOG_RETENTION_PERIOD})
                    ## mv it straight off to arhive dir
                    /usr/bin/env mv ${FILE} ${ARCHIVE_LOG_ROOT}/${BASE_FILE_NAME};

                    [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
                    [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
                    [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
                    [ ! -z "${FILE}" ] && unset -v FILE;

                    continue;
                    ;;
                *)
                    /usr/bin/env cat ${FILE} >| ${LOG_ROOT}/${BASE_FILE_NAME}.${NEW_FILE_COUNT};
                    ;;
            esac

            [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
            [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
            [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
            [ ! -z "${FILE}" ] && unset -v FILE;
        done

        typeset TOUCH_LOG_FILE="$(/usr/bin/env sed -e "s/.log/.${DATE_PATTERN}.log/" <<< "${LOG_FILE}")";

        [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "TOUCH_LOG_FILE -> ${TOUCH_LOG_FILE}";

        /usr/bin/env touch ${TOUCH_LOG_FILE};

        [ ! -z "${TOUCH_LOG_FILE}" ] && unset -v TOUCH_LOG_FILE;
        [ ! -z "${LOG_FILE}" ] && unset -v LOG_FILE;
    done

    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
    [ ! -z "${ENABLE_DEBUG}" -a "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} -> exit";

    [ ! -z "${LOG_FILE}" ] && unset -v LOG_FILE;
    [ ! -z "${FILE_COUNT}" ] && unset -v FILE_COUNT;
    [ ! -z "${NEW_FILE_COUNT}" ] && unset -v NEW_FILE_COUNT;
    [ ! -z "${BASE_FILE_NAME}" ] && unset -v BASE_FILE_NAME;
    [ ! -z "${FILE}" ] && unset -v FILE;
    [ ! -z "${COUNTER}" ] && unset -v COUNTER;

    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i END_EPOCH=$(/usr/bin/env date +"%s");
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && typeset -i RUNTIME=$(( START_EPOCH - END_EPOCH ));
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} TOTAL RUNTIME: $(( RUNTIME / 60)) MINUTES, TOTAL ELAPSED: $(( RUNTIME % 60)) SECONDS";
    [ ! -z "${ENABLE_PERFORMANCE}" -a "${ENABLE_PERFORMANCE}" = "${_TRUE}" ] && writeLogEntry "PERFORMANCE" "${FUNCTION_NAME}" "${SCRIPT_NAME}" "${LINENO}" "${FUNCTION_NAME} END: $(/usr/bin/env date +"${TIMESTAMP_OPTS}")";

    [ ! -z "${FUNCTION_NAME}" ] && unset -v FUNCTION_NAME;
    [ ! -z "${SCRIPT_NAME}" ] && unset -v SCRIPT_NAME;

    return ${RETURN_CODE};
}

#=====  FUNCTION  =============================================================
#          NAME:  writeLogEntry
#   DESCRIPTION:  Cleans up the archived log directory
#    PARAMETERS:  Archive Directory, Logfile Name, Retention Time
#       RETURNS:  0 regardless of result.
#==============================================================================
function writeLogEntry()
{
    if [[ -z "${LOGGING_LOADED}" ]] || [[ "${LOGGING_LOADED}" == "${_FALSE}" ]]
    then
        if [[ -r "/etc/logging.properties" ]]; then source "/etc/logging.properties"; fi
    fi

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi
    if [[ -n "${ENABLE_LOGGER_VERBOSE}" ]] && [[ "${ENABLE_LOGGER_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_LOGGER_TRACE}" ]] && [[ "${ENABLE_LOGGER_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    ## create the directory if it doesn't already exist
    if [[ -n "${LOG_ROOT}" ]] && [[ ! -d "${LOG_ROOT}" ]]; then mkdir -pv "${LOG_ROOT}"; fi

    set +o noclobber;
    write_to_log="${_TRUE}";

    if (( ${#} == 0 )) || (( ${#} != 5 ))
    then
        return_code=3;

        printf "\e[00;31m%s\e[00;32m\n" "${BASH_SOURCE[0]}#${FUNCNAME[0]} - Write a log message to stdout/err or to a logfile" >&2;
        printf "\e[00;31m%s\e[00;32m\n" "Usage: ${FUNCNAME[0]} [ <level> ] [ <class/script> ] [ <method> ] [ <line> ] [ <message> ]
                 -> The level to write for. Supported levels (not case-sensitive):
                     STDOUT
                     STDERR
                     PERFORMANCE
                     FATAL
                     ERROR
                     INFO
                     WARN
                     AUDIT
                     DEBUG
                 -> The class/script calling the logger
                 -> The method calling the logger
                 -> The line number making the call
                 -> The message to be printed.\n" >&2;

        return ${return_code};
    fi

    log_level="${1}";
    log_source="${2}";
    log_method="${3}";
    log_line="${4}";
    log_message="${5}";
    log_date="$(printf "%($(printf "%s" "${TIMESTAMP_OPTS}"))T %s")";

    case "${log_level}" in
        [Ss][Tt][Dd][Oo][Uu][Tt]) printf "%s\n" "${log_message}" >&1; write_to_log="${_FALSE}" ;;
        [Ss][Tt][Dd][Ee][Rr][Rr]) printf "\e[00;31m%s\e[00;32m\n" "${log_message}" >&2; write_to_log="${_FALSE}" ;;
        [Pp][Ee][Rr][Ff][Oo][Rr][Mm][Aa][Nn][Cc][Ee]) log_file="${PERF_LOG_FILE}"; ;;
        [Ff][Aa][Tt][Aa][Ll]) log_file="${FATAL_LOG_FILE}"; ;;
        [Ee][Rr][Rr][Oo][Rr]) log_file="${ERROR_LOG_FILE}"; ;;
        [Ww][Aa][Rr][Nn]) log_file="${WARN_LOG_FILE}"; ;;
        [Ii][Nn][Ff][Oo]) log_file="${INFO_LOG_FILE}"; ;;
        [Aa][Uu][Dd][Ii][Tt]) log_file="${AUDIT_LOG_FILE}"; ;;
        [Dd][Ee][Bb][Uu][Gg]) log_file="${DEBUG_LOG_FILE}"; ;;
        [Mm][Oo][Nn][Ii][Tt][Oo][Rr]) log_file="${MONITOR_LOG_FILE}"; ;;
        *) log_file="${DEFAULT_LOG_FILE}"; ;;
    esac

    if [[ "${write_to_log}" == "${_TRUE}" ]] && [[ -n "${log_file}" ]] && [[ -w "${LOG_ROOT}" ]]
    then
        printf "%s %s%s %s %s %s %s %s %s\n" "${CONVERSION_PATTERN}" "${log_date}" "${PPID}" "${log_file}" "${log_level}" "${log_source}" "${log_line}" "${log_method}" "${log_message}" >> "${LOG_ROOT}/${log_file}";
    fi

    [[ -n "${log_date}" ]] && unset -v log_date;
    [[ -n "${log_level}" ]] && unset -v log_level;
    [[ -n "${log_method}" ]] && unset -v log_method;
    [[ -n "${log_source}" ]] && unset -v log_source;
    [[ -n "${log_line}" ]] && unset -v log_line;
    [[ -n "${log_message}" ]] && unset -v log_message;
    [[ -n "${log_file}" ]] && unset -v log_file;
    [[ -n "${write_to_log}" ]] && unset -v write_to_log;

    if [[ -n "${ENABLE_LOGGER_VERBOSE}" ]] && [[ "${ENABLE_LOGGER_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_LOGGER_TRACE}" ]] && [[ "${ENABLE_LOGGER_TRACE}" == "${_TRUE}" ]]; then set +v; fi
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    return 0;
}

