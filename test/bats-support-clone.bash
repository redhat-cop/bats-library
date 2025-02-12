if [[ ! -d "test/test_helper/bats-support" ]]; then
  # Download bats-support dynamically so it doesnt need to be added into source
  git clone https://github.com/ztombol/bats-support test/test_helper/bats-support --depth 1
fi
