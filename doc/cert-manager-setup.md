### Cert Manager

https://cert-manager.io/v1.1-docs/installation/kubernetes/

Installing with Helm
https://cert-manager.io/docs/installation/helm/

Securing NGINX-ingress
https://cert-manager.io/docs/tutorials/acme/nginx-ingress/

Работа с cert-manager с помощью Helm 3
https://cloud.vk.com/docs/base/k8s/use-cases/case-certmanager-helm3

cert-manager-issuers
https://artifacthub.io/packages/helm/adfinis/cert-manager-issuers
---

`helm repo add jetstack https://charts.jetstack.io`

`helm repo update`

`helm repo list`

```
helm update --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.3 \
  --set installCRDs=true
```
  OR

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.3/cert-manager.crds.yaml

helm update --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.13.3 \
  # --set installCRDs=true
```



### Verify

```
kubectl get pods --namespace cert-manager


```

Check on the status of the issuer after you create it:


`kubectl describe issuer letsencrypt-staging`

`kubectl get certificate`

`kubectl describe certificate quickstart-example-tls`

`kubectl describe secret quickstart-example-tls`

You will also need to delete the existing secret, which cert-manager is watching and will cause it to reprocess the request with the updated issuer.

`kubectl delete secret quickstart-example-tls`

secret "quickstart-example-tls" deleted
This will start the process to get a new certificate, and using describe you can see the status. Once the production certificate has been updated, you should see the example KUARD running at your domain with a signed TLS certificate.

`kubectl describe challenge quickstart-example-tls-889745041-0`
