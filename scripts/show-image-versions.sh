#!/usr/bin/env bash

set -o pipefail

IMAGES=$(kubectl get pods --all-namespaces -o jsonpath="{..image}" | tr -s '[:space:]' '\n' | sort | uniq)

RESULT="\u001b[1mImage|Current Version|Latest Versions\u001b[0m\n"
SKIPPED=""

for image in $IMAGES; do
  if [[ "$image" =~ :v?[0-9]\.[0-9](\.[0-9])?([a-z0-9.-]+)?$ ]]; then
    IMG=$(node -p "const a = '${image}'.match(/^(?:docker\.io\/)?(.+?):.+$/)[1]; a.includes('/') ? a : 'library/' + a")
    CURRENT_VERSION=$(node -p "'${image}'.match(/^.+?:(.+)$/)[1]")
    TAG_REQUEST=$(curl -s -H 'Accept: application/json' -H "Authentication: JWT ${DOCKER_HUB_TOKEN}" "https://hub.docker.com/v2/repositories/$IMG/tags/?page_size=10&page=1&ordering=last_updated")

    if TAGS=$(echo "$TAG_REQUEST" | jq '.results[].name' -r 2> /dev/null | grep -vE '(latest|stable|dev)' | sort -r | tr '\n' ' '); then
      RESULT+="${IMG}|${CURRENT_VERSION}|${TAGS}\n"
    else
      SKIPPED+="$IMG\n"
    fi
  else
    SKIPPED+="$image\n"
  fi
done

echo -e "$RESULT" | column -s '|' -t -x

if [ -n "$SKIPPED" ]; then
  echo -e "\n\u001b[1mSkipped\u001b[0m $(echo -e "$SKIPPED" | tr '\n' ' ')"
fi
