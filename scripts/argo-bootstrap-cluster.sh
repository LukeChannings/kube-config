#!/usr/bin/env bash

set -exu -o pipefail

argocd repo add git@github.com:LukeChannings/kube-config.git --insecure-ignore-host-key --ssh-private-key-path ~/Projects/kube-config/secrets/argocd-github

argocd app create --name apps --repo git@github.com:LukeChannings/kube-config.git --dest-server https://kubernetes.default.svc --dest-namespace default --path apps/apps
argocd app sync apps

kubectl appy -f ~/Projects/kube-config/secrets/kubernetes-sealed-secret-master.key

argocd app sync sealed-secrets --strategy apply; sleep 2

argocd app sync cert-manager --strategy apply; sleep 2

argocd app sync monitoring --strategy apply; sleep 2

argocd app sync haproxy-ingress --strategy apply; sleep 2
