#!/usr/bin/env sh

set -o errexit -o nounset

python -m venv ./.venv
# "source" relative to the location of this script
. "$(dirname "$0")/../.venv/bin/activate"
pip install --requirement ./requirements.txt
# "source" relative to the location of this script
. "$(dirname "$0")/setup_ssh.sh"
