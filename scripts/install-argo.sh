#!/usr/bin/env bash

set -exu -o pipefail

helm repo add argo https://argoproj.github.io/argo-helm
kubectl create ns argocd || true

cat > argo-values.yaml << EOF
---
installCRDs: false
controller:
  metrics:
    enabled: true
server:
  service:
    type: LoadBalancer
    loadBalancerIP: "192.168.1.201"
  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-production
      haproxy.org/ssl-redirect: true
      haproxy.org/ssl-passthrough: true
    hosts:
      - argo.private.channings.me
    tls:
      - hosts:
          - argo.private.channings.me
        secretName: argocd-secret
EOF

# https://github.com/argoproj/argo-helm/tree/master/charts/argo-cd
helm upgrade -i --atomic -f argo-values.yaml argo -n argocd argo/argo-cd

rm argo-values.yaml

echo "
Username: admin
Password: $(kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2)
"
