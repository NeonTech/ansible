#!/usr/bin/env sh

set -o errexit -o nounset

# https://pypi.org/project/pip-review
pip-review --interactive
