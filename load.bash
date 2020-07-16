# Check all the tools are installed
command -v jq &> /dev/null || { echo >&2 'ERROR: jq not installed - Aborting'; exit 1; }
command -v yq &> /dev/null || { echo >&2 'ERROR: yq not installed - Aborting'; exit 1; }
command -v helm &> /dev/null || { echo >&2 'ERROR: helm not installed - Aborting'; exit 1; }
command -v oc &> /dev/null || { echo >&2 'ERROR: oc not installed - Aborting'; exit 1; }
command -v conftest &> /dev/null || { echo >&2 'ERROR: conftest not installed - Aborting'; exit 1; }

# Two versions of yq exist, check its the correct one
[[ $(yq --help | grep -c "jq wrapper") -eq 1 ]] || { echo >&2 'ERROR: found yq installed but not the jq wrapper version (https://github.com/kislyuk/yq) - Aborting'; exit 1; }

# shellcheck disable=SC1090
source "$(dirname "${BASH_SOURCE[0]}")/src/yaml-json-manipulation.bash"

# shellcheck disable=SC1090
source "$(dirname "${BASH_SOURCE[0]}")/src/error-handling.bash"

# shellcheck disable=SC1090
source "$(dirname "${BASH_SOURCE[0]}")/src/helm.bash"

# shellcheck disable=SC1090
source "$(dirname "${BASH_SOURCE[0]}")/src/conftest.bash"

# shellcheck disable=SC1090
source "$(dirname "${BASH_SOURCE[0]}")/src/dollar.bash"