#!/bin/bash
# remediation = none

{{% if 'ubuntu' in product %}}
users_to_remove=$(awk -F: '$4 == 0 && $1 !~ /^(root|sync|shutdown|halt|operator)$/ {print $1}' /etc/passwd)
for user in $users_to_remove; do
    sudo userdel -rf "$user"
done
{{% endif %}}
