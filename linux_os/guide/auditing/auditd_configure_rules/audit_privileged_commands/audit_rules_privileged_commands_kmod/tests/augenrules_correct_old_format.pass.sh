#!/bin/bash
# platform = multi_platform_ubuntu
# packages = audit

echo "-w /bin/kmod -p x -k privileged" >> /etc/audit/rules.d/privileged.rules
