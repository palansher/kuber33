#!/usr/bin/env bash

# Set Cert Manager
echo Setting Cert Manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml

helm repo add jetstack https://charts.jetstack.io &&
    helm repo update &&
    helm repo list &&
    helm upgrade --install \
        cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --version v1.13.3 \
        --atomic \
        --wait
# --set installCRDs=true

