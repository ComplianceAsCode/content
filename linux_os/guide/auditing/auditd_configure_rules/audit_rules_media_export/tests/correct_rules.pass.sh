#!/bin/bash
# packages = audit

echo "-a always,exit -F arch=b32 -S mount -F auid>={{{ uid_min }}} -F auid!=unset -k mount" >> /etc/audit/rules.d/mount.rules
echo "-a always,exit -F arch=b64 -S mount -F auid>={{{ uid_min }}} -F auid!=unset -k mount" >> /etc/audit/rules.d/mount.rules
