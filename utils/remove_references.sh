#!/bin/bash

while IFS= read -r -d '' file
do
	sed -i '/^\s*cis@rhel[7,8,9]:/d' "$file"
done < <(find linux_os -name 'rule.yml' -print0)
