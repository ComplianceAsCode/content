#!/bin/bash
# platform = multi_platform_sle,multi_platform_ubuntu

if ! grep -q "^shadow" /etc/group; then
    groupadd shadow
fi
sed -ri 's/(^shadow:[^:]*:[^:]*:)([^:]+$)/\1/' /etc/group
