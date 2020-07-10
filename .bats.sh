#!/usr/bin/env bash

set -e

rm -rf /tmp/bats-support
rm -rf test/test_helper

mkdir -p test/test_helper/bats-support

git clone https://github.com/ztombol/bats-support /tmp/bats-support --depth 1
mv /tmp/bats-support/* test/test_helper/bats-support