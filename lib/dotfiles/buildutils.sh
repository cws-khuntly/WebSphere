#!/usr/bin/env bash

#=====  FUNCTION  =============================================================
#          NAME:  deployFiles
#   DESCRIPTION:  ssh's to a target host and removes the existing dotfiles
#                 directory and copies the new one
#    PARAMETERS:  None
#       RETURNS:  0 if success, non-zero otherwise
#==============================================================================
function buildPackage()
(
    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set -x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set -v; fi

    set +o noclobber;
    cname="buildutils.sh";
    function_name="${cname}#${FUNCNAME[0]}";
    return_code=0;
    error_count=0;

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        start_epoch="$(date +"%s")";

        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} START: $(date -d @"${start_epoch}" +"${TIMESTAMP_OPTS}")";
    fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> enter";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Provided arguments: ${*}";
    fi

    if [[ ! -d "${TMPDIR:-${USABLE_TMP_DIR}}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Temporary directory ${TMPDIR:-${USABLE_TMP_DIR}} does not exist. Creating.";
        fi

        mkdir -p "${TMPDIR:-${USABLE_TMP_DIR}}";

        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
            writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Directory created: ${TMPDIR:-${USABLE_TMP_DIR}}";
        fi
    fi

    if [[ -d "${DOTFILES_BASE_PATH}" ]]; then
        if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "Switching to ${DOTFILES_BASE_PATH} to generate package"; fi

        cd "${DOTFILES_BASE_PATH}" || (( error_count += 1 ));

        if [[ "${PWD}" == "${DOTFILES_BASE_PATH}" ]]; then
            if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "EXEC: tar --exclude-vcs --exclude=README.md --exclude=LICENSE.md -cvf - * | ${ARCHIVE_PROGRAM} > ${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}"; fi

            tar --exclude-vcs --exclude=README.md --exclude=LICENSE.md --exclude=dotfiles.code-workspace -cf - ./* | ${ARCHIVE_PROGRAM} > "${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}";

            if [[ ! -s "${TMPDIR:-${USABLE_TMP_DIR}}/${PACKAGE_NAME}.${ARCHIVE_FILE_EXTENSION}" ]]; then
                (( error_count += 1 ))

                [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "Failed to generate source archive. Cannot continue.";
            fi
        else
            (( error_count += 1 ))

            [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "Failed to switch into directory ${DOTFILES_BASE_PATH}. Please ensure the directory exists and can be written to.";
        fi
    else
        (( error_count += 1 ))

        [[ "${LOGGING_LOADED}" == "${_TRUE}" ]] && writeLogEntryToFile "ERROR" "${cname}" "${function_name}" "${$}" "${LINENO}" "The specified source directory ${DOTFILES_BASE_PATH} does not exist. Cannot continue.";
    fi

    if [[ -n "${error_count}" ]] && (( error_count != 0 )); then return_code="${error_count}"; fi

    if [[ -n "${ENABLE_DEBUG}" ]] && [[ "${ENABLE_DEBUG}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "return_code -> ${return_code}";
        writeLogEntryToFile "DEBUG" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} -> exit";
    fi

    if [[ -n "${ENABLE_PERFORMANCE}" ]] && [[ "${ENABLE_PERFORMANCE}" == "${_TRUE}" ]] && [[ "${LOGGING_LOADED}" == "${_TRUE}" ]]; then
        end_epoch="$(date +"%s")"
        runtime=$(( end_epoch - start_epoch ));

        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} END: $(date -d "@${end_epoch}" +"${TIMESTAMP_OPTS}")";
        writeLogEntryToFile "PERFORMANCE" "${$}" "${cname}" "${LINENO}" "${function_name}" "${function_name} TOTAL RUNTIME: $(( runtime / 60)) MINUTES, TOTAL ELAPSED: $(( runtime % 60)) SECONDS";
    fi

    [[ -n "${error_count}" ]] && unset -v error_count;
    [[ -n "${function_name}" ]] && unset -v function_name;

    if [[ -n "${ENABLE_VERBOSE}" ]] && [[ "${ENABLE_VERBOSE}" == "${_TRUE}" ]]; then set +x; fi
    if [[ -n "${ENABLE_TRACE}" ]] && [[ "${ENABLE_TRACE}" == "${_TRUE}" ]]; then set +v; fi

    return ${return_code};
)
