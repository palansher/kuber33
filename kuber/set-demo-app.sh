#!/usr/bin/env bash
echo -e "\nCreating demo app .."
# echo delete old deploy
# kubectl delete deploy autoscale-dp || true
# echo create deploy
kubectl apply -f kuber/autoscale-dp.yml \
&& kubectl apply -f kuber/autoscale-svc.yml \
&& bash files/set-dns.sh autoscale-svc default "${appDnsName}" >/dev/null \
&& kubectl apply -f kuber/autoscale-monitor.yml || exit 1
