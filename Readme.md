# KUB 33: Custom Metrics для HPA

https://lk.rebrainme.com/kubernetesv2/task/699

run `kubeconfig-set-rebrain` on dev - для управления кубером с машины разработчика

## Задание:

<!-- Domain name: ingress.de495.task32.rbr-kubernetes.com -->

### 1 Установите metrics server в kubernetes кластер.

`kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml`

> Иногда бывает так, что metrics-server не взлетает. Такое возможно из-за того, что используются неподписанные сертификаты. В этом случае нужно скачать локально файл components.yaml и выставить дополнительный параметр --kubelet-insecure-tls в args, например вот так:

```
# открываем на редактирование и вставляем нужный параметр в args, если используются самоподписанные сертификаты:
$ vi components.yaml
...
args:
  --kubelet-insecure-tls
  --kubelet-preferred-address-types=InternalIP
  --cert-dir=/tmp
  --secure-port=4443
...
```

Проверка autoscaling после обновления kubernetes- должно быть v2

`kubectl api-resources | grep autoscaling`

> После установки вы можете проверить что kubernetes api расширился и у него появилась группа metrics.k8s.io
> `kubectl api-resources | grep metrics.k8s.io`

### 2 Установите prometheus stack в namespace monitoring.

basic auth
admin:adminpassword

### 3  Создайте дейплоймент autoscale-dp в namespace default, который внутри будет запускать 
контейнер autoscale (image: luxas/autoscale-demo:v0.1.2). Шаблоны можно найти в документации https://github.com/kubernetes-sigs/prometheus-adapter/blob/master/docs/walkthrough.md

### 4 Создайте podmonitor autoscale-monitor в namespace default, который будет собирать метрики с подов autoscale.

### 5 Установите prometheus-adapter в namespace monitoring.

### 6 Создайте HorizontalPodAutoScaler hpa-autoscale в namespace default, который будет увеличивать количество реплик данного деплоймента при достижении http_requests более 1ого запроса в секунду.