#!/usr/bin/env bash

set -exu -o pipefail

helm repo add argo https://argoproj.github.io/argo-helm
kubectl create ns argocd || true

# https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd
helm upgrade -i -f ./apps/infrastructure/argocd/values.bootstrap.yaml argo -n argocd argo/argo-cd

PASSWORD="$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)"

echo "
Username: admin
Password: ${PASSWORD}
"

echo "Waiting 4 minutes to log in..."

sleep 240

argocd login 192.168.1.201 --username admin --password "$PASSWORD"

./argo-bootstrap-cluster.sh

echo "
Syncing apps. Once the infrastructure is fully synced, run:
helm upgrade -i -f ./apps/infrastructure/argocd/values.yaml argo -n argocd argo/argo-cd

Then re-login to argo with:
argocd login argo.private.channings.me --username admin --password $PASSWORD
"
