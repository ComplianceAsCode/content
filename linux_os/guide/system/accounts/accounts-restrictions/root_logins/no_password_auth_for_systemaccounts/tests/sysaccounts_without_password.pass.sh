#!/bin/bash

# lock all system accounts (ID < {{{ uid_min }}}) from /etc/passwd
readarray -t systemaccounts < <(awk -F: \
  '($3 < {{{ uid_min }}} && $3 != root && $3 != halt && $3 != sync && $3 != shutdown \
  && $3 != nfsnobody) { print $1 }' /etc/passwd)

for systemaccounts in "${systemaccounts[@]}"; do
    usermod -L "$systemaccounts"
done
