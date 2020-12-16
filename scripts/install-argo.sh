#!/usr/bin/env bash

set -exu -o pipefail

CWD="$(pwd)"

if ! [ -d "${CWD}/secrets" ]; then
  echo "Could not find secrets folder in ${CWD}. Make sure you're running this script from kube-config."
fi

kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for argocd to be available..."

kubectl wait --for=condition=Available deployment -n argocd argocd-server

kubectl port-forward svc/argocd-server -n argocd 8080:443 &
PORT_FORWARD_PID=$!

PASSWORD="$(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)"
argocd login localhost:8080 --username admin --password "$PASSWORD"

kubectl apply -f "${CWD}/secrets/kubernetes-sealed-secret-master.key"

argocd repo add https://charts.helm.sh/stable --type helm --name stable
argocd repo add https://haproxytech.github.io/helm-charts/ --type helm --name haproxytech
argocd repo add https://charts.jetstack.io/ --type helm --name jetstack
argocd repo add https://k8s-at-home.com/charts/ --type helm --name k8s-at-home

argocd repo add git@github.com:LukeChannings/kube-config-private.git --insecure-ignore-host-key --ssh-private-key-path "${CWD}/secrets/argocd-github"
argocd repo add git@github.com:LukeChannings/kube-config.git --insecure-ignore-host-key --ssh-private-key-path "${CWD}/secrets/argocd-github"

argocd app create \
  --name apps \
  --sync-policy automated \
  --repo git@github.com:LukeChannings/kube-config.git \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default \
  --path apps/apps

argocd app sync apps

argocd app sync argocd --strategy apply; sleep 2
argocd app sync sealed-secrets --strategy apply; sleep 2
argocd app sync cert-manager --strategy apply; sleep 2
argocd app sync monitoring --strategy apply; sleep 2
argocd app sync haproxy-ingress --strategy apply; sleep 2

kill $PORT_FORWARD_PID
