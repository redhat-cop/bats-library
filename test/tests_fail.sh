#!/usr/bin/env bats

load bats-support-clone
load test_helper/bats-support/load
load load

@test "print_info - Fail: Missing 'tmp' arg" {
  run ls ~/

  print_info "${status}" "${output}"
  [ "$status" -eq 0 ]
}

@test "file_contains_dollar - Fail: Found dollar in file" {
  local tmp=$(split_files "test/data/template-with-missingparam-input.yml")
  file_contains_dollar "${tmp}/template-with-missingparam-input.yml"

  run ls "${tmp}/template-with-missingparam-input.yml"

  echo "${output}"
  [ "$status" -eq 0 ]
}

@test "file_contains_dollar - Fail: Found dollar in dir" {
  local tmp=$(split_files "test/data/template-with-missingparam-input.yml")
  file_contains_dollar "${tmp}"

  run ls "${tmp}"

  echo "${output}"
  [ "$status" -eq 0 ]
}