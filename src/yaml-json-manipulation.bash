# split_files
# ============
#
# Summary: Split a YML/JSON file which contains an array, such as a List or Template. If a template is found, 'oc process' is executed.
#
# Usage: split_files <search_path>
#
# Options:
#   <search_path>         'find' search path for files to process
#   <dont_resolve_key>    Whether a known key should be resolved. If dont want to split the file, set this to 'true'
# Globals:
#   none
# Returns:
#   string - path to where files have been processed, i.e.: /tmp/rhcop/${date-time}/${search_path}
split_files() {
  local search_path="${1}"
  local dont_resolve_key="${2}"

  local root_dir_search_path
  local tmp_write_dir
  if [[ -d "${search_path}" ]]; then
    root_dir_search_path="${search_path}"
    tmp_write_dir=$(_create_tmp_write_dir "${root_dir_search_path}")
  else
    root_dir_search_path=$(dirname "${search_path}")
    tmp_write_dir=$(_create_tmp_write_dir "${root_dir_search_path}")
  fi

  # shellcheck disable=SC2038
  for file in $(find "${search_path}" \( -name "*.yml" -o -name "*.yaml" -o -name "*.json" \) -type f | xargs); do
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
    if [[ "${file#*.}" == "yml" ]] || [[ "${file#*.}" == "yaml" ]] ; then
      yq_opts="--yaml-output"
    fi

    # Get the number of required params
    local required_params_count
    required_params_count=$(yq "[select(.parameters != null) | .parameters[] | select(.required == true)] | length" "${file}")

    local yq_command
    if [[ "${key}" == "objects" ]] && [[ "${required_params_count}" == "0" ]]; then
      # Process the Template if we didnt find any required params, split the List and write to a tmp dir
      yq_command="oc process -f ${file} --local -o json | yq ${yq_opts} '.items[]'"
    elif [[ "${key}" == "objects" ]] || [[ "${key}" == "items" ]]; then
      # Split the Template/List and write to a tmp dir
      yq_command="yq ${yq_opts} '.${key}[]' ${file}"
    elif [[ "${key}" == "." ]]; then
      # It doesnt require splitting, just write to a tmp dir to validate the syntax
      yq_command="yq ${yq_opts} '.' ${file}"
    else
      fail "# FATAL-ERROR: (yaml-json-manipulation.bash): Unsupported key: '${key}'" || return $?
    fi

    # NOTE: conftest does not search sub-dirs, so to handle files in sub-dirs, we:
    # 1. remove the root search dir from the file name
    # 2. replace any / with _ to create a flat filename
    local file_without_root
    file_without_root=${file/$root_dir_search_path\//}

    local output_file
    output_file="${tmp_write_dir}/${file_without_root////_}"

    # NOTE: eval is used due to yq not liking empty yq_opts
    eval "${yq_command} > ${output_file}"

    # Safety check to make sure nothing above silently failed
    if [[ ! -s "${output_file}" ]] ; then
      fail "# FATAL-ERROR: (yaml-json-manipulation.bash): File is empty: '${output_file}'" || return $?
    fi
  done

  # Another safety check to make sure nothing above silently failed
  if [[ "$(find "${tmp_write_dir}" -type f | wc -l)" -lt 1 ]] ; then
    fail "# FATAL-ERROR: (yaml-json-manipulation.bash): No files created: '${tmp_write_dir}'" || return $?
  fi

  echo "${tmp_write_dir}"
}

_create_tmp_write_dir() {
  local tmp_write_dir
  tmp_write_dir=/tmp/rhcop/$(date +'%d-%m-%Y-%H-%M')/"${1}"

  mkdir -p "${tmp_write_dir}"

  echo "${tmp_write_dir}"
}