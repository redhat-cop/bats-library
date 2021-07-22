# print_info
# ===========
#
# Summary: Prints out the status and output.
#
# Usage: print_info <status> <output> <cmd> <tmp>
#
# Options:
#   <status>   ${status} returned from BATS
#   <output>   ${output} returned from BATS
#   <cmd>      ${cmd} executed via run
#   <tmp>      ${tmp} returned from 'split_via_key'
# Globals:
#   none
# Returns:
#   none
print_info() {
  local status="${1}"
  local output="${2}"
  local cmd="${3}"
  local tmp="${4}"

  batslib_err "# Status: ${status}"
  batslib_err "# CMD: '${cmd}'"

  if [[ -d "${tmp}" ]] || [[ -f "${tmp}" ]]; then
    batslib_err "# TMP: '${tmp}'"
    batslib_err "# Processed Files:"

    # shellcheck disable=SC2038
    for file in $(find "${tmp}" -type f | xargs); do
      batslib_err "# ${file}"
    done
  else
    fail "# FATAL-ERROR: (error-handling.bash): Expected TMP to be a path but got: '${tmp}'" || return $?
  fi

  batslib_err "# Output"
  batslib_err "${output}"
}
