# conftest_pull
# ==============
#
# Summary: Pulls the redhat-cop/rego-policies when the policy directory does not exist, to make local development easier.
#
# Usage: conftest_pull
#
# Options:
#   none
# Globals:
#   none
# Returns:
#   none
conftest_pull() {
  if [[ ! -d "policy" ]]; then
    conftest pull github.com/redhat-cop/rego-policies.git//policy
  fi
}

# get_rego_namespaces
# ====================
#
# Summary: Resolves the package names in your rego policies against a regex lookup
#
# Usage: get_rego_namespaces ${regex}
#
# Options:
#   <regex>     Regex pattern matching package name
# Globals:
#   none
# Returns:
#   string - list of --namespaces {which-matched-regex}
get_rego_namespaces() {
  local regex="${1:-.*}"
  declare -a namespaces

  # shellcheck disable=SC2038
  for file in $(find policy/* -name "*.rego" -type f | xargs); do
    read -r line < "${file}"

    local current
    current="$(echo "${line/package/}" | xargs)"

    local found
    found="$(echo "${current}" | grep -P "${regex}" || true)"
    if [[ -n "${found}" ]]; then
      if [[ ! "${namespaces[*]}" =~ ${current} ]]; then
        namespaces+=("--namespace ${current}")
      fi
    fi
  done

  # Safety check to make sure nothing above silently failed
  if [[ ${#namespaces[*]} -lt 1 ]]; then
    fail "# FATAL-ERROR: (conftest.bash): Found no namespaces; either in the 'policy' dir or matched the regex '${regex}'" || return $?
  fi

  echo "${namespaces[*]}"
}