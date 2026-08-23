#!/bin/bash
# platform = multi_platform_all

if ! grep -q "^shadow" /etc/group; then
    groupadd shadow
fi
sed -ri 's/(^shadow:[^:]*:[^:]*:)([^:]+$)/\1/' /etc/group
