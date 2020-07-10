# split_files
# ============
#
# Summary: Split a YML/JSON file which contains an array, such as a List or Template. If a template is found, 'oc process' is executed.
#
# Usage: split_files <search_path>
#
# Options:
#   <search_path>   'find' search path for files to process
# Globals:
#   none
# Returns:
#   string - path to where files have been processed, i.e.: /tmp/rhcop/${date-time}/${search_path}
split_files() {
  local search_path="${1}"
  local dont_resolve_key="${2}"

  local tmp_write_dir
  if [[ -d "${search_path}" ]]; then
    tmp_write_dir=$(_create_tmp_write_dir "${search_path}")
  else
    tmp_write_dir=$(_create_tmp_write_dir "$(dirname "${search_path}")")
  fi

  # shellcheck disable=SC2038
  for file in $(find "${search_path}" \( -name "*.yml" -o -name "*.json" \) -type f | xargs); do
    # Resolve the key from the file
    local key
    if [[ -z "${dont_resolve_key}" ]]; then
      key="$(yq -r 'keys | .[] | select(. == "objects" or . == "items")' "${file}")"
    fi

    # If the key is empty, its probably a YAML list
    if [[ -z "${key}" ]]; then
      key="."
    fi

    local yq_opts
    if [[ "${file#*.}" == "yml" ]]; then
      yq_opts="--yaml-output"
    fi

    local yq_command
    if [[ "${key}" == "objects" ]]; then
      # Process the template, split the List and write to a tmp dir
      yq_command="oc process -f ${file} --local -o json | yq ${yq_opts} '.items[]'"
    elif [[ "${key}" == "items" ]]; then
      # Split the List and write to a tmp dir
      yq_command="yq ${yq_opts} '.items[]' ${file}"
    elif [[ "${key}" == "." ]]; then
      # It doesnt require splitting, just write to a tmp dir to validate the syntax
      yq_command="yq ${yq_opts} '.' ${file}"
    else
      fail "# FATAL-ERROR: (yaml-json-manipulation.bash): Unsupported key: '${key}'"
    fi

    # NOTE: eval is used due to yq not liking empty yq_opts
    eval "${yq_command} > ${tmp_write_dir}/$(basename "${file}")"

    # Safety check to make sure nothing above silently failed
    if [[ ! -s "${file}" ]]; then
      fail "# FATAL-ERROR: (yaml-json-manipulation.bash): File is empty: '${file}'"
    fi
  done

  # Another safety check to make sure nothing above silently failed
  if [[ "$(find "${tmp_write_dir}" -type f | wc -l)" -lt 1 ]] ; then
    fail "# FATAL-ERROR: (yaml-json-manipulation.bash): No files created: '${tmp_write_dir}'"
  fi

  echo "${tmp_write_dir}"
}

_create_tmp_write_dir() {
  local tmp_write_dir
  tmp_write_dir=/tmp/rhcop/$(date +'%d-%m-%Y-%H-%M')/"${1}"

  mkdir -p "${tmp_write_dir}"

  echo "${tmp_write_dir}"
}