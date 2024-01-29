#!/usr/bin/env bash

echo -e "\nSetting prometheus-adapter .."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm -n monitoring upgrade --install prometheus-adapter -f kuber/charts/values.prom-adapter.dev.yaml prometheus-community/prometheus-adapter
echo

for i in {1..150}; do

  if [[ $i -eq 150 ]]; then
    echo -e "\nprometheus-adapter is not ready!"
    exit 1
  fi

  echo -n "Checking prometheus-adapter ready.. $i"
  tput hpa 0 # move the cursor to the left-most column
  # https://unix.stackexchange.com/questions/464357/print-something-in-console-in-the-same-place-of-the-previous-echo-with-a-sort-o

  prometheus_adapter_replicas=$(kubectl -n monitoring get deploy prometheus-adapter -o jsonpath='{.status.readyReplicas}')

  if [[ $prometheus_adapter_replicas -eq 1 ]]; then
    echo -e "\n\nprometheus-adapter ready!"
    kubectl -n monitoring get deploy prometheus-adapter
    break
  fi
  sleep 2

done

for i in {1..150}; do

  if [[ $i -eq 150 ]]; then
    echo -e "\nhttp_requests metrica is not available!"
    exit 1
  fi

  echo -n "Checking http_requests metrica available.. $i"
  tput hpa 0 # move the cursor to the left-most column

  if kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests >/dev/null; then
    echo -e "\n\nhttp_requests metrica available is available:\n"
    kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests | jq .
    break
  fi
  sleep 2

done

# kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq | grep -i http_requests

# kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 | jq
#Restart prom-adapter pods
#kubectl rollout restart deployment prometheus-adapter -n monitoring

# kubectl get pods --field-selector=status.phase!=Running
