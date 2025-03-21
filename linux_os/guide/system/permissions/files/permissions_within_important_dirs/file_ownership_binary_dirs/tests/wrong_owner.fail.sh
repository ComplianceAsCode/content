#!/bin/bash

useradd testUser

dirs=("/bin" "/sbin" "/usr/bin" "/usr/sbin" "/usr/local/bin" "/usr/local/sbin")
{{% if 'ubuntu' not in product %}}
dirs+=("/usr/libexec")
{{% endif %}}

for directory in "${dirs[@]}"; do

    file="${directory}/emptyfile"

    touch "$file"

    chown testUser "$file"
done
