#!/usr/bin/env bash

set -e -o pipefail

if ! [ -d .git ]; then
  echo "Lint should be run from the project root."
  exit 1
fi

# Install githook
if ! [ -L .git/hooks/pre-commit ]; then
  ln -s "$(pwd)/scripts/lint.sh" .git/hooks/pre-commit
fi

yamllint -c .yamllint.yaml .

shellcheck -s bash ./**/*.sh

kubeval -i '(Chart|values.*|requirements|.*\.crds?)\.yaml$' -d ./apps --additional-schema-locations file://./crds


while IFS= read -d '' -r file; do
  helm dependencies update "$(dirname "$file")" || true
  helm dependencies build "$(dirname "$file")"
  helm lint --with-subcharts "$(dirname "$file")"
done < <(find . -name 'Chart.yaml' -print0)
