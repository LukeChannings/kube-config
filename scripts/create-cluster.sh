#!/usr/bin/env bash

set -exu -o pipefail

ssh -t Suplex 'curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable servicelb --cluster-cidr 172.30.0.0/16 --service-cidr 172.31.0.0/16 --cluster-dns 172.31.0.10" sh -' || true
ssh -t Suplex "sudo bash -c 'cp /var/lib/rancher/k3s/server/node-token /home/luke/node-token; chown luke:luke /home/luke/node-token'"

scp Suplex:~/node-token ~/.nodetoken

# shellcheck disable=SC2029
#ssh -t Snowkube "curl -sfL https://get.k3s.io | K3S_URL=https://suplex.local:6443 K3S_TOKEN='$(cat ~/.nodetoken)' sh -" || true

# shellcheck disable=SC2029
ssh -t Sentinel "curl -sfL https://get.k3s.io | K3S_URL=https://suplex.local:6443 K3S_TOKEN='$(cat ~/.nodetoken)' sh -" || true

rm ~/.nodetoken

ssh -t Suplex "sudo systemctl restart k3s"

ssh -t Suplex "sudo bash -c 'mkdir -p ~/.kube; cp /etc/rancher/k3s/k3s.yaml /home/luke/.kube/config; chown luke:luke /home/luke/.kube/config'"
scp Suplex:~/.kube/config ~/.kube/config

sed -i.bak 's/127.0.0.1/suplex.local/g' ~/.kube/config

ssh Suplex 'rm /home/luke/node-token'

echo "
CLUSTER SETUP COMPLETE

---
Remember to test inter-node communication, it is possible there are errors.

> krun nicolaka/netshoot -H snowkube
> krun nicolaka/netshoot -H suplex

> ip a
> iperf -s

> iperf -c <ip-address>

Once that is all working, install metallb and then argocd
"
