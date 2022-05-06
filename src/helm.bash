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
  local return_message
  local tmp_write_dir
  tmp_write_dir=/tmp/rhcop/$(date +'%d-%m-%Y-%H-%M')/"${chart_dir}"

  mkdir -p "${tmp_write_dir}"

  local output_file
  output_file="${tmp_write_dir}/templates.yaml"

  # NOTE: eval is used due to helm not liking empty template_opts
  return_message=$(eval "helm template ${template_opts} ${chart_dir} &> ${output_file}")

  # Safety check to make sure nothing above silently failed
  if [[ $? -ne 0 ]] ; then
    fail "# FATAL-ERROR: (helm.bash): helm template failed: ${return_message}" || return $?
  fi

  # Safety check to make sure nothing above silently failed
  return_message=$(eval "helm lint ${template_opts} ${chart_dir}")
  if [[ $? -ne 0 ]] ; then
    fail "# FATAL-ERROR: (helm.bash): helm lint failed: ${return_message} " || return $?
  fi

  echo "${tmp_write_dir}"

}
