#!/usr/bin/env bash

echo -e "\nSetting Ingress-Nginx Controller .."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx \
    ingress-nginx/ingress-nginx \
    --namespace ingress-nginx --create-namespace \
    --atomic \
    --wait || exit 1

kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=200s || exit 1
