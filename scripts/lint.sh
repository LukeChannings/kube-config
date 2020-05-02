#!/usr/bin/env bash

if ! [ -d .git ]; then
  echo "Lint should be run from the project root."
  exit 1
fi

# Install githook
if ! [ -L .git/hooks/pre-commit ]; then
  ln -s "$(pwd)/scripts/lint.sh" .git/hooks/pre-commit
fi

set -e -o pipefail

yamllint -c .yamllint.yaml .

shellcheck -s bash ./**/*.sh
