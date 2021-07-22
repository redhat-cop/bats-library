# Check all the dev-tools are installed
command -v diff &> /dev/null || { echo >&2 'ERROR: diff not installed - Aborting'; exit 1; }
command -v bc &> /dev/null || { echo >&2 'ERROR: bc not installed - Aborting'; exit 1; }

# shellcheck source=../load.bash
source "$(dirname "${BASH_SOURCE[0]}")/../load.bash"