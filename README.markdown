# Luke's kubeconfig

![Lint Status](https://github.com/LukeChannings/kube-config/workflows/Lint/badge.svg?branch=master)

All of these scripts and configurations are specific to my home cluster. Do not expect any configurations to "just work" if you plan on using them.

This repo contains the Argo app-of-apps configuration, which installs Argo projects and apps. See [`apps/apps`](./apps/apps).

## Scripts

- **create-cluster.sh**: Installs and configures [k3s](https://k3s.io) on all nodes.
- **destroy-cluster.sh**: Uninstalls k3s from all nodes. (I have had to rebuild the cluster many, many times.)
- **install-metallb.sh**: Installs [metallb](https://metallb.universe.tf)
- **uninstall-metallb.sh**: Uninstalls metallb
- **install-argo.sh**: Installs [Argo CD](https://argoproj.github.io/argo-cd/)
- **uninstall-argo.sh**: Uninstalls Argo CD

### k3s

k3s is installed with as little as possible. There is no [**Traefik**](https://containo.us/traefik/) (we will use our own ingress controller) or **servicelb** (we're using metallb) installed.

### metallb

I'm using metallb instead of servicelb because I use a LoadBalancer service with a `loadBalancerIP`, which is unsupported by servicelb. It's also very convenient to have a virtual IP address for external services.

## Troubleshooting

### Inter-node flannel communication

As soon as you set up a cluster, do yourself a favour and test inter-node communication works. The cluster can appear to be working initially, but big and confusing issues prop up if this is broken and you don't know.

I test with:

- `krun nicolaka/netshoot -H snowkube`
- `krun nicolaka/netshoot -H suplex`
- `krun ubuntu -H sentinel` (`nicolaka/netshoot` isn't available on arm64)

Run `ip a` and note the IP address, and then run `iperf -s` on one of the pods.
Use `iperf -c <IP>` on all other nodes. They should all be communicating at roughly network speeds.

Note: [`krun`](https://github.com/LukeChannings/.config/blob/master/fish/functions/krun.fish) is a custom fish script.

If you find there is no communication between nodes, try:

1. restarting k3s: `sudo systemctl restart k3s` on the master node
2. Restarting all nodes
3. Destroying the cluster and starting again
4. Ensure routes are correctly set up on the nodes, iptables is configured, etc. See also: [k3s known issues](https://rancher.com/docs/k3s/latest/en/known-issues/)

### Exec format error

Caused by an x86 image running on ARM.

Unfortunately ARM is a second class citizen in the k8s world and there are many images that are not supported.
You can either build your own ARM image, or use the following to de-select ARM machines from scheduling:

```yaml
nodeSelector:
  kubernetes.io/arch: amd64
```

### mlock error

I experienced the Argo Application Controller in a crash loop, tailing the logs I found:

```
runtime: mlock of signal stack failed: 12
runtime: increase the mlock limit (ulimit -l) or
runtime: update your kernel to 5.3.15+, 5.4.2+, or 5.5+
fatal error: mlock failed
```

Manually upgrading the kernel to `5.4.28` appears to have fixed the issue.

For Ubuntu, download and `dpkg -i *.deb`: [https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.28/](https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.4.28/) the filed listed under `Build for amd64 succeeded`, except `lowlatency` labelled packages.

## Nodes

| Hostname | Arch    | OS                      | CPU                      | RAM  | Storage                             |
|----------|---------|-------------------------|--------------------------|------|-------------------------------------|
| Suplex   | x86_64  | Arch Linux              | E3-1245 v3 @ 3.40GHz     | 32GB | 458GB SSD, 30TB spinning rust (ZFS) |
| Snowkube | x86_64  | Ubuntu Server 20.04 LTS | i7-8700B CPU @ 3.20GHz   | 22GB | 200GB SSD                           |
| Sentinel | aarch64 | Ubuntu Server 20.04 LTS | ARM Cortex-A72 @ 1.50GHz | 2GB  | 59GB MicroSD                        |
