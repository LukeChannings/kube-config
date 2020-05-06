#!/usr/bin/env bash

set -exu -o pipefail

helm repo add argo https://argoproj.github.io/argo-helm
kubectl create ns argocd || true

# https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd
helm upgrade -i -f ./apps/infrastructure/argocd/values.yaml argo -n argocd argo/argo-cd

PASSWORD="$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)"

echo "
Username: admin
Password: ${PASSWORD}
"

argocd login argo.private.channings.me --username admin --password "$PASSWORD"

argocd repo add git@github.com:LukeChannings/k8s-at-home.git --insecure-ignore-host-key --ssh-private-key-path ~/Projects/k8s-at-home/secrets/argocd-github

argocd app create --name apps --repo git@github.com:LukeChannings/k8s-at-home.git --dest-server https://kubernetes.default.svc --dest-namespace default --path apps/apps
argocd app sync apps
