#!/usr/bin/env bash

set -exu -o pipefail

helm uninstall argo -n argocd

helm repo add argo https://argoproj.github.io/argo-helm
kubectl delete ns argocd || true
