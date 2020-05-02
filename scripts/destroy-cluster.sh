#!/usr/bin/env bash

set -ex -o pipefail

ssh -t Sentinel "/usr/local/bin/k3s-agent-uninstall.sh; sudo shutdown -r now" || true
ssh -t Snowkube "/usr/local/bin/k3s-agent-uninstall.sh; sudo shutdown -r now" || true
ssh -t Suplex "/usr/local/bin/k3s-uninstall.sh; sudo shutdown -r now" || true
