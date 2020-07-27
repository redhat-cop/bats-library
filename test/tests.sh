#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load load

setup_file() {
  rm -rf /tmp/rhcop
}

@test "split_files - k8s List.yml" {
  tmp=$(split_files "test/data/list-input.yml")

  run diff "${tmp}/list-input.yml" test/data/list-expected.yml

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "split_files - k8s List.yaml" {
  tmp=$(split_files "test/data/list-input.yaml")

  run diff "${tmp}/list-input.yaml" test/data/list-expected.yaml

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "split_files - OCP Template.yml" {
  tmp=$(split_files "test/data/template-input.yml")

  run diff "${tmp}/template-input.yml" test/data/template-expected.yml

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "split_files - OCP Template.yml with required params" {
  tmp=$(split_files "test/data/template-required-params-input.yml")

  run diff "${tmp}/template-required-params-input.yml" test/data/template-required-params-expected.yml

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "split_files - Single JSON" {
  tmp=$(split_files "test/data/json-root.json" "true")

  run diff "${tmp}/json-root.json" test/data/json-root.json

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "split_files - Directory" {
  tmp=$(split_files "test/data/multiple")

  run ls "${tmp}"

  echo "${output}"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "list-input.yml" ]
  [ "${lines[1]}" = "template-input.yml" ]
}

@test "split_files - Directory with sub directories containing same filenames" {
  tmp=$(split_files "test/data/multiple-subs")

  run ls "${tmp}"

  echo "${output}"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "a_list-input.yml" ]
  [ "${lines[1]}" = "b_list-input.yml" ]
}

@test "print_info" {
  tmp=$(split_files "test/data/multiple" "true")

  local cmd="ls ${tmp}"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 0 ]
}

@test "helm_template" {
  tmp=$(helm_template "test/data/test-chart")

  run diff "${tmp}/templates.yaml" test/data/test-chart-expected.yaml

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "conftest_pull" {
  rm -rf policy/
  conftest_pull

  run ls policy/

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "file_contains_dollar - file with dollar (matched)" {
  tmp=$(split_files "test/data/template-with-missingparam-input.yml")
  file_contains_dollar "${tmp}/template-with-missingparam-input.yml" "false"

  run ls "${tmp}/template-with-missingparam-input.yml"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "file_contains_dollar - file without dollar (no-match)" {
  tmp=$(split_files "test/data/template-with-param-input.yml")
  file_contains_dollar "${tmp}/template-with-param-input.yml" "false"

  run ls "${tmp}/template-with-param-input.yml"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "file_contains_dollar - dir with dollar (matched)" {
  tmp=$(split_files "test/data/template-with-missingparam-input.yml")
  file_contains_dollar "${tmp}" "false"

  run ls "${tmp}"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "get_rego_namespaces" {
  skip
  namespaces=$(get_rego_namespaces "ocp\.deprecated\.ocp4_1.*")

  run echo "${namespaces}"

  echo "${output}"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "--namespace ocp.deprecated.ocp4_1.buildconfig_custom_strategy" ]
}