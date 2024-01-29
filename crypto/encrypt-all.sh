#!/usr/bin/env bash

for filename in secrets/*; do
  # [ -e "$filename" ] || continue
  echo "$filename"
  target_path="secrets-encripted/$(basename "${filename}")"
  echo "$target_path"
  sops -e --pgp 5B69DCE680552A6F661E143616A4814D910F43C0 "$filename" > "$target_path"
done


