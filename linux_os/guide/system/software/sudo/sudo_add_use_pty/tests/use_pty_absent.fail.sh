#!/bin/bash
# platform = multi_platform_all

touch /etc/sudoers.d/empty
# Code taken from macro bash_sudo_remove_config()
for f in $( ls /etc/sudoers /etc/sudoers.d/* 2> /dev/null ) ; do
  matching_list=$(grep -P '^(?!#).*[\s]+use_pty.*$' $f | uniq )
  if ! test -z "$matching_list"; then
    while IFS= read -r entry; do
      # comment out "{{{ parameter }}}" matches to preserve user data
      sed -i "s/^${entry}$/# &/g" $f
    done <<< "$matching_list"

    /usr/sbin/visudo -cf $f &> /dev/null || echo "Fail to validate $f with visudo"
  fi
done
