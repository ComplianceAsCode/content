#!/bin/bash
# remediation = none

# Delete all groups with gid 0 except root.
awk -F: '$3 == 0 && $1 != "root" { print $1 }' /etc/group | xargs -I '{}' groupdel -f '{}'
