#!/bin/bash
# platform = multi_platform_all

if ! grep -q "^shadow" /etc/group; then
    groupadd shadow
fi
sed -i '/^shadow:[^:]*:[^:]*:/ s/$/vnc/' /etc/group
