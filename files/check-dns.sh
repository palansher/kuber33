#!/usr/bin/env bash

# source /env/dns.env
echo
while IFS="" read -r line || [ -n "$line" ]; do
  # dig +short
  name=$(echo "$line" | awk -F '=' '{print $1}')
  ip=$(echo "$line" | awk -F '=' '{print $2}')
  if [[ $ip != $(dig +short "$name" | tail -n1) ]]; then
    echo "Warning: dns record $name is not updated!"
    exit 1
  else
    echo "$name OK"
  fi

done <env/dns.env

echo -e "\nDns records are updated!"
# dnsValue="$(dig +short "$dnsName" | tail -n1)"
