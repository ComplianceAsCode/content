#!/bin/bash
# packages = audit

echo "-a always,exit -F arch=b32 -S mount -F auid>={{{ uid_min }}} -F auid!=unset -k {{{ "privileged-mount" if product == "rhel10" else "export" }}}" >> /etc/audit/rules.d/export.rules
echo "-a always,exit -F arch=b64 -S mount -F auid>={{{ uid_min }}} -F auid!=unset -k {{{ "privileged-mount" if product == "rhel10" else "export" }}}" >> /etc/audit/rules.d/export.rules
