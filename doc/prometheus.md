### Prometheus

Как настроить мониторинг и оповещения на Nginx ingress в Kubernetes: https://habr.com/ru/companies/vk/articles/729796/

Prometheus: exposing Prometheus/Grafana as Ingress for kube-prometheus-stack: https://fabianlee.org/2022/07/02/prometheus-exposing-prometheus-grafana-as-ingress-for-kube-prometheus-stack/

prometheus-operator
https://github.com/prometheus-operator/prometheus-operator

How to Integrate Prometheus and Grafana on Kubernetes Using Helm
https://semaphoreci.com/blog/prometheus-grafana-kubernetes-helm

PodMonitor vs ServiceMonitor what is the difference?
https://github.com/prometheus-operator/prometheus-operator/issues/3119


#### Создаем namespace для мониторинга

`kubectl create ns monitoring`

#### Скачиваем чарт локально

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

`helm search repo prometheus-stack`

```

NAME                                                    CHART VERSION   APP VERSION     DESCRIPTION
prometheus-community/kube-prometheus-stack              55.3.0          v0.70.0         kube-prometheus-stack collects Kubernetes manif...
prometheus-community/prometheus-stackdriver-exp...      4.4.1           v0.14.1         Stackdriver exporter for Prometheus
```

prometheus-community/kube-prometheus-stack - сам стек
prometheus-community/prometheus-stackdriver-exp - драйвер для google cloud

```
cd kuber
helm  pull prometheus-community/kube-prometheus-stack

# v55.3.0
tar zxf kube-prometheus-stack-**.tgz

rm kube-prometheus-stack-*.tgz

cd kube-prometheus-stack

# copy values.yaml and change values.
# Enable Ingress.
# ingress:
#   enabled: true
#   hosts:
#       - alertmanager.dev.kis.im

# grafana:
#   enabled: true
#   ingress: true
#   hosts:
#       - alertmanager.dev.kis.im


# cp values.yaml values.prometheus.dev.yaml

# deploy chart
helm upgrade kube-prometheus-stack --install --wait --namespace monitoring --create-namespace -f ~/kuberdeploy/charts/values.prometheus.dev.yaml ~/kuberdeploy/charts/kube-prometheus-stack

#debug
helm upgrade --debug --dry-run --set --set alertmanager.ingress.hosts[0]=alertmanager.domain.com kube-prometheus-stack --install --wait --namespace monitoring --create-namespace -f ~/kuberdeploy/charts/values.prometheus.dev.yaml ~/kuberdeploy/charts/kube-prometheus-stack

helm install --dry-run --set username=$USERNAME --debug [chart name] [chart path]

# request ingress by curl and see status

```

```
#https://github.com/jimangel/kubernetes-the-easy-way/blob/main/docs/setup-prometheus-operator.md

helm upgrade -i prometheus-app prometheus-community/kube-prometheus-stack \
--namespace monitoring \
--create-namespace \
--version "45.8.0" \
--set prometheus.ingress.enabled=true \
--set kubeProxy.enabled=false \
--set kubeEtcd.enabled=false \
--set prometheus.ingress.ingressClassName=nginx \
--set prometheus.ingress.hosts[0]="prometheus.${DOMAIN}" \
--set prometheus.ingress.annotations."cert-manager\.io/cluster-issuer"="digitalocean-issuer-prod" \
--set prometheus.ingress.tls[0].hosts[0]="prometheus.${DOMAIN}" \
--set prometheus.ingress.tls[0].secretName="prometheus-secret" \
--set grafana.adminPassword='H4Rd2Gu3ss!' \
--set grafana.ingress.enabled=true \
--set grafana.ingress.ingressClassName=nginx \
--set grafana.ingress.hosts[0]="grafana.${DOMAIN}" \
--set grafana.ingress.annotations."cert-manager\.io/cluster-issuer"="digitalocean-issuer-prod" \
--set grafana.ingress.tls[0].hosts[0]="grafana.${DOMAIN}" \
--set grafana.ingress.tls[0].secretName="grafana-secret" \
--set alertmanager.ingress.enabled=true \
--set alertmanager.ingress.ingressClassName=nginx \
--set alertmanager.alertmanagerSpec.externalUrl="https://alertmanager.${DOMAIN}" \
--set alertmanager.ingress.hosts[0]="alertmanager.${DOMAIN}" \
--set alertmanager.ingress.annotations."cert-manager\.io/cluster-issuer"="digitalocean-issuer-prod" \
--set alertmanager.ingress.tls[0].hosts[0]="alertmanager.${DOMAIN}" \
--set alertmanager.ingress.tls[0].secretName="alertmanager-secret" \
```

## Verify

```
kubectl -n monitoring get ing
# must be 3 items
```

kubectl get crd --namespace cert-manager | grep monitoring.coreos.com

Используем созданные prometheus ресурсы:
podmonitors.monitoring.coreos.com
servicemonitors.monitoring.coreos.com

`kubectl -n monitoring get pods`

```
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0          58m
kube-prometheus-stack-grafana-8d65b94df-q67sv               3/3     Running   0          58m
kube-prometheus-stack-kube-state-metrics-7ccc7bb9c9-tsmcz   1/1     Running   0          58m
kube-prometheus-stack-operator-98dcc7fd-sxthq               1/1     Running   0          58m
kube-prometheus-stack-prometheus-node-exporter-4t8s7        1/1     Running   0          58m
kube-prometheus-stack-prometheus-node-exporter-5l7zm        1/1     Running   0          58m
kube-prometheus-stack-prometheus-node-exporter-gqmgn        1/1     Running   0          58m
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   0          58m
```

#### Prometheus

`kubectl get prometheusrules -A` все правила прометеуса, видны в прометеусе

`kubectl get prometheusrules kube-prometheus-stack-kube-state-metrics -n monitoring -o yaml` отдельное правило

### описание кастомного ресурса prometheus

```
kubectl -n monitoring get prometheuses
# got kube-prometheus-stack-prometheus -o yaml

kubectl -n monitoring get prometheuses kube-prometheus-stack-prometheus -o yaml | grep podMonitorSelector -A10
# см. секцию podMonitorSelector
# got release: kube-prometheus-stack. можно подредактировать в helm values
```

```
podMonitorSelector:
    matchLabels:
      release: kube-prometheus-stack # должно совпадать с label в PodMonitor

```

кастомную метку kube-prometheus-stack можно указать в
`cat kuber/charts/values.prometheus.dev.yaml | grep podMonitorSelector -A10`

чтобы мы могли выбирать только те подмониторы, которые еам нужны.

### Grafana

default credentials:\
admin:prom-operator

`grep prom-operator kuber/charts/values.prometheus.dev.yaml
  adminPassword: prom-operator`
