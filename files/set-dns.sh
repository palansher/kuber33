#!/usr/bin/env bash

# set -o allexport

echo -e "\nSeting DNS records"

# source dns_lib.sh and $dnsName, if not source before
source files/dns_lib.sh
source env/cluster-env.env

if [ "$#" -lt 3 ]; then
    echo "Illegal number of parameters."
    echo "Usage: $0 service_name service_namespace dns_name1 dns_name2 dns_nameX "
    exit 1
fi

serviceName=$1
service_namespace=$2
shift 2
dnsNamesArray=("$@")

if [[ ${#dnsNamesArray[@]} -eq 0 ]]; then

    echo "Error: no domain names provided!"
    exit 1
fi

echo -e "\nwaiting for assigning external IP"
while true; do
    extIP=$(kubectl get services -n "$service_namespace" "$serviceName" -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ "$extIP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo -e "\n\ngot external ingress IP: $extIP"
        break

    else
        echo -n "."
        sleep 2
    fi
done
echo

# dnsNamesArray=("$alertmanagerDnsName" "$grafanaDnsName" "$prometheusDnsName")

for dnsName in "${dnsNamesArray[@]}"; do
    echo "dnsName=$dnsName"
    if [[ $(type -t SetDNSValue) != function || -z $dnsName ]]; then
        echo "There was an error with dnsName $dnsName ! Exit"
        exit 1
    fi

    SetDNSValue "$dnsName" "$extIP" &
done

# wait $(jobs -rp)
