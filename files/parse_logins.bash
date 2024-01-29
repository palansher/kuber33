#!/bin/bash
parentdir=$(dirname "$0")
mkdir -p "$(dirname "$parentdir")"/env
resultFile=$(dirname "$parentdir")/env/hosts-auth.env
rm -f "$resultFile"
DONE=false
declare allIPs=""
until $DONE; do

    read -r line || DONE=true
    [ -z "$line" ] && continue # skip empty lines

    IFS=':' read -r -a line_array <<<"$line"    # read line to array by delimiter
    hostname=$(echo "${line_array[0]}" | xargs) #  | xargs - trim spaces
    declare -n ip_var="${hostname}_ip"          # https://stackoverflow.com/a/55331060/10884666 - Method 2. Using a “reference” variable
    declare -n user_var="${hostname}_user"
    declare -n pwd_var="${hostname}_pwd"
    declare -x ip_var
    declare -x user_var
    declare -x pwd_var

    ip="${line_array[2]}"
    ip_var=$(grep -oP '(?<=@).*?(?=\s)' <<<"$ip") # https://stackoverflow.com/a/21077908/10884666
    user_var=$(grep -oP '(?<=ssh\s).*?(?=@)' <<<"$ip")
    pwd_var=$(echo "${line_array[3]}" | xargs)

    echo deleting from known_hosts dirty IP: "$ip_var"
    ssh-keygen -f ~/.ssh/known_hosts -R "$ip_var" &>/dev/null

    # write vars to ENV file
    echo "${!user_var}=$user_var" >>"$resultFile"
    echo "${!pwd_var}=$pwd_var" >>"$resultFile"
    echo "${!ip_var}=$ip_var" >>"$resultFile"

    if [[ -n "$allIPs" ]]; then
        allIPs="$allIPs $ip_var"
    else
        allIPs="$ip_var"
    fi

done <rebrain_logins.txt

echo "all_ips=$(echo \""$allIPs"\")" >>"$resultFile"
echo "Finish env."

if [ -f "$(dirname "$parentdir")/templates/hosts.yml" ]; then
    echo templating hosts.yml
    cat "$(dirname "$parentdir")/templates/hosts.yml" | envsubst >"$(dirname "$parentdir")/hosts.yml"
else
    echo "No file $(dirname "$parentdir")/templates/hosts.yml, skip templating"
fi
