#!/bin/bash

# Delete all users with uid 0 except root.
awk -F: '$3 == 0 && $1 != "root" { print $1 }' /etc/passwd | xargs -I '{}' userdel '{}'
