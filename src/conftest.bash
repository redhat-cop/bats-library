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
    local line
    line="$(grep -P "^package " "${file}")"

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

# filter_policies_by_version
# ====================
#
# Summary: Filters (via rm -f) deprek8ion and redhat-cop based on the version in the path
#
# Usage: filter_policies_by_version ${deprek8ion_k8s_version} ${redhatcop_ocp_version}
#
# Options:
#   <deprek8ion_k8s_version>    Max version to use for deprek8ion policies
#   <redhatcop_ocp_version>     Max version to use for redhat-cop deprecated policies
#   <policy_dir>                Directory where policies are, defaults to: policy
# Globals:
#   none
# Returns:
#   none
filter_policies_by_version() {
  local deprek8ion_k8s_version="${1}"
  local redhatcop_ocp_version="${2}"
  local policy_dir="${3:-policy}"

  if [[ -n "${deprek8ion_k8s_version}" ]]; then
    # shellcheck disable=SC2038
    for file in $(find "${policy_dir}" -name "kubernetes-*.rego" -type f | xargs); do
      k8s_ver=$(echo "$file" | awk '{split($0,a,"-"); split(a[2],b,".rego"); print b[1]}')
      if [[ $(echo "$k8s_ver > $deprek8ion_k8s_version" | bc -l) -eq 1 ]]; then
        #echo "DEBUG: Matched deprek8ion: $file"
        rm -f "${file}"
      fi
    done
  fi

  if [[ -n "${redhatcop_ocp_version}" ]]; then
    # shellcheck disable=SC2038
    for dir in $(find "${policy_dir}/ocp/deprecated" -maxdepth 1 -name "ocp[0-9]_*" -type d  | xargs); do
      ocp_ver=$(basename "${dir}" | awk '{sub("_",".",$0);sub("ocp","",$0); print $0}')
      echo "$ocp_ver > $redhatcop_ocp_version"
      if [[ $(echo "$ocp_ver > $redhatcop_ocp_version" | bc -l) -eq 1 ]]; then
        #echo "DEBUG: Matched redhat-cop: $dir"
        rm -rf "${dir}"
      fi
    done
  fi
}
