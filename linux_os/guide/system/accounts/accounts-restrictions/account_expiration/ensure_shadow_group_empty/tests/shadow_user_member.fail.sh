#!/bin/bash
# platform = multi_platform_sle,multi_platform_ubuntu
# remediation = none

if ! grep -q "^shadow" /etc/group; then
    groupadd shadow
fi
useradd testuser_123
usermod -g shadow testuser_123
