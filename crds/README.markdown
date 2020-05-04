# CRDs

This directory is for linting purposes. I use [Kubeval](https://www.kubeval.com/#crds) to make sure the yaml I create is a valid Kubernetes schema.
This works great for built-in kubernetes types (Deployment, Ingress, Service, etc.), but some operators add custom resource types (CRDs).
kubeval doesn't have these schemas by defaul, so can't validate them. It's possible to just skip them, with --skip-kinds, but we really want to know if we're writing an invalid schema.

This directory contains the CRD schema definitions that kubeval can read.

Definitions can be pulled from the cluster using:

`k get crd servicemonitors.monitoring.coreos.com -o json | pbcopy`, for example.
