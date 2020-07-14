#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load load

@test "split_files - k8s List.yml" {
  local tmp=$(split_files "test/data/list-input.yml")

  run diff "${tmp}/list-input.yml" test/data/list-expected.yml

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "split_files - OCP Template.yml" {
  local tmp=$(split_files "test/data/template-input.yml")

  run diff "${tmp}/template-input.yml" test/data/template-expected.yml

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "split_files - Single JSON" {
  local tmp=$(split_files "test/data/json-root.json" "true")

  run diff "${tmp}/json-root.json" test/data/json-root.json

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "split_files - Directory" {
  local tmp=$(split_files "test/data/multiple")

  run ls "${tmp}"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "print_info" {
  local tmp=$(split_files "test/data/multiple" "true")

  local cmd="ls ${tmp}"
  run ${cmd}

  print_info "${status}" "${output}" "${cmd}" "${tmp}"
  [ "$status" -eq 0 ]
}

@test "helm_template" {
  local tmp=$(helm_template "test/data/test-chart")

  run diff "${tmp}/serviceaccount.yaml" test/data/test-chart-serviceaccount-expected.yaml

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
  local tmp=$(split_files "test/data/template-with-missingparam-input.yml")
  file_contains_dollar "${tmp}/template-with-missingparam-input.yml" "false"

  run ls "${tmp}/template-with-missingparam-input.yml"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "file_contains_dollar - file without dollar (no-match)" {
  local tmp=$(split_files "test/data/template-with-param-input.yml")
  file_contains_dollar "${tmp}/template-with-param-input.yml" "false"

  run ls "${tmp}/template-with-param-input.yml"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "file_contains_dollar - dir with dollar (matched)" {
  local tmp=$(split_files "test/data/template-with-missingparam-input.yml")
  file_contains_dollar "${tmp}" "false"

  run ls "${tmp}"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "get_rego_namespaces" {
  skip
  local namespaces=$(get_rego_namespaces "ocp\.deprecated\.ocp4_1.*")

  run echo "${namespaces}"

  echo "${output}"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "--namespace ocp.deprecated.ocp4_1.buildconfig_custom_strategy" ]
}