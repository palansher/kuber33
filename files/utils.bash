#!/bin/bash

# Printing a fixed length title
title() {

    # usage: title [title string] [character] [length]
    title="$1"
    ch="="
    len=200

    if [ -z "$1" ]; then title=''; fi
    if [ -n "$2" ]; then ch="$2"; fi
    if [ -n "$3" ]; then len="$3"; fi

    len=$((len - 5))

    padding=$(printf '%*s' "$len" | tr ' ' "$ch")
    # title=$(echo $title | tr [:lower:] [:upper:])
    title=$(echo "$title" | awk '{print toupper($0)}')
    printf "\n \U2193 %s  %s \n\n" "$title" "${padding:${#title}}"
}

yaml2env() {

    # https://stackoverflow.com/a/965072/10884666

    sort=0

    if [[ "$*" == *"--sort"* ]]; then
        sort=1
        shift
    fi

    srcPaths=$*

    for srcPath in $srcPaths; do

        dstPath="${srcPath%.*}".yml
        sed 's/: /=/' >"$dstPath" <"$srcPath"
        sort -o "$dstPath" "$dstPath"

    done

}

env2yaml() {

    sort=0

    if [[ "$*" == *"--sort"* ]]; then
        sort=1
        shift
    fi

    srcPaths=$*

    for srcPath in $srcPaths; do

        dstPath="${srcPath%.*}".yml
        sed '/^#/b; s/=/: /' >"$dstPath" <"$srcPath"
        if [[ "${sort}" == "1" ]]; then
            sort -o "$dstPath" "$dstPath"
        fi

    done
}

env-convert() {

    echo "Converting env .."
    # usage: --direction=env2yaml|yaml2env [--sort] file1 file2 ..
    sort=0
    direction=""
    param=""

    # start params
    while [[ "$1" == *"--"* ]]; do

        # param="${1#*=}"

        if [[ "$*" != *"--direction"* ]]; then
            echo "Param --direction is required."
        fi

        param="$(echo $1 | cut -d'=' -f1)"
        if [[ "${1}" == *"="* ]]; then
            value="$(echo $1 | cut -d'=' -f2-)"
        fi

        # echo "param=$param, value=$value"

        case "${param}" in
        "--direction")

            case "${value}" in
            "env2yaml") direction="$value" ;;
            "yaml2env") direction="$value" ;;
            *)
                echo "--direction param requires 'env2yaml' or 'yaml2env'"
                exit
                ;;
            esac
            ;;

        "--sort")
            sort=1
            ;;
        esac

        shift

    done

    if [[ "$*" == *"--sort"* ]]; then
        sort=1
        shift
    fi

    # end params
    echo "direction=$direction, sort=$sort files=$*"

    # start files

    srcPaths=$*

    for srcPath in $srcPaths; do

        # comment lines (with first #) are skipped
        # env2yaml|yaml2env
        # https://stackoverflow.com/questions/3583111/regular-expression-find-spaces-tabs-space-but-not-newlines
        # https://stackoverflow.com/questions/4798149/ignore-comments-using-sed-but-keep-the-lines-untouched
        # https://superuser.com/questions/145926/sed-how-to-ignore-remarked-lines

        if [[ "$direction" == "env2yaml" ]]; then
            dstPath="${srcPath%.*}".yml
            sed '/^[ \t]*#/b; s/=/: /' >"$dstPath" <"$srcPath"
        elif [[ "$direction" == "yaml2env" ]]; then
            dstPath="${srcPath%.*}".env
            sed '/^[ \t]*#/b; s/: /=/' >"$dstPath" <"$srcPath"
        else
            echo "no proper --direction value"
            exit
        fi

        if [[ "${sort}" == "1" ]]; then
            sort -o "$dstPath" "$dstPath"
        fi

    done

}
