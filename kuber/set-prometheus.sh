#!/usr/bin/env bash

echo -e "\nSetting Prometheus .."

# source env/cluster-env.env

if [[ -z "$alertmanagerDnsName" || -z "$grafanaDnsName" || -z "$prometheusDnsName" ]]; then
    echo Variables does not set!
    exit 1
fi

echo "alertmanagerDnsName=$alertmanagerDnsName"
echo "grafanaDnsName=$grafanaDnsName"
echo "prometheusDnsName=$prometheusDnsName"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# helm template \
#     --namespace monitoring --create-namespace \
#     -f kuber/charts/values.prometheus.dev.yaml \
#     --set alertmanager.ingress.hosts[0]="$alertmanagerDnsName" \
#     --set alertmanager.ingress.tls[0].hosts[0]="$alertmanagerDnsName" \
#     --set grafana.ingress.hosts[0]="$grafanaDnsName" \
#     --set grafana.ingress.tls[0].hosts[0]="$grafanaDnsName" \
#     --set prometheus.ingress.hosts[0]="$prometheusDnsName" \
#     --set prometheus.ingress.tls[0].hosts[0]="$prometheusDnsName" \
#     prometheus-community/kube-prometheus-stack
# # kuber/charts/kube-prometheus-stack
# # --disable-openapi-validation \

helm upgrade kube-prometheus-stack \
    --install \
    --atomic \
    --wait \
    --namespace monitoring --create-namespace \
    -f kuber/charts/values.prometheus.dev.yaml \
    --set alertmanager.ingress.hosts[0]="$alertmanagerDnsName" \
    --set alertmanager.ingress.tls[0].hosts[0]="$alertmanagerDnsName" \
    --set grafana.ingress.hosts[0]="$grafanaDnsName" \
    --set grafana.ingress.tls[0].hosts[0]="$grafanaDnsName" \
    --set prometheus.ingress.hosts[0]="$prometheusDnsName" \
    --set prometheus.ingress.tls[0].hosts[0]="$prometheusDnsName" \
    prometheus-community/kube-prometheus-stack
#     # kuber/charts/kube-prometheus-stack
