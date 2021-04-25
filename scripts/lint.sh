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

helm repo add k8s-at-home https://k8s-at-home.com/charts/
helm repo add stable https://charts.helm.sh/stable
helm repo add haproxytech https://haproxytech.github.io/helm-charts/
helm repo add jetstack https://charts.jetstack.io/

while IFS= read -d '' -r file; do
  if ! dirname "$file" | grep -q 'cert-manager'; then
    helm dependencies update "$(dirname "$file")" || true
    helm dependencies build "$(dirname "$file")"
    helm lint "$(dirname "$file")"
  fi
done < <(find . -name 'Chart.yaml' -print0)

yamllint -c .yamllint.yaml .

shellcheck -s bash ./**/*.sh

kubeval -i '(Chart|values.*|requirements|.*\.crds?)\.yaml$' -d ./apps --schema-location https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/ -v 1.20.6 --additional-schema-locations file://./crds
