# Testing
Each BATS addon must be tested by its own [BATS test](https://github.com/redhat-cop/bats-library/blob/master/test/tests.sh#L6).

## How do I write a test?
Add a new test into the [tests file](test/tests.sh) or [failed tests file](test/tests_fail.sh), depending on the use case.
All test data should be added under [data.](test/data).

## Execute Locally
```bash
bats test/tests.sh
bats test/tests_fail.sh
```

## CI Linting
The repo uses a [shellcheck](https://github.com/koalaman/shellcheck) GitHub Action to lint all the bash files.
