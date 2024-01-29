# Вопросы

## 1

Здравствуйте!

Пока автопроверка показывает:

```
Checking prometheus adapter: OK
Checking deployment autoscale-dp: FAILED
Checking monitor autoscale-monitor: OK
Checking horizontal pod autoscaler: FAILED
```

Но метрика http_requests уже должна прилетать в прометеус, но этого не происходит.


Я не понимаю вообще что тут происходит, не понимаю роль адаптера.
И дебажу по наитию.

Начинаем:


```
kubectl -n  monitoring get deploy prometheus-adapter
NAME                 READY   UP-TO-DATE   AVAILABLE   AGE
prometheus-adapter   1/1     1            1           91m

kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests | jq
Error from server (NotFound): the server could not find the metric http_requests for pods
```

```
k get pods
NAME                          READY   STATUS    RESTARTS   AGE
sample-app-7fbb577cd5-pdqnh   1/1     Running   0          113m
```


```
k get pods -n monitoring
NAME                                                        READY   STATUS    RESTARTS   AGE
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0          109m
kube-prometheus-stack-grafana-5cffd47ff6-rjjjp              3/3     Running   0          109m
kube-prometheus-stack-kube-state-metrics-5744bb9db6-htzhf   1/1     Running   0          109m
kube-prometheus-stack-operator-59594cd6bf-8nxzz             1/1     Running   0          109m
kube-prometheus-stack-prometheus-node-exporter-95hn2        1/1     Running   0          109m
kube-prometheus-stack-prometheus-node-exporter-mkssc        1/1     Running   0          109m
kube-prometheus-stack-prometheus-node-exporter-ws9tn        1/1     Running   0          109m
prometheus-adapter-7784f8d984-49s5q                         1/1     Running   0          100m
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   0          109m
```

Тут есть ошибки:

```
k -n monitoring  logs prometheus-adapter-7784f8d984-49s5q

...

E0124 21:42:45.057395       1 wrap.go:54] timeout or abort while handling: method=GET URI="/apis/custom.metrics.k8s.io/v1beta1" audit-ID="2635435b-15d3-4f6a-bd9a-31e2465dc537"
E0124 21:42:45.057604       1 writers.go:122] apiserver was unable to write a JSON response: http2: stream closed
E0124 21:42:45.058584       1 writers.go:135] apiserver was unable to write a fallback JSON response: http2: stream closed
E0124 21:42:45.059761       1 timeout.go:142] post-timeout activity - time-elapsed: 2.490089ms, GET "/apis/custom.metrics.k8s.io/v1beta1" result: <nil>
E0124 21:42:45.063118       1 status.go:71] apiserver received an error that is not an metav1.Status: &errors.errorString{s:"http2: stream closed"}: http2: stream closed
E0124 21:42:45.065649       1 writers.go:135] apiserver was unable to write a fallback JSON response: http2: stream closed
E0124 21:42:45.067029       1 timeout.go:142] post-timeout activity - time-elapsed: 9.582436ms, GET "/apis/custom.metrics.k8s.io/v1beta1" result: <nil>
I0124 21:42:49.760800       1 httplog.go:132] "HTTP" verb="GET" URI="/healthz" latency="293.046µs" userAgent="kube-probe/1.28" audit-ID="7366014e-b267-4c1b-a359-4669cf6b192c" srcIP="178.62.231.99:44102" resp=200
I0124 21:42:49.761292       1 httplog.go:132] "HTTP" verb="GET" URI="/healthz" latency="225.289µs" userAgent="kube-probe/1.28" audit-ID="79a57806-95c8-4047-af75-91e2fb3ef4e3" srcIP="178.62.231.99:44104" resp=200
I0124 21:42:59.759442       1 httplog.go:132] "HTTP" verb="GET" URI="/healthz" latency="229.789µs" userAgent="kube-probe/1.28" audit-ID="9796bbf7-bf27-467b-a0d9-4f7b550ea871" srcIP="178.62.231.99:51236" resp=200
I0124 21:42:59.764386       1 httplog.go:132] "HTTP" verb="GET" URI="/healthz" latency="380.107µs" userAgent="kube-probe/1.28" audit-ID="8293b1ea-3508-4a13-99b4-5f6da74c24ec" srcIP="178.62.231.99:51234" resp=200
I0124 21:43:09.760754       1 httplog.go:132] "HTTP" verb="GET" URI="/healthz" latency="257.158µs" userAgent="kube-probe/1.28" audit-ID="b2a1ebd6-119c-4767-9723-de1a2ea81eca" srcIP="178.62.231.99:45944" resp=200
I0124 21:43:09.763315       1 httplog.go:132] "HTTP" verb="GET" URI="/healthz" latency="394.209µs" userAgent="kube-probe/1.28" audit-ID="8e9fe5eb-8ab6-466d-8f69-62ec32c7ba05" srcIP="178.62.231.99:45954" resp=200

```

Погуглил: советуют выключить правила по умолчанию:

```
rules:
  default: false
```

да, ошибки исчезают, но тогда вообще никаких правил нет. Оставил включенными.

Посмотрел веб морду прометеуса. Насторожила краснота (отфильтровано по unhealthy):

https://i.imgur.com/reRvKk9.png

В общем, прошу подсказать с чего начинать дебажить.
Что происходит - не понимаю вообще. Статей по теме в таске нет.
Даже не понимаю, как эта кастомная метрика должна откуда/куда попасть.
Посоветуйте, плз, что почитать.

## 2

В задании пункт 6 указана метрика для мониторинга с именем http_requests. 

И вроде все в порядке:

```
 kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests | jq .
{
  "kind": "MetricValueList",
  "apiVersion": "custom.metrics.k8s.io/v1beta1",
  "metadata": {},
  "items": [
    {
      "describedObject": {
        "kind": "Pod",
        "namespace": "default",
        "name": "autoscale-dp-56dd85457b-86vd8",
        "apiVersion": "/v1"
      },
      "metricName": "http_requests",
      "timestamp": "2024-01-29T18:21:27Z",
      "value": "33m",
      "selector": null
    }
  ]
}
```

Однако, само приложение отдает единственную метрику с другми именем: http_requests_total

```
curl 178.128.137.4/metrics
# HELP http_requests_total The amount of requests served by the server in total
# TYPE http_requests_total counter
http_requests_total 22
```

Это та же метрика с другим именем ?