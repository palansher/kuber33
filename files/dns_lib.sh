#!/usr/bin/env bash

GetDNSValue() {
    # sets the variable to IP value from DNS
    echo "Getting DNS value .."
    local expectedDnsValue=$1
    echo -e "waiting for DNS record $dnsName not empty"
    while true; do
        dnsValue="$(dig +short "$dnsName" | tail -n1)"

        if [ -n "$dnsValue" ]; then
            echo
            break
        fi

        # echo -n "."
        sleep 2
    done
    echo

    if [ -n "$expectedDnsValue" ] && [ "$expectedDnsValue" != "$dnsValue" ]; then
        echo -e "waiting for DNS record $dnsName (now is: $dnsValue) becomes expected value ($expectedDnsValue)"
        while true; do
            dnsValue="$(dig +short "$dnsName" | tail -n1)"

            if [ "$expectedDnsValue" == "$dnsValue" ]; then
                echo
                break
            fi
            # echo -n "."
            sleep 2
        done
        echo
    fi

    echo -e "Got DNS value: $dnsName=$dnsValue\n"
    true

}

post_data() {
    cat <<EOF

{ "type": "A",
  "name": "$dnsName",
  "content": "$extIP",
  "proxied": false
}
EOF
}

# run SetDNSValue <DNS Name> <external IP address>
SetDNSValue() {

    local dnsName=$1
    local extIP=$2

    if [[ -z "$dnsName" ]] || ! [[ "$extIP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "Improper arguments. run SetDNSValue <DNS Name> <external IP address>"
        false
        return
    fi

    dnsValue=""
    # DNS recod ID=ef9f578bacee37accfaf8c184c12417c

    # get DNS ID

    dnsRecordCount=$(
        curl -s \
            -H "Authorization: Bearer r6EhzlIilHr0fUu9BRBVm7zV4GPkb6hcaVsvYBb5" \
            -H "Content-Type:application/json" \
            https://api.cloudflare.com/client/v4/zones/9152ec3c08b1a4faeaa95353a929fcc5/dns_records?name="$dnsName" |
            jq --raw-output '.result | length'
    )

    if [ "$dnsRecordCount" -gt 1 ]; then
        echo "There is more than one ($dnsRecordCount) DNS records for $dnsName. Error. Exit."
        false
        return
    fi

    if [ "$dnsRecordCount" -eq 0 ]; then
        # Create DNS record
        echo -e "\nNo DNS records for $dnsName. Creating one ..\n"
        dnsIDresponse=$(
            curl --no-progress-meter \
                -H "Authorization: Bearer r6EhzlIilHr0fUu9BRBVm7zV4GPkb6hcaVsvYBb5" \
                -H "Content-Type:application/json" \
                -X POST --data "$(post_data)" \
                "https://api.cloudflare.com/client/v4/zones/9152ec3c08b1a4faeaa95353a929fcc5/dns_records"
        )

        if [[ $(echo "$dnsIDresponse" | jq --raw-output '.success') != true ]]; then
            echo -e "\nError creating DNS record. Exit\n\n"
            false
            return
        fi

        dnsID=$(echo "$dnsIDresponse" | jq --raw-output '.result.id')
    else
        echo "There is one DNS record for $dnsName, getting its ID"
        dnsID=$(
            curl -s \
                -H "Authorization: Bearer r6EhzlIilHr0fUu9BRBVm7zV4GPkb6hcaVsvYBb5" \
                -H "Content-Type:application/json" \
                https://api.cloudflare.com/client/v4/zones/9152ec3c08b1a4faeaa95353a929fcc5/dns_records?name="$dnsName" |
                jq --raw-output '.result[].id'
        )

    fi

    echo -e "\ngot DNS ID: $dnsID\n"

    # GetDNSValue

    if [ "$dnsValue" != "$extIP" ]; then
        echo -e "\nService IP ($extIP) is different than DNS value ($dnsValue), updating DNS record $dnsName\n\n"

        success=$(
            curl -s \
                -X PUT \
                -H "Authorization: Bearer r6EhzlIilHr0fUu9BRBVm7zV4GPkb6hcaVsvYBb5" \
                -H "Content-Type:application/json" \
                --data "$(post_data)" \
                "https://api.cloudflare.com/client/v4/zones/9152ec3c08b1a4faeaa95353a929fcc5/dns_records/$dnsID" |
                jq --raw-output '.success'

        )

        [ "$success" != "true" ] && {
            echo -e "\nError updating record!\n\n"
            false
            return
        }

        # GetDNSValue "$extIP"

        echo -e "\nDNS record $dnsName updated to $extIP.\n\n"
    fi

    echo "$dnsName=$extIP" >>env/dns.env
    echo >&2 -e "\nDNS record $dnsName set to $extIP.\n\n"
}
