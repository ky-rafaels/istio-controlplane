#!/bin/bash

echo "Enter context of cluster"
read CONTEXT

echo "Installing istio-cni in context ${CONTEXT}"
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo update

helm --kube-context=${CONTEXT} upgrade --install istio-cni istio/cni -n kube-system --values - <<EOF
cni
  hub: "docker.io/istio"
  image: install-cni
  tag: "1.15.3"
EOF