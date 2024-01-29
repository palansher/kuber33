# Ingress-Nginx Controller

https://artifacthub.io/packages/helm/prometheus-community/prometheus

Securing NGINX-ingress
https://cert-manager.io/docs/tutorials/acme/nginx-ingress/

`helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx`

`helm repo update`

Installation Guide
https://kubernetes.github.io/ingress-nginx/deploy/


```
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```
A few pods should start in the ingress-nginx namespace:
`kubectl get pods --namespace=ingress-nginx`

After a while, they should all be running. 

**Certificate generation**

**Attention**\
The first time the ingress controller starts, two Jobs create the SSL Certificate used by the admission webhook.

This can cause an initial delay of up to two minutes until it is possible to create and validate Ingress definitions.

The following command will wait for the ingress controller pod to be up, running, and ready:

```
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s```
```



If you want a full list of values that you can set, while installing with Helm, then run:

`helm show values ingress-nginx --repo https://kubernetes.github.io/ingress-nginx`

## Firewall configuration¶

To check which ports are used by your installation of ingress-nginx, look at the output of `kubectl -n ingress-nginx get pod -o yaml`.\
In general, you need: - Port 8443 open between all hosts on which the kubernetes nodes are running.\
This is used for the ingress-nginx admission controller. - Port 80 (for HTTP) and/or 443 (for HTTPS) open to the public on the kubernetes nodes to which the DNS of your apps are pointing.


## Checking ingress controller version
Run /nginx-ingress-controller --version within the pod, for instance with kubectl exec:

```
POD_NAMESPACE=ingress-nginx
POD_NAME=$(kubectl get pods -n $POD_NAMESPACE -l app.kubernetes.io/name=ingress-nginx --field-selector=status.phase=Running -o name)
kubectl exec $POD_NAME -n $POD_NAMESPACE -- /nginx-ingress-controller --version
```

## Scope
By default, the controller watches Ingress objects from all namespaces. If you want to change this behavior, use the flag `--watch-namespace` or check the Helm chart value controller.scope to limit the controller to a single namespace.

See also [“How to easily install multiple instances of the Ingress NGINX controller in the same cluster”](https://kubernetes.github.io/ingress-nginx/#how-to-easily-install-multiple-instances-of-the-ingress-nginx-controller-in-the-same-cluster) for more details.


## Verify

kubectl -n ingress-nginx get svc ingress-nginx-controller
kubectl -n ingress-nginx get pods
