# file_contains_dollar
# =====================
#
# Summary: Checks a file does not contain a '$'
#          i.e.: if a processed template still contains a '$', its typically because a param has been missed.
#
# Usage: file_contains_dollar ${file_path}
#
# Options:
#   <file_path>     File path to search
#   <should_fail>   Boolean value as to whether to fail the test or not, defaults to true
# Globals:
#   none
# Returns:
#   none
file_contains_dollar() {
  local file_path="${1}"
  local should_fail="${2:-true}"

  # shellcheck disable=SC2038
  for file in $(find "${file_path}" \( -name "*.yml" -o -name "*.json" \) -type f | xargs); do
    local found
    found="$(grep --line-number "\\$" "${file}" || true)"

    if [[ -n "${found}" ]]; then
      batslib_err "# Failed: Found a dollar ($):" | batslib_err "${found}"
      if [[ "${should_fail}" == "true" ]]; then
        fail ""
      fi
    fi
  done
}