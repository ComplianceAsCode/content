#!/bin/bash

useradd testUser

dirs=("/bin" "/sbin" "/usr/bin" "/usr/sbin" "/usr/libexec" "/usr/local/bin" "/usr/local/sbin")

for directory in "${dirs[@]}"; do

    file="${directory}/emptyfile"

    touch "$file"

    chown testUser "$file"
done
