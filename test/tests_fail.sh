#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load load

@test "split_files - Fail: empty.yml" {
  tmp=$(split_files "test/data/empty.yml")

  run echo "${tmp}"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "print_info - Fail: Missing 'tmp' arg" {
  run ls ~/

  print_info "${status}" "${output}"
  [ "$status" -eq 0 ]
}

@test "helm_template - Fail: empty chart" {
  tmp=$(helm_template "test/data/test-empty-chart")

  run echo "${tmp}"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "file_contains_dollar - Fail: Found dollar in file" {
  tmp=$(split_files "test/data/template-with-missingparam-input.yml")
  file_contains_dollar "${tmp}/template-with-missingparam-input.yml"

  run ls "${tmp}/template-with-missingparam-input.yml"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "file_contains_dollar - Fail: Found dollar in dir" {
  tmp=$(split_files "test/data/template-with-missingparam-input.yml")
  file_contains_dollar "${tmp}"

  run ls "${tmp}"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "get_rego_namespaces - Fail: no match" {
  namespaces=$(get_rego_namespaces "nevermatch")

  run echo "${namespaces}"

  echo "${output}"
  [ "$status" -eq 0 ]
}