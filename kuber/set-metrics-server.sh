#!/usr/bin/env bash

echo "Installing metrics-server .."
wget -q -O kuber/metrics-server-components.yaml https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# Fixing slf-signed sertificat issue in metrics-server:
# Иногда бывает так, что metrics-server не взлетает. Такое возможно из-за того, что используются неподписанные сертификаты.
# В этом случае нужно скачать локально файл components.yaml и выставить дополнительный параметр --kubelet-insecure-tls в args, например вот так:
# открываем на редактирование и вставляем нужный параметр в args:
# $ vi components.yaml

# args:
#   --kubelet-insecure-tls
#   --kubelet-preferred-address-types=InternalIP
#   --cert-dir=/tmp
#   --secure-port=4443
# ...
yq -i 'with(select(.kind == "Deployment").spec.template.spec.containers.0.args;  select(all_c(. != "--kubelet-insecure-tls")) | .  += "--kubelet-insecure-tls")' kuber/metrics-server-components.yaml
kubectl apply -f kuber/metrics-server-components.yaml && rm kuber/metrics-server-components.yaml

echo
for i in {1..150}; do

  if [[ $i -eq 150 ]]; then
    echo -e "\nmetrics-server is not installed properly!"
    exit 1
  fi
  
  echo -n "Checking metrics-server .. $i"
  tput hpa 0 # move the cursor to the left-most column
  if kubectl api-resources | grep -q autoscaling/v2 && kubectl api-resources | grep -q metrics.k8s.io; then
    echo
    echo -e "\nmetrics-server installed!"
    kubectl api-resources | grep autoscaling/v2 && kubectl api-resources | grep metrics.k8s.io
    break
  fi
  sleep 2

done
