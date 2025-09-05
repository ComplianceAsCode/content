#!/bin/bash

for f in /etc/sysctl.d/*.conf ; do
  matching_list=$(grep -P '^(?!#).*[\s]+fs.protected_regular.*$' $f | uniq )
  if ! test -z "$matching_list"; then
    while IFS= read -r entry; do
      sed -i "s/^${entry}$/d" $f
    done <<< "$matching_list"
  fi
done

/sbin/sysctl -q -n -w fs.protected_regular='2'
{{{ bash_replace_or_append('/etc/sysctl.conf', '^fs.protected_regular', '0' ) }}}
