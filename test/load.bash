# Check all the dev-tools are installed
command -v diff &> /dev/null || { echo >&2 'ERROR: diff not installed - Aborting'; exit 1; }

# shellcheck disable=SC1090
source "$(dirname "${BASH_SOURCE[0]}")/../load.bash"