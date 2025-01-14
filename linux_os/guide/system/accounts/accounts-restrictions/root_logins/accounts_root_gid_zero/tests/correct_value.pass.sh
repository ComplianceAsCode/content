#!/bin/bash
# remediation = none

{{% if 'ubuntu' in product %}}
awk -F: '$4 == 0 && $1 !~ /^(root|sync|shutdown|halt|operator)$/ {print $1}' /etc/passwd | xargs --no-run-if-empty -I '{}' userdel -f '{}'
{{% endif %}}
