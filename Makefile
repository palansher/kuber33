.PHONY: list
list:
	@echo "Targets:"
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
	@echo

.ONESHELL:
SHELL := /bin/bash

# set kubeconfig for rebrain
include env/cluster-env.env
export KUBECONFIG=/home/vladp/.kube/config_rebrain
export

init: delete-dns-env set-hostsenv set-common set-helm set-metrics-server \
	set-ingress-controller set-demo-app set-hpa set-prometheus set-prometheus-adapter check-dns

set-hostsenv: parse-logins convert-env

set-common:
	ansible-playbook ansible/common.yml -i hosts.yml -e '@env/hosts-auth.yml'

set-metrics-server:
	bash kuber/set-metrics-server.sh

delete-dns-env:
	@rm env/dns.env # удаляем старые значение dns

check-dns:
	@bash files/check-dns.sh
	
set-ingress-controller:
	@ansible-playbook ansible/basic-auth.yml

	bash kuber/set-cert-manager.sh \
	&& echo -e "\nSetting letsencrypt-issuer .." && kubectl apply -f kuber/letsencrypt-issuer.yml \
	&& kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f - \
	&& echo -e "\nCreating basic-auth secret .." && kubectl -n monitoring create secret generic basic-auth --from-file=auth/auth --dry-run=client -o yaml | kubectl apply -f - \
	&& bash kuber/set-nginx-ingress-controller.sh \
	&& bash files/set-dns.sh ingress-nginx-controller ingress-nginx ${alertmanagerDnsName} ${grafanaDnsName} ${prometheusDnsName} > /dev/null
	
set-hpa:
	bash kuber/set-hpa.sh

set-prometheus:
	@bash kuber/set-prometheus.sh

set-demo-app:	
	@bash kuber/set-demo-app.sh
	
	
set-prometheus-adapter:
	@bash kuber/set-prometheus-adapter.sh


set-helm:
	@ansible-playbook ansible/helm.yml -i hosts.yml -e '@env/hosts-auth.yml' -e '@env/cluster-env.yml'
		
parse-logins:
	@bash files/parse_logins.bash

convert-env:	
	. files/utils.bash; env-convert --direction=env2yaml env/hosts-auth.env
	. files/utils.bash; env-convert --direction=env2yaml env/cluster-env.env


encrypt-all:
	bash crypto/encrypt-all.sh

load-app:
	@# Generate http requests to demo app
	for i in {1..1000}; do curl http://${appDnsName}; done
	curl http://${appDnsName}/metrics
	kubectl get pods
