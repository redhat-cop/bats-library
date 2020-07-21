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
#   string - path to where files have been processed, i.e.: /tmp/rhcop/${date-time}/${chart_dir}/${chart-name}/templates
helm_template() {
  local chart_dir=$1
  local template_opts=$2
  local tmp_write_dir
  tmp_write_dir=/tmp/rhcop/$(date +'%d-%m-%Y-%H-%M')/"${chart_dir}"

  mkdir -p "${tmp_write_dir}"

  # shellcheck disable=SC2164
  pushd "${chart_dir}" > /dev/null 2>&1

  # NOTE: eval is used due to helm not liking empty template_opts
  eval "helm template ${template_opts} $(pwd) --output-dir ${tmp_write_dir} > /dev/null 2>&1"

  # shellcheck disable=SC2164
  popd > /dev/null 2>&1

  # Safety check to make sure nothing above silently failed
  if [[ "$(find "${tmp_write_dir}" -type f | wc -l)" -lt 1 ]] ; then
    fail "# FATAL-ERROR: (helm.bash): No files created: '${tmp_write_dir}'" || return $?
  fi

  # As the templates files end up in '${chart-name}/templates', lets resolve that
  local first_templated_file
  first_templated_file=$(find "${tmp_write_dir}" -type f | head -1 | xargs)

  # shellcheck disable=SC2005
  echo "$(dirname "${first_templated_file}")"
}