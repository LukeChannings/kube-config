#!/usr/bin/env bash
#shellcheck disable=SC2094

SECRET_PATH="$1"
SEALED_SECRET_PATH="${SECRET_PATH/secret/sealedsecret}"

echo "Encrypting $SECRET_PATH -> $SEALED_SECRET_PATH"

kubeseal --controller-namespace sealed-secrets --controller-name sealed-secrets -o yaml < "$SECRET_PATH" > "$SEALED_SECRET_PATH"

cat <<-EOF > "$SEALED_SECRET_PATH"
---
$(cat "$SEALED_SECRET_PATH")
EOF
