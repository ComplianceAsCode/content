#!/bin/bash
# platform = multi_platform_ol,multi_platform_rhel,multi_platform_almalinux
# remediation = none

touch /etc/pam.d/{password,system}-auth-{mycustomconfig,ac}
