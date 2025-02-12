# Check all the tools are installed
command -v jq &> /dev/null || { echo >&2 'ERROR: jq not installed - Aborting'; exit 1; }
command -v yq &> /dev/null || { echo >&2 'ERROR: yq not installed - Aborting'; exit 1; }
command -v helm &> /dev/null || { echo >&2 'ERROR: helm not installed - Aborting'; exit 1; }
command -v oc &> /dev/null || { echo >&2 'ERROR: oc not installed - Aborting'; exit 1; }
command -v conftest &> /dev/null || { echo >&2 'ERROR: conftest not installed - Aborting'; exit 1; }

# Two versions of yq exist, check its the correct one
[[ $(yq --help | grep -c "jq wrapper") -eq 1 ]] || { echo >&2 'ERROR: found yq installed but not the jq wrapper version (https://github.com/kislyuk/yq) - Aborting'; exit 1; }

# shellcheck source=./src/yaml-json-manipulation.bash
source "$(dirname "${BASH_SOURCE[0]}")/src/yaml-json-manipulation.bash"

# shellcheck source=./src/error-handling.bash
source "$(dirname "${BASH_SOURCE[0]}")/src/error-handling.bash"

# shellcheck source=./src/helm.bash
source "$(dirname "${BASH_SOURCE[0]}")/src/helm.bash"

# shellcheck source=./src/conftest.bash
source "$(dirname "${BASH_SOURCE[0]}")/src/conftest.bash"

# shellcheck source=./src/dollar.bash
source "$(dirname "${BASH_SOURCE[0]}")/src/dollar.bash"
