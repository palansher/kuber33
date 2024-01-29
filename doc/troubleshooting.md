> Симигин Евгений @ES111M

В данном задании нам не принципиально почему у нас не заработал сбор таргетов с компонентов control plane кубера. В 90% случаев, они должны работать из коробки (кроме шедулера и контроллер-менеджера т.к. там метрики перевесили на 127.0.0.1 и они стали не доступны с других нод, только физически со своего хоста) Либо бывает такое, что в кластере сеть криво завелась ( kubectl get nodes что все доступны)

Там практически полная копипаста гайда https://github.com/kubernetes-sigs/prometheus-adapter/blob/master/docs/walkthrough.md , только обратите внимание, что у них апи v1beta2 у нас v1beta1


Пока механизм такой:

- Проверить появился ли в таргетах ваш прометеус_адаптер. По ощущениям - нет т.к. вот тут https://github.com/palansher/kube33/blob/main/kuber/autoscale-monitor.yml у вас имя порта не верное (должно быть такое же как в манифесте деплоймента)

- Проверяем kubectl get --raw /apis/custom.metrics.k8s.io/v1beta1 это покажет верно ли мы развернули kind: APIService`

90% проблем в данном задании, это то, что подмонитор не находит контейнер.`

---


Get metrics from endpoit:

`curl address:9100/metrics`



`k get po -n monitoring `
```
NAME                                                        READY   STATUS    RESTARTS   AGE
alertmanager-kube-prometheus-stack-alertmanager-0           2/2     Running   0          140m
kube-prometheus-stack-grafana-5cffd47ff6-rjjjp              3/3     Running   0          140m
kube-prometheus-stack-kube-state-metrics-5744bb9db6-htzhf   1/1     Running   0          140m
kube-prometheus-stack-operator-59594cd6bf-8nxzz             1/1     Running   0          140m
kube-prometheus-stack-prometheus-node-exporter-95hn2        1/1     Running   0          140m
kube-prometheus-stack-prometheus-node-exporter-mkssc        1/1     Running   0          140m
kube-prometheus-stack-prometheus-node-exporter-ws9tn        1/1     Running   0          140m
prometheus-adapter-7784f8d984-49s5q                         1/1     Running   0          132m
prometheus-kube-prometheus-stack-prometheus-0               2/2     Running   0          140m
```

`k get cm -n monitoring `
```
NAME                                                      DATA   AGE
kube-prometheus-stack-alertmanager-overview               1      144m
kube-prometheus-stack-apiserver                           1      144m
kube-prometheus-stack-cluster-total                       1      144m
kube-prometheus-stack-controller-manager                  1      144m
kube-prometheus-stack-etcd                                1      144m
kube-prometheus-stack-grafana                             1      144m
kube-prometheus-stack-grafana-config-dashboards           1      144m
kube-prometheus-stack-grafana-datasource                  1      144m
kube-prometheus-stack-grafana-overview                    1      144m
kube-prometheus-stack-k8s-coredns                         1      144m
kube-prometheus-stack-k8s-resources-cluster               1      144m
kube-prometheus-stack-k8s-resources-multicluster          1      144m
kube-prometheus-stack-k8s-resources-namespace             1      144m
kube-prometheus-stack-k8s-resources-node                  1      144m
kube-prometheus-stack-k8s-resources-pod                   1      144m
kube-prometheus-stack-k8s-resources-workload              1      144m
kube-prometheus-stack-k8s-resources-workloads-namespace   1      144m
kube-prometheus-stack-kubelet                             1      144m
kube-prometheus-stack-namespace-by-pod                    1      144m
kube-prometheus-stack-namespace-by-workload               1      144m
kube-prometheus-stack-node-cluster-rsrc-use               1      144m
kube-prometheus-stack-node-rsrc-use                       1      144m
kube-prometheus-stack-nodes                               1      144m
kube-prometheus-stack-nodes-darwin                        1      144m
kube-prometheus-stack-persistentvolumesusage              1      144m
kube-prometheus-stack-pod-total                           1      144m
kube-prometheus-stack-prometheus                          1      144m
kube-prometheus-stack-proxy                               1      144m
kube-prometheus-stack-scheduler                           1      144m
kube-prometheus-stack-workload-total                      1      144m
kube-root-ca.crt                                          1      152m
prometheus-adapter                                        1      135m
prometheus-kube-prometheus-stack-prometheus-rulefiles-0   35     144m
```

`k edit cm prometheus-adapter -n monitoring`

`k get ep -n monitoring`
