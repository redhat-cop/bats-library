# helm_template
# ==============
#
# Summary: Process a helm template
#
# Usage: helm_template <chart_dir> <template_opts>
#
# Options:
#   <chart_dir>       directory of the chart
#   <template_opts>   any options the template requires to be processed
# Globals:
#   none
# Returns:
#   string - path to where files have been processed, i.e.: /tmp/rhcop/${date-time}/${chart_dir}
helm_template() {
  local chart_dir=$1
  local template_opts=$2
  local tmp_write_dir
  tmp_write_dir=/tmp/rhcop/$(date +'%d-%m-%Y-%H-%M')/"${chart_dir}"

  mkdir -p "${tmp_write_dir}"

  local output_file
  output_file="${tmp_write_dir}/templates.yaml"

  # NOTE: eval is used due to helm not liking empty template_opts
  eval "helm template ${template_opts} ${chart_dir} &> ${output_file}"

  # Safety check to make sure nothing above silently failed
  if [[ ! -s "${output_file}" ]] || [[ $(wc -c "${output_file}" | awk '{print $1}') -le 1 ]] ; then
    fail "# FATAL-ERROR: (helm.bash): File is empty: '${output_file}'" || return $?
  fi

  # Another, safety check to make sure nothing above silently failed
  helm lint . > /dev/null 2>&1
  if [[ $? -eq 1 ]] ; then
    fail "# FATAL-ERROR: (helm.bash): File is not valid YAML: '${output_file}', helm lint failed" || return $?
  fi

  echo "${tmp_write_dir}"
}
