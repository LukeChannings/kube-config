# Helm Tools

## Installation

`npm i && npm link`

## compare-helm-versions

Make sure you're in the kube-config project root and run `compare-helm-versions`.

This project has many helm dependencies and it's difficulat to keep track of their versions.
This script outputs the current and latest versions of all dependencies.

## Example output

```bash
| Chart Name          |  Chart Dependency     |  Current Version  |  Latest Version |
-------------------------------------------------------------------------------------
| cert-manager        |  cert-manager         |  v0.15.0          |  v0.15.0        |
| ingress-controller  |  kubernetes-ingress   |  1.2.0            |  1.2.0          |
| monitoring          |  prometheus-operator  |  8.13.7           |  8.13.7         |
| sealed-secrets      |  sealed-secrets       |  1.10.0           |  1.10.0         |
| home-assistant      |  home-assistant       |  0.13.2           |  0.13.2         |
```

## eject-chart

Go to a folder with a Chart.yaml, run `eject-chart` and it will output the templated chart to `./helm-manifests`.
It's useful if a chart isn't great and doesn't allow everything you need, you can bail out and just do it yourself.
