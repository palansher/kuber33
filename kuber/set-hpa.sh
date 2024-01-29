#!/usr/bin/env bash
echo -e "\nCreating HPA .."

kubectl apply -f kuber/hpa-autoscale.yml || exit 1
